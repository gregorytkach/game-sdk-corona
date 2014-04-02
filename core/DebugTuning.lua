require('sdk.core.ELogLevel')
require('sdk.core.Utils')

--
-- functions
--

assertProperty = nil

if(application.debug)then
    
    local printOriginal = print
    
    print = 
    function(message, level)
        
        level = level or ELogLevel.ELL_INFO
        
        if(level < application.log_level)then
            return
        end
        
        if(message == nil )then
            message = ""
        end
        
        if(level == ELogLevel.ELL_INFO)then
            
            printOriginal("[INFO]: "..getString(message))
            
        elseif(level == ELogLevel.ELL_WARNING)then
            
            printOriginal("[WARNING]: "..getString(message))
            
        elseif(level == ELogLevel.ELL_ERROR)then
            
            printOriginal("[ERROR]: "..getString(message))
            
        else            
            printOriginal(message)
        end
    end
    
    local assertOriginal = assert
    
    assert = 
    function(condition, message)
        if(condition)then
            --do nothing
        else
            print(message, ELogLevel.ELL_ERROR)
            
            if(application.debug)then
                assertOriginal(false)
            end
        end
        
    end
    
    assertProperty = 
    function(data, property)
        local result = data[property]
        
        assert(result ~= nil, 'Not found property'..property)
        
        return result
    end
    
    
else
    
    local function debug_hook(phase, l, error)
        print(debug.getinfo(1).source)
        print(debug.getinfo(1).currentline)
        print(debug.getinfo(2).name)
    end
    
    debug.sethook (debug_hook, "",0 )
    
    assert  = function(condition, message)     end
    print   = function(message) end
    
    
    assertProperty = 
    function(data, property)
        return data[property]
    end
    
end





