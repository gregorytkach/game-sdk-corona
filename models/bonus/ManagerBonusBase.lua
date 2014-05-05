require('sdk.models.bonus.BonusInfoBase')

ManagerBonusBase = classWithSuper(SerializableObject, 'ManagerBonusBase')

--
-- Properties
--

function ManagerBonusBase.needManageMemory(self)
    return false
end

function ManagerBonusBase.timeLeft(self)
    return self._timeLeft
end

function ManagerBonusBase.bonuses(self)
    return self._bonuses
end

function ManagerBonusBase.isBonusAvailable(self)
    return self._timeLeft == 0
end

--
-- Events
--

function ManagerBonusBase.onBonusClaimed(self)
    self:timerStop()
    
    self._timeLeft = self._timePeriod
    
    self:timerStart()
end

--
-- Methods
--

function ManagerBonusBase.init(self, bonusInfoClass)
    SerializableObject.init(self)
    
    assert(bonusInfoClass ~= nil)
    
    self._bonusInfoClass = bonusInfoClass
    self._bonuses        = {}
end

function ManagerBonusBase.timerStop(self)
    if(self._timer ~= nil)then
        timer.cancel(self._timer)
        self._timer = nil
    end
end

function ManagerBonusBase.timerStart(self)
    self._timer = timer.performWithDelay(application.animation_duration * 4,
    function ()
        self._timeLeft = self._timeLeft - 1
    end, 
    self._timeLeft)
end

function ManagerBonusBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    self._timePeriod    = tonumber(assertProperty(data, 'time_period'))
    self._timeLeft      = tonumber(assertProperty(data, 'time_left'))
    
    local bonusesData = assertProperty(data, 'bonuses')
    
    for i, bonusData in ipairs(bonusesData) do
        
        local bonus = self._bonusInfoClass:new()
        bonus:deserialize(bonusData)
        
        table.insert(self._bonuses, bonus)
    end
end

