
local server = require("server_lib")

if not server then
    error("Failed to load server")
    return nil
end

server.run()