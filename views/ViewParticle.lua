
ViewParticle = classWithSuper(ViewBase, 'ViewParticle')

function ViewParticle.init(self, params)
    assert(params.particles ~= nil)
    assert(params.loop ~= nil)
    assert(params.oneShoot ~= nil)
    
    local managerParticles = GameInfoBase:instance():managerParticles()
    
    self._oneShoot = params.oneShoot
    self._emmiterName =  system.getTimer()
    
    self._autodestroy = false
    
    if(params.autodestroy ~= nil)then
        assert((not params.loop) and params.autodestroy, "Looped emmiters can't be autodestroyed")
        self._autodestroy = params.autodestroy
    end
    
    managerParticles:particleProvider().CreateEmitter(
    self._emmiterName,  --name 
    0,                  --x     
    0,                  --y
    0,                  --rotation
    application.debug,  --visible
    params.loop,        --loop
    self._autodestroy)              --autoDestroy  
    
    self._sourceView = managerParticles:particleProvider().GetEmitter(self._emmiterName)
    table.insert(managerParticles:emmiters(), self._sourceView)
    
    self._sourceView.x = 0
    self._sourceView.y = 0
    
    --attach particles to emmiter
    for i = 1, #params.particles, 1 do
        local particleParams = params.particles[i]
        
        assert(particleParams.imagePaths        ~= nil)
        assert(type(particleParams.imagePaths)  == 'table')
        assert(particleParams.particleType ~= nil)
        assert(particleParams.rate ~= nil)
        assert(particleParams.duration ~= nil)
        
        for i, path in ipairs(particleParams.imagePaths) do
            assert(Utils.isFileExists(path), 'File not found: '..path, ELogLevel.ELL_WARNING) 
        end
        
        managerParticles:particleProvider().SetParticleProperty(particleParams.particleType, "imagePath", particleParams.imagePaths)
        
        managerParticles:particleProvider().AttachParticleType(
        self._emmiterName,                      --EMITTER NAME
        particleParams.particleType,            --PARTICLE TYPE NAME
        particleParams.rate,                    --EMISSION RATE
        particleParams.duration,                --DURATION
        0)                                      --DELAY
    end
    
    
    managerParticles:particleProvider().StartEmitter(self._emmiterName, self._oneShoot)
end

function ViewParticle.resumeGeneration(self)
    GameInfo:instance():managerParticles():particleProvider().StartEmitter(self._emmiterName, self._oneShoot)
end

function ViewParticle.pauseGeneration(self)
    GameInfo:instance():managerParticles():particleProvider().StopEmitter(self._emmiterName)
end

function ViewParticle.cleanup(self)
    local managerParticles = GameInfoBase:instance():managerParticles()
    
    if(managerParticles:particleProvider():GetEmitter(self._emmiterName) ~= nil)then
        managerParticles:particleProvider().StopEmitter(self._emmiterName)
    end
    
    if(not self._autodestroy)then
        managerParticles:particleProvider().DeleteEmitter(self._emmiterName)
    end
    
    managerParticles:particleProvider().ClearParticles(self._emmiterName)
    
    local emmiters = managerParticles:emmiters()
    
    for i = 1, #emmiters, 1 do
        local emmiter = emmiters[i]
        
        if(emmiter == self._sourceView)then
            table.remove(emmiters, i)
            break;
        end
        
    end
    
    self._sourceView = nil
    
    ViewBase.cleanup(self)
end