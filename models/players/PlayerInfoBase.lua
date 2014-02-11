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
    
end

function PlayerInfoBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.currency_soft                   ~= nil)
    assert(data.energy                          ~= nil)
    
    self._currencySoft  = data.currency_soft
    self._energy        = data.energy 
    
end
