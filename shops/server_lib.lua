package.path = '../?.lua;' .. package.path

local lib = require("shops.shop_lib")
local confi = require("confi.confi")
local mmp = require("mmp.mmp")

local server = {}
local config = {}
server.config = config
config.path = "shops"
config.ports = {
    client = 1141,
    server = 1142,
}

server.manager = lib.manager.new()

if not server.manager then
    printError("Failed to create manager!")
    return nil
end

function config.load()
    local exitst = confi.exists(server.config.path)
    if not exitst then
        confi.addFile(server.config.path)
    end
    local config = confi.loadFile(server.config.path)
    if not config then
        printError("Failed to load config file: " .. server.config.path)
        return nil
    end
    print("Config file loaded: " .. confi.getPath(server.config.path))
    if not config or #config == 0 then
        printError("Config '" .. server.config.path .. "' is NIL or EMPTY.")
        return nil
    end
    return config
end

function config.openPorts()
    mmp.changePorts(config.ports.client, config.ports.server)
end

function config.changeProtocol()
    mmp.changeProtocol("shop")
end

function server.handleMessageData(messageData) 
    local protocol = messageData.protocol
    if protocol ~= mmp.protocol then
        printError("Invalid protocol: " .. protocol)
        return nil
    end
    local data = messageData.data
    if not data then
        printError("No data in message!")
        return nil
    end
    
    return server.matchMessage(messageData.message, data)
end

function server.matchMessage(message, data)
    if not message then
        printError("MATCH: No message provided!")
        return nil
    end
    if message == "" then
        printError("Empty message!")
        return nil
    end
    if not data then
        printError("No data provided!")
        return nil
    end

    if message == "create" then
        print("Creating new shop...")
        if not data.name then
            printError("No name provided!")
            return nil
        end
        if not data.coord then
            printError("No coord provided!")
            return nil
        end
        local shop = lib.shop.new(data.name, data.coord)
        lib.manager.addShop(server.manager, shop)
        return "Created shop " .. shop.name .. " successfully!"
    end

    printError("Invalid message: " .. message)
    return nil
end

function server.run()
    local config = server.config.load()

    local data = mmp.server.recieve()
    local result = server.handleMessageData(data)
    if not result then
        printError("Failed to handle message data!")
        return nil
    end
    print("Result: " .. result)
end

server.config.openPorts()
server.config.changeProtocol()

return server