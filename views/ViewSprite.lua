ViewSprite = classWithSuper(ViewBase, 'ViewSprite')

--
--Methods
--
--default initializer
function ViewSprite.init(self, params)
    ViewBase.init(self, params)
    
    assert(params.image ~= nil)
    
    if(application.platform_type ~= EPlatformType.EPT_ANDROID)then
        assert(Utils.isFileExists(params.image), string.format('Not found image: %s', params.image))
    end
    
    if(params.scale == nil)then
        params.scale = self:getDefaultScale()
    end
    
    self._sourceView = display.newImage(params.image)
    
    self._sourceView.x = 0
    self._sourceView.y = 0
    
    self._sourceView.xScale = EScaleType.getScale(params.scale)
    self._sourceView.yScale = self._sourceView.xScale
end


function ViewSprite.cleanup(self)
    self._sourceView:removeSelf()
    self._sourceView = nil
    
    ViewBase.cleanup(self)
end

