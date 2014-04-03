--todo: remove requirements for specify game


ManagerCacheBase = classWithSuper(Object, 'ManagerCacheBase')

--
-- Properties
--
function ManagerCacheBase.version(self)
    return self._version
end

function ManagerCacheBase.needManageMemory(self)
    return false
end

function ManagerCacheBase.getDataPlayerCurrent(self)
    assert(false, 'Please override')
end

function ManagerCacheBase.getDataLevelContainers(self)
    assert(false, 'Please override')
end

function ManagerCacheBase.getDataPurchases(self)
    assert(false, 'Please override')
end

function ManagerCacheBase.getDataBonus(self)
    assert(false, 'Please override')
end

function ManagerCacheBase.getDataBonusEnergy(self)
    assert(false, 'Please override')
end

--
-- Paths
-- 

function ManagerCacheBase.directoryPlayers(self)
    return application.dir_data..'players'
end

function ManagerCacheBase.fileNamePlayerCurrent(self)
    return 'player_current.json'
end

function ManagerCacheBase.directoryLevelContainers(self)
    return application.dir_data..'level_containers'
end

function ManagerCacheBase.fileNameLevelContainer(self)
    return  'data.json'
end


function ManagerCacheBase.directoryLevels(self)
    return 'levels'
end

function ManagerCacheBase.directoryPurchases(self)
    return application.dir_data..'purchases'
end

function ManagerCacheBase.fileNamePurchases(self)
    return 'purchases.json'
end

function ManagerCacheBase.directoryBonus(self)
    return application.dir_data..'bonus'
end

function ManagerCacheBase.fileNameBonus(self)
    return 'bonus.json'
end

function ManagerCacheBase.directoryBonusEnergy(self)
    return application.dir_data..'bonus'
end

function ManagerCacheBase.fileNameBonusEnergy(self)
    return 'bonus_energy.json'
end

function ManagerCacheBase.fileNameVersion(self)
    return 'version.json'
end

--
-- Methods
--

function ManagerCacheBase.init(self)
    
    local versionData = self:getOrCreateVersionData()
    
    self._version = tonumber(versionData.value)
    
    print('remove after debug')
    print('use version 0')
    self._version = 0
end

function ManagerCacheBase.getOrCreateVersionData(self)
    
    local result = nil
    
    local fileName = string.format('%s', self:fileNameVersion())
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        
        self:updateVersion(0)
        
        result = self:getOrCreateVersionData()
    end
    
    
    return result
end

function ManagerCacheBase.update(self, type, data, callback)
    
    if(type == ERemoteUpdateTypeBase.ERUT_GAME_START)then
        
        if(data == nil)then
            data = 
            {
                version = self._version
            }
        end
        
        assert(data.version ~= nil)
        
        --todo: remove 
        data.version = self._version + 1
        
        if(tonumber(data.version) > self._version)then
            --todo: update data
            self:updateLocalData(data)
        end
        
        self:onGameStart(data, callback)
    else
        assert(false, 'TODO: review')
    end
    
end

function ManagerCacheBase.updateLocalData(self, data)
    assert(data.players     ~= nil)
    assert(data.levels      ~= nil)
    assert(data.purchases   ~= nil)
    
    
    self:updatePlayers(data.players)
    self:updateLevels(data.levels)
    self:updatePurchases(data.purchases)
    --    self:updateBonus(data)
    --    self:updateBonusEnergy(data)
    
    --todo: update bonus data
    
    self:updateVersion(data.version)
end

function ManagerCacheBase.updatePlayers(self, data)
    assert(data.player_current ~= nil)
    
    --try remove old data
    Utils.removeDirectoryOrFile(self:directoryPlayers(), system.DocumentsDirectory)
    
    self:savePlayerCurrent(data.player_current)
end

function ManagerCacheBase.updatePurchases(self, data)
    --try remove old data
    Utils.removeDirectoryOrFile(self:directoryPurchases(), system.DocumentsDirectory)
    
    self:savePurchases(data)
