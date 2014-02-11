require('sdk.models.string.ELanguageType')

ManagerStringBase = classWithSuper(Object, 'ManagerStringBase')

--
-- Properties
--

function ManagerStringBase.needManageMemory(self)
    return false
end

function ManagerStringBase.setCurrentLanguage(self, value)
    self._currentLanguage = self._languages[value]
    
    assert(self._currentLanguage ~= nil, 'Language not present')
end

--
-- Methods
--

function ManagerStringBase.init(self)
    self._languages = {}
    
end

function ManagerStringBase.initLanguageEnglish(self)
    self._languages[ELanguageType.ELT_ENGLISH] = {}
end

function ManagerStringBase.initLanguageRussian(self)
    self._languages[ELanguageType.ELT_RUSSIAN] = {}
end

function ManagerStringBase.getString(self, stringType)
    assert(self._currentLanguage ~= nil,'Current language not initialized')
    
    local result = self._currentLanguage[stringType]
    
    assert(result ~= nil, string.format('Not found string type %s', stringType))
    
    return result
end
