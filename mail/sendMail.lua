local mail = require "lib" or error("Could not load mail library")
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

local id, message
repeat
    id, message = rednet.receive()
until id == mail.serverID

print("Mailserver> " .. message)