end


function ManagerCacheBase.updateLevels(self, data)
    assert(data.level_containers ~= nil)
    
    --try remove old data
    Utils.removeDirectoryOrFile(self:directoryLevelContainers(), system.DocumentsDirectory)
    
    local levelContainers = data.level_containers
    
    self:saveLevelContainers(levelContainers)
end

function ManagerCacheBase.updateVersion(self, value)
    
    if(self._version == tonumber(value))then
        return
    end
    
    self._version = value
    
    local versionData = 
    {
        value = self._version
    }
    
    JSONHelper.saveDataTo(versionData, self:fileNameVersion())
    
    print('db version updated to '..self._version)
    
end

function ManagerCacheBase.onGameStart(self, type, callback)
    
    local result = nil
    
    --get data from local files
    
    
    local resultData            = {}
    resultData.status           = EResponseType.ERT_OK
    
    local response              = {}
    
    --
    -- players
    --
    local dataPlayers           = {}
    dataPlayers.player_current   = self:getOrCreatePlayerCurrent()
    
    response.players            = dataPlayers
    
    --
    -- levels                                                                                                                                                                                                                                     
    --
    local dataLevels            = {}
    dataLevels.level_containers = self:getOrCreateLevelContainers()
    
    response.levels             = dataLevels
    
    --
    --purchases
    --
    
    local dataPurchases         = self:getOrCreatePurchases()
    response.purchases          = dataPurchases
    
    --
    --bonuses
    --
    local dataBonus             = self:getOrCreateBonus()
    response.bonus              = dataBonus
    
    
    local dataBonusEnergy       = self:getOrCreateBonusEnergy()
    response.bonus_energy       = dataBonusEnergy
    
    resultData.response = response
    
    local result                = Response:new()
    result:deserialize(resultData)
    
    callback(result)
    
end

function ManagerCacheBase.getOrCreateBonus(self)
    local result = nil
    
    local fileName = string.format('%s/%s', self:directoryBonus() ,self:fileNameBonus())
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        local data = self:getDataBonus()
        
        JSONHelper.saveDataTo(data, fileName)
        
        --todo: remove
        result = self:getOrCreateBonus()
    end
    
    return result
end

function ManagerCacheBase.getOrCreateBonusEnergy(self)
    local result = nil
    
    local fileName = string.format('%s/%s', self:directoryBonusEnergy(), self:fileNameBonusEnergy())
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        
        local data = self:getDataBonusEnergy()
        
        JSONHelper.saveDataTo(data, fileName)
        
        --todo: remove
        result = self:getOrCreateBonusEnergy()
    end
    
    return result
end


function ManagerCacheBase.getOrCreatePurchases(self)
    local result = nil
    
    local fileName = string.format('%s/%s', self:directoryPurchases(), self:fileNamePurchases())
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        
        local data = self:getDataPurchases()
        
        self:savePurchases(data)
        
        --todo: remove
        result = self:getOrCreatePurchases()
    end
    
    return result
end

function ManagerCacheBase.getOrCreatePlayerCurrent(self)
    local result = nil
    
    local fileName = string.format('%s/%s', self:directoryPlayers(), self:fileNamePlayerCurrent())
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        local data = self:getDataPlayerCurrent()
        
        self:savePlayerCurrent(data)
        
        --todo: remove
        result = self:getOrCreatePlayerCurrent()
    end
    
    return result
end

