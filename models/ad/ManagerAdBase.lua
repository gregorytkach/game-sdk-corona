require('sdk.models.ad.ChartboostDelegate')

ManagerAdBase = classWithSuper(Object, 'ManagerAdBase')


--
-- Properties
--

function ManagerAdBase.delegate(self)
    return self._delegate
end

function ManagerAdBase.setCallbackAd(self, value)
    self._callbackAd = value
end

function ManagerAdBase.callbackAd(self)
    return self._callbackAd
end

--
-- Methods
--

function ManagerAdBase.init(self, params)
    assert(params ~= nil)
    --    assert(params.)
    
    
    --todo: move to params
    local appId = nil
    local appSignature = nil
--    if system.getInfo("platformName") == "iPhone OS" then
        -- iPhone Sample App ID
--        appId = "4f21c409cd1cb2fb7000001b"
--        appSignature = "92e2de2fd7070327bdeb54c15a5295309c6fcd2d"
--    else
        -- Android Sample App ID
        appId = "4f7b433509b6025804000002"
        appSignature = "dd2d41b69ac01b80f443f5b6cf06096d457f82bd"
--    end
    
    self._provider = require('vendors.chartboost')
    
    self._delegate = ChartboostDelegate:new()
    
    self._provider.create
    {
        appId           = appId,
        appSignature    = appSignature,
        delegate        = self._delegate,
        appBundle       = "com.chartboost.cbtest"
    }
    
    self._provider.startSession()
    
    self._provider.cacheInterstitial()
end

function ManagerAdBase.showAd(self)
    
    self._provider.showInterstitial()
end

function ManagerAdBase.cleanup(self)
    Object.cleanup(self)
end


