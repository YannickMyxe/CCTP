local mmp = require "mmp" or error("Could not load mmp library")

mmp.client.send("Hello World!")
print("Data sent")
local ack = mmp.client.recieve()
print("Ack received " .. ack)