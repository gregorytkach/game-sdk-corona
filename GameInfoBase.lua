require('sdk.core.Object')
require('sdk.core.SerializableObject')
require('sdk.core.Utils')
require('sdk.core.JSONHelper')

require('sdk.controllers.EControllerUpdateBase')

require('sdk.models.ad.ManagerAdBase')
require("sdk.models.states.ManagerStatesBase")
require("sdk.models.levels.ManagerLevelsBase")
require("sdk.models.purchases.ManagerPurchasesBase")
require("sdk.models.bonus.ManagerBonusBase")
require("sdk.models.bonus.ManagerBonusEnergyBase")
require("sdk.models.players.ManagerPlayersBase")
require("sdk.models.ManagerFontsBase")
require("sdk.models.ManagerParticlesBase")
require("sdk.models.sounds.ManagerSoundsBase")
require("sdk.models.string.ManagerStringBase")
require("sdk.models.ManagerGameBase")
require("sdk.models.ManagerResourcesBase")
require("sdk.models.remote.ManagerRemoteBase")
require("sdk.models.remote.ManagerRemoteStub")
require('sdk.models.cache.ManagerCacheBase')
require('sdk.states.empty.StateEmpty')
require('sdk.states.EStateTypeBase')

GameInfoBase = classWithSuper(Object, 'GameInfoBase') 
--
-- Static fields
--
local _instance

--
--Static methods
--

function GameInfoBase.initGameInfo(class)
    
    assert(class ~= nil)
    
    local isFirstRun = _instance == nil
    
    if(not isFirstRun)then
        print("GameInfoBase:instance() already established.", ELogLevel.ELL_WARNING)
        _instance:cleanup()
        _instance = nil
    else
        display.setStatusBar(display.HiddenStatusBar)
        system.setAccelerometerInterval(10)		-- INCREASE BATTERY LIFE
        system.setGyroscopeInterval    (10)		-- INCREASE BATTERY LIFE
        system.setIdleTimer( false )                    -- DISABLE AUTOMATIC SCREEN DIMMING
        
        GameInfoBase.initSystemInfo()
        GameInfoBase.initAppConstants()
        GameInfoBase.initMargins()
    end
    
    _instance = class:new()
    _instance:onInitComplete()
end


--
-- Properties
--

function GameInfoBase.needManageMemory(self)
    return false
end

function GameInfoBase.managerGame(self)
    return self._managerGame
end

function GameInfoBase.managerResources(self)
    return self._managerResources
end

function GameInfoBase.managerFonts(self)
    return self._managerFonts
end

function GameInfoBase.managerParticles(self)
    return self._managerParticles
end

function GameInfoBase.managerSounds(self)
    return self._managerSounds
end

function GameInfoBase.managerStates(self)
    return self._managerStates
end

function GameInfoBase.managerString(self)
    return self._managerString
end

function GameInfoBase.managerPurchases(self)
    return self._managerPurchases
end

function GameInfoBase.managerBonus(self)
    return self._managerBonus
end

function GameInfoBase.managerBonusEnergy(self)
    return self._managerBonusEnergy
end

function GameInfoBase.managerPlayers(self)
    return self._managerPlayers
end

function GameInfoBase.managerLevels(self)
    return self._managerLevels
end

function GameInfoBase.managerRemote(self)
    return self._managerRemote
end

function GameInfoBase.managerCache(self)
    return self._managerCache
end

function GameInfoBase.managerAd(self)
    return self._managerAd
end

function GameInfoBase:instance(self)
    return _instance
end






--
--Events
--

function GameInfoBase.system(self, event )
    
    print( "System event name and type: " .. event.name, event.type )
    
end

function GameInfoBase.onGameStart(self, value)
    assert(value ~= nil)
    assert(self._managerGame == nil, 'Game already started')
    
    self._managerGame = value
end

function GameInfoBase.onGameEnd(self)
    assert(self._managerGame ~= nil)
    
    self._managerGame:cleanup()
    self._managerGame = nil
end

function GameInfoBase.onGameStartComplete(self, response)
    
end

--
--Methods
--

function GameInfoBase.init(self)
    assert(_instance == nil, "GameInfoBase is Singleton. Please use GameInfoBase.instance instead GameInfoBase.new")
    _instance = self
    
    self:initManagers()
    self:loadFonts()
    self:registerStates()
end

