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

--function ManagerSoundsBase.onStateChanged(self, stateType)
--    
--end

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

function ManagerSoundsBase.playMusic(self, stateType)
    
    local audioName = self:getMusicForState(stateType)
    
    local musicHandle = audio.loadStream(audioName)
    
    local playMusicParams = 
    {
        channel =   musicHandle,
        loops   =   -1,
        fadein  =   application.animation_duration
    }
    
    audio.play(musicHandle, playMusicParams)
    
    local a = audio.setVolume(1, 
    { 
        channel = musicHandle  
    })
    
    audio.setMinVolume(1, 
    { 
        channel = musicHandle  
    })
    
    self._audioHandlers[ESoundTypeBase.ESTB_MUSIC] = musicHandle
end


function ManagerSoundsBase.stopMusic(self, soundName)
    
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
    
    assert(result ~= nil, 'Not found audio handler for '..soundType)
    
    return result
end