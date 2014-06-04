require('sdk.models.purchases.PurchaseItemBase')
require('sdk.models.purchases.EPurchaseTypeBase')
require('sdk.models.purchases.EPurchaseState')
require('sdk.models.purchases.EStoreType')

ManagerPurchasesBase = classWithSuper(SerializableObject, 'ManagerPurchasesBase')

--
-- Properties
--

function ManagerPurchasesBase.needManageMemory(self)
    return false
end

function ManagerPurchasesBase.purchases(self)
    return self._purchases
end

-- 
-- Events
--

function ManagerPurchasesBase.onTryPurchase(self, purchaseItem, onComplete, onError)
    assert(purchaseItem ~= nil)
    
    local playerCurrent = GameInfo:instance():managerPlayers():playerCurrent()
    
    print('can pay by hard: '..tostring(self._canPayByHard), ELogLevel.ELL_PURCHASES)
    
    if(playerCurrent:currencySoft() >= purchaseItem:priceSoft() and purchaseItem:priceSoft() > 0)then
        print(1)
        
        playerCurrent:setCurrencySoft(playerCurrent:currencySoft() - purchaseItem:priceSoft())
        
        if(onComplete ~= nil)then
            onComplete()
        end
        
    elseif(self._canPayByHard and purchaseItem:priceHard() > 0)then
        --try buy by hard currency
        
        assert(self._callbacks[purchaseItem:name()] == nil, 'Previous purchase not handled')
        
        self._callbacks[purchaseItem:name()] =
        {
            on_complete = onComplete,
            on_error    = onError
        }
        
        print(purchaseItem:name(), ELogLevel.ELL_PURCHASES)
        
        self._store.purchase({purchaseItem:name()})
        
    elseif(onError ~= nil)then
        onError()
    end
end

function ManagerPurchasesBase.onRuntimeEvent(self, event)
    if (event.type == ERuntimeSystemEvent.ERES_APP_RESUME) then
        self:updateHardPaymentsState()
    end
end


