local md = require "md" or error("Could not get MD library")

--[[ Prints functions and variables from the import
for key, _ in pairs(md) do
    print(("Found [%s]"):format(key))
end
]]

--[[
    BASED ON : https://tekkitclassic.fandom.com/wiki/Tutorial/Simple_Chat_System
]]

Username = ""

local function ChangeUsername()
    write("New username: ")
    Username = read()
end

local function Help() 
    print("Welcome to MD-CHAT 1.0")
    print("Press C to Change your username")
    print("Press R to Clear the screen")
    print("Press H to show the Help menu")
    print("Press T to Type a message")
end

local function Clear()
    term.clear()
    term.setCursorPos(1,1)
end

local function Type()
    write(Username.."> ")
    local msg_sent = read()
    md.Send(Username.." > "..msg_sent)
end

local function Quit()
    print("Bye bye!")
    md.Send("{SYSTEM}> "..Username.." has left the channel.")
end

local function Main()
    ChangeUsername()
    Clear()
    Help()

    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEventRaw()
        if event == "modem_message" then
            print(message)

        elseif event == "char" then
            local id = side
            if id == "t" then
                Type()
            elseif id == "h" then
                Help()
            elseif id == "c" then
                ChangeUsername()
            elseif id == "q" then
                Quit()
                break;
            end
        elseif event == "terminate" then
            os.exit(0, true)
        end
        
    end
end

Main()

