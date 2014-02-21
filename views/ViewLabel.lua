require('sdk.views.ELabelTextAlign')

ViewLabel = classWithSuper(ViewBase, 'ViewLabel')

--
--Properties
--

--
--Methods
--
function ViewLabel.init(self, params)
    ViewBase.init(self, params)
    
    assert(params.fontType ~= nil, string.format("Font %s type not defined", tostring(params.fontType)))
    assert(params.text ~= nil, "Text not defined")
    
    if(params.align == nil)then
        params.align = ELabelTextAlign.ELTA_CENTER
    end
    
    if(params.scale == nil)then
        params.scale = self:getDefaultScale()
    end
    
    self._text = params.text
    
    local initText = ''
    
    if(params.value ~= nil)then
        assert(type(params.value) == ELuaType.ELT_NUMBER)
        assert(params.timeUpdate ~= nil)
        
        self._value         = params.value
        
        self._timeStep      =  application.animation_duration  / 4
        self._timeUpdate    =  params.timeUpdate
        self._updatesCount  =  self._timeUpdate / self._timeStep
        
        initText            = string.format(self._text, self._value)
        self._deltaValue    = 0
    else
        initText            = self._text
    end
    
    local textProvider  = require("vendors.lib_text_candy")
    
    local fontSize = GameInfoBase:instance():managerFonts():getFontSize(params.fontType)
    
    local lineSpacing = (fontSize / 4)
    
    self._sourceView = textProvider.CreateText(
    {
        fontName     = params.fontType,
        text         = initText,	
        originX      = params.align,							
        originY      = "CENTER",							
        textFlow     = "CENTER",	
        lineSpacing  = lineSpacing,
        charBaseLine = "CENTER",
        showOrigin   = application.debug,
        wrapWidth    = params.wrapWidth
    })
    
    
    
    self._sourceView.x = 0
    self._sourceView.y = 0
    
    self._sourceView.xScale = EScaleType.getScale(params.scale)
    self._sourceView.yScale = self._sourceView.xScale
    
end


function ViewLabel.setValue(self, value)
    
    assert(self._value ~= nil)
    
    self:cleanupTimerUpdate()
    
    self._value         = self._value   + self._deltaValue
    self._deltaValue    = value         - self._value 
    
    self._step          = self._deltaValue / self._updatesCount
    
    self:_updateLabel() 
    
    
    self._timerUpdate = timer.performWithDelay(self._timeStep,
    function ()
        self:_updateLabel() 
    end,
    self._updatesCount - 1)
end

function ViewLabel._updateLabel(self)
    self._value = self._value + self._step
    
    self._deltaValue = self._deltaValue - self._step
    
    self._sourceView:setText(string.format(self._text, math.round(self._value)))
end

function ViewLabel.cleanupTimerUpdate(self)
    if self._timerUpdate ~= nil then
        
        timer.cancel(self._timerUpdate)
        self._timerUpdate = nil
        
    end
end

function ViewLabel.cleanup(self)
    self:cleanupTimerUpdate()
    
    local textProvider  = require("vendors.lib_text_candy")
    
    textProvider.DeleteText(self._sourceView)
    
    ViewBase.cleanup(self)
end

