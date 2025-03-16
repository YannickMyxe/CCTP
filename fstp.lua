--[[
    File-Server Transfer Protocol
    Send and receive files over rednet
]]

peripheral.find("modem", rednet.open)

if not rednet.isOpen() then
    error("Rednet is not open")
end


local fileTransfer = {}

-- Sends a file to a specified receiver over Rednet.
-- @param file The path to the file to be sent.
-- @param reciever The ID of the receiver to send the file to.
-- @throws Error if the file cannot be found or opened.
-- @usage
-- fileTransfer.SendFile("example.txt", 5)
function fileTransfer.SendFile(file, reciever)
    local f = fs.open(file, "r") or error("File `" .. file .. "` not found")
    local fData = f.readAll()
    f.close()
    local data = { name = file, data = fData }
    --[[
    for key, value in pairs(data) do
        print(key, value)
    end
    ]]
    rednet.send(reciever, data)
end

function fileTransfer.RecieveFile(path)
    local id, file_data = rednet.receive()
    print("File received from: #" .. id)
    print("File name: " .. file_data.name)

    local filename = fileTransfer.extractFileName(file_data.name)
    local dir = path .. filename
    
    local file = fs.open(dir, "w")
    file.write(file_data.data)
    file.close()
    print("File saved at: " .. dir)

    return dir, id
end

function fileTransfer.CreateDir(dir)
    fs.makeDir(dir)
end

function fileTransfer.CreateFile(fileName, content)
    local file, e = fs.open(fileName, "w")

    if e then
        error("Could not create file[".. fileName .. "] reason: " .. e)
    end

    if content then 
        file.write(content)
    end
    file.close()
end

function fileTransfer.ListDir(dir)
    return fs.list(dir)
end

-- Extracts the filename from a given path.
-- @param path The full path to extract the filename from.
-- @return The extracted filename.
function fileTransfer.extractFileName(path)
    return path:match("([^/\\]+)$")
end

function fileTransfer.MoveFileOverwrite(oldPath, newPath)
    if fs.exists(newPath) then
        fs.delete(newPath)
    end

    fs.move(oldPath, newPath)
end

return fileTransfer