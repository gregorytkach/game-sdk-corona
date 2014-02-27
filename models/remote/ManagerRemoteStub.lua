ManagerRemoteStub = classWithSuper(ManagerRemoteBase, 'ManagerRemoteStub')

--
-- Properties
--

--
-- Methods
--

function ManagerRemoteStub.init(self)
    ManagerRemoteBase.init(self)
    
    self._isConnectionEstablished = false
    
    local paramsOk = 
    {
        status = EResponseType.ERT_OK,
        response = ''
    }
    
    self._responseOk    = Response.new()
    self._responseOk:deserialize(paramsOk)
    
    local paramsError = 
    {
        status      = EResponseType.ERT_ERROR,
        response    = ''
    }
    
    self._responseError = Response.new()
    self._responseError:deserialize(paramsError)
end

function ManagerRemoteStub.update(self, type, data, callback)
    
    if(callback ~= nil)then
        callback(self._responseOk)
    end
    
end

function ManagerRemoteStub.cleanup(self)
    Object.cleanup(self)
end