function GameInfoBase.initManagers(self)
    
end

function GameInfoBase.onInitComplete(self)
    if(self._managerRemote ~= nil)then
        self._managerRemote:update(ERemoteUpdateTypeBase.ERUT_GAME_START, nil, 
        function(response) 
            self:onGameStartComplete(response) 
        end)
    else
        self:onGameStartComplete() 
    end
end

function GameInfoBase.registerStates(self)
    self._managerStates:registerState(EStateTypeBase.EST_EMPTY,     "sdk.states.empty.StateEmptyCreator")
end

function GameInfoBase.loadFonts(self)
end

function GameInfoBase.initSystemInfo(self)
    application.device_id = system.getInfo("deviceID")
end

function GameInfoBase.initAppConstants(self)
    --
    --Screen size
    --
    print(string.format("Screen origin\t\t %i:%i", display.screenOriginX, display.screenOriginY))
    
    application.screenWidth         = (display.contentWidth - (display.screenOriginX * 2) ) / display.contentScaleX 
    application.screenHeight        = (display.contentHeight - (display.screenOriginY * 2) ) / display.contentScaleY
    
    print(string.format("Device resolution:\t %i x %i", math.round(application.screenWidth), math.round(application.screenHeight)))
    
    
    --
    --Scale factors
    --
    
    application.scaleFactorX = application.screenWidth / display.contentWidth
    application.scaleFactorY = application.screenHeight / display.contentHeight
    
    print(string.format("Scale factor XY:\t %f:%f", application.scaleFactorX, application.scaleFactorY))
    
    print(string.format("Scale factor\t\t %i:%i", application.scaleFactorX, application.scaleFactorY))
    
    application.scaleFactor = math.max(application.scaleFactorX, application.scaleFactorY)
    
    print(string.format("Device scale factor:\t %f", application.scaleFactor))
    
    local scaleDevice = math.round(application.scaleFactor) 
    
    local delimeterHeight = application.scaleFactorY / application.scaleFactorX
    application.scaleFillHeight = delimeterHeight / scaleDevice
    print(string.format("Scale fill height\t\t %f", application.scaleFillHeight))
    
    local delimeterWidth = application.scaleFactorX / application.scaleFactorY
    application.scaleFillWidth = 1 / (delimeterWidth) --/ scaleDevice)
    print(string.format("Scale fill width\t\t %f", application.scaleFillWidth))
    
    application.scaleMax = 1 / math.min(application.scaleFactorX, application.scaleFactorY)  
    print(string.format("Scale max\t\t %f", application.scaleMax))
    
    application.scaleMin = 1 / math.max(application.scaleFactorX, application.scaleFactorY)
    print(string.format('Scale min\t\t %f', application.scaleMin))
    
    if (scaleDevice > 4) then
        scaleDevice = 4
    elseif (scaleDevice < 1) then
        scaleDevice = 1
    end
    
    application.scaleNone = 1 / scaleDevice
    print(string.format('Scale none\t\t %f', application.scaleNone))
    
    application.scaleSuffix =  string.format("_%ix", scaleDevice)
    
    
    print(string.format("Use image suffix:\t %s", application.scaleSuffix))
    
end

function GameInfoBase.initMargins()
    --display 
    application.margin_top                = display.screenOriginY
    application.margin_bottom             = display.contentHeight - display.screenOriginY
    application.margin_left               = display.screenOriginX
    application.margin_right              = display.contentWidth - display.screenOriginX 
end



function GameInfoBase.cleanup(self)
    if(self._managerGame ~= nil)then
        self._managerGame:cleanup() 
        self._managerGame = nil
    end
    
    if(self._managerResources ~= nil)then
        self._managerResources:cleanup() 
        self._managerResources = nil
    end
    
    if(self._managerFonts ~= nil)then
        self._managerFonts:cleanup() 
        self._managerFonts = nil
    end
    
    if(self._managerParticles ~= nil)then
        self._managerParticles:cleanup() 
        self._managerParticles = nil
    end
    
    if(self._managerSounds ~= nil)then
        self._managerSounds:cleanup() 
        self._managerSounds = nil
    end
    
    if(self._managerStates ~= nil)then
        self._managerStates:cleanup() 
        self._managerStates = nil
    end
    
    if(self._managerString ~= nil)then
        self._managerString:cleanup() 
        self._managerString = nil
    end
    
end
