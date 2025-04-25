local basalt = require("basalt")

-- Get the main frame (your window)
local main = basalt.getMainFrame()

local lib = {}

function lib.createMenuBar(items)
    local spacing = 0
    for index, item in ipairs(items) do
        print("["..index.."]: " .. item)
        main:addButton()
            :setText("["..item.."]")
            :setPosition(spacing + index, 1)
            :onClick(function()
                -- (BOB) do something
            end)
        spacing = spacing + string.len(item) + 10
    end
end

lib.run = function() basalt.run() end

return lib