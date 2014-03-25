ChartboostDelegate = classWithSuper(Object, 'ChartboostDelegate')

--
-- Properties
--

--
-- Methods
--

function ChartboostDelegate.init()
end

function ChartboostDelegate.cleanup()
    Object.cleanup()
end

function ChartboostDelegate.shouldRequestInterstitial( location) 
    print("Chartboost: shouldRequestInterstitial " .. location .. "?"); 
    return true 
end

function ChartboostDelegate.shouldDisplayInterstitial( location) print("Chartboost: shouldDisplayInterstitial " .. location .. "?"); 
    return true
end

function  ChartboostDelegate.didCacheInterstitial( location)
    print("Chartboost: didCacheInterstitial " .. location); 
    return
end

function    ChartboostDelegate.didFailToLoadInterstitial( location, error) 
    print("Chartboost: didFailToLoadInterstitial " .. location)
    if error then
        print("    Error: " .. error) 
    end 
end

function   ChartboostDelegate.didDismissInterstitial( location) 
    print("Chartboost: didDismissInterstitial " .. location); 
    
    ChartboostDelegate.tryCallCallback()
    
end

function       ChartboostDelegate.didCloseInterstitial( location) 
    print("Chartboost: didCloseInterstitial " .. location); 
    
    ChartboostDelegate.tryCallCallback()
    
end

function     ChartboostDelegate.didClickInterstitial( location)
    print("Chartboost: didClickInterstitial " .. location); 
    
    ChartboostDelegate.tryCallCallback()
    
end

function  ChartboostDelegate.didShowInterstitial( location) 
    print("Chartboost: didShowInterstitial " .. location);
    return
end
function  ChartboostDelegate.shouldDisplayLoadingViewForMoreApps() 
    return true
end
function      ChartboostDelegate.shouldRequestMoreApps() 
    print("Chartboost: shouldRequestMoreApps");
    return true
end
function      ChartboostDelegate.shouldDisplayMoreApps() 
    print("Chartboost: shouldDisplayMoreApps"); 
    return true
end

function     ChartboostDelegate.didCacheMoreApps( error) 
    print("Chartboost: didCacheMoreApps")
    if error then 
        print("    Error: " .. error) 
    end
end

function    ChartboostDelegate.didFailToLoadMoreApps( error) 
    print("Chartboost: didFailToLoadMoreApps: " .. error);
    return 
end

function    ChartboostDelegate.didDismissMoreApps() 
    print("Chartboost: didDismissMoreApps"); 
    return 
end

function    ChartboostDelegate.didCloseMoreApps() 
    print("Chartboost: didCloseMoreApps");
    return 
end

function    ChartboostDelegate.didClickMoreApps() 
    print("Chartboost: didClickMoreApps");
    return
end

function    ChartboostDelegate.didShowMoreApps() 
    print("Chartboost: didShowMoreApps"); 
    return 
end

function   ChartboostDelegate.shouldRequestInterstitialsInFirstSession() 
    return true
end

function    ChartboostDelegate.didFailToLoadUrl( url, error)
    print("Chartboost:didFailToLoadUrl: " .. tostring(url))
    if error then 
        print("    Error: " .. error) 
    end 
end

function ChartboostDelegate.tryCallCallback()
    local callbackAd = GameInfoBase:instance():managerAd():callbackAd()
    
    if(callbackAd ~= nil)then
        callbackAd()
    end
end


