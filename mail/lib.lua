-- mailing_lib.lua

package.path = '../?.lua;' .. package.path
local fstp = require("CCTP.fstp") or error("Could not load fstp library")

local MailingLib = {}

MailingLib.root         = "/home/"
MailingLib.dir          = MailingLib.root   .. "mail/"
MailingLib.inbox        = "inbox/"
MailingLib.configDir    = MailingLib.dir    .. ".config/"
MailingLib.tagDir       = ".tags/"
MailingLib.temp         = MailingLib.dir    .. "temp/"

MailingLib.showDir = {
    ROOT = MailingLib.root,
    DIR = MailingLib.dir,
    INBOX = MailingLib.getInboxPath(),
    READ = MailingLib.read,
    UNREAD = MailingLib.unread,
    CONFIG = MailingLib.configDir,
    TAG = MailingLib.tagDir,
    TEMP = MailingLib.temp,
}

MailingLib.serverID = nil

MailingLib.EmailStates = {
    UNREAD = "unread",
    READ = "read",
}

-- Function to show all Dir of the Library
function MailingLib.listDir()
    for key, value in pairs(MailingLib.showDir) do
        print(key .. ": " .. value)
    end
end

-- Function to change the root directory
function MailingLib.setRoot(newRootPath)
    MailingLib.root = newRootPath
end

-- Setup an Id for the client to send the mails to
function MailingLib.setServerId(RednetID)
    MailingLib.serverID = RednetID
end

-- Setup the client
function MailingLib.setupClient(name) 
    MailingLib.setName(name)
end

-- Validate the server ID
function MailingLib.validID()
    if not MailingLib.serverID then
        error("Server ID not set")
    end
end

-- Function to create a new email Object
function MailingLib.newMailObject(sender, recipient, subject, body)
    return {
        sender = sender,
        recipient = recipient,
        subject = subject,
        body = body
    }
end

-- Function to create a new email
function MailingLib.newEmail(recipient, subject, body)
    return {
        sender = MailingLib.getName(),
        recipient = recipient,
        subject = subject,
        body = body
    }
end

-- Function to validate an email object
function MailingLib.isValidEmail(email)
    if not email then
        error("Email object is nil")
    elseif type(email) ~= "table" then
        error("Email object is not a table")
    elseif not email.sender then
        error("Email object does not have a sender")
    elseif not email.recipient then
        error("Email object does not have a recipient")
    elseif not email.subject then
        error("Email object does not have a subject")
    elseif not email.body then
        error("Email object does not have a body")
    end
    return true
end

function MailingLib.getInboxPath(user)
    return MailingLib.dir .. user .. MailingLib.inbox
end

function MailingLib.inboxExists(user)
    if not user then
        user = MailingLib.getName()
    end

    return fs.exists(MailingLib.getInboxPath(user))
end

function MailingLib.setupMailbox(user) 
    if not MailingLib.inboxExists(user.Name) then
        fs.makeDir(MailingLib.getInboxPath(user.Name))
    end
end

function MailingLib.getMailbox(user)
    return MailingLib.newMailboxItem(user, MailingLib.loadMails(MailingLib.getInboxPath(user)))
end

-- Function to send an email
function MailingLib.sendEmail(email)
    if MailingLib.isValidEmail(email) then
        local path = MailingLib.mailToFile(email)
        fstp.SendFile(path, MailingLib.serverID)
    end
end

-- Function to print an email
function MailingLib.printEmail(email)
    print("From: " .. email.sender)
    print("To: " .. email.recipient)
    print("Subject: " .. email.subject)
    print("--------------------------")
    print(email.body)
    print("--------------------------")
end

-- Function to save an email
function MailingLib.saveEmail(email)
    if not MailingLib.isValidEmail(email) then
        error("Invalid email format")
    end
    local inbox = MailingLib.getInboxPath()
    local fPath = inbox .. email.sender .. "-" .. email.subject .. ".mail"
    fstp.CreateDir(inbox)
    fstp.CreateFile(fPath, email.body)
    print("Email saved at: " .. fPath)
    return fPath
end

