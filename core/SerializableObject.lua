SerializableObject = classWithSuper(Object, 'SerializableObject')

function SerializableObject.init(self)
end


function SerializableObject.serialize(self)
    assert(false, 'Please override')
    
    return nil
end

function SerializableObject.deserialize(self, data)
    if(data == nil)then
        print('set breakpoint here')
    end
    
    assert(data ~= nil, 'Data must be non nil')
end