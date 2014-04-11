ManagerTutorialBase = classWithSuper(SerializableObject, 'ManagerTutorialBase')

--
-- Properties
--

function ManagerTutorialBase.isComplete(self)
    return self._stepCurrent == self._stepCount
end

function ManagerTutorialBase.stepCurrent(self)
    return self._stepCurrent
end

function ManagerTutorialBase.stepCount(self)
    return self._stepCount
end

--
-- Events
--

function ManagerTutorialBase.onStepCurrentComplete(self)
    assert(not self:isComplete())
    
    self._stepCurrent = self._stepCurrent + 1
    
    --todo: save
    print('todo:saves to disk', ELogLevel.ELL_WARNING)
end

--
-- Methods
--

function ManagerTutorialBase.init(self)
    SerializableObject.init(self)
    
end

function ManagerTutorialBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    self._stepCurrent = assertProperty(data, "step_current")
    
    self._stepCount   = assertProperty(data, "step_count")
end

function ManagerTutorialBase.cleanup(self)
    Object.cleanup(self)
end

