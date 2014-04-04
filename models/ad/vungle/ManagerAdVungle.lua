require('sdk.models.ad.ManagerAdBase')
require('sdk.models.ad.vungle.EVungleEvent')


--==================================================================================================
-- 
-- IMPORTANT: You must get your own "app ID" from Vungle (https://v.vungle.com/dashboard/signup).  
-- Further, you must build for device to properly test this sample, because "ads" library is not 
-- supported by the Corona Simulator.
--
--   1. Get your app ID from Vungle
--   2. Modify the code below to use your own app ID 
--   3. Build and deploy on device
--
--==================================================================================================
-- Initial configuration and load Corona 'ads' library
--==================================================================================================

-- the name of the ad provider
-- Corona uses this value to construct the name of the plugin.
-- Corona then asks Lua to load a module with the name "CoronaProvider.ads.[provider]"

-- replace with your own Vungle application ID
ManagerAdVungle = classWithSuper(ManagerAdBase, 'ManagerAdVungle')

--
-- Properties
--


--
--Events
-- 

-- event table includes:
--		event.name		=	'adsRequest'
--		event.provider	=	'vungle'
--		event.type			(string - e.g. 'adStart', 'adView', 'adEnd')
--		event.isError		(boolean)
--		event.response		(string)
function ManagerAdVungle.onEvent(self, event)
    
    
    -- video ad not yet downloaded and available
    if event.type == EVungleEvent.EVE_START then
        --downloading video ad
        if(event.isError)then
            -- wait 5 seconds before retrying to display ad
            timer.performWithDelay(5000, self:showAd())
            -- video ad displayed and then closed
        end
        
    elseif event.type == EVungleEvent.EVE_VIEW then
        --do nothing    
    elseif event.type == EVungleEvent.EVE_END then
        --do nothing    
        self:tryCallCallback()
    else
        print( "Received event:"..event.type, ELogLevel.ELL_WARNING)
    end
end

--
-- Methods
--

function ManagerAdVungle.init(self)
    ManagerAdBase.init(self)
    
    assert(application.vungle_id ~= nil, 'Please init vungle config first')
    
    -- load Corona 'ads' library
    self._provider = require "ads"
    
    self._provider.init( 'vungle', application.vungle_id,
    function( event )
        self:onEvent(event)
    end)
    
end

-- show an ad if one has been downloaded and is available for playback
function ManagerAdVungle.showAd(self, callback)
    self._callback = callback
    
    -- if on simulator, must call callback at once
    if Utils.isSimulator() then
        
        self:tryCallCallback()
        
    else        
        
        --isAnimated (optional)
        --Boolean. This parameter only applies to iOS. If true (default), the video ad will transition in with a slide effect. If false, it will appear instantaneously.
        --
        --isAutoRotation (optional)
        --Boolean. If true (default), the video ad will rotate automatically with the device's orientation. If false, it will use the ad's preferred orientation.
        --
        --isBackButtonEnabled (optional)
        --Boolean. This parameter only applies to Android. If true, the Android back button will stop playback of the video ad and display the post-roll. If false (default), the back button will be disabled during playback. Note that the back button is always enabled in the post-roll — when pressed, it exits the ad and returns to the application.
        --
        --isSoundEnabled (optional)
        --Boolean. If true (default), sound will be enabled during video ad playback, subject to the device's sound settings. If false, video playback will begin muted. Note that the user can mute or un-mute sound during playback.
        --
        --username (optional)
        --String. This parameter only applies to the "incentivized" ad unit type. When specified, it represents the user identifier that you wish to receive in a server-to-server callback that rewards the user for a completed video ad view.
        --
        --isCloseShown (optional)
        --Boolean. This parameter only applies to the "incentivized" ad unit type. If true (default), a close button will appear after 4 seconds, allowing the user to skip the video ad. If false, the close button will not appear, thus forcing the user to watch the entire ad. Note that the close button can be hidden for all ad types via the Vungle Dashboard.
        
        local params = 
        {
            isBackButtonEnabled = false
        }
        
        self._provider.show( "interstitial", params )
        
    end
end

function ManagerAdVungle.cleanup(self)
    ManagerAdBase.cleanup(self)
end