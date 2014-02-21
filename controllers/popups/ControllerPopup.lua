require('sdk.views.popups.ViewPopup')

ControllerPopup = classWithSuper(Controller, 'ControllerPopup')

--
--Properties
--

function ControllerPopup.getType()
    assert(false, 'Please override')
    return nil
end

--
-- Events
--

function ControllerPopup.onButtonCloseClicked(self)
    local currentState = GameInfoBase:instance():managerStates():currentState()
    
    assert(currentState:currentPopup() == self, "Can't hide not current popup")
    
    currentState:hidePopup()
end

--
--Methods
--

function ControllerPopup.init(self, params)
    Controller.init(self, params)
end


function ControllerPopup.onViewClicked(self, target, event)
    local result = Controller.onViewClicked(self, target, event)
    
    if(target == self._view:buttonClose())then
        
        self:onButtonCloseClicked()
        
        result = true
    end
    
    
    return result
end




