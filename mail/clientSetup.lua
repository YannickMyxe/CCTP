local mail = require "lib" or error("Could not load mail library")

-- Create a config Library
mail.createConfig()


-- Setup your name
write("Enter your name: ")
local name = read()
mail.setName(name)

-- Setup the serverID
write("Enter your server ID: ")
local id = read()
mail.addConfig("serverID", id)


-- Print the config
print("Name set to: " .. name)
print("Server ID set to: " .. id)
print("Config saved at: " .. mail.configDir)

-- End of file