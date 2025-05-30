package.path = '../?.lua;' .. package.path

local server = require("shops.server_lib")
local mmp = require("mmp.mmp")

if not server then
    error("Failed to load server")
    return nil
end

local client = {}

function client.send(data)
    if not data then
        printError("No data provided!")
        return nil
    end
    if not data.message then
        printError("No message provided!")
        return nil
    end

    if not data.data then
        printError("No data provided!")
        return nil
    end

    mmp.client.send(data.data, data.message)
end

function client.receive()
    local data = mmp.client.receive()
    --[[
    for k, v in pairs(data) do
        if type(v) == "table" then
            v = "table"
        end
        print(k .. ": " .. tostring(v))
    end
    --]]
    return data
end

return client