require('sdk.models.remote.EResponseType')

Response = classWithSuper(SerializableObject, 'Response')

--
-- Properties
--

function Response.status(self)
    return self._status
end

function Response.response(self)
    return self._response
end

--
-- Methods
--

function Response.init(self)
end

function Response.cleanup(self)
    Object.cleanup(self)
end

function Response.deserialize(self, data)
    SerializableObject.deserialize(self, data)
    
    assert(data.status      ~= nil)
    assert(data.response    ~= nil)
    
    self._status = data.status
    self._response = data.response
    
end

