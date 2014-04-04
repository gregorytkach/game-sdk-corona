ManagerAdBase = classWithSuper(Object, 'ManagerAdBase')


--
-- Properties
--

--
-- Methods
--

function ManagerAdBase.init(self, params)
end

function ManagerAdBase.showAd(self, callback)
    assert(false, 'please override')
end

function ManagerAdBase.tryCallCallback(self)
    if(self._callback ~= nil)then
        self._callback()
    end
end

function ManagerAdBase.cleanup(self)
    Object.cleanup(self)
end