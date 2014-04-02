require('sdk.states.base.StateBase')

ManagerStatesBase = classWithSuper(Object, 'ManagerStatesBase') 

--
--Properties
--
function ManagerStatesBase.needManageMemory(self)
    return false
end

function ManagerStatesBase.currentState(self)
    return self._currentState
end

function ManagerStatesBase.gestureProvider(self)
    return self._gestureProvider
end

function ManagerStatesBase.easingProvider(self)
    return self._easingProvider
end

--
--Methods
--    

--Default constructor
function ManagerStatesBase.init(self)
    --    fields
    self._storyboard        = require( "storyboard" )
    self._easingProvider    = require("vendors.lib_easing")
    
    if(application.enableGesture)then
        self._gestureProvider   = require("vendors.lib_gesture")
    end
    
    self._registeredStates  = {}
    
    display.setStatusBar(display.HiddenStatusBar)
end

function ManagerStatesBase.onStateGone(self)
    local needCleanupPrevState = self:currentState() ~= nil
    local prevStateType  = ''
    
    if(needCleanupPrevState)then
        prevStateType = self:currentState():getType() 
    end
    
    GameInfoBase:instance():managerSounds():onStateChanged(self._nextStateType)
    
    self._storyboard.gotoScene(self:_getStatePath(self._nextStateType), application.stateChangeEffect, application.stateChangeTime)
    
    if(needCleanupPrevState) then
        if( prevStateType == self._nextStateType)then
            print(string.format('set state %s after same', prevStateType), ELogLevel.ELL_WARNING)
        end
        
        local prevStateName = self:_getStatePath(prevStateType)
        
        self._storyboard.removeScene(prevStateName)
        self._storyboard.purgeScene(prevStateName)
    end
end

function ManagerStatesBase.setState(self, stateType)
    
    self._nextStateType = stateType
    
    if(self:currentState() ~= nil)then
        self:currentState():prepareToExit()
    else
        self:onStateGone()
    end
end

function ManagerStatesBase.registerState(self, typeName, statePath)
    assert(typeName     ~= nil)
    assert(statePath    ~= nil)
    
    assert(self._registeredStates[typeName] == nil, "States already registered")
    
    self._registeredStates[typeName] = statePath
end


function ManagerStatesBase._getStatePath(self, typeName)
    local result = self._registeredStates[typeName]
    
    assert(result ~= nil, 'Not found state type for type: '..typeName)
    
    return result
end

--Please do not use this method manually
function ManagerStatesBase.onCurrentStateCreated(self, value)
    assert(value ~= nil)
    
    self.reportMemory();
    collectgarbage()
    
    self._currentState = value
end

function ManagerStatesBase.reportMemory(self)
    
    local memory = collectgarbage("count") / 1024
    local memoryTextures = system.getInfo( "textureMemoryUsed" ) / (1024 * 1024)
    
    print(string.format("Memory Usage: \t\t %i \t MB", memory))
    print( string.format("Texture Memory: \t %i \t MB", memoryTextures))
end


function ManagerStatesBase.cleanup(self)
    
    self._storyboard.removeAll() 
    self._storyboard.purgeAll()
    
    Object.cleanup(self)
end

