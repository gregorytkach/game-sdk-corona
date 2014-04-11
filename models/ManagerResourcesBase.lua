ManagerResourcesBase = classWithSuper(Object, 'ManagerResourcesBase')

--
--Properties
--
function ManagerResourcesBase.needManageMemory(self)
    return false
end


--
--Methods
--


function ManagerResourcesBase.init(self)
    self._resources = {}
    self:initAnimations()
end

function ManagerResourcesBase.initAnimations(self)
    self._animations = {}
end

function ManagerResourcesBase.getStateBackground(self, stateType)
    assert(false, 'Please implement in derrived class')
end

function ManagerResourcesBase.getPopupBackground(self, type)
    assert(false, 'Please implement in derrived class')
end

function ManagerResourcesBase.getAsImage(self, resourceType)
    return self:_getImage(resourceType, nil)
end

function ManagerResourcesBase.getAsImageWithParam(self, resourceType, param)
    assert(param        ~= nil)
    
    return self:_getImage( resourceType, param)
end

function ManagerResourcesBase._getImage(self, resourceType, param)
    assert(resourceType ~= nil)
    
    local result = self._resources[resourceType]
    
    assert(result ~= nil, string.format('Not found resource type: %s', resourceType))
    
    if(param == nil)then
        result = string.format(result, application.dir_assets, application.scaleSuffix)
    else
        result = string.format(result, application.dir_assets, param, application.scaleSuffix)
    end
    
    return result
end

function ManagerResourcesBase.getAsButton(self, resourceType)
    if(resourceType == nil)then
        print('set breakpoint here')
    end
    
    assert(resourceType ~= nil)
    
    local result = self._resources[resourceType]
    
    assert(result ~= nil, string.format('Not found resource type: %s', resourceType))
    
    result = string.format(result, application.dir_assets, "%s", application.scaleSuffix)
    
    return result
end

function ManagerResourcesBase.getAsAnimation(self, resourceType, scale)
    return self:_getAnimation(resourceType, nil, scale)
end

function ManagerResourcesBase.getAsAnimationWithParam(self, resourceType, param, scale)
    assert(param        ~= nil)
    
    return self:_getAnimation(resourceType, param, scale)
end

function ManagerResourcesBase._getAnimation(self, resourceType, param, scale)
    local result = nil
    
    assert(resourceType ~= nil)
    assert(self._resources[resourceType]    ~= nil, string.format("Not registered animation image: %s", resourceType))
    assert(self._animations[resourceType]   ~= nil, string.format("Not registered animation data: %s", resourceType))
    
    if(scale == nil)then
        scale = application.scaleMin
    end
    
    local sheetImage = nil
    
    if (param == nil) then
        sheetImage = string.format(self._resources[resourceType], application.dir_assets, application.scaleSuffix)
    else
        sheetImage = string.format(self._resources[resourceType], application.dir_assets, param, application.scaleSuffix)
    end
    
    assert(Utils.isFileExists(sheetImage, system.ResourceDirectory))
    
    local pathWithoutExtention        = getFilenameWithoutExtention(sheetImage)
    
    local sheetInfoPath = string.gsub(pathWithoutExtention, '/', '.' )
    
    local animationSheetInfo = require(sheetInfoPath)
    
    local imageSheet = graphics.newImageSheet(sheetImage, animationSheetInfo:getSheet())
    
    result = display.newSprite(imageSheet, self._animations[resourceType])
    
    assert(result ~= nil)
    
    result.xScale = scale
    result.yScale = scale
    
    return result
end
