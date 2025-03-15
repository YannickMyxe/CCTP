package.path = '../?.lua;' .. package.path
local fstp = require("fstp") or error("Could not load fstp library")

local mail = require "lib" or error("Could not load mail library")
local mailserver = require "mailServer" or error("Could not load mail server library")

print("Libraries loaded")

print("Listening on id #" .. os.getComputerID())

mailserver.setup()

local server = mailserver.run()