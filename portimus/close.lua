local portimus = require "prime" or error("Cannot find portimus lib, prime.lua")

local p_arg, port = arg[1], nil

if not p_arg then
    write("Port to close> ")
    local r = read()
    if not r then
       printError("Invalid port provided, port cannot be nil.") 
       return nil
    end
end

port = tonumber(p_arg)
if not port then 
    printError("Invalid port provided, port needs to be a number.") 
    return nil
end
if port < 0 then
    printError("Invalid port number, port needs to be bigger than 0.") 
    return nil
end

print("Closing port " .. port)

portimus.close(port)

local id = multishell.launch(_ENV, "/programs/cctp/portimus/show.lua")
multishell.setTitle(id, "Portimus-"..id)
multishell.setFocus(id)