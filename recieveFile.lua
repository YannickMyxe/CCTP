local fstp = require "fstp" or error("Could not load fstp library")

local filepath, id = fstp.RecieveFile("/temp/")
print("File received from: #" .. id)