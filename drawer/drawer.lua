local monitor = peripheral.find("monitor") or error("Could not find a display target")

local drawer = {}

drawer.sw, drawer.sh = monitor.getSize()
drawer.background_color = colors.gray
drawer.foreground_color = colors.cyan

function drawer.setBgColor(color)
    if not color then
        printError("No color provided")
    end

    drawer.background_color = color
end

function drawer.setForegroundColor(color)
    if not color then
        printError("No color provided")
    end

    drawer.foreground_color = color
    monitor.setTextColor(color)
end

function drawer.fillBg(color)
    if not color then
        color = drawer.background_color
    end
    paintutils.drawFilledBox(1, 1, drawer.sw, drawer.sh, color)
end

function drawer.setTextPos(text, pos)
    if not text then
        printError("Text not provided")
    end
    if not pos or not pos.x or not pos.y then
        printError("Position not provided, or Position does not have x or y value")
    end

    monitor.setCursorPos(pos.x, pos.y)
    monitor.write(text)
end

function drawer.setText(text, x, y)
    return drawer.setTextPos(text, {x = x, y = y})
end

function drawer.createMenuBar(items)
    for i, item in ipairs(items) do
        print("{", i, "}", "{", item, "}")
    end
end


drawer.setForegroundColor(drawer.foreground_color)

return drawer