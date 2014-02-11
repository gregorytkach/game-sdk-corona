---
-- Converts all UTF-8 character sets to unicode/ASCII characters
-- to generate ISO-8859-1 email bodies etc.
--@param utf8 UTF-8 encoded string
--@return a ASCII/ISO-8859-1 8-bit conform string
function utf8_decode(utf8)
    
    local unicode = ""
    local mod = math.mod
    
    local pos = 1
    while pos < string.len(utf8) + 1 do
        
        local v = 1
        local c = string.byte(utf8, pos)
        local n = 0
        
        if c < 128 then v = c
        elseif c < 192 then v = c
        elseif c < 224 then v = mod(c, 32) n = 2
        elseif c < 240 then v = mod(c, 16) n = 3
        elseif c < 248 then v = mod(c,  8) n = 4
        elseif c < 252 then v = mod(c,  4) n = 5
        elseif c < 254 then v = mod(c,  2) n = 6
        else v = c end
        
        for i = 2, n do
            pos = pos + 1
            c = string.byte(utf8,pos)
            v = v * 64 + mod(c, 64)
        end
        
        pos = pos + 1
        if v < 255 then 
            unicode = unicode..string.char(v)
        end
        
    end
    
    return unicode
end

---
-- Converts all unicode characters (>127) into UTF-8 character sets
--@param unicode ASCII or unicoded string
--@return a UTF-8 representation
function utf8_encode(unicode)
    
    local math = math
    local utf8 = ""
    
    for i=1,string.len(unicode) do
        local v = string.byte(unicode,i)
        local n, s, b = 1, "", 0
        if v >= 67108864 then n = 6; b = 252
        elseif v >= 2097152 then n = 5; b = 248
        elseif v >= 65536 then n = 4; b = 240
        elseif v >= 2048 then n = 3; b = 224
        elseif v >= 128 then n = 2; b = 192
        end
        for i = 2, n do
            local c = math.mod(v, 64); v = math.floor(v / 64)
            s = string.char(c + 128)..s
        end
        s = string.char(v + b)..s
        utf8 = utf8..s
    end
    
    return utf8
end


local r0 = utf8_decode("щ")
local r1 = utf8_encode(r0)

print(r1)




