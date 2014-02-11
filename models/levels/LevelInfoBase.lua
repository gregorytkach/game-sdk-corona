LevelInfoBase = classWithSuper(SerializableObject, 'LevelInfoBase')

--
--Properties
--

function LevelInfoBase.needManageMemory(self)
    return false
end

function LevelInfoBase.rewardScores(self)
    return self._rewardScores
end

function LevelInfoBase.isComplete(self)
    return self._isComplete
end

--
--Methods
--

function LevelInfoBase.init(self)
    SerializableObject.init(self)
end

function LevelInfoBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.reward_scores   ~= nil)
    assert(data.is_complete     ~= nil)
    
    self._rewardScores = data.reward_scores
    self._isComplete = data.is_complete
end