--[[ 
    Creates the configuration directory if it does not exist.
    @return boolean True if the config was made, false if it already existed.
]]
function MailingLib.createConfig()
    if not fs.exists(MailingLib.configDir) then
        fstp.CreateDir(MailingLib.configDir)
        -- Setup the clientID
        mail.addConfig("clientID", os.getComputerID())
        return true
    end
    return false
end

function MailingLib.addConfig(name, value)
    MailingLib.createConfig()
    local dir = MailingLib.configDir .. name
    fstp.CreateFile(dir)
    local file = fs.open(dir, "w") or error("File `" .. dir .. "` not found")
    file.write(value)
    file.close()
end

function MailingLib.changeConfig(name, value) 
    if not fs.exists(MailingLib.configDir .. name) then
        return nil
    end
    local file = fs.open(MailingLib.configDir .. name, "w") or error("File `" .. MailingLib.configDir .. name .. "` not found")
    file.write(value)
    file.close()
end

function MailingLib.getConfigValue(name)
    if not fs.exists(MailingLib.configDir .. name) then
        return nil
    end
    local file = fs.open(MailingLib.configDir .. name, "r") or error("File `" .. MailingLib.configDir .. name .. "` not found")
    local value = file.readAll()
    file.close()
    return value
end

function MailingLib.setName(name)
    if not fs.exists(MailingLib.configDir .. "name") then
        MailingLib.createConfig()
    end
    MailingLib.addConfig("name", name)
end

function MailingLib.getConfig()
    print("Loading config ... " .. MailingLib.configDir)
    local files = fstp.ListDir(MailingLib.configDir)

    if #files == 0 then
        print("No files found in config directory")
        return
    end

    for _, file in ipairs(files) do
        local f = fs.open(MailingLib.configDir .. file, "r") or error("File `" .. MailingLib.configDir .. file .. "` not found")
        local value = f.readAll()
        print(file .. ": "  .. value)
        f.close()
    end
end

function MailingLib.getName() 
    return MailingLib.getConfigValue("name")
end

function MailingLib.addTag(tagName, path)
    local dir = MailingLib.dir .. path .. MailingLib.tagDir
    fstp.CreateDir(dir)
    local filePath = dir .. tagName
    fstp.CreateFile(filePath)
    local file = fs.open(filePath, "w") or error("File `" .. filePath .. "` not found")
    file.close()
end

function MailingLib.removeTag(tagName, path)
    local dir = MailingLib.dir .. path .. MailingLib.tagDir
    local filePath = dir .. tagName
    fs.delete(filePath)
end

function MailingLib.getTags(path)
    local dir = MailingLib.dir .. path .. MailingLib.tagDir
    if not fs.exists(dir) then
        return {}
    end
    local files = fstp.ListDir(dir)
    return files
end

function MailingLib.hasTag(tagName, path)
    local tags = MailingLib.getTags(path)
    for _, tag in ipairs(tags) do
        if tag == tagName then
            return true
        end
    end
    return false
end

function MailingLib.setRead(path)
    MailingLib.addTag("read", path)
end

function MailingLib.setUnread(path)
    MailingLib.removeTag("read", path)
end

function MailingLib.mailToFile(email)
    print("Transforming E-mail to file: " .. email.subject)

    local tempDir = MailingLib.temp
    local fPath = tempDir .. email.subject .. ".mail"
    fstp.CreateDir(tempDir)
    local file = fs.open(fPath, "w") or error("Could not create/write to file "  .. fPath)
    file.write(email.sender .. "\n")
    file.write(email.recipient .. "\n")
    file.write(email.subject .. "\n")
    file.write(email.body)
    file.close()
    return fPath
end

function MailingLib.fileToMail(filePath)
    print("Transforming file to E-mail: " .. filePath)

    local file = fs.open(filePath, "r") or error("File `" .. filePath .. "` not found")
    local sender = file.readLine()
    local recipient = file.readLine()
    local subject = file.readLine()
    local body = file.readAll()
    file.close()

    return MailingLib.newMailObject(sender, recipient, subject, body)
end

return MailingLib