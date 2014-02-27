require ('sdk.views.EBlendMode')
require ('sdk.views.EScaleType')

ViewBase = classWithSuper(Object, 'ViewBase')

--
--Properties
--
function ViewBase.getDefaultScale(self)
    return EScaleType.EST_NONE
end

function ViewBase.sourceView(self)
    if(self._sourceView == nil)then
        print('set breakpoint here')
    end
    
    return self._sourceView
end

function ViewBase.realWidth(self)
    return  self._sourceView.contentWidth 
end

function ViewBase.realHeight(self)
    return  self._sourceView.contentHeight
end

function ViewBase.x0(self)
    return  self._x0
end

function ViewBase.y0(self)
    return  self._y0
end

function ViewBase.x1(self)
    return  self._x1
end

function ViewBase.y1(self)
    return  self._y1
end


--
-- Events
--

function ViewBase.touch(self, event)
    assert(false, "TODO:implement")
end

--
--Methods
--

--Default constructor
function ViewBase.init(self, params)
    if(params.controller == nil)then
        print('review')
    end
    
    assert(params               ~= nil)
    assert(params.controller    ~= nil)
    
    self._controller = params.controller
    
    self._boundsEstablished = false
end

function ViewBase.handleTouches(self, handleClick, handleEvents)
    assert(self._sourceView ~= nil, 'Source view must be non nil')
    
    local needHandleEvents = (handleEvents == true) or (handleEvents == true)
    
    self._handleClick  = handleClick
    self._handleEvents = handleEvents
    
    if(needHandleEvents)then
        self._sourceView:addEventListener("touch", self)
    else
        self._sourceView:removeEventListener("touch", self)
    end
end

function ViewBase.isInsideEvent(self, event)
    assert(self._boundsEstablished, 'Please establish bounds first')
    
    local result = false
    
    result = (event.x >= self._x0) and (event.x <= self._x1) and   (event.y >= self._y0) and (event.y <= self._y1)
    
    return result
end

function ViewBase.establishBounds(self)
    local widthHalf     = self:realWidth()  / 2
    local heightHalf    = self:realHeight() / 2
    
    local xGlobal, yGlobal = self._sourceView:localToContent(0, 0)
    
    self._x0 = xGlobal - widthHalf
    self._x1 = xGlobal + widthHalf
    
    self._y0 = yGlobal - heightHalf
    self._y1 = yGlobal + heightHalf
    
    self._boundsEstablished = true
end

function ViewBase.show(self, time, callback)
    
    self:cleanupTweenHide()
    self:cleanupTweenShow()
    
    local callbackWrapper = 
    function()
        self._tweenShow = nil
        if(callback ~= nil)then
            callback()
        end  
    end
    
    local paramsShow = self:getParamsTweenShow(time, callbackWrapper)
    
    self._tweenShow = transition.to(self._sourceView, paramsShow)
    
end

function ViewBase.getParamsTweenShow(self, time, callback)
    
    if(time == nil)then
        time = application.animation_duration * 2
    end
    
    local result = 
    {
        time        = time,
        alpha       = 1, 
        onComplete  = 
        function()
            if(callback ~= nil)then
                callback()
            end
        end
    }
    
    return result
end

function ViewBase.hide(self, time, callback)
    
    self:cleanupTweenHide()
    self:cleanupTweenShow()
    
    local callbackWrapper = 
    function()
        self._tweenHide = nil
        if(callback ~= nil)then
            callback()
        end  
    end
    
    local paramsHide = self:getParamsTweenHide(time, callbackWrapper)
    
    self._tweenHide = transition.to(self._sourceView, paramsHide)
    
end

function ViewBase.getParamsTweenHide(self, time, callback)
    
    if(time == nil)then
        time = application.animation_duration * 2
    end
    
    local result = 
    {
        time        = time,
        alpha       = 0, 
        onComplete  =
        function()
            if(callback ~= nil)then
                callback()
            end
        end
    }
    
    return result
end



function ViewBase.placeViews(self)
    
end

function ViewBase.cleanupTweenShow(self)
    if(self._tweenShow ~= nil)then
        transition.cancel(self._tweenShow)
        self._tweenShow = nil
    end
end


function ViewBase.cleanupTweenHide(self)
    if(self._tweenShow ~= nil)then
        transition.cancel(self._tweenHide)
        self._tweenHide = nil
    end
end

function ViewBase.cleanup(self)
    self:cleanupTweenHide()
    self:cleanupTweenShow()
    
    Object.cleanup(self)
end

--
-- Helpers methods
--
function ViewBase.createSprite(self, image, params)
    assert(self._sourceView ~= nil, 'create source view first')
    assert(image ~= nil)
    
    local result = nil
    
    
    local paramsSprite = 
    {
        controller  = self._controller,
        image       = image
    }
    
    if(params ~= nil)then
        for key, value in pairs(params)do
            paramsSprite[key] = value
        end
    end
    
    result = ViewSprite:new(paramsSprite)
    
    self._sourceView:insert(result:sourceView())
    
    return result
end

function ViewBase.createButton(self, image, params, text, fontType, align)
    assert(self._sourceView ~= nil, 'create source view first')
    assert(image ~= nil)
    
    local result = nil
    
    
    local paramsButton = 
    {
        controller  = self._controller,
        image       = image,
        
        text        = text,
        fontType    = fontType,
        align       = align
    }
    
    if(params ~= nil)then
        for key, value in pairs(params)do
            paramsButton[key] = value
        end
    end
    
    result = ViewButton:new(paramsButton)
    self._sourceView:insert(result:sourceView())
    
    return result
end

function ViewBase.createLabel(self, text, fontType, align, wrapWidth, value, timeUpdate)
    local result = nil
    
    local paramsLabel =
    {
        controller  = self._controller,
        text        = text, 
        align       = align,
        fontType    = fontType,
        value       = value,
        timeUpdate  = timeUpdate,
        wrapWidth   = wrapWidth
    }
    
    result = ViewLabel:new(paramsLabel)
    self._sourceView:insert(result:sourceView())
    
    return result
end


