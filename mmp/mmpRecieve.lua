local mmp = require "mmp" or error("Could not load mmp library")

local data = mmp.server.recieve()
print("Protocol: " .. data.protocol)
print("Message: " .. data.message)
print("Data received: " .. data.data)
mmp.server.send("Hello back!", "ack")
print("Data sent")