function ManagerPurchasesBase.onPurchasesLoaded(self, event)
    if event.isError then
        print(event.errorType)
        print(event.errorString)
        
        return
    end
    
    local products = event.products
    
    print('loaded '..tostring(#products)..'purchases')
    
    for _, purchase in ipairs(products) do
        print(purchase.title,               ELogLevel.ELL_PURCHASES)                -- This is a string.
        print(purchase.description,         ELogLevel.ELL_PURCHASES)                -- This is a string.
        print(purchase.price,               ELogLevel.ELL_PURCHASES)                -- This is a number.
        print(purchase.localizedPrice,      ELogLevel.ELL_PURCHASES)                -- This is a string.
        print(purchase.productIdentifier,   ELogLevel.ELL_PURCHASES)                -- This is a string.
        
        print('Found purchase info: '..tostring(purchase.productIdentifier))
        
        for _, purchaseItem in ipairs(self._purchases)do
            purchaseItem:setPriceHard(tonumber(purchase.localizedPrice))
        end
    end
    
    print('invalid purchases count: '..tostring(#event.invalidProducts), ELogLevel.ELL_WARNING)
    
    print('Invalid purchases:')
    if(#event.invalidProducts > 0)then
        for _, purchase in ipairs(event.invalidProducts) do
            print(purchase, ELogLevel.ELL_WARNING)
        end  
    end
    
    self._productsLoaded = #products > 0
end

function ManagerPurchasesBase.onTransactionEvent(self, event)
    if(event == nil)then
        print("Purchase can't be completed -> transaction event is nil", ELogLevel.ELL_ERROR)
        return
    end
    
    print("onTransactionEvent")
    
    --    print(event)
    
    local transaction   = event.transaction
    local tstate        = event.transaction.state
    
    print('state '..tostring(tstate), ELogLevel.ELL_PURCHASES)
    print("receipt "..tostring(transaction.receipt), ELogLevel.ELL_PURCHASES)
    print("transactionIdentifier "..tostring(transaction.identifier), ELogLevel.ELL_PURCHASES)
    print("date "..tostring(transaction.date), ELogLevel.ELL_PURCHASES)
    
    local callbacks     = self._callbacks[transaction.productIdentifier]
    
    self._callbacks[transaction.productIdentifier] = nil
    
    local onComplete    = callbacks.on_complete
    local onError       = callbacks.on_error
    
    --Google does not return a "restored" state when you call store.restore()
    --You're only going to get "purchased" with Google. This is a work around
    --to the problem.
    --
    --The assumption here is that any real purchase should happen reasonably
    --quick while restores will have a transaction date sometime in the past.
    --5 minutes seems sufficient to separate a purchase from a restore.
    if self._targetStore == EStoreType.EST_GOOGLE and tstate == EPurchaseState.EPS_PURCHASED then
        local timeStamp = UtilsTime.makeTimeStamp(transaction.date, "ctime")
        if timeStamp + 360 < os.time() then  -- if the time stamp is older than 5 minutes, we will assume a restore.
            print("map this purchase to a restore", ELogLevel.ELL_PURCHASES)
            
            tstate = EPurchaseState.EPS_RESTORED
            print("I think tstate is "..tostring(tstate), ELogLevel.ELL_PURCHASES)
            --            restoring = false
        end
    end
    
    if tstate == EPurchaseState.EPS_PURCHASED or tstate == EPurchaseState.EPS_CONSUMED then
        print("Transaction succuessful!", ELogLevel.ELL_PURCHASES)
        native.showAlert("Thank you!", "Your support is greatly appreciated!", 
        {
            "Okay"
        })
    elseif  tstate == EPurchaseState.EPS_RESTORED then
        print("Transaction restored (from previous session)", ELogLevel.ELL_PURCHASES)
        
    elseif tstate == EPurchaseState.EPS_REFUNDED then
        print("User requested a refund -- locking app back", ELogLevel.ELL_PURCHASES)
        
    elseif tstate == EPurchaseState.EPS_REVOKED then --Amazon feature
        print ("The user who has a revoked purchase is "..tostring(transaction.userId), ELogLevel.ELL_PURCHASES)
        --Revoke this SKU here:
        
    elseif tstate == EPurchaseState.EPS_CANCELLED then
        print("User cancelled transaction", ELogLevel.ELL_PURCHASES)
    elseif tstate == EPurchaseState.EPS_FAILED then
        print("Transaction failed, type: ".. tostring(transaction.errorType)..' '..tostring(transaction.errorString), ELogLevel.ELL_PURCHASES)
    else
        assert(false, "unknown purchase event: "..tostring(tstate))
    end
    
    if(tstate ~= EPurchaseState.EPS_REVOKED)then
        self._store.finishTransaction( transaction )
    end
    
    if(tstate == EPurchaseState.EPS_PURCHASED or tstate == EPurchaseState.EPS_RESTORED)then
        if(onComplete ~= nil)then
            onComplete()
        end
    else
        if(onError ~= nil)then
            onError()
        end
    end
end

function ManagerPurchasesBase.onLicenseChecked(event)
    --Prints the name of this event, "licensing".
    print('event.name: '..tostring(event.name), ELogLevel.ELL_PURCHASES)
    --Prints the name of the provider for this licensing instance, "google"
    print('event.provider: '..tostring(event.provider), ELogLevel.ELL_PURCHASES)
    --Prints true if it has been verified else it prints false.
    print('event.isVerified: '..tostring(event.isVerified), ELogLevel.ELL_PURCHASES)
    --Prints true if there was an error during verification else it will return nil.  Errors can be anything from configuration errors to network errors.
    print('event.isError: '..tostring(event.isError), ELogLevel.ELL_PURCHASES)
    --Prints the type of error, "configuration" or "network".  If there was no error then this will return nil.
    print('event.errorType: '..tostring(event.errorType), ELogLevel.ELL_PURCHASES)
    --Prints a translated response from the licensing server.
    print('event.response: '..tostring(event.response), ELogLevel.ELL_PURCHASES)
    --Prints the expiration time of the expiration time of the cached license.
    print('event.expiration: '..tostring(event.expiration), ELogLevel.ELL_PURCHASES)
    
    if not event.isVerified then
        --failed verify app from the play store, we print a message
        print( "Application not licensed. Now quit.", ELogLevel.ELL_ERROR)
        native.requestExit()  --assuming this is how we handle pirates
    end
end

--
-- Methods
--

--    self._store.availableStores     — used to see if a store is valid for your device.
--    self._store.canLoadProducts     — check to see if loading products is allowed, which it’s not for Google Play.
--    self._store.canMakePurchases    — parents can turn off purchasing for their kids.
--    self._store.finishTransaction() — very important call, used in your event listener function.
--    self._store.isActive            — a way to confirm the store was initialized properly.
--    self._store.loadProducts()      — a function to return information about products, including localized descriptions, names, and prices. This is not supported on Google.
--    self._store.target              — returns the value of the store selected in the build screen.
function ManagerPurchasesBase.init(self)
    
    SerializableObject.init(self)
    
    self._productsLoaded    = false
    self._callbacks         = {}
    
    self._store             = require( "store" )
    
    self._targetStore       = self._store.target
    print('Target store is: '..tostring(self._targetStore), ELogLevel.ELL_PURCHASES)
    
    if (self._store.availableStores ~= nil)then
        print('available stores is:')
        for key, value in pairs(self._store.availableStores)do
            print('available store is:'..tostring(key)..' '..tostring(value), ELogLevel.ELL_PURCHASES)
        end
    end
    
    -- Property "canLoadProducts" indicates that localized product information such as name and price
    -- can be retrieved from the store (such as iTunes). Fetch all product info here asynchronously.
    print('can load products: '..tostring(self._store.canLoadProducts), ELogLevel.ELL_PURCHASES)
    print('can make purchases: '..tostring(self._store.canMakePurchases), ELogLevel.ELL_PURCHASES)
    print('is active: '..tostring(self._store.isActive), ELogLevel.ELL_PURCHASES)
    
    
    
    if self._targetStore == EStoreType.EST_GOOGLE then
        self._store = require("plugin.google.iap.v3")
        self._store['purchase'] = self._store['consumePurchase']
    end
    
    self:updateHardPaymentsState()
    
    Runtime:addEventListener(ERuntimeEvent.ERE_SYSTEM, 
    function(event)
        self:onRuntimeEvent(event) 
    end)
    
    self:tryCheckLicense()
end

function ManagerPurchasesBase.tryCheckLicense(self)
    if((self._targetStore ~= EStoreType.EST_GOOGLE) or (not application.check_license))then
        return 
    end
    
    local licensing = require("licensing")
    licensing.init("google")
    
    licensing.verify(
    function(event)
        self:onLicenseChecked(event)
    end)
    
end

function ManagerPurchasesBase.updateHardPaymentsState(self)
    self._canPayByHard = self._store.canMakePurchases and self._store.isActive
    print('can pay by hard: '..tostring(self._canPayByHard), ELogLevel.ELL_PURCHASES)
end

function ManagerPurchasesBase.getPurchases(self, type)
    local result = {}
    
    for _, purchase in ipairs(self._purchases)do
        if(purchase:type() == type)then
            table.insert(result, purchase)
        end
    end
    
    return result
end

function ManagerPurchasesBase.getPurchaseFirst(self, type)
    local result = nil
    
    for _, purchase in ipairs(self._purchases)do
        if(purchase:type() == type)then
            result = purchase
            break
        end
    end
    
    assert(result ~= nil, 'Not found purchase with type: '..tostring(type))
    
    return result
end

function ManagerPurchasesBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    self._purchases = {}
    
    local purchasesIDs = {}
    
    for i, purchaseData in ipairs(data)do
        
        local purchaseItem = PurchaseItemBase:new()
        purchaseItem:deserialize(purchaseData)
        
        table.insert(self._purchases, purchaseItem)
        
        if(purchaseItem:canPaymentInHard())then
            table.insert(purchasesIDs, purchaseItem:name())
        end
    end
    
    if(#self._purchases > 0)then
        UtilsArray.sortQuick(self._purchases, "_contentCount")
    end
    
    self:initStores(purchasesIDs)
end

function ManagerPurchasesBase.initStores(self, purchasesIDs)
    
    local storeInitialized = false
    
    if(self._targetStore == EStoreType.EST_APPLE)then
        self:initStoreApple()
        storeInitialized = true
    elseif(self._targetStore == EStoreType.EST_GOOGLE)then
        self:initStoreGoogle()
        storeInitialized = true
    end
    
    timer.performWithDelay( 1000,
    function()
        if(storeInitialized)then
            self:updateHardPaymentsState()
            
            timer.performWithDelay( 1000, function() self:tryLoadPurchases(purchasesIDs) end)
        end
    end)
end

function ManagerPurchasesBase.initStoreApple(self)
    print('init apple store', ELogLevel.ELL_PURCHASES)
    
    self._store.init( "apple", 
    
    function(event)
        self:onTransactionEvent(event)
    end) 
    
end

function ManagerPurchasesBase.initStoreGoogle(self)
    print('init google store', ELogLevel.ELL_PURCHASES)
    
    self._store.init("google", 
    function(event)         
        self:onTransactionEvent(event) 
    end)
    
end

function ManagerPurchasesBase.tryLoadPurchases(self, purchasesIDs)
    
    if(self._productsLoaded or self._productsLoadingInProgress or not self._canPayByHard)then
        return
    end
    
    self._productsLoadingInProgress = true
    
    print('try load purchases. Purchases count: '..table.getn(purchasesIDs), ELogLevel.ELL_PURCHASES)
    
    if(self._store.canLoadProducts)then
        self._store.loadProducts(purchasesIDs, 
        function(event)
            self._productsLoadingInProgress  = false
            
            self:onPurchasesLoaded(event)
        end)
    else
        self._productsLoadingInProgress  = false
        
        self._productsLoaded = true
    end
end


