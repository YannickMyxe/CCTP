local port = 42
local modem = peripheral.find("modem") or error("Cannot find any modem", 0) -- modem

local md = {}

modem.open(port)

-- [[ Sends a given message to the sending channel ]]
function md.send(message)
    --print(("Sending on channel #%d, recieving on channel #%d"):format(port, 43))
    modem.transmit(port, 43, message)
end

--[[ Waits for a message to recieve on the given channel --]]
function md.recieve()
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == port

    return event, side, channel, replyChannel, message, distance
end


return md;