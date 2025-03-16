local mmp = require "mmp" or error("Could not load mmp library")

local data = mmp.server.recieve()
print("Data received: " .. data)
mmp.server.send("Hello back!")
print("Data sent")