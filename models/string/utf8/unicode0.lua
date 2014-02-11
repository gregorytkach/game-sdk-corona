function CodeToUTF8 (Unicode)
    if (Unicode <= 0x7F) then return string.char(Unicode); end;
    
    if (Unicode <= 0x7FF) then
        local Byte0 = 0xC0 + math.floor(Unicode / 0x40);
        local Byte1 = 0x80 + (Unicode % 0x40);
        return string.char(Byte0, Byte1);
    end;
    
    if (Unicode <= 0xFFFF) then
        local Byte0 = 0xE0 +  math.floor(Unicode / 0x1000);
        local Byte1 = 0x80 + (math.floor(Unicode / 0x40) % 0x40);
        local Byte2 = 0x80 + (Unicode % 0x40);
        return string.char(Byte0, Byte1, Byte2);
    end;
    
    return "";                                   -- ignore UTF-32 for the moment
end

function CodeFromUTF8 (UTF8)
    local Byte0 = string.byte(UTF8,1);
    
    if (math.floor(Byte0 / 0x80) == 0) then 
        return Byte0; 
    end
    
    local Byte1 = string.byte(UTF8,2) % 0x40;
    if (math.floor(Byte0 / 0x20) == 0x06) then
        return (Byte0 % 0x20)*0x40 + Byte1;
    end;
    
    local Byte2 = string.byte(UTF8,3) % 0x40;
    if (math.floor(Byte0 / 0x10) == 0x0E) then
        return (Byte0 % 0x10)*0x1000 + Byte1*0x40 + Byte2;
    end;
    
    local Byte3 = string.byte(UTF8,4) % 0x40;
    if (math.floor(Byte0 / 0x08) == 0x1E) then
        return (Byte0 % 0x08) * 0x40000 + Byte1 * 0x1000 + Byte2 * 0x40 + Byte3;
    end;
end

function unichr(ord)
    if ord == nil then return nil end
    if ord < 32 then return string.format('\\x%02x', ord) end
    if ord < 126 then return string.char(ord) end
    if ord < 65539 then return string.format("\\u%04x", ord) end
    if ord < 1114111 then return string.format("\\u%08x", ord) end
end


local res = CodeToUTF8(1092)

local code = CodeFromUTF8('щ')



--res = string.char(300)

local b, b1 = string.byte('Ы',2)
b, b2 = string.byte('Щ')

b = string.byte('s')

local l = string.len('ф')
l = string.len('s')


local subs = string.sub('aav', 1, 2)

local f = string.format("\\u%08x", 200)
res = string.byte('ф')
local var = string.sub ('ф',1,1)
print(var)

local c = '\u127' --string.char(0x83)

--local cond = 'щ' < 300


--local c = string.utf8code('щ')

--local r = unichr(317)

