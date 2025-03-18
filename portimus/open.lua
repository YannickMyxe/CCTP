local portimus = require "prime" or error("Cannot find portimus lib, prime.lua")

local ports = {table.unpack(arg, 2, -1)}

if not ports then
    write("Port to open> ")
    local r = read()
    for str in string.gmatch(r, "%S+") do
        table.insert(ports, str)
    end
end

print("Type: ", type(ports))

for _, port in pairs(ports) do
    port = tonumber(port)
    if not port then 
        printError("Invalid port provided, port needs to be a number.") 
        return nil
    end
    if port < 0 then
        printError("Invalid port number, port needs to be bigger than 0.") 
        return nil
    end
    print("Opening port " .. port)
    portimus.open(port)
end





local id = multishell.launch(_ENV, "/programs/cctp/portimus/show.lua")
multishell.setTitle(id, "Portimus-"..id)
multishell.setFocus(id)