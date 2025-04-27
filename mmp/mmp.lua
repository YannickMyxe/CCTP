--# Mode Message Protocol
package.path = '../?.lua;' .. package.path

local portimus = require "portimus.prime" or error("Could not load portimus library")
local modem = peripheral.find("modem") or error("No modem attached", 0)
if not modem then
    error("No modem attached", 0)
end

local mmp = {}
mmp.client = {}
mmp.server = {}

mmp.ports = {
    client = 300,
    server = 333,
}

mmp.protocol = "mmp"

function mmp.send(data, message, channel, replyChannel)
    print("Sending data ... on port " .. channel .. " via the " .. mmp.protocol .. " protocol")
    if not message then 
        message = mmp.protocol
    end
    local data = { protocol = mmp.protocol, message = message, data = data } 
    modem.transmit(channel, replyChannel, data)
end

function mmp.client.send(data, message)
    mmp.send(data, message, mmp.ports.client, mmp.ports.server)
end

function mmp.server.send(data, message)
    mmp.send(data, message, mmp.ports.server, mmp.ports.client)
end

function mmp.recieve(channel)
    local event, side, pchannel, replyChannel, data, distance
    repeat
        print("Waiting for data ... on channel " .. channel)
        event, side, pchannel, replyChannel, data, distance = os.pullEvent("modem_message")
    until pchannel == channel and data.protocol == mmp.protocol

    return data
end

function mmp.client.recieve()
    return mmp.recieve(mmp.ports.server)
end

function mmp.server.recieve()
    return mmp.recieve(mmp.ports.client)
end

function mmp.openPorts()
    portimus.open(mmp.ports.client)
    portimus.open(mmp.ports.server)
end

--[[ 
    Changes the ports for the client and server
    Closes the current ports and opens the new ones 
]]
function mmp.changePorts(client, server)
    portimus.close(mmp.ports.client)
    portimus.close(mmp.ports.server)

    mmp.ports.client = client
    mmp.ports.server = server

    mmp.openPorts()
end

function mmp.changeProtocol(newProtocol)
    print("Protocol changed from "..mmp.protocol .. " to: " .. newProtocol)
    mmp.protocol = newProtocol
end

mmp.openPorts()

return mmp