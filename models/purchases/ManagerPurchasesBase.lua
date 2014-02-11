require('sdk.models.purchases.PurchaseItemBase')
require('sdk.models.purchases.EPurchaseTypeBase')

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

function ManagerPurchasesBase.onTryPurchase(self, purchaseItem)
     assert(purchaseItem ~= nil)
     
     
end

--
-- Methods
--

function ManagerPurchasesBase.init(self)
    
    SerializableObject.init(self)
end


function ManagerPurchasesBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    self._purchases = {}
    
    for i, purchaseData in ipairs(data)do
        
        local purchaseItem = PurchaseItemBase:new()
        purchaseItem:deserialize(purchaseData)
        
        table.insert(self._purchases, purchaseItem)
        
    end
    
end





