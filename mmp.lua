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

modem.open(mmp.ports.client)
modem.open(mmp.ports.server)

function mmp.send(data, channel, replyChannel)
    print("Sending data ... on port " .. channel)
    modem.transmit(channel, replyChannel, data)
end

function mmp.client.send(data)
    mmp.send(data, mmp.ports.client, mmp.ports.server)
end

function mmp.server.send(data)
    mmp.send(data, mmp.ports.server, mmp.ports.client)
end

function mmp.recieve(channel, replyChannel)
    local event, side, pchannel, replyChannel, data, distance
    repeat
        print("Waiting for data ... on channel " .. channel)
        event, side, pchannel, replyChannel, data, distance = os.pullEvent("modem_message")
    until pchannel == channel

    return data
end

function mmp.client.recieve()
    return mmp.recieve(mmp.ports.server)
end

function mmp.server.recieve()
    return mmp.recieve(mmp.ports.client)
end


return mmp