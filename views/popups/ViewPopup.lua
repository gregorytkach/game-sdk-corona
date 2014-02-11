ViewPopup = classWithSuper(ViewBase, 'ViewPopup')


--
--Properties
--

function ViewPopup.buttonClose(self)
    return self._buttonClose
end


--
--Methods
--

function ViewPopup.init(self, params)
    ViewBase.init(self, params)
    
end

function ViewPopup.setButtonClose(self, view)
    assert(view             ~= nil)
    assert(self._sourceView ~= nil)
    
    self._buttonClose = view
    self._sourceView:insert(self._buttonClose:sourceView())
    
end

function ViewPopup.cleanup(self)
    self._buttonClose:cleanup()
    self._buttonClose = nil
    
    ViewBase.cleanup(self)
end

