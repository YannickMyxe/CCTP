

local confi = {}
confi.dir = "/.config/"
confi.extention = ".cfg"

function confi.getPath(path)
    return confi.dir .. path .. confi.extention
end
-- Function to create a directory if it doesn't exist, returns the file or Nil if it fails
function confi.addFile(filename)
    local path = confi.getPath(filename)
    local f = io.open(path, "w")
    if not f then
        printError("Failed to open file: " .. path)
        return nil
    end
    f:close()
    return f
end

function confi.add(filename, content)
    local path = confi.getPath(filename)
    local f = io.open(path, "w")
    if not f then
        printError("Failed to open file: " .. path)
        return nil
    end
    f:write(content)
    f:close()
    print("File created: " .. path)
end

-- Loads the file and returns the content or Nil if it fails
-- @param file: The file to load
-- @return: The content of the file or Nil
function confi.loadFile(file)
    local path = confi.getPath(file)
    local f = io.open(path, "r")
    if not f then
        printError("Failed to open file: " .. path)
        return nil
    end
    local content = f:read("*a")
    f:close()
    print("File loaded: " .. path)
    if not content then
        printError("Failed to read file: " .. path)
        return nil
    end
    print("File content: [" .. content .. "]")
    return content
end

function confi.exists(file)
    local path = confi.getPath(file)
    local f = io.open(path, "r")
    if not f then
        return false
    end
    f:close()
    return true
end

return confi