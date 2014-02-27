--todo: remove requirements for specify game


ManagerCacheBase = classWithSuper(Object, 'ManagerCacheBase')

--
-- Properties
--

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
-- Methods
--

function ManagerCacheBase.init(self)
    self._directoryPlayers          = application.dir_data..'players'
    self._fileNamePlayerCurrent     = 'player_current.json'
    
    self._directoryLevelContainers  = application.dir_data..'levels/level_containers'
    self._fileNameLevelContainer    = 'data.json'
    self._directoryLevels           = 'levels'
    
    self._directoryPurchases        = application.dir_data..'purchases'
    self._fileNamePurchases         = 'purchases.json'
    
    self._directoryBonus           = application.dir_data..'bonus'
    self._fileNameBonus             = 'bonus.json'
    
    self._directoryBonusEnergy      = application.dir_data..'bonus'
    self._fileNameBonusEnergy       = 'bonus_energy.json'
    
end

function ManagerCacheBase.update(self, type, data, callback)
    
    if(type == ERemoteUpdateTypeBase.ERUT_GAME_START)then
        
        self:onGameStart(data, callback)
    else
        assert(false, 'TODO: review')
    end
    
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
    
    local fileName = string.format('%s/%s', self._directoryBonus, self._fileNameBonus)
    
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
    
    local fileName = string.format('%s/%s', self._directoryBonusEnergy, self._fileNameBonusEnergy)
    
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
    
    local fileName = string.format('%s/%s', self._directoryPurchases, self._fileNamePurchases)
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        local data = self:getDataPurchases()
        
        JSONHelper.saveDataTo(data, fileName)
        
        --todo: remove
        result = self:getOrCreatePurchases()
    end
    
    return result
end

function ManagerCacheBase.getOrCreatePlayerCurrent(self)
    local result = nil
    
    local fileName = string.format('%s/%s', self._directoryPlayers, self._fileNamePlayerCurrent)
    
    result = JSONHelper.getDataFrom(fileName, system.DocumentsDirectory)
    
    if(result == nil)then
        local data = self:getDataPlayerCurrent()
        
        JSONHelper.saveDataTo(data, fileName)
        
        --todo: remove
        result = self:getOrCreatePlayerCurrent()
    end
    
    return result
end

function ManagerCacheBase.getOrCreateLevelContainers(self)
    local result = {}
    
    local subDirs = getAllFilesInDirectory(self._directoryLevelContainers, system.DocumentsDirectory)
    
    for i, childName in ipairs(subDirs)do
        
        local isDirectory = getIsDirectory(string.format('%s/%s', self._directoryLevelContainers, childName), system.DocumentsDirectory)
        
        if(childName == '.' or childName == '..')then
            --do nothing
        elseif(isDirectory)then
            --try load container
            local dataLevelContainer =  self:tryLoadLevelContainerData(string.format('%s/%s', self._directoryLevelContainers, childName))
            
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
    
    local subDirs = getAllFilesInDirectory(dirContainer, system.DocumentsDirectory)
    
    for i, childName in ipairs(subDirs)do
        
        local childPath = string.format("%s/%s", dirContainer, childName)
        
        if(childName == self._directoryLevels)then
            
            if(getIsDirectory(childPath, system.DocumentsDirectory))then
                --found levels data
                
                dataLevels = {}
                
                --get levels info
                local levelsFiles =  getAllFilesInDirectory(childPath, system.DocumentsDirectory)
                
                for levelFileIndex = 1, #levelsFiles, 1 do
                    local levelFile = levelsFiles[levelFileIndex]
                    
                    local levelFilePath = string.format('%s/%s/%s', dirContainer, childName, levelFile)
                    
                    local isDirectory = getIsDirectory(levelFilePath, system.DocumentsDirectory)
                    
                    local levelData = nil
                    
                    if(not isDirectory)then
                        levelData = JSONHelper.getDataFrom(levelFilePath, system.DocumentsDirectory)
                        
                        if(levelData ~= nil)then
                            table.insert(dataLevels, levelData)
                        end
                    end
                    
                end
                
            end
            
        elseif(childName == self._fileNameLevelContainer)then
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

function ManagerCacheBase.saveLevelContainers(self, dataLevelContainers)
    assert(dataLevelContainers ~= nil)
    
    for i = 1, #dataLevelContainers, 1 do
        local dataLevelContainer = dataLevelContainers[i]
        
        for levelIndex = 1, #dataLevelContainer.levels, 1 do 
            local dataLevel = dataLevelContainer.levels[i]
            
            JSONHelper.saveDataTo(dataLevel, string.format("%s/%i/%s/%i.json", self._directoryLevelContainers, i, self._directoryLevels, levelIndex))
        end
        
        dataLevelContainer.levels = nil
        
        JSONHelper.saveDataTo(dataLevelContainer, string.format('%s/%i/%s', self._directoryLevelContainers, i, self._fileNameLevelContainer))
        
    end
    
end


function ManagerCacheBase.cleanup(self)
    Object.cleanup(self)
end

