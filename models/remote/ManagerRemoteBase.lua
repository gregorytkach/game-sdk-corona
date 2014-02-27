require('sdk.models.remote.ERemoteUpdateTypeBase')
require('sdk.models.remote.Response')

ManagerRemoteBase = classWithSuper(Object, 'ManagerRemoteBase')

--
-- Properties
--

function ManagerRemoteBase.isConnectionEstablished(self)
    return self._isConnectionEstablished
end

--
-- Methods
--

function ManagerRemoteBase.init(self, params)
    assert(params               ~= nil)
    assert(params.server_url    ~= nil)
    
    self._serverUrl = params.server_url
    
    self._socket = require("socket")
    
    self._timerMonitor = timer.performWithDelay(2000,
    function()
        self:monitorConnection(self.monitorConnection)
    end, 9999)
    
    self:monitorConnection()
    
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
    
    if(type == ERemoteUpdateTypeBase.ERUT_GAME_START)then
        self:getDataGameStart(data)
    else
        assert(false, 'Not implemented '..type)
    end
    
end

function ManagerRemoteBase.getDataGameStart(self, data)
    
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