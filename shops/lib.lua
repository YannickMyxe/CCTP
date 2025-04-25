local lib = {}

-- Coordinates
local coord = {}
function coord.new(x, y, z)
    local co = {x = x, y = y, z = z}
    return co
end

function coord.checkType(co)
    if not co then
        return "Coordinate cannot be nil"
    end
    if not type(co) == "table" then 
        return "Is not a Table!"
    end
    if not co.x then
        return "Does not have a [X] property!"
    end
    if not co.y then
        return "Does not have a [Y] property!"
    end
    if not co.z then
        return "Does not have a [Z] property!"
    end
    return nil
end

function coord.print(coordinate)
    print("x: ".. coordinate.x .. ", y: " .. coordinate.y .. ", z: " .. coordinate.z)
end

-- Item
local item = {}
function item.new(name, price) 
    local item = {name = name, price = price}
    return item
end

function item.isValidItem(item)
    if not item then
        return "Item cannot be nil"
    end
    if not type(item) == "table" then 
        return "Is not a Table!"
    end
    if not item.name then
        return "Does not have a [Name] property!"
    end
    if not item.price then
        return "Does not have a [Price] property!"
    end
    if not item.price > 0 then
        return "Price is not valid!"
    end
    if not string.len(item.name) <= 0 then
        return "Item name is not valid!"
    end
    return nil
end


-- Shop
local shop = {}
function shop.new(name, coord) 
    local shop = {name = name, coord = coord, items = {}}
    return shop
end

function shop.isValidName(name) 
    -- Check if the name is valid (not empty, not too long, etc.)
    if not name or string.len(name) == 0 then
        return false
    end
    return true
end

-- Checks if the given object is a type of shop
function shop.checkType(isShopObj)
    if not isShopObj then
        return "Shop cannot be nil"
    end
    if not type(isShopObj) == "table" then 
        return "Is not a Table!"
    end
    if not isShopObj.coord then
        return "Does not have a [Coordinate] property!"
    end
    local error = coord.checkType(isShopObj.coord)
    if error then
        return "Coordinate is not a valid coordinate! {" .. error .. "}"
    end
    if not shop.isValidName(isShopObj.name) then
        return "Shop name is not valid!"
    end
    return nil
end

function shop.print(shop)
    print("Shop Name: " .. shop.name)
    coord.print(shop.coord)
end

function shop.addItem(shop, item)
    local valid_shop = shop.checkType(shop)
    if not valid_shop then
        printError("Shop is not valid! {" .. valid_shop .. "}")
        return
    end
    local valid_item = item.isValidItem(item)
    if not valid_item then
        printError("Item is not valid! {" .. valid_item .. "}")
        return
    end
    if shop.items[item.name] then
        printError("Item already exists in the shop!")
        return
    end
    shop.items[item.name] = item
end

-- Manager
local manager = {}
function manager.new()
    local mg = {}
    mg.shops = {}
    return mg
end

function manager.addShop(shop) 
    local valid_shop = shop.checkType(shop)
    if not valid_shop then
        printError("Shop is not valid! {" .. valid_shop .. "}")
        return
    end
    if manager.shops[shop.name] then
        printError("Shop already exists!")
        return
    end
    manager.shops[shop.name] = shop
end

function manager.findShop(name) 
    if not shop.isValidName(name) then
        printError("Shop name is not valid!")
        return nil
    end
    local shop = manager.shops[name]
    if not shop then
        printError("Shop not found!")
        return nil
    end
    return shop
end

lib.coord = coord
lib.item = item
lib.shop = shop
lib.manager = manager

return lib