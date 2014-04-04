ManagerAdChartboost = classWithSuper(ManagerAdBase, 'ManagerAdChartboost')

--
-- Properties
--

--
-- Events
--




function ManagerAdChartboost.shouldRequestInterstitial(self, location) 
    print("Chartboost: shouldRequestInterstitial " .. location .. "?"); 
    return true 
end

function ManagerAdChartboost.shouldDisplayInterstitial(self, location) 
    print("Chartboost: shouldDisplayInterstitial " .. location .. "?"); 
    return true
end

function  ManagerAdChartboost.didCacheInterstitial(self, location)
    print("Chartboost: didCacheInterstitial " .. location); 
    return
end

function    ManagerAdChartboost.didFailToLoadInterstitial(self, location, error) 
    print("Chartboost: didFailToLoadInterstitial " .. location)
    if error then
        print("    Error: " .. error) 
    end 
end

function ManagerAdChartboost.didDismissInterstitial(self, location) 
    print("Chartboost: didDismissInterstitial " .. location); 
    
    self:tryCallCallback()
end

function ManagerAdChartboost.didCloseInterstitial(self, location) 
    print("Chartboost: didCloseInterstitial " .. location); 
    
    self:tryCallCallback()
end

function ManagerAdChartboost.didClickInterstitial(self, location)
    print("Chartboost: didClickInterstitial " .. location); 
    
    self:tryCallCallback()
    
end

function  ManagerAdChartboost.didShowInterstitial(self, location) 
    print("Chartboost: didShowInterstitial " .. location);
    return
end

function  ManagerAdChartboost.shouldDisplayLoadingViewForMoreApps(self) 
    return true
end

function      ManagerAdChartboost.shouldRequestMoreApps(self) 
    print("Chartboost: shouldRequestMoreApps");
    return true
end
function      ManagerAdChartboost.shouldDisplayMoreApps(self) 
    print("Chartboost: shouldDisplayMoreApps"); 
    return true
end

function     ManagerAdChartboost.didCacheMoreApps(self, error) 
    print("Chartboost: didCacheMoreApps")
    if error then 
        print("    Error: " .. error, ELogLevel.ELL_WARNING) 
    end
end

function    ManagerAdChartboost.didFailToLoadMoreApps(self, error) 
    print("Chartboost: didFailToLoadMoreApps: " .. error);
    return 
end

function    ManagerAdChartboost.didDismissMoreApps(self) 
    print("Chartboost: didDismissMoreApps"); 
    return 
end

function    ManagerAdChartboost.didCloseMoreApps(self) 
    print("Chartboost: didCloseMoreApps");
    return 
end

function    ManagerAdChartboost.didClickMoreApps(self) 
    print("Chartboost: didClickMoreApps");
    return
end

function    ManagerAdChartboost.didShowMoreApps(self) 
    print("Chartboost: didShowMoreApps"); 
    return 
end

function   ManagerAdChartboost.shouldRequestInterstitialsInFirstSession(self) 
    return true
end

function    ManagerAdChartboost.didFailToLoadUrl(self, url, error)
    print("Chartboost:didFailToLoadUrl: " .. tostring(url))
    if error then 
        print("    Error: " .. error) 
    end 
end



--
-- Methods
--

function ManagerAdChartboost.init(self)
    ManagerAdBase.init(self)
    
    assert(application.chartboost_id        ~= nil, 'Please establish chartboost config')
    assert(application.chartboost_signature ~= nil, 'Please establish chartboost config')
    assert(application.chartboost_bundle    ~= nil, 'Please establish chartboost config')
    
    self._provider = require('vendors.chartboost')
    
    self._provider.create
    {
        appId           = application.chartboost_id,
        appSignature    = application.chartboost_signature,
        appBundle       = application.chartboost_bundle,
        delegate        = 
        {
            shouldRequestInterstitial = 
            function(location) 
                return self:shouldRequestInterstitial(location)
            end, 
            shouldDisplayInterstitial =
            function (location) 
                return self:shouldDisplayInterstitial(location)
            end,
            didCacheInterstitial =
            function(location) 
                return self:didCacheInterstitial(location)
            end,
            didFailToLoadInterstitial =
            function(location, error)
                return self:didFailToLoadInterstitial(location, error)
            end,
            didDismissInterstitial =
            function(location) 
                return self:didDismissInterstitial(location)
            end,
            didCloseInterstitial =
            function(location) 
                return self:didCloseInterstitial(location)
            end,
            didClickInterstitial =
            function(location)
                return self:didClickInterstitial(location)
            end,
            didShowInterstitial =
            function(location)
                return self:didShowInterstitial(location)
            end,
            shouldDisplayLoadingViewForMoreApps =
            function() 
                return self:shouldDisplayLoadingViewForMoreApps()
            end,
            shouldRequestMoreApps =
            function()
                return self:shouldRequestMoreApps()
            end ,
            shouldDisplayMoreApps =
            function()
                return self:shouldDisplayMoreApps()
            end ,
            didCacheMoreApps =
            function(error) 
                return self:didCacheMoreApps(error)
            end,
            didFailToLoadMoreApps =
            function(location)
                return self:didFailToLoadMoreApps()
            end ,
            didDismissMoreApps=
            function(location)
                return self:didDismissMoreApps()
            end ,
            didCloseMoreApps =
            function(location)
                return self:didCloseMoreApps()
            end ,
            didClickMoreApps =
            function(location)
                return self:didClickMoreApps()
            end ,
            didShowMoreApps =
            function(location)
                return self:didShowMoreApps()
            end,
            shouldRequestInterstitialsInFirstSession =
            function(location) 
                return self:shouldRequestInterstitialsInFirstSession()
            end,
            didFailToLoadUrl =
            function(url, error)
                return self:didFailToLoadUrl(url, error)
            end
        }
    }
    
    self._provider.startSession()
    
    self._provider.cacheInterstitial()
end

function ManagerAdChartboost.showAd(self, callback)
    self._callback = callback
    
    self._provider.showInterstitial()
end

function ManagerAdChartboost.cleanup(self)
    ManagerAdBase.cleanup(self)
end



