--[[
    Git clone script based on
    Based on : https://github.com/Konijima/cc-git-clone
--]]

local expect = dofile("rom/modules/main/cc/expect.lua").expect
local gclone = require "getcloned" or error("Cannot load lib")

local args = {...}

expect(1, args[1], 'string')
expect(1, args[2], 'string')
expect(1, args[3], 'string')


local user = args[1]
local repo = args[2]
local branch = args[3]
local localPath = args[4] or shell.dir()

gclone.clone(user, repo, branch, localPath)

