BonusInfoBase = classWithSuper(SerializableObject, 'BonusInfoBase')

--
-- Properties
--

function BonusInfoBase.needManageMemory(self)
    return false
end

function BonusInfoBase.type(self)
    return self._type
end

function BonusInfoBase.contentCount(self)
    return self._contentCount
end


--
-- Methods
--

function BonusInfoBase.init(self)
    
    SerializableObject.init(self)
end

function BonusInfoBase.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data["type"]             ~= nil)
    assert(data["content_count"]    ~= nil)
    
    self._contentCount  = data["content_count"]
    self._type          = data["type"]
    
end

