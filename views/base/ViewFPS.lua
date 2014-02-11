
ViewFPS = classWithSuper(ViewBase, 'ViewFPS')

--
--Events
--
function ViewFPS.enterFrame(self)
    local curTime = system.getTimer();
    
    if(curTime == self._prevTime)then
        return
    end
    
    local dt = curTime - self._prevTime;
    self._prevTime = curTime;
    
    local fps = math.floor(1000 / dt);
    
    self._lastFps[self._lastFpsCounter] = fps;
    self._lastFpsCounter = self._lastFpsCounter + 1;
    
    if(self._lastFpsCounter > self._maxSavedFps) then 
        self._lastFpsCounter = 1; 
    end
    
    local minLastFps = fps 
    
    for i = 1, #self._lastFps do
        minLastFps = math.min(self._lastFps[i], minLastFps);
    end
    
    self._labelFPS.text = "FPS: "..fps;
    
    self._labelFPSMin.text = "FPSMin:"..minLastFps;
    
    self._labelMemory.text = "Mem:"..string.format("%i",(system.getInfo("textureMemoryUsed") / (1024 * 1024))).." mb"; 
end

--
--Methods
--

function ViewFPS.init(self, params)
    ViewBase.init(self, params)
    
    self._sourceView = display.newGroup();
    
    self._prevTime          = 0;
    self._maxSavedFps       = 30;
    self._lastFps           = {};
    self._lastFpsCounter    = 1
    
    local fontSize          = 16
    
    local labelWidth        = fontSize * 5
    
    local labelParams = 
    {
        text        = "_______________________",
        width       = labelWidth,
        height      = fontSize,
        align       = "left",
        font        = "Helvetica",
        fontSize    = fontSize
    }
    
    self._labelMemory = display.newText(labelParams);
    self._labelMemory:setFillColor(255,255,255);
    self._sourceView:insert(self._labelMemory);
    
    self._labelFPS = display.newText(labelParams);
    self._labelFPS:setFillColor(255,255,255);
    self._sourceView:insert(self._labelFPS);
    
    self._labelFPSMin = display.newText(labelParams);
    self._labelFPSMin:setFillColor(255,255,255);
    self._sourceView:insert(self._labelFPSMin);
    
    self._background = display.newRect(
    0,
    0, 
    labelWidth,
    fontSize * 4);
    
    self._background:setFillColor(0, 0, 0);
    self._sourceView:insert(self._background);
    self._background:toBack()
    
    Runtime:addEventListener(ERuntimeEvent.ERE_ENTER_FRAME, self);
end

function ViewFPS.placeViews(self)
    local fontSize = self._labelMemory.height
    
    self._labelMemory.x = 0 + self._labelMemory.width / 2
    self._labelMemory.y = 0 + display.screenOriginY +  fontSize / 2
    
    self._labelFPS.x = self._labelMemory.x
    self._labelFPS.y = self._labelMemory.y + fontSize
    
    self._labelFPSMin.x = self._labelFPS.x
    self._labelFPSMin.y = self._labelFPS.y + fontSize
    
    self._background.x = self._labelMemory.x
    self._background.y =  0 + display.screenOriginY + fontSize
    
    ViewBase.placeViews(self)
end

function ViewFPS.cleanup(self)
    Runtime:removeEventListener(ERuntimeEvent.ERE_ENTER_FRAME, self);
    
    self._labelMemory:removeSelf()
    self._labelMemory = nil
    
    self._labelFPSMin:removeSelf()
    self._labelFPSMin = nil
    
    self._labelFPS:removeSelf()
    self._labelFPS = nil
    
    self._sourceView:removeSelf()
    
    ViewBase.cleanup(self)
end


