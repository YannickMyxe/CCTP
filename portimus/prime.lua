local modem = peripheral.find("modem") or error("No modem attached", 0)
if not modem then
    error("No modem attached", 0)
end

local portimus = {}
portimus.dir = "/portimus/"
portimus.openFile = portimus.dir .. "ports.pt"

-- Returns the port(as a number) if its valid else returns nil
function portimus.isValidPort(port)
    local port = tonumber(port)
    if not port then 
        printError("Invalid port provided, port needs to be a number.") 
        return nil
    end
    if port < 0 then
        printError("Invalid port number, port needs to be bigger than 0.") 
        return nil
    end
    return port
end

-- Opens the requested port and returns if the port was opened 
function portimus.open(port)
    port = portimus.isValidPort(port)
    if portimus.isOpen(port) then
        --printError("Port already open")
        return false
    end
    modem.open(port)
    local file = fs.open(portimus.openFile, "a")
    file.writeLine(port)
    file.close()
    return true
end

-- Returns all open ports in a table
function portimus.getOpenPorts()
    local file = fs.open(portimus.openFile, "r")
    local ports = {}
    while true do
        local line = file.readLine()
        if not line then
            break
        end
        table.insert(ports, tonumber(line))
    end
    file.close()
    return ports
end

-- Clears all ports, makes a new dir and file
function portimus.setup()
    portimus.clear()
    portimus.closeAll()

    fs.makeDir(portimus.dir)
    local file = fs.open(portimus.openFile, "w")
    file.close()
end

-- Remove the ports-file
function portimus.clear()
    fs.delete(portimus.openFile)
end

-- Check if a given port is open
function portimus.isOpen(port)
    return modem.isOpen(port)
end

-- Prints all open ports to the console
function portimus.printOpenports()
    local ports = portimus.getOpenPorts()
    print("--- OPEN PORTS ---")
    for _, value in pairs(ports) do
        print(("[%d]"):format(value))
    end
    print("------------------")
end

-- Closes a given port
function portimus.close(port)
    port = portimus.isValidPort(port)
    if not port then
        printError("Port is invalid! Cannot close port")
        return nil
    end
    local isopen = portimus.isOpen(port)
    if not isopen then
        --printError("Port is already closed")
        return nil
    end

    local openPorts = portimus.getOpenPorts()

    portimus.setup()
    
    for _, p in pairs(openPorts) do
        if p ~= port then
            portimus.open(p)
        end
    end

end

function portimus.closeAll()
    modem.closeAll()
end

return portimus