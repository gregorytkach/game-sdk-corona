utf8  = {}
function utf8.charbytes(s, i)
    local result = 0
    
    -- argument defaults
    i = i or 1
    
    local c = string.byte(s, i)
    
    -- determine bytes needed for character, based on RFC 3629
    if c > 0 and c <= 127 then
        -- UTF8-1
        result = 1
    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = string.byte(s, i + 1)
        
        result = 2
    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        
        result =  3
    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)
        
        result = 4
    end
    
    if(result == 0)then
        print(1)
    end
    
    assert(result > 0)
    
    return result
end

-- returns the number of characters in a UTF-8 string
function utf8.len(s)
    if(s~=nil) then
        local pos = 1
        local bytes = string.len(s)
        local lenX = 0
        while pos <= bytes and lenX ~= chars do
            local c = string.byte(s,pos)
            lenX = lenX + 1
            
            pos = pos + utf8.charbytes(s, pos)
        end
        if chars ~= nil then
            return pos - 1
        end
        
        return lenX
    end
    return 0
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
function  utf8.sub(s, i, j)
    j = j or -1
    
    if i == nil then
        return ""
    end
    local pos = 1
    local bytes = string.len(s)
    local len = 0
    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8.len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1
    
    -- can't have start before end!
    if startChar > endChar then
        return ""
    end
    
    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes
    
    while pos <= bytes do
        len = len + 1
        
        if len == startChar then
            startByte = pos
        end
        
        pos = pos + utf8.charbytes(s, pos)
        
        if len == endChar then
            endByte = pos - 1
            break
        end
    end
    
    return string.sub(s, startByte, endByte)
end

-- replace UTF-8 characters based on a mapping table
function utf8.replace(s, mapping)
    local pos = 1
    local bytes = string.len(s)
    local charbytes
    local newstr = ""
    
    while pos <= bytes do
        charbytes = utf8.charbytes(s, pos)
        local c = string.sub(s, pos, pos + charbytes - 1)
        newstr = newstr .. (mapping[c] or c)
        pos = pos + charbytes
    end
    
    return newstr
end