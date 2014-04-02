require('sdk.models.remote.ERemoteUpdateTypeBase')
require('sdk.models.remote.Response')
require('sdk.models.remote.RemoteConnector')

ManagerRemoteBase = classWithSuper(Object, 'ManagerRemoteBase')

--
-- Properties
--

function ManagerRemoteBase.needManageMemory(self)
    return false
end

function ManagerRemoteBase.isConnectionEstablished(self)
    return self._isConnectionEstablished
end

--
-- Methods
--

function ManagerRemoteBase.init(self, params)
    
    assert(params.remote_connector ~= nil)
    
    assert(application.server_url ~= nil)
    
    self._serverUrl = application.server_url
    
    self._socket = require("socket")
    
    self._timerMonitor = timer.performWithDelay(2000,
    function()
        self:monitorConnection(self.monitorConnection)
    end, 9999)
    
    self:monitorConnection()
    
    self._remoteConnector = params.remote_connector
    
    if(self._isConnectionEstablished)then
        print("Internet access is available")
    else
        print("Internet access is not available")
    end
    
end

function ManagerRemoteBase.monitorConnection(self)
    local tcpConnection = self._socket.tcp()
    tcpConnection:settimeout(1000)                   -- Set timeout to 1 second
    
    local connectionResult = tcpConnection:connect(self._serverUrl, 80)        
    
    self._isConnectionEstablished = connectionResult ~= nil
    
    tcpConnection:close()
end

function ManagerRemoteBase.update(self, type, data, callback)
    
    local params = nil
    
    if(type == ERemoteUpdateTypeBase.ERUT_GAME_START)then
        params = self:getParamsGameStart(data)
    else
        assert(false, 'Not implemented '..type)
    end
    
    self._remoteConnector:update(type, params, callback)
    
end

function ManagerRemoteBase.getParamsGameStart(self, data)
    local result  = 
    {
        uuid    = application.device_id,
        version = GameInfoBase:instance():managerCache():version()
    }
    
    return result
end

function ManagerRemoteBase.tryCleanupTimerMonitor(self)
    if( self._timerMonitor ~= nil)then
        timer.cancel(self._timerMonitor)
        self._timerMonitor = nil
    end
end

function ManagerRemoteBase.cleanup(self)
    self:tryCleanupTimerMonitor()
    
    Object.cleanup(self)
end