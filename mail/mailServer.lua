local mail = require "lib" or error("Could not load mail library")

package.path = '../?.lua;' .. package.path
local fstp = require("fstp") or error("Could not load fstp library")

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
    if not mail.isValidEmail(email) then
        error("Invalid email format")
    end
    local dir = mailserver.getInboxPath(email.recipient)
    local fPath = dir .. email.subject .. ".mail"
    fstp.CreateDir(dir)
    fstp.CreateFile(fPath, mail.mailToFile(email))
    print("Email saved at: " .. dir)
end

function mailserver.uploadMail(email)
    if mail.isValidEmail(email) then
        if not mailserver.inboxExists(email.recipient) then
            error("Recipient does not have a mailbox")
        end
        mailserver.storeMail(email)
    else
        error("Invalid email format")
    end
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
    local path = fstp.RecieveFile(mail.temp)
    local email = mail.fileToMail(path)
    mailserver.storeMail(email)

    mail.printEmail(email)
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