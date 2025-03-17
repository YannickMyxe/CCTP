local modem = peripheral.find("modem") or error("No modem attached", 0)
if not modem then
    error("No modem attached", 0)
end

local portimus = {}
portimus.dir = "/portimus/"
portimus.openFile = portimus.dir .. "ports.pt"

-- Opens the requested port and returns if the port was opened 
function portimus.open(port)
    if portimus.isOpen(port) then
        return false
    end
    modem.open(port)
    local file = fs.open(portimus.openFile, "w")
    file.writeLine(port)
    file.close()
    return true
end

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

function portimus.setup()
    portimus.clear()
    fs.makeDir(portimus.dir)
    local file = fs.open(portimus.openFile, "w")
    file.close()
end

function portimus.clear()
    fs.delete(portimus.openFile)
end

function portimus.isOpen(port)
    return modem.isOpen(port)
end

return portimus