local client = require("client_lib")
local shop_lib = require("shop_lib")
if not client then
    error("Failed to load client")
    return
end
if not shop_lib then
    error("Failed to load shop library")
    return
end


local function help_create() 
    print("Usage: create <name> <x> <y> <z>")
    print("Creates a new shop with the given name and coordinates.")
end

local function help_find() 
    print("Usage: find <name>")
    print("Finds a shop with the given name.")
end


local function printHelp()
    help_create()
    help_find()
end

local args = arg
if not args or #args == 0 then
    printError("No arguments provided!")
    printHelp()
    return nil
end

if args[1] == "help" then
    printHelp()
    return nil
elseif args[1] == "create" then
    if #args < 5 then
        printError("Not enough arguments!")
        help_create()
        return nil
    end

    local name = args[2]
    local x = tonumber(args[3])
    local y = tonumber(args[4])
    local z = tonumber(args[5])

    if not name or not x or not y or not z then
        printError("Invalid arguments!")
        help_create()
        return nil
    end

    local shop = shop_lib.shop.new(name, {x = x, y = y, z = z})
    client.send({ message = "create", data = shop })

elseif args[1] == "find" then
    if #args < 2 then
        printError("Not enough arguments!")
        help_find()
        return nil
    end

    local name = args[2]
    if not name then
        printError("Invalid arguments!")
        help_find()
        return nil
    end

    client.send({ message = "find", data = { name = name } })
    local shop = client.receive().data
    shop_lib.shop.print(shop)
else
    printError("Unknown command: " .. args[1])
    printHelp()
end
