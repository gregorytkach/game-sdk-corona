require('sdk.views.ViewBase')
require('sdk.views.ViewButton')
require('sdk.views.ViewSprite')
require('sdk.views.ViewLabel')
require('sdk.views.ViewParticle')



ViewStateBase = classWithSuper(ViewBase, 'ViewStateBase')



--
--Properties
--
function ViewStateBase.background(self)
    return self._background
end

--
--Methods
--
--default initializer
function ViewStateBase.init(self, params)
    ViewBase.init(self, params)
    
    self._sourceView = display.newGroup()
end

function ViewStateBase.initBackground(self, resourceType)
    
    local paramsBg = 
    {
        scale       = EScaleType.EST_MAX,
    }
    
    self._background = self:createSprite(resourceType, paramsBg)
    self._sourceView:insert(self._background:sourceView())
    self._background:sourceView():toBack()
    
end


function ViewStateBase.placeViews(self)
    if(self._background ~= nil)then
        self._background:sourceView().x = display.contentCenterX
        self._background:sourceView().y = display.contentCenterY
    end
    
   
    
    ViewBase.placeViews(self)
end

function ViewStateBase.cleanup(self)
    
    if(self._background ~= nil)then
        self._background:cleanup()
        self._background = nil
    end
    
 
    
    self._sourceView:removeSelf()
    self._sourceView = nil
    
    ViewBase.cleanup(self)
end