function ManagerCacheBase.getOrCreateLevelContainers(self)
    local result = {}
    
    local subDirs = Utils.getAllFilesInDirectory(self:directoryLevelContainers(), system.DocumentsDirectory)
    
    for i, childName in ipairs(subDirs)do
        
        local isDirectory = Utils.getIsDirectory(string.format('%s/%s', self:directoryLevelContainers(), childName), system.DocumentsDirectory)
        
        if(childName == '.' or childName == '..')then
            --do nothing
        elseif(isDirectory)then
            --try load container
            local dataLevelContainer =  self:tryLoadLevelContainerData(string.format('%s/%s', self:directoryLevelContainers(), childName))
            
            if(dataLevelContainer ~= nil)then
                table.insert(result, dataLevelContainer)
            end
        end
    end
    
    --if level containers not loaded -->  need create default containers
    if(#result == 0)then
        --create container 0
        local dataLevelContainers = self:getDataLevelContainers()
        
        self:saveLevelContainers(dataLevelContainers)
        
        --reload data
        result = self:getOrCreateLevelContainers()
    end
    
    
    return result
end

function ManagerCacheBase.tryLoadLevelContainerData(self, dirContainer)
    assert(dirContainer ~= nil)
    
    local result = nil
    
    local dataLevels            = nil
    local dataLevelContainer    = nil
    
    local subDirs = Utils.getAllFilesInDirectory(dirContainer, system.DocumentsDirectory)
    
    for i, childName in ipairs(subDirs)do
        
        local childPath = string.format("%s/%s", dirContainer, childName)
        
        if(childName == self:directoryLevels())then
            
            if(Utils.getIsDirectory(childPath, system.DocumentsDirectory))then
                --found levels data
                
                dataLevels = {}
                
                --get levels info
                local levelsFiles =  Utils.getAllFilesInDirectory(childPath, system.DocumentsDirectory)
                
                for levelFileIndex = 1, #levelsFiles, 1 do
                    local levelFile = levelsFiles[levelFileIndex]
                    
                    local levelFilePath = string.format('%s/%s/%s', dirContainer, childName, levelFile)
                    
                    local isDirectory = Utils.getIsDirectory(levelFilePath, system.DocumentsDirectory)
                    
                    local levelData = nil
                    
                    if(not isDirectory)then
                        levelData = JSONHelper.getDataFrom(levelFilePath, system.DocumentsDirectory)
                        
                        if(levelData ~= nil)then
                            table.insert(dataLevels, levelData)
                        end
                    end
                    
                end
                
            end
            
        elseif(childName == self:fileNameLevelContainer())then
            --found level container data
            dataLevelContainer = JSONHelper.getDataFrom(childPath, system.DocumentsDirectory)
            
        elseif(childName == '.' or childName == '..')then
            --do nothing
        end
    end
    
    if(dataLevels ~= nil and dataLevelContainer ~= nil)then
        result          = dataLevelContainer
        result.levels   = dataLevels
    end
    
    return result
end

function ManagerCacheBase.savePurchases(self, data)
    assert(data ~= nil)
    
    local fileName = string.format('%s/%s', self:directoryPurchases(), self:fileNamePurchases())
    
    JSONHelper.saveDataTo(data, fileName)
end


function ManagerCacheBase.savePlayerCurrent(self, data)
    assert(data ~= nil)
    
    local fileName = string.format('%s/%s', self:directoryPlayers(), self:fileNamePlayerCurrent())
    
    JSONHelper.saveDataTo(data, fileName)
end

function ManagerCacheBase.saveLevelContainers(self, dataLevelContainers)
    assert(dataLevelContainers ~= nil)
    
    for i = 1, #dataLevelContainers, 1 do
        local dataLevelContainer = dataLevelContainers[i]
        
        for levelIndex = 1, #dataLevelContainer.levels, 1 do 
            local dataLevel = dataLevelContainer.levels[levelIndex]
            
            JSONHelper.saveDataTo(dataLevel, string.format("%s/%i/%s/%i.json", self:directoryLevelContainers(), i, self:directoryLevels(), levelIndex))
        end
        
        dataLevelContainer.levels = nil
        
        JSONHelper.saveDataTo(dataLevelContainer, string.format('%s/%i/%s', self:directoryLevelContainers(), i, self:fileNameLevelContainer()))
        
    end
    
end


function ManagerCacheBase.cleanup(self)
    Object.cleanup(self)
end

