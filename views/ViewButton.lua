require('sdk.views.ETouchEvent')

ViewButton = classWithSuper(ViewBase, 'ViewButton')

--
--Properties
--

function ViewButton.isTouchBegan(self)
    return self._isTouchBegan
end

function ViewButton.label(self)
    return self._label
end

function ViewButton.isEnabled(self)
    return self._isEnabled 
end

function ViewButton.setIsEnabled(self, value)
    if(self._isEnabled == value)then
        return
    end
    
    self._isEnabled = value
    self._sourceView:setEnabled(self._isEnabled)
    
    if(self._isEnabled)then
        
        self._sourceView:setFillColor(1, 1, 1)
        
        if(self._label ~= nil)then
            self._label:sourceView():setColor(1, 1, 1)
        end
        
    else
        
        self._sourceView:setFillColor(0.5, 0.5, 0.5)
        
        if(self._label ~= nil)then
            self._label:sourceView():setColor(0.5, 0.5, 0.5)
        end
    end
end

--
--Events
--

function ViewButton.onEvent(self, event)
    local result = false
    
    if(not self._isEnabled) then
        return result
    end
    
    if(event.phase == ETouchEvent.ETE_BEGAN)then
        
        if(application.sounds)then
            audio.play(GameInfoBase:instance():managerSounds():getSound(ESoundTypeBase.ESTB_BUTTON_DOWN))
        end
        
        if(self._label ~= nil)then
            self._label:sourceView():scale(self._labelScaleFactor, self._labelScaleFactor) 
        end
        
        if(self._handleEvents)then
            self._controller:onViewEvent(self, event)
        end
        
        self._isTouchBegan = true
        
        result = true
        
    elseif(event.phase == ETouchEvent.ETE_MOVED)then
        
        if(self._handleEvents)then
            self._controller:onViewEvent(self, event)
        end
        
        result = true
        
    elseif(event.phase == ETouchEvent.ETE_CANCELLED)then
        
        if(self._handleEvents)then
            self._controller:onViewEvent(self, event)
        end
        
        if(self._isTouchBegan)then
            
            if(self._label ~= nil)then
                self._label:sourceView():scale(1 / self._labelScaleFactor, 1 / self._labelScaleFactor) 
            end
            
        end
        
        
        self._isTouchBegan = false
        
        result = true
        
    elseif(event.phase == ETouchEvent.ETE_ENDED)then
        
        if(self._isTouchBegan)then
            if(self._label ~= nil)then
                self._label:sourceView():scale(1 / self._labelScaleFactor, 1 / self._labelScaleFactor) 
            end
            
            if(application.sounds)then
                audio.play(GameInfoBase:instance():managerSounds():getSound(ESoundTypeBase.ESTB_BUTTON_UP))
            end
        end
        
        if(self._handleEvents)then
            self._controller:onViewEvent(self, event)
        elseif(self._isTouchBegan)then
            self._controller:onViewClicked(self)
        end
        
        self._isTouchBegan = false
        
        result = true
        
    end
    
    return result
end


--
--Methods
--


--Default initializer
--required params:
--  image_name
--optional params:
--  handle_click
--  handle_move
--  text
--  fontType
--  align
function ViewButton.init(self, params)
    ViewBase.init(self, params)
    
    assert(params.image ~= nil)
    
    if(params.handleEvents ~= nil)then
        self._handleEvents = params.handleEvents
    end
    
    if(params.scale == nil)then
        params.scale = self:getDefaultScale()
    end
    
    local imageNameUp = string.format(params.image,     'up')
    local imageNameDown = string.format(params.image,   'down')
    
    assert(Utils.isFileExists(imageNameUp,   system.ResourceDirectory),   string.format('Not found button image up: %s', imageNameUp))
    assert(Utils.isFileExists(imageNameDown, system.ResourceDirectory),   string.format('Not found button image down: %s', imageNameDown))
    
    local widget = require("widget")
    
    self._sourceView = widget.newButton
    {
        defaultFile     = imageNameUp,
        overFile        = imageNameDown,
        onEvent         = 
        function(event)
            self:onEvent(event)
        end
    }
    
    self._sourceView.x = 0
    self._sourceView.y = 0
    
    self._sourceView.xScale = EScaleType.getScale(params.scale)
    self._sourceView.yScale = self._sourceView.xScale
    
    if(params.text ~= nil)then
        assert(params.fontType  ~= nil)
        
        if(params.align == nil)then
            params.align = ELabelTextAlign.ELTA_CENTER
        end
        
        local labelParams = 
        {
            text        = params.text,
            fontType    = params.fontType,
            align       = params.align,
            wrapWidth   = self:sourceView().width,
            
            controller  = self._controller
        }
        
        self._label = ViewLabel:new(labelParams)
        local labelSource = self._label:sourceView()
        
        --todo: review
        labelSource.xScale = 1 
        labelSource.yScale = 1 
        
        labelSource.x = self._sourceView.width / 2
        labelSource.y = self._sourceView.height / 2
        
        self._sourceView:insert(labelSource)
        
        self._labelScaleFactor = 0.75
    end
    
    self:setIsEnabled(true)
    
end

function ViewButton.cleanup(self)
    
    if(self._label ~= nil)then
        self._label:cleanup()
        self._label = nil
    end
    
    self._sourceView:removeSelf()
    self._sourceView = nil
    
    ViewBase.cleanup(self)
end
