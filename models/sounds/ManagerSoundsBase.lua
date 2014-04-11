require('sdk.models.sounds.ESoundTypeBase')

ManagerSoundsBase = classWithSuper(Object, 'ManagerSounds')

--
--Events
--

function ManagerSoundsBase.needManageMemory(self)
    return false
end


function ManagerSoundsBase.system(self, event )
    
    if (event.type == "applicationResume") then
        
        if(application.music and self._musicHandle ~= nil)then
            audio.resume(self._musicHandle)
        end
        
    end
    
end

function ManagerSoundsBase.onStateChanged(self, stateType)
    if(self._prevStateType == stateType)then
        return
    end
    
    self._prevStateType = stateType
    
    self:stopMusic()
    
    self:unloadSounds()
    
    self:loadSounds(stateType)
    
    if(application.music)then
        self:playMusic(stateType)
    end
end

--
--Methods
--

function ManagerSoundsBase.init(self)
    Runtime:addEventListener( ERuntimeEvent.ERE_SYSTEM, self )
    
    self._audioHandlers = {}
end

function ManagerSoundsBase.getMusicForState(self, stateType)
    return nil
end


function ManagerSoundsBase.unloadSounds(self)
    
    for i, audioHandle in pairs(self._audioHandlers) do
        
        audio.dispose(audioHandle)
        self._audioHandlers[i] = nil
        
    end
    
end

function ManagerSoundsBase.loadSounds(self, stateType)
    
end


function ManagerSoundsBase.playMusic(self, stateType)
    
    if(stateType == nil)then
        local currentState = GameInfoBase:instance():managerStates():currentState()
        
        if(currentState ~= nil)then
            stateType = currentState:getType()
        end
        
    end
    
    if(stateType ~= nil)then
        
        local audioName = self:getMusicForState(stateType)
        
        local musicHandle = audio.loadStream(audioName)
        
        local playMusicParams = 
        {
            channel =   musicHandle,
            loops   =   -1,
            fadein  =   application.animation_duration
        }
        
        audio.play(musicHandle, playMusicParams)
        
        local paramsVolume = 
        { 
            channel = musicHandle  
        }
        
        local volume = 0.1
        
        print(audio.setVolume(volume, paramsVolume))
        print(audio.setMinVolume(volume, paramsVolume))
        print(audio.setMaxVolume(volume, paramsVolume))
        
       
        self._audioHandlers[ESoundTypeBase.ESTB_MUSIC] = musicHandle
    end
end



function ManagerSoundsBase.stopMusic(self)
    
    local musicHandle = self._audioHandlers[ESoundTypeBase.ESTB_MUSIC]
    
    if(musicHandle ~= nil)then
        self._audioHandlers[ESoundTypeBase.ESTB_MUSIC] = nil
        
        local stopMusicParams =
        {
            channel = musicHandle,
            time    = application.animation_duration
        }
        
        audio.fadeOut(stopMusicParams)
        
        timer.performWithDelay(application.animation_duration, 
        function() 
            audio.dispose(musicHandle)
        end)
    end
end

--
--Resources
--

function ManagerSoundsBase.getSound(self, soundType)
    local result
    
    result = self._audioHandlers[soundType]
    
    if(result == nil)then
        print('Not found audio handler for '..tostring(soundType), ELogLevel.ELL_WARNING)
    end
    
    return result
end