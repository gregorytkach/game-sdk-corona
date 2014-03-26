PlayerInfoBase = classWithSuper(SerializableObject, 'PlayerInfoBase')

--
-- Properties
--

function PlayerInfoBase.needManageMemory(self)
    return false
end

function PlayerInfoBase.currencySoft(self)
    return self._currencySoft
end

function PlayerInfoBase.setCurrencySoft(self, value)
    if(value == self._currencySoft)then
        return
    end
    
    self._currencySoft = value
    
    self:trySaveProgress()
    
    local currentState = GameInfo:instance():managerStates():currentState()
    
    if(currentState ~= nil)then
        currentState:update(EControllerUpdateBase.ECUT_PLAYER_CURERNCY)
    end
end

function PlayerInfoBase.energy(self)
    return self._energy
end

function PlayerInfoBase.setEnergy(self, value)
    if(value == self._energy)then
        return
    end
    
    self._energy = value
    
    self:trySaveProgress()
    
    local currentState = GameInfo:instance():managerStates():currentState()
    
    if(currentState ~= nil)then
        currentState:update(EControllerUpdateBase.ECUT_PLAYER_ENERGY)
    end
end


--
-- Methods
--


function PlayerInfoBase.init(self)
    SerializableObject.init(self)
    
    self._managerCache = GameInfoBase:instance():managerCache()
    
end

function PlayerInfoBase.trySaveProgress(self)
    if( self._managerCache ~= nil)then
        self._managerCache:savePlayerCurrent(self:serialize())
    end
end

function PlayerInfoBase.serialize(self)
    local result = 
    {
        currency_soft   = self._currencySoft,
        energy          = self._energy 
    }
    
    return result
end

function PlayerInfoBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.currency_soft                   ~= nil)
    assert(data.energy                          ~= nil)
    
    self._currencySoft  = tonumber(data.currency_soft)
    self._energy        = tonumber(data.energy)
    
end
