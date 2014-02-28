require('sdk.core.ELuaType')
require('sdk.core.ERuntimeEvent')

local objectsForCleanup = {}

-- Create a new class that inherits from a base class
function classWithSuper( baseClass, className )
    
    -- Create the table and metatable representing the class.
    local classInstance = {}
    
    if baseClass ~= nil then
        setmetatable( classInstance, { __index = baseClass } )
    end
    
    -- Note that this function uses class_mt as an upvalue, so every instance
    -- of the class will share the same metatable.
    --
    -- The following is the key to implementing inheritance:
    
    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    
    function classInstance:new(params)
        local instance = {}
        
        setmetatable( instance, { __index = classInstance } )
        instance:init(params)
        
        if(application.debug and instance:class().needManageMemory())then
            instance._isCleanuped       = false
            objectsForCleanup[instance] = instance
        end
        
        return instance
    end
    
    function classInstance:init(self, params)
        assert(false, 'Please implement in derived class')
    end
    
    
    function classInstance.needManageMemory(self)
        return true
    end
    
    function classInstance.cleanup(self)
        if(self == nil)then
            print("set breakpoint here")
        end
        
        if(self._isCleanuped)then
            print("set breakpoint here")
        end
        
        assert(not self._isCleanuped)
        
        if(application.debug and self:class().needManageMemory())then
            self._isCleanuped = true
            
            objectsForCleanup[self] = nil
        end
    end
    
    -- Implementation of additional OO properties starts here --
    
    function classInstance:className()
        return className
    end
    
    -- Return the class object of the instance
    function classInstance:class()
        return classInstance
    end
    
    -- Return the super class object of the instance
    function classInstance:classSuper()
        return baseClass
    end
    
    -- Return true if the caller is an instance of theClass
    function classInstance:isA(theClass)
        local result = false
        
        local classCurrent = classInstance
        
        while ( nil ~= classCurrent ) and ( false == result ) do
            if classCurrent == theClass then
                result = true
            else
                classCurrent = classCurrent:classSuper()
            end
        end
        
        return result
    end
    
    return classInstance
end

Object = classWithSuper(nil, 'Object') 

function reportObjectsForCleanup()
    
    for object, object in pairs(objectsForCleanup)do
        print(string.format('object with class %s not cleanuped', object:className()))
    end
    
    return objectsForCleanup
end
