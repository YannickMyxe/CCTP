local mail = require "lib" or error("Could not load mail library")
local mmp  = require "mmp" or error("Could not load mmp library")
mail.setServerId(3)
mail.setupClient("Yannick-bot")

local recipient, subject, body 

-- Check if arguments are supplied
if arg[1] then
    recipient = arg[1]
else
    write("Enter recipient: ")
    recipient = read()
end

if arg[2] then
    subject = arg[2]
else
    write("Enter subject: ")
    subject = read()
end

if arg[3] then
    body = table.concat({select(3, ...)}, " ")
else
    write("Enter body: ")
    body = read()
end

local email = mail.newEmail(recipient, subject, body)

mail.sendEmail(email)
print("Waiting for response from mail server...")

local response = mmp.client.recieve()
print("Response received: " .. response)