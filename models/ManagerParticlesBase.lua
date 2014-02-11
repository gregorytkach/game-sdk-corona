
ManagerParticlesBase = classWithSuper(Object, 'ManagerParticlesBase')

--
--Properties
--

function ManagerParticlesBase.needManageMemory(self)
    return false
end

function ManagerParticlesBase.assetsDir(self)
    assert(false, 'Please implement in derrived class')
    return nil
end


function ManagerParticlesBase.particleProvider(self)
    return self._particleProvider
end

function ManagerParticlesBase.emmiters(self)
    return self._emmiters
end

function ManagerParticlesBase.registeredParticles(self)
    return {}
end

--
--Events
--

function ManagerParticlesBase.enterFrame(self, event)
    self._particleProvider:Update()
end

--
--Methods
--

function ManagerParticlesBase.init(self)
    self._particleProvider = require("vendors.lib_particle_candy")
    
    self._emmiters = {}
    
    self:loadParticles()
    
    Runtime:addEventListener(ERuntimeEvent.ERE_ENTER_FRAME, self)
end

function ManagerParticlesBase.loadParticles(self)
    
end

function ManagerParticlesBase.cleanup(self)
    local particles = self:registeredParticles()
    
    for i, particleType in ipairs( particles) do
        self._particleProvider.DeleteParticleType(particleType)
    end
    
    Object.cleanup(self)
end
