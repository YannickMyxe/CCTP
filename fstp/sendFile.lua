local fstp = require "fstp" or error("Could not load fstp library")

if not arg[1] then
    error("No file path argument supplied")
end

if not arg[2] then
    error("No file recieverID supplied")
end

local file = arg[1]
local reciever = tonumber(arg[2]) or error("Reciever ID must be a number")


print("Sending file: " .. file .. " to: #" .. reciever)

fstp.SendFile(file, reciever)

