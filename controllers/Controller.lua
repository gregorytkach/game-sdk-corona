Controller = classWithSuper(Object, 'Controller')

--
--Properties
--

function Controller.view(self)
    return self._view
end

--
--Events
--

function Controller.onViewClicked(self, target, event)
    return false
end

function Controller.onViewEvent(self, target, event)
    return false
end

function Controller.update(self, updateType)
    assert(false, 'Implement in derrived class')
end

--
--Methods
--

function Controller.init(self, params)
    assert(params ~= nil)
    assert(params.view ~= nil)
    
    self._view = params.view
end
