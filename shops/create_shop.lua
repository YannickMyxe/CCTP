local lib = require("lib")

if not lib then
    error("Failed to load lib")
    return
end

local function printHelp()
    print("Usage: create_shop <name> <x> <y> <z>")
    print("Creates a new shop with the given name and coordinates.")
end

local args = arg
if not args or #args == 0 then
    printError("No arguments provided!")
    return nil
end

local name = args[1]
if not name or #name == 0 then
    printError("No name provided!")
    return nil
end

if name == "help" or name == "-h" or name == "--help" then
    printHelp()
    return nil -- Stops if help is requested
end

local coordinate = lib.coord.new(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
for _, x in ipairs(coordinate) do
    print(x)
end
local error = lib.coord.checkType(coordinate)
if not coordinate or error then
    printError("Invalid coordinates! " .. error)
    return nil
end

local shop = lib.shop.new(name, coordinate)
local error = lib.shop.checkType(shop)
if error then
    printError("Invalid shop! " .. error)
    return nil
end
lib.shop.print(shop)