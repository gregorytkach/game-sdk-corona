PurchaseItemBase = classWithSuper(SerializableObject, 'PurchaseItemBase')

--
-- Properties
--

function PurchaseItemBase.needManageMemory(self)
    return false
end

function PurchaseItemBase.type(self)
    return self._type
end

function PurchaseItemBase.contentCount(self)
    return self._contentCount
end

function PurchaseItemBase.priceSoft(self)
    return self._priceSoft
end

function PurchaseItemBase.priceHard(self)
    return self._priceHard
end

--need for set localized price
function PurchaseItemBase.setPriceHard(self, value)
    if(self._priceHard == value)then
        return
    end
    
    self._priceHard = value
end

function PurchaseItemBase.name(self)
    return self._name
end

function PurchaseItemBase.canPaymentInSoft(self)
    local result = false
    
    if(self._priceSoft > 0)then
        
        result = GameInfoBase:instance():managerPlayers():currentPlayer():currencySoft() > self._priceSoft
        
    end
    
    return result
end

--
-- Methods
--

function PurchaseItemBase.init(self)
    SerializableObject.init(self)
    
end

function PurchaseItemBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    self._contentCount  = tonumber(assertProperty(data, "content_count"))
    self._priceSoft     = tonumber(assertProperty(data, "price_soft"))
    self._priceHard     = tonumber(assertProperty(data, "price_hard"))
    
    self._name          = assertProperty(data, "name")
    self._type          = assertProperty(data, "type")
    
end


