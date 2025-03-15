-- RSA Lib for CCSTL

local rsa = {}

local function modexp(base, exp, mod)
    local r = 1
    while exp > 0 do
        if exp % 2 == 1 then
            r = (r * base) % mod
        end
        base = (base * base) % mod
        exp = math.floor(exp / 2)
    end
    return r
end

function rsa.encrypt(data, e, n)
    local result = {}
    for i = 1, #data do
        result[i] = modexp(data:byte(i), e, n)
    end
    return result
end

function rsa.decrypt(data, d, n)
    local result = {}
    for i = 1, #data do
        result[i] = string.char(modexp(data[i], d, n))
    end
    return table.concat(result)
end

function rsa.generateKeyPair()
    local p, q = 0, 0
    while true do
        p = math.random(2^15, 2^16)
        if p % 2 == 0 then
            break
        end
    end
    while true do
        q = math.random(2^15, 2^16)
        if q % 2 == 0 then
            break
        end
    end
    local n = p * q
    local phi = (p - 1) * (q - 1)
    local e = 65537
    local d = 0
    while true do
        d = d + 1
        if (d * e) % phi == 1 then
            break
        end
    end
    return {
        publicKey = {e = e, n = n},
        privateKey = {d = d, n = n}
    }
end

function rsa.serializeKey(key)
    return textutils.serialize(key)
end

return rsa