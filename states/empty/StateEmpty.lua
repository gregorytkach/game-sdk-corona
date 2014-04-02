
StateEmpty = classWithSuper(StateBase, 'StateEmpty')


--
-- Properties
--

function StateEmpty.needManageMemory(self)
    return false
end

function StateEmpty.getType(self)
    return EStateTypeBase.EST_EMPTY
end

function StateEmpty.init(self)
    StateBase.init(self)
end

function StateEmpty.update(self, updateType)
    
    if(updateType == EControllerUpdateBase.ECUT_SCENE_ENTER)then
        
        local objectsForCleanup = reportObjectsForCleanup()
        
        for object, object in pairs(objectsForCleanup)do
            if(object:isA(ViewBase))then
                
                local sourceView = object:sourceView()
                
                if(sourceView ~= nil)then
                    self._sceneStoryboard.view:insert(sourceView)
                    
                    sourceView.x = display.contentCenterX
                    sourceView.y = display.contentCenterY
                    
                else
                    print(string.format("class %s has nil source view ", object:className()), ELogLevel.ELL_WARNING) 
                end
            end
        end
        
        GameInfoBase:instance():managerStates():reportMemory()
        
        --do nothing
    elseif(updateType == EControllerUpdateBase.ECUT_SCENE_EXIT)then
        --do nothing
    else
        print(string.format("receive update %s on empty state.", updateType), ELogLevel.ELL_WARNING)
    end
    
end
