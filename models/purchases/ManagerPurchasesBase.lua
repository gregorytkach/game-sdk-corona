require('sdk.models.purchases.PurchaseItemBase')
require('sdk.models.purchases.EPurchaseTypeBase')
require('sdk.models.purchases.EPurchaseState')

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
    
    print('can pay by hard: '..tostring(self._canPayByHard))
    
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
        
        print(purchaseItem:name())
        
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
    
    print('purchases loaded')
    
    local products = event.products
    
    for _, purchase in ipairs(products) do
        print(purchase.title)              -- This is a string.
        print(purchase.description)        -- This is a string.
        print(purchase.price)              -- This is a number.
        print(purchase.localizedPrice)     -- This is a string.
        print(purchase.productIdentifier)  -- This is a string.
        
        print('Found purchase info: '..tostring(purchase.productIdentifier))
        
        for _, purchaseItem in ipairs(self._purchases)do
            purchaseItem:setPriceHard(tonumber(purchase.localizedPrice))
        end
    end
    
    if(#event.invalidProducts > 0)then
        for _, purchase in ipairs(#event.invalidProducts) do
            print('Invalid purchase: '..tostring(purchase.productIdentifier), ELogLevel.ELL_WARNING)
        end  
    end
    
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
    
    print('state'..tostring(tstate))
    print("receipt"..tostring(transaction.receipt))
    print("transactionIdentifier"..tostring(transaction.identifier))
    print("date"..tostring(transaction.date))
    
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
    if self._store.availableStores.google and tstate == EPurchaseState.EPS_PURCHASED then
        local timeStamp = UtilsTime.makeTimeStamp(transaction.date, "ctime")
        if timeStamp + 360 < os.time() then  -- if the time stamp is older than 5 minutes, we will assume a restore.
            print("map this purchase to a restore")
            
            tstate = EPurchaseState.EPS_RESTORED
            print("I think tstate is "..tostring(tstate))
            --            restoring = false
        end
    end
    
    if tstate == EPurchaseState.EPS_PURCHASED then
        print("Transaction succuessful!")
        native.showAlert("Thank you!", "Your support is greatly appreciated!", 
        {
            "Okay"
        })
        
    elseif  tstate == EPurchaseState.EPS_RESTORED then
        print("Transaction restored (from previous session)")
        
    elseif tstate == EPurchaseState.EPS_REFUNDED then
        print("User requested a refund -- locking app back")
        
    elseif tstate == EPurchaseState.EPS_REVOKED then --Amazon feature
        print ("The user who has a revoked purchase is "..tostring(transaction.userId))
        --Revoke this SKU here:
        
    elseif tstate == EPurchaseState.EPS_CANCELLED then
        print("User cancelled transaction")
    elseif tstate == EPurchaseState.EPS_FAILED then
        print("Transaction failed, type: ".. tostring(transaction.errorType)..' '..tostring(transaction.errorString))
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

--
-- Methods
--

function ManagerPurchasesBase.init(self)
    
    SerializableObject.init(self)
    
    self._store = require( "store" )
    
    self:updateHardPaymentsState()
    
    Runtime:addEventListener(ERuntimeEvent.ERE_SYSTEM, 
    function(event)
        self:onRuntimeEvent(event) 
    end)
    
    
    
    
    self._callbacks = {}
    
    self:updateHardPaymentsState()
    --    self._store.availableStores     — used to see if a store is valid for your device.
    --    self._store.canLoadProducts     — check to see if loading products is allowed, which it’s not for Google Play.
    --    self._store.canMakePurchases    — parents can turn off purchasing for their kids.
    --    self._store.finishTransaction() — very important call, used in your event listener function.
    --    self._store.isActive            — a way to confirm the store was initialized properly.
    --    self._store.loadProducts()      — a function to return information about products, including localized descriptions, names, and prices. This is not supported on Google.
    --    self._store.target              — returns the value of the store selected in the build screen.
end

function ManagerPurchasesBase.updateHardPaymentsState(self)
    self._canPayByHard = self._store.canMakePurchases and self._store.isActive
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
    
    timer.performWithDelay( 1000,
    function()
        local storeInitialized = false
        
        if(self._store.availableStores.apple)then
            self:initStoreApple()
            storeInitialized = true
        elseif(self._store.availableStores.google)then
            self:initStoreGoogle()
            storeInitialized = true
        end
        
        if(storeInitialized)then
            self:updateHardPaymentsState()
            self:loadPurhcases(purchasesIDs)
        end
    end)
    
    
end

function ManagerPurchasesBase.initStoreApple(self)
    print('init apple store')
    
    self._store.init( "apple", 
    
    function(event)
        self:onTransactionEvent(event)
    end) 
    
end

function ManagerPurchasesBase.initStoreGoogle(self)
    print('init google store')
    
    self._store.init( "google", 
    function(event)         
        self:onTransactionEvent(event)                
    end)
    
end

function ManagerPurchasesBase.loadPurhcases(self, purchasesIDs)
    if(self._canPayByHard)then
        print('try load purchases. Purchases count: '..table.getn(purchasesIDs))
        self._store.loadProducts(purchasesIDs, 
        function(event)
            self:onPurchasesLoaded(event)
        end)
    end
end


