local portimus = require "prime" or error("Cannot find portimus lib, prime.lua")
local ports = {table.unpack(arg, 2, -1)}

if not ports then
    write("Port to close> ")
    local r = read()
    for str in string.gmatch(r, "%S+") do
        table.insert(ports, str)
    end
end

for _, port in pairs(ports) do
    local p = tonumber(port)
    if not p then 
        printError("Invalid port provided, port needs to be a number.") 
        return nil
    end
    if p < 0 then
        printError("Invalid port number, port needs to be bigger than 0.") 
        return nil
    end
    print("Closing port " .. p)
    portimus.close(p)
end
