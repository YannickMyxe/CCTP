local portimus = require "/programs/cctp/portimus/prime" or error("Cannot find portimus library.")

portimus.setup()

local ports = portimus.getOpenPorts()

print("--- OPEN PORTS ---")
for _, value in pairs(ports) do
    print(("[%d]"):format(value))
end
print("------------------")