LevelContainerBase = classWithSuper(SerializableObject, 'LevelContainerBase')

--
-- Properties
--

function LevelContainerBase:isOpen(self)
    --todo: implement
    return true
end

function LevelContainerBase.firstIncompleteLevel(self)
    local result
    
    for i = 1, #self._levels, 1 do
        local level = self._levels[i]
        
        if(not level:progress():isComplete())then
            result = level
            break
        end
        
    end
    
    return result
end

function LevelContainerBase.id(self)
    return self._id
end


function LevelContainerBase.number(self)
    return self._number
end


function LevelContainerBase.name(self)
    return self._name
end

function LevelContainerBase.levels(self)
    return self._levels
end

--
-- Methods
--

function LevelContainerBase.init(self, params)
    SerializableObject.init(self)
    
    assert(params               ~= nil)
    assert(params.level_class   ~= nil)
    
    self._levelInfoClass = params.level_class 
    
    self._levels = {}
end

function LevelContainerBase.cleanup(self)
    Object.cleanup(self)
end

function LevelContainerBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.id              ~= nil)
    assert(data.number          ~= nil)
    assert(data.name            ~= nil)
    assert(data.requirements    ~= nil)
    assert(data.levels          ~= nil)
    
    self._id            = data.id
    self._number        = data.number
    self._name          = data.name
    
    self._requirements = {}
    
    for i, requirementData in ipairs(data.requirements)do
        assert(requirementData.type     ~= nil)
        assert(requirementData.count    ~= nil)
        
        local requirement = {}
        requirement.type    = requirementData.type
        requirement.count   = requirementData.count
        
        table.insert(self._requirements, requirement)
    end
    
    for i, levelData in ipairs(data.levels)do
        
        local level =   self._levelInfoClass:new()
        level:deserialize(levelData) 
        
        table.insert(self._levels, level)
    end
    
end

