require('sdk.core.ELuaType')
require('utf8')

function string.lenUnicode(value)
    assert(value == nil or (value ~= nil and type(value) == ELuaType.ELT_STRING), 'Value type is not string')
    
    local result = 0
    
    if(value == nil)then
        return result
    end
    
    local result, k = 0, 1
    
    while k <= #value do
        result = result + 1
        if string.byte(value, k) <= 190 then
            k = k + 1 
        else 
            k = k + 2 
        end
    end
    
    return result
end

--------------------------------------------------------------
function string.subUnicode(value, positionStart, positionEnd)
    assert(value ~= nil and type(value) == ELuaType.ELT_STRING, 'Value type is not string')
    
    local result = ''
    
    local chars = {}
    
    local currentCharPosition = 1
    
    while currentCharPosition <= #value do
        local byte1 = string.byte(value, currentCharPosition)
        
        if byte1 <= 190 then
            
            chars[#chars + 1] = string.char(byte1)
            currentCharPosition = currentCharPosition + 1
            
        else
            
            local byte2 = string.byte(value, currentCharPosition + 1)
            chars[#chars + 1] = string.char( byte1, byte2 )
            currentCharPosition = currentCharPosition + 2
            
        end
    end
    
    for charPosition = positionStart, positionEnd do
        result = result..chars[charPosition]
    end
    
    return result
end 


local word = "фsф"
print( string.lenUnicode( word ) )

for i = 1, string.lenUnicode( word ) do
    print( string.subUnicode( word, i, i ) )
end

print(1)

local result = utf8.len(word)

for i = 1, result do
    print( utf8.sub( word, i, i ) )
end




