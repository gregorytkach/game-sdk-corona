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
    
    for i, purchaseData in ipairs(data)do
        
        local purchaseItem = PurchaseItemBase:new()
        purchaseItem:deserialize(purchaseData)
        
        table.insert(self._purchases, purchaseItem)
        
    end
    
end





