
ManagerFontsBase = classWithSuper(Object, 'ManagerFontsBase')

--
--Properties
--

function ManagerFontsBase.needManageMemory(self)
    return false
end


function ManagerFontsBase.getFontSize(self, fontType)
    assert(fontType ~= nil)
    
    local result = self._fontSizes[fontType]
    
    assert(result ~= nil, 'Not found size for font type '..fontType)
    
    return result
end

function ManagerFontsBase.textProvider(self)
    return self._textProvider
end

--
--Methods
--

function ManagerFontsBase.init(self)
    self._textProvider = require("vendors.lib_text_candy")
    
    self._loadedFonts   = {}
    self._fontSizes     = {}
end

function ManagerFontsBase.loadFont(self, fontType, fontPath, fontImage, fontSize)
    assert(self._loadedFonts[fontType] == nil, 'font already loaded')
    
    assert(Utils.isFileExists(fontPath))
    
    if(application.platform_type ~= EPlatformType.EPT_ANDROID)then
        assert(Utils.isFileExists(fontImage))
    end
    
    self._textProvider.AddCharsetFromBMF(fontType, fontPath, fontImage, "", fontSize)
    
    self._fontSizes[fontType] = fontSize * application.scaleFactor
    
    self._loadedFonts[fontType] = true
end

function ManagerFontsBase.cleanup(self)
    
    for key, value in pairs(self._loadedFonts)do
        self._textProvider.RemoveCharset(key)
    end
    
    
    Object.cleanup(self)
end
