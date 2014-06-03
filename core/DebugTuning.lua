require('sdk.core.ELogLevel')
require('sdk.core.Utils')

--
-- cache
--

local originalAssert    = assert
local originalPrint     = print


--
-- debug
--

local function debugAssert(condition, message)
    if(condition)then
        --do nothing
    else
        print(message, ELogLevel.ELL_ERROR)
        
        if(application.debug)then
            originalAssert(false)
        end
    end
end

local function debugPrint(message, level)
    
    level = level or ELogLevel.ELL_INFO
    
    if(level < application.log_level)then
        return
    end
    
    if(message == nil )then
        message = ""
    end
    
    if(level == ELogLevel.ELL_INFO)then
        
        originalPrint("[INFO]: "..getString(message))
        
    elseif(level == ELogLevel.ELL_WARNING)then
        
        originalPrint("[WARNING]: "..getString(message))
        
    elseif(level == ELogLevel.ELL_ERROR)then
        
        originalPrint("[ERROR]: "..getString(message))
        
    elseif(level == ELogLevel.ELL_PURCHASES)then
        
        originalPrint("[PURCHASES]: "..getString(message))
        
    else            
        originalPrint(message)
    end
end

local function debugAssertProperty(data, property)
    local result = data[property]
    
    assert(result ~= nil, 'Not found property'..property)
    
    return result
end


--
-- release
--

local function releaseAssert(condition, message)
end

local function releasePrint(message)
end

local function releaseAssertProperty(data, property)
    return data[property]
end


--
-- init
--

assertProperty = nil

if(application.debug)then
    
    print           = debugPrint
    assert          = debugAssert
    assertProperty  = debugAssertProperty
    
else
    
    local function debug_hook(phase, l, error)
        print(debug.getinfo(1).source)
        print(debug.getinfo(1).currentline)
        print(debug.getinfo(2).name)
    end
    
    debug.sethook (debug_hook, "",0 )
    
    assert          = releaseAssert
    print           = releasePrint
    assertProperty  = releaseAssertProperty
    
end