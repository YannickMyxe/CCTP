local rsa = require("cry")

local amount_of_tests = 100
local random_string_length = 200

-- Helper function to generate a random string
local function generateRandomString(length)
    local str = ""
    for i = 1, length do
        local charCode = math.random(32, 126)  -- Printable ASCII characters
        str = str .. string.char(charCode)
    end
    return str
end

-- Generate a key pair
local keyPair = rsa.key()

-- Test with 100 random strings
for i = 1, amount_of_tests do
    local message = generateRandomString(math.random(5, random_string_length))  -- Random length between 5 and 20
    local ciphertext = rsa.encrypt(message, keyPair)
    local decryptedMessage = rsa.decrypt(ciphertext, keyPair)

    if decryptedMessage == message then
        print("Test passed for iteration " .. i)
    else
        print("Test failed for iteration " .. i)
        print("Original message:", message)
        print("Decrypted message:", decryptedMessage)
        break  -- Stop on the first failure
    end
end

print("All tests completed.")
