ManagerBonusEnergyBase = classWithSuper(ManagerBonusBase, 'ManagerBonusEnergyBase')

--
-- Properties
-- 

function ManagerBonusEnergyBase.bonusEnergy(self)
    return self._bonusEnergy
end

function ManagerBonusEnergyBase.onBonusEnergyClaimed(self)
end

function ManagerBonusEnergyBase.timeLeftEnergy(self)
    return self._timeLeftEnergy
end

function ManagerBonusEnergyBase.limit(self)
    return self._limit
end

function ManagerBonusEnergyBase.onEnergyChanged(self)
    local player =  GameInfo:instance():managerPlayers():playerCurrent()
    
    if(player:energy() < self._limit and self._timer == nil)then
        
        self._timeLeftEnergy = self._timePeriodEnergy
        
        self:timerEnergyStart()
        
    else
        self._timeLeftEnergy = -1
    end
end

--
-- Methods
--

function ManagerBonusEnergyBase.init(self, bonusInfoClass)
    ManagerBonusBase.init(self, bonusInfoClass)
    
end

function ManagerBonusEnergyBase.timerEnergyStop(self)
    if(self._timerEnergy ~= nil)then
        timer.cancel(self._timerEnergy)
        self._timerEnergy = nil
    end
end

function ManagerBonusEnergyBase.timerEnergyStart(self)
    self._timerEnergy = timer.performWithDelay(application.animation_duration * 4,
    function ()
        self._timeLeftEnergy = self._timeLeftEnergy - 1
        
        if(self._timeLeftEnergy == 0)then
            self:timerEnergyStop()
            
            local player =  GameInfo:instance():managerPlayers():playerCurrent()
            
            player:setEnergy(player:energy() + 1)
        end
    end, 
    self._timeLeftEnergy)
end

function ManagerBonusEnergyBase.deserialize(self, data)
    ManagerBonusBase.deserialize(self, data)
    
    assert(data.energy              ~= nil)
    assert(data.energy.time_period  ~= nil)
    assert(data.energy.time_left    ~= nil)
    assert(data.energy.bonus        ~= nil)
    assert(data.energy.limit        ~= nil)
    
    local bonusEnergy = BonusInfoBase:new()
    bonusEnergy:deserialize(data.energy.bonus)
    
    self._bonusEnergy       = bonusEnergy
    
    self._timePeriodEnergy  = data.energy.time_period
    self._timeLeftEnergy    = data.energy.time_left
    self._limit             = data.energy.limit
    self:timerEnergyStart()
end

