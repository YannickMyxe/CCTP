package.path = '../?.lua;' .. package.path

local lib = require("lib")
local confi = require("confi.confi")

local server = {}
local config = {}
server.config = config
config.path = "shops"
server.manager = lib.manager.new()

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

function server.run()
    local config = server.config.load()
    
end

local function run()
    local args = arg
    if not args or #args == 0 then
        printError("No arguments provided!")
        return server
    end
    if args[1] == "run" then
        print("Running server...")
        server.run()
    else 
        printError("Invalid command! " .. args[1])
        return nil
    end

end

run()