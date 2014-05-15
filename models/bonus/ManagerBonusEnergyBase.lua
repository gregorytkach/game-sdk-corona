ManagerBonusEnergyBase = classWithSuper(ManagerBonusBase, 'ManagerBonusEnergyBase')

--
-- Properties
-- 

function ManagerBonusEnergyBase.needManageMemory(self)
    return false
end


function ManagerBonusEnergyBase.onBonusClaimed(self)
--    self:timerStop()
    
--    self._timeLeft = self._timePeriod
    
--    self:timerStart()
end

function ManagerBonusEnergyBase.limit(self)
    return self._limit
end

function ManagerBonusEnergyBase.onEnergyChanged(self)
    local player =  GameInfo:instance():managerPlayers():playerCurrent()
    
    if(player:energy() < self._limit and self._timer == nil)then
        
        self._timeLeft = self._timePeriod
        
        self:timerStart()
        
    else
        self._timeLeft = -1
    end
end

--
-- Methods
--

function ManagerBonusEnergyBase.init(self, bonusInfoClass)
    ManagerBonusBase.init(self, bonusInfoClass)
    
end

function ManagerBonusEnergyBase.timerStart(self)
    
    self._timer = timer.performWithDelay(application.animation_duration * 4,
    function ()
        self._timeLeft = self._timeLeft - 1
        
        if(self._timeLeft == 0)then
            self:timerStop()
            
            local player =  GameInfoBase:instance():managerPlayers():playerCurrent()
            
            player:setEnergy(player:energy() + 1)
        end
    end, 
    self._timeLeft)
end

function ManagerBonusEnergyBase.deserialize(self, data)
    ManagerBonusBase.deserialize(self, data)
    
    self._limit         = tonumber(assertProperty(data, 'limit'))   
end

