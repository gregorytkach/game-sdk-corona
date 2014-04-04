require('sdk.models.levels.LevelInfoBase')
require('sdk.models.levels.LevelContainerBase')
require('sdk.models.levels.LevelProgressBase')

ManagerLevelsBase = classWithSuper(SerializableObject, 'ManagerLevelsBase')

--
-- Properties
--

function ManagerLevelsBase.needManageMemory(self)
    return false
end

function ManagerLevelsBase.levelContainers(self)
    return self._levelContainers
end

function ManagerLevelsBase.firstIncompleteLevel(self)
    local result
    
    for _, levelContainer in ipairs(self._levelContainers)do
        
        if(levelContainer:isOpen())then
            result = levelContainer:firstIncompleteLevel()
            
            if(result ~= nil)then
                break
            end
        end
        
    end
    
    return result
end


function ManagerLevelsBase.completeLevelsCount(self)
    local result = 0
    
    for _, levelContainer in ipairs(self._levelContainers)do
        
        for _, level in ipairs(levelContainer:levels())do
            
            if(level:progress():isComplete())then
                result = result + 1
            end
            
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
    
    self._levelContainers = {}
end


function ManagerLevelsBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.level_containers    ~= nil)
    
    local levelContainerParams = 
    {
        level_class = self._levelInfoClass
    }
    
    for i, levelContainerData in ipairs(data.level_containers)do
        local levelContainer = LevelContainerBase:new(levelContainerParams)
        levelContainer:deserialize(levelContainerData) 
        
        table.insert(self._levelContainers, levelContainer)
    end
    
end
