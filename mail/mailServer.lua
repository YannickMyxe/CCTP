local mail = require "lib" or error("Could not load mail library")

package.path = '../?.lua;' .. package.path
local fstp = require("fstp") or error("Could not load fstp library")
local mmp = require("mmp") or error("Could not load mmp library")

local mailserver = {}

mailserver.dir = "mailboxes/"
mailserver.userData = "users/"

mailserver.user = {
    Name = "",
    RednetID = -1, -- -1 means no rednet ID
}

function mailserver.isUserType(user)
    return type(user) == "table" and user.Name and user.RednetID
end

function mailserver.validateUser(user)
    if not mailserver.isUserType(user) then
        error("Invalid user object")
    elseif user.Name == "" then
        error("User name cannot be empty")
    elseif user.RednetID == -1 then
        error("User rednet ID cannot be -1")
    end
end

function mailserver.newMailboxItem(user, inbox)
    return {
        user = user,
        inbox = inbox,
    }
end

function mailserver.userExitst(user)
    return mail.inboxExists(user.Name)
end

function mailserver.setupUser(userName, rednetID)
    if mail.inboxExists(userName) then
        error("User already exists")
    end

    mail.setupMailbox(userName)
    local file = fs.open(mailserver.userData .. userName .. ".user", "w") or error("Could not create user file")
    file.write(rednetID)
    file.close()
end

function mailserver.loadMails(path)
    local mails = {}
    for _, file in ipairs(fs.list(path)) do
        local mail = mail.readMail(path .. file)
        table.insert(mails, mail)
    end
    return mails
end

function mailserver.loadMailsUnread(path)
    local mails = mailserver.loadMails(path)
    local unread = {}
    for _, mail in ipairs(mails) do
        if mail.state == mail.EmailStates.UNREAD then
            table.insert(unread, mail)
        end
    end

    return unread
end

function mailserver.setup()
    fs.makeDir(mailserver.dir)
    mail.setRoot("/")
end

function mailserver.storeMail(email)
    local err = mail.isValidEmail(email)
    if err then
        error("Invalid email format: " .. err)
    end

    local fPath = mail.getInboxPath(email.recipient) .. email.sender .. "-" .. email.subject .. ".mail"
    local tmp = mail.mailToFile(email)
    fstp.MoveFileOverwrite(tmp, fPath)
    print("Email saved: " .. fPath)
end

function mailserver.uploadMail(email)
    local err = mail.isValidEmail(email)
    if err then
        error("Invalid email format: " .. err)
    end 
    if not mailserver.inboxExists(email.recipient) then
        error("Recipient does not have a mailbox")
    end
    mailserver.storeMail(email)
end

function mailserver.getRednetID(userName)
    local file = fs.open(mailserver.userData .. userName .. ".user", "r") or error("Could not open user file")
    local rednetID = file.readAll()
    file.close()
    return rednetID
end

function mailserver.sendMail(email)
    if not mail.isValidEmail(email) then
        error("Invalid email format")
    end
    fstp.SendFile(email, mailserver.getRednetID(email.recipient))
end

function mailserver.receiveMail()
    local path, id = fstp.RecieveFile(mail.temp())
    mailserver.storeFile(path)
    mailserver.removeFile(path)
    mmp.server.send("Mail received", id)
    -- rednet.send(id, "Mail received")
end

function mailserver.storeFile(file)
    local email = mail.fileToMail(file)
    mailserver.storeMail(email)
end

function mailserver.removeFile(file)
    print("Removing file: " .. file)
    fs.delete(file)
end

function mailserver.run()
    if not fs.exists(mailserver.dir) then
        mailserver.setup()
    end
    while true do
        mailserver.receiveMail()
    end
end

return mailserver