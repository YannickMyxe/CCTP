--[[
    File-Server Transfer Protocol
    Send and receive files over Modem Message Protocol 
]]

package.path = '../?.lua;' .. package.path
local mmp = require "mmp" or error("Could not load mmp library")

local fileTransfer = {}

mmp.changePorts(844, 845)
mmp.changeProtocol("fstp")

function fileTransfer.SendFile(file, reciever)
    local f = fs.open(file, "r") or error("File `" .. file .. "` not found")
    local fData = f.readAll()
    f.close()
    local data = { recieverId = reciever, name = file, data = fData }
    --[[
    for key, value in pairs(data) do
        print(key, value)
    end
    ]]
    -- (Channel, replyChannel, data)
    mmp.client.send(data)
end

function fileTransfer.RecieveFile(newPath)
    local data = mmp.server.recieve()

    print("File received from: #" .. data.recieverId)
    print("File name: " .. data.name)

    local filename = fileTransfer.extractFileName(data.name)
    local dir = newPath .. filename
    
    local file = fs.open(dir, "w")
    file.write(data.data)
    file.close()
    print("File saved at: " .. dir)

    return dir, data.recieverId
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