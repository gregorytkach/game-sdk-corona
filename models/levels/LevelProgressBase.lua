LevelProgressBase = classWithSuper(SerializableObject, 'LevelProgressBase')

--
-- Properties
--


function LevelProgressBase.needManageMemory(self)
    return false
end


function LevelProgressBase.isComplete(self)
    return self._isComplete
end

--
-- Methods
--


function LevelProgressBase.init(self)
    SerializableObject.init(self)
    
end



function LevelProgressBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.is_complete ~= nil)
    
    self._isComplete = data.is_complete
end

function LevelProgressBase.cleanup(self)
    
end