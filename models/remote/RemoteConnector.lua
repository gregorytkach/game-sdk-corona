require('sdk.models.remote.ERequestHeaderType')
require('sdk.models.remote.EMethodType')
require('sdk.models.remote.EProtocolType')

RemoteConnector = classWithSuper(Object, 'RemoteConnector')

--
-- Properties
--
function RemoteConnector.getSubController(self)
    return ''
end
--
-- Events
-- 

--
-- Methods
--

function RemoteConnector.init(self, params)
    assert(params                   ~= nil)
    assert(params.protocol          ~= nil)
    assert(application.server_url   ~= nil)
    
    self._serverUrl = params.protocol..'://'..application.server_url..self:getSubController()
    self._json      = require('json')
    
end

function RemoteConnector.update(self, updateType, data, callback, methodType, contentType)
    
    if(contentType == nil)then
        contentType = ERequestHeaderType.ERHT_JSON
    end
    
    if(methodType == nil)then
        methodType = EMethodType.EMT_POST
    end
    
    
    local controller = self:getController(updateType)
    
    local headers = 
    {
        ["Content-Type"] = contentType
    }
    
    local params    = {}
    params.headers  = headers
    params.body     = self:getParams(data, contentType) 
    
    local url = self._serverUrl..controller
    
    local http  = require("socket.http")
    local ltn12 = require("ltn12")
    
    local responseString = {}
    
    local headers = 
    {
        ["content-length"]  = #self:getParams(data, contentType),
        ["Content-Type"]    = contentType --"application/x-www-form-urlencoded"
    }
    
    local tmpFilename                   = system.pathForFile('tmp_request_file', system.DocumentsDirectory)
    local tmpFile, errorMessage         = io.open(tmpFilename, 'w')
    
    assert(tmpFile ~= nil, errorMessage)
    
    local request =
    {
        url         = url,
        method      = "POST",
        headers     = headers,
        source      = ltn12.source.string(self:getParams(data, contentType)),
        sink        = ltn12.sink.file(tmpFile)
    }
    
    local r, c, h = http.request(request) 
    
    --reopen file
    tmpFile, errorMessage = io.open(tmpFilename, 'r')
    
    assert(tmpFile ~= nil, errorMessage)
    
    local contents = tmpFile:read("*a")
    
    os.remove(tmpFilename)
    
    
    local responseData = self._json.decode(contents)
    
    local response = Response:new()
    response:deserialize(responseData)
    
    if(response:status() == EResponseType.ERT_ERROR)then
        print("Server response error", ELogLevel.ELL_WARNING)
        
        local responseString = getString(response:response())
        
        print(responseString)
        
    end
    
    if(callback ~= nil)then
        callback(response) 
    end
    
end

function RemoteConnector.getController(self, type)
    local result = ''
    
    if(type == ERemoteUpdateTypeBase.ERUT_GAME_START)then
        result = "game/init"
        
    else
        assert(false)
    end
    
    return result
end

function RemoteConnector.getParams(self, data, headerType)
    local result = nil
    
    if(headerType == ERequestHeaderType.ERHT_JSON)then
        result = self._json.encode(data)
    else
        assert(false)
    end
    
    return result 
end

function RemoteConnector.cleanup(self)
    Object.cleanup(self)
end

