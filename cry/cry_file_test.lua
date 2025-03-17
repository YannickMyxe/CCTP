local rsa = require("cry")

local function read_file(filename)
    local file = io.open(filename, "rb")
    if not file then return nil end
    local content = file:read "*all"
    file:close()
    return content
end

local function write_file(filename, content)
    local file = io.open(filename, "wb")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

local function test_encryption(filename)
    local original_content = read_file(filename)
    if not original_content then
        print("Error reading file: " .. filename)
        return false
    end

    local keyPair = rsa.key()
    local encrypted_content = rsa.encrypt(original_content, keyPair)

    -- Save encrypted content to a file
    local encrypted_filename = filename .. ".enc"
    if not write_file(encrypted_filename, table.concat(encrypted_content, ",")) then
        print("Error writing encrypted file: " .. encrypted_filename)
        return false
    end

    -- Read the encrypted content back from the file
    local encrypted_content_read = read_file(encrypted_filename)
    if not encrypted_content_read then
        print("Error reading encrypted file: " .. encrypted_filename)
        return false
    end

    -- Convert the string back to a table
    local encrypted_content_table = {}
    for value in string.gmatch(encrypted_content_read, "([^,]+)") do
        table.insert(encrypted_content_table, tonumber(value))
    end

    local decrypted_content = rsa.decrypt(encrypted_content_table, keyPair)

     -- Save decrypted content to a file
    local decrypted_filename = filename .. ".dec"
    if not write_file(decrypted_filename, decrypted_content) then
        print("Error writing decrypted file: " .. decrypted_filename)
        return false
    end

    if original_content == decrypted_content then
        print("Encryption and decryption successful for: " .. filename)
        return true
    else
        print("Encryption and decryption failed for: " .. filename)
        return false
    end
end

-- Create a test file
local test_filename = "mmp.lua"

-- Run the test
test_encryption(test_filename)


