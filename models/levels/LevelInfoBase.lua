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

function LevelInfoBase.rewardCurrencySoft(self)
    return self._rewardCurrencySoft
end

function LevelInfoBase.progress(self)
    return self._progress
end

function LevelInfoBase.number(self)
    return self._number
end

--
--Methods
--

function LevelInfoBase.init(self)
    SerializableObject.init(self)
end

function LevelInfoBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    if(data.number == nil)then
        print('Not found number for level info base. Use by default 1. TODO: remove it after implement on server side', ELogLevel.ELL_WARNING)
        data.number = 1
    end
    
    assert(data.progress                ~= nil)
    
    self._rewardCurrencySoft    = tonumber(assertProperty(data, 'reward_currency_soft'))
    self._rewardScores          = tonumber(assertProperty(data, 'reward_scores'))
    self._number                = tonumber(assertProperty(data, 'number'))
    
    self:initLevelProgress(data.progress)
end

function LevelInfoBase.initLevelProgress(self, data)
    
    self._progress = LevelProgressBase:new()
    self._progress:deserialize(data)
    
end
