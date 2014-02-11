require('sdk.models.levels.LevelInfoBase')

ManagerLevelsBase = classWithSuper(SerializableObject, 'ManagerLevelsBase')

--
-- Properties
--

function ManagerLevelsBase.needManageMemory(self)
    return false
end

function ManagerLevelsBase.levels(self)
    return self._levels
end

function ManagerLevelsBase.firstIncompleteLevel(self)
    local result
    
    for i = 1, #self._levels, 1 do
        local level = self._levels[i]
        
        if(not level:isComplete())then
            result = level
            break
        end
        
    end
    
    return result
end



--
--Methods
--

function ManagerLevelsBase.init(self, levelInfoClass)
    SerializableObject.init(self)
    
    assert(levelInfoClass ~= nil)
    self._levelInfoClass = levelInfoClass
    
    self._levels = {}
end


function ManagerLevelsBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.levels ~= nil)
    
    for i, levelData in ipairs(data.levels)do
        local level =  self._levelInfoClass:new()
        level:deserialize(levelData) 
        
        table.insert(self._levels, level)
    end
end
