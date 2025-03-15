local rsa = require("rsa") or error("Could not load rsa library")
local server = {listening = false, requests = {}, publicKey = {}, privateKey = {}}
peripheral.find("modem", rednet.open)

local function onRequest(req) end
local function onResponse(res) end

if not rednet.isOpen() then
    print("No modem found")
    return
end

local certType = {
    request = "request",
    response = "response",
    challenge = {
        request = "request",
        solution = "solution"
    }
}

local ccstlStyles = {
    certificate = "certificate",
    request = "request",
    response = "response",
}

local function handleCertificate(id, type, body, ack)
    --ccstl:certificate:request
    --ccstl:certificate:response
    --ccstl:certificate:challenge:request
    --ccstl:certificate:challenge:solution

    -- Return error if server is not listening and the certificate is a request
    if not server.listening and type[3] == "request" then
        rednet.send(id, "ccstl:response:::error:503:Service Unavailable:::" .. ack)
        return
    end

    if type[3] == "request" then
        rednet.send(id, "ccstl:certificate:response:::".. server.publicKey.signee .. "-" .. server.publicKey.e .. "-" .. server.publicKey.n .. ":::" .. ack)
        return
    end

    if type[3] == "response" then
        local request = server.requests[ack .. id]
        if request == nil then
            rednet.send(id, "ccstl:response:::error:500:Internal Server Error:::" .. ack)
            return
        end

        request.server.publicKey = {signee = tonumber(body:split("-")[1]), e = tonumber(body:split("-")[2]), n = tonumber(body:split("-")[3])}
        request.server.challengeSolution = math.random(2^15, 2^16)
        request.server.challenge = rsa.encrypt(request.server.challengeSolution, request.server.publicKey.e, request.server.publicKey.n)
        rednet.send(id, "ccstl:certificate:challenge:request:::" .. request.server.challenge .. ":::" .. ack)
        
        -- Save the request to the server because I've no idea if Lua is by reference or value
        server.requests[ack .. id] = request

        return
    end

    if type[3] == "challenge" and type[4] == "solution" then
        local request = server.requests[ack .. id]
        if request == nil then
            rednet.send(id, "ccstl:response:::error:500:Internal Server Error:::" .. ack)
            return
        end

        if request.server.challengeSolution == body then
            request.server.verified = true
            -- send request if verified
            rednet.send(id, "ccstl:request:::" .. request.body .. ":::" .. ack)
            return
        end

        rednet.send(id, "ccstl:response:::error:401:Unauthorized:::" .. ack)
        return
    end
end

local function handleRequest(id, type, body, ack)
    --ccstl:request

    if not server.listening then
        rednet.send(id, "ccstl:response:::error:503:Service Unavailable:::" .. ack)
        return
    end

    local request = server.requests[ack .. id]
    request.body = textutils.unserialize(body)

    onRequest(request)
end

local function handleResponse(id, type, body, ack)
    --ccstl:response
    local request = server.requests[ack .. id]
    request.response = textutils.unserialize(body)

    onResponse(request)
end

local ccstl = {}

function ccstl.listen()
    server.listening = true
end

function ccstl.createRequest(id, body)
    local ack = math.random(2^15, 2^16)
    local request = {
        id = id,
        body = body,
        ack = ack,
        server = {
            publicKey = nil,
            privateKey = nil,
            challenge = nil,
            challengeSolution = nil,
            verified = false
        }
    }

    server.requests[ack .. id] = request

    rednet.send(id, "ccstl:certificate:request:::nil:::" .. ack)
end

function ccstl.onRequest(callback)
    onRequest = callback
end

function ccstl.onResponse(callback)
    onResponse = callback
end

function ccstl.generateKeyPair()
    local keyPair = rsa.generateKeyPair()
    server.publicKey.signee = "self"
    server.publicKey = keyPair.publicKey
    server.privateKey = keyPair.privateKey

    local private = fs.open("private.key", "w")
    private.write(textutils.serialize(server.privateKey))
    private.close()

    local public = fs.open("public.key", "w")
    public.write(textutils.serialize(server.publicKey))
    public.close()

    return keyPair
end

local function handleMessage(id, msg, protocol)
    -- "ccstl:response:::error:503:Service Unavailable:::" .. ack
    msg = msg:split(":::")
    local type = msg[1]:split(":")
    local body = msg[2]
    local ack = msg[3]

    if not (type[1] == "ccstl") then return end

    if type[2] == ccstlStyles.certificate then
        handleCertificate(id, type, body, ack)
        return
    end

    if type[2] == ccstlStyles.request then
        handleRequest(id, type, body, ack)
        return
    end

    if type[2] == ccstlStyles.response then
        handleResponse(id, type, body, ack)
        return
    end
end

function ccstl.run() 
    while true do
        local id, msg, protocol = rednet.receive()
        handleMessage(id, msg, protocol)
    end
end

return ccstl