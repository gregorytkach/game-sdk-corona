ManagerGameBase = classWithSuper(Object, 'ManagerGameBase')

--
--Properties
--

function ManagerGameBase.isPlayerWin(self)
    return self._isPlayerWin
end

function ManagerGameBase.bonusesCollected(self)
    return self._bonusesCollected
end

function ManagerGameBase.scores(self)
    return self._scores
end

function ManagerGameBase.isGameEnded(self)
    return self._gameEnded
end

function ManagerGameBase.setScores(self, value)
    
    if(self._scores ~= value)then
        
        self._scores = value
        
        if(self._currentState  ~= nil)then
            self._currentState:update(EControllerUpdateBase.ECUT_GAME_SCORES)
        end
    end
    
end

function ManagerGameBase.currentLevel(self)
    return self._currentLevel
end

--
--Events
--

function ManagerGameBase.onGameStart(self)
    
end


function ManagerGameBase.onGameEnd(self)
    assert(not self._gameEnded, "game already ended")
    
    self._gameEnded = true
    
    self._currentState:update(EControllerUpdateBase.ECUT_GAME_FINISHED)
end

function ManagerGameBase.onPlayerWin(self)
    self._isPlayerWin = true
    
    local playerCurrent = GameInfo:instance():managerPlayers():playerCurrent()
    
    playerCurrent:setCurrencySoft(playerCurrent:currencySoft() + self._currentLevel:rewardCurrencySoft())
    
    --todo: reimplement
    self._currentLevel:progress()._isComplete = true
    
    self:onGameEnd()
    
end

function ManagerGameBase.onPlayerLose(self)
    self._isPlayerWin = false
    
    self:onGameEnd()
end


--
--Methods
--

function ManagerGameBase.init(self, params)
    if(params ~= nil)then
        assert(params.currentLevel ~= nil)
        
        self._currentLevel = params.currentLevel
    end
    
    self._scores            = 0
    self._bonusesCollected  = 0
    self._gameEnded         = false
    
end

function ManagerGameBase.cleanup(self)
    Object.cleanup(self)
end

function ManagerGameBase.registerCurrentState(self, currentState)
    assert(self._currentState == nil, "State already registered")
    
    self._currentState = currentState
end
