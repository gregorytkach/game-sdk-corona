require('sdk.views.base.ViewStateBase')

require('sdk.views.ViewButton')
require('sdk.views.ViewBase')
require('sdk.views.ViewSprite')
require('sdk.views.ViewLabel')
require('sdk.views.ViewParticle')

require('sdk.controllers.Controller')
require('sdk.controllers.popups.ControllerPopup')

local storyboard = require( "storyboard" )

StateBase = classWithSuper(Object, 'StateBase')

--
--Properties
--
function StateBase.getType(self)
    assert(false, 'Please implement in derived classes')
    return  nil
end

function StateBase.getPopup(self, type)
    assert(type ~= nil)
    assert(self._popups[type] ~= nil, 'Popup not registered')
    
    return self._popups[type]
end

--corona scene
function StateBase.sceneStoryboard(self)
    return self._sceneStoryboard
end

function StateBase.currentPopup(self)
    return self._currentPopup
end

--
--Events
--

function StateBase.createScene(self, event)
    
    self:initLayerScene()
    self:initLayerUI()
    self:initLayerPopups()
    
    self:placeViews()
    
end

function StateBase.enterScene(self, event)
    self:update(EControllerUpdateBase.ECUT_SCENE_ENTER)
end

function StateBase.exitScene(self, event)
    self:update(EControllerUpdateBase.ECUT_SCENE_EXIT)
end

function StateBase.destroyScene(self, event)
    self:cleanup()
end

--
-- Methods
--

--Default constructor
function StateBase.init(self)
    
    self._sceneStoryboard = storyboard.newScene()
    self._sceneStoryboard:addEventListener( "createScene",  self)
    self._sceneStoryboard:addEventListener( "enterScene",   self)
    self._sceneStoryboard:addEventListener( "exitScene",    self)
    self._sceneStoryboard:addEventListener( "destroyScene", self)
    
end


function StateBase.prepareToExit(self)
    GameInfoBase:instance():managerStates():onStateGone()
end

function StateBase.update(self, updateType)
    assert(false, 'Please implement in derived classes')
end

function StateBase.showPopup(self, popupType, callback)
    assert(self._popups[popupType]  ~= nil, 'Popup not registered')
    assert(self._currentPopup       == nil, 'Popup currently shown')
    
    self._currentPopup = self._popups[popupType]
    
    self:onDeactivate()
    
    self._blockerPopups.alpha = 0.01
    
    self._currentPopup:view():show(nil, 
    function()
        self._blockerPopups.alpha = 0
        
        if(callback ~= nil)then
            callback()
        end
    end)
end

function StateBase.onDeactivate(self)
    self._blockerScene.alpha = 0.6
end

function StateBase.hidePopup(self, callback)
    assert(self._currentPopup ~= nil, 'Nothing to hide')
    
    self._blockerPopups.alpha = 0.01
    
    local paramsTweenBlockerScene = 
    {
        time        = self._currentPopup:view():getParamsTweenHide().time,
        alpha       = 0,
        onComplete  = 
        function ()
            self._tweenBlockerSceneHide = nil
        end
    }
    self._tweenBlockerSceneHide = transition.to(self._blockerScene, paramsTweenBlockerScene)
    
    self._currentPopup:view():hide(nil,
    function() 
        self._blockerPopups.alpha = 0
        
        self:onActivate()
        
        self._currentPopup = nil
        
        if(callback ~= nil)then
            callback()
        end
    end)
end

function StateBase.onActivate(self)
    self._blockerScene.alpha = 0
end

function StateBase.initLayerScene(self)
    self._layerScene = display.newGroup()
    self._sceneStoryboard.view:insert(self._layerScene)
end

function StateBase.initLayerUI(self)
    self._layerUI = display.newGroup()
    self._sceneStoryboard.view:insert(self._layerUI)
    
    --        self._layerUI.fill.effect = "filter.blur"
end

function StateBase.blockersCallback(event)
    return true
end

function StateBase.initLayerPopups(self)
    self._blockerScene = display.newRect(0,0, display.contentWidth, display.contentHeight)
    self._blockerScene:setFillColor(0,0,0)
    self._blockerScene.alpha = 0
    self._blockerScene:addEventListener(ERuntimeEvent.ERE_TOUCH, StateBase.blockersCallback)
    
    self._sceneStoryboard.view:insert(self._blockerScene)
    
    self._layerPopups = display.newGroup()
    self._sceneStoryboard.view:insert(self._layerPopups)
    
    self._blockerPopups = display.newRect(0,0, display.contentWidth, display.contentHeight)
    self._blockerPopups:setFillColor(0,0,0)
    self._blockerPopups.alpha = 0
    self._blockerPopups:addEventListener(ERuntimeEvent.ERE_TOUCH, StateBase.blockersCallback) 
    
    self._sceneStoryboard.view:insert(self._blockerPopups)
    
    self._popups = {}
end


function StateBase.registerPopup(self, popup)
    assert(popup ~= nil)
    
    assert(self._popups[popup:getType()] == nil, 'Popup already registered')
    
    self._layerPopups:insert(popup:view():sourceView())
    self._popups[popup:getType()] = popup
    
end

function StateBase.placeViews(self)
    
    for popupType, popup in pairs(self._popups)do
        popup:view():placeViews()
        
        popup:view():sourceView().x = display.contentCenterX
        popup:view():sourceView().y = display.contentCenterY
        
        popup:view():hide(0)
    end
    
    self._blockerScene.x = display.contentCenterX
    self._blockerScene.y = display.contentCenterY
    
    self._blockerPopups.x = self._blockerScene.x
    self._blockerPopups.y = self._blockerScene.y 
end

--
-- Events
--



--
-- Dispose
--

function StateBase.cleanup(self)
    self._sceneStoryboard:removeEventListener( "createScene",  self)
    self._sceneStoryboard:removeEventListener( "enterScene",   self)
    self._sceneStoryboard:removeEventListener( "exitScene",    self)
    self._sceneStoryboard:removeEventListener( "destroyScene", self)
    
    if(self._tweenBlockerSceneHide ~= nil)then
        transition.cancel(self._tweenBlockerSceneHide)
    end
    
    self._blockerPopups:removeEventListener(ERuntimeEvent.ERE_TOUCH, StateBase.blockersCallback)
    self._blockerPopups:removeSelf()
    self._blockerPopups = nil
    
    self._blockerScene:removeEventListener(ERuntimeEvent.ERE_TOUCH, StateBase.blockersCallback)
    self._blockerScene:removeSelf()
    self._blockerScene = nil
    
    for type, popup in pairs(self._popups)do
        popup:cleanup()
    end
    
    self._popups = nil
    
    Object.cleanup(self)
end