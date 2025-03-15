local mail = require "lib" or error("Could not load mail library")

-- Check if a file path argument is supplied
if not arg[1] then
    error("No file path argument supplied")
end

local filePath = tostring(arg[1]) 

if not fs.exists(filePath) then
    error("Could not find email at `" .. filePath .. "`;")
end

local email = mail.fileToMail(filePath)
mail.printEmail(email)