local gclone = require "getcloned"

local url = "https://github.com/YannickMyxe/CCTP.git"
local ulrOk, err = http.checkURL(url)
if not ulrOk then
    print("Error checking URL: " .. err)
end

gclone.clone("YannickMyxe", "cctp", "main", "/programs/")