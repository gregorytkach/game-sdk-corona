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
    
    assert(data.content_count   ~= nil)
    assert(data.price_soft      ~= nil)
    assert(data.price_hard      ~= nil)
    assert(data.name            ~= nil)
    assert(data.type            ~= nil)
    
    
    self._contentCount  = tonumber(data.content_count)
    self._priceSoft     = tonumber(data.price_soft)
    self._priceHard     = tonumber(data.price_hard)
    self._name          = data.name
    self._type          = data.type
    
end


