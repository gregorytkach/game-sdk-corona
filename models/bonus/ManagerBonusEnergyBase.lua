ManagerBonusEnergyBase = classWithSuper(ManagerBonusBase, 'ManagerBonusEnergyBase')

--
-- Properties
-- 

function ManagerBonusEnergyBase.needManageMemory(self)
    return false
end

function ManagerBonusEnergyBase.onBonusEnergyClaimed(self)
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
    
    assert(data.limit           ~= nil)
    
    self._limit = data.limit
    
    --todo: review
--    self:timerEnergyStart()
end

