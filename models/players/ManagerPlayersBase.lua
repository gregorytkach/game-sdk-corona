require('sdk.models.players.PlayerInfoBase')

ManagerPlayersBase = classWithSuper(SerializableObject, 'ManagerPlayersBase')

--
-- Properties
--

function ManagerPlayersBase.needManageMemory(self)
    return false
end

function ManagerPlayersBase.playerCurrent(self)
    return self._playerCurrent
end

--
-- Methods
--

function ManagerPlayersBase.init(self, playerInfoClass)
    SerializableObject.init(self)
    
    assert(playerInfoClass ~= nil)
    
    self._playerInfoClass = playerInfoClass
    
end


function ManagerPlayersBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.player_current ~= nil)
    
    local player = self._playerInfoClass:new()
    player:deserialize(data.player_current)
    self._playerCurrent = player
end
