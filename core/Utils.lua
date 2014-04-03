require('sdk.core.ELuaType')
require('sdk.core.Object')

Utils = classWithSuper(Object, 'Utils')

--
-- Static fields
--

local lfs = require 'lfs'

--
-- Properties
--

--
-- Methods
--

function Utils.getPlatformType()
    local result = system.getInfo("platformName")
    
--    if( systemName == 'Mac OS X'  or
--        systemName == 'iPhone OS')then
--        
--        result = EPlatformType.EPT_UNIX
--        
--    elseif( systemName == 'Win' or 
--            systemName == 'Android')then
--        
--        result = EPlatformType.EPT_WIN
--        
--    else
----        local path = system.pathForFile('', system.ResourceDirectory)
----        
----        local directoryHandler = io.open(path)
----        
----        if(directoryHandler == nil)then
----            result = EPlatformType.EPT_WIN
----        else
----            directoryHandler:close()
----            result = EPlatformType.EPT_UNIX
----        end 
--    end
        
    return result
end


--check is file exists
--WARNING: do not use for check directory. For windows it not works properly
--if base dir not present - try found in resource directory 
function Utils.isFileExists(fileName, baseDir)
    
    assert(fileName ~= nil)
    
    local result = false
    
    if(baseDir == nil)then
        print('Utils:isFileExists. base dir not specified. Use resource dir by default')
        baseDir = system.ResourceDirectory
    end
    
    local filePath = system.pathForFile(fileName, baseDir)
    
    print('try find:')
    print(filePath)
    
    if(filePath ~= nil)then
        
        local mode =    lfs.attributes(filePath, "mode")
        result = mode ~= nil
    end
    
    if(not result)then
        print(string.format("Not found file : %s", filePath), ELogLevel.ELL_WARNING)
    end
    
    return result
end

--returns true if path is directory
--if path not exists -> for unix returns false, for windows returns true
function Utils.getIsDirectory(fileName, baseDir)
    assert(fileName ~= nil)
    assert(baseDir ~= nil)
    
    local result = false
    
    local path = system.pathForFile(fileName, baseDir)
    
    result = lfs.attributes(path, "mode") == "directory"
    
    return result
end

-- remove directory recursively
-- return true if remove success
function Utils.removeDirectoryOrFile(targetName, baseDir)
    assert(targetName   ~= nil)
    assert(baseDir      ~= nil)
    
    if(not Utils.isFileExists(targetName, baseDir))then
        print('File not exists. Nothing to remove.\n'..targetName, ELogLevel.ELL_WARNING)
        
        return false
    end
    
    local result = true
    
    local path  = system.pathForFile(targetName, baseDir)
    
    if(Utils.getIsDirectory(targetName, baseDir))then
        
        print(targetName..' is a directory')
        
        --remove subfiles and subdirectories
        local filesInDir = Utils.getAllFilesInDirectory(targetName, baseDir)
        
        for _, fileName in ipairs(filesInDir) do
            
            local filePath = targetName..'/'..fileName
            
            result = Utils.removeDirectoryOrFile(filePath, baseDir)
            
            if(not result)then
                break
            end
            
        end
        
    end
    
    if(result)then
        local resultOK, errorMsg = os.remove(path)
        
        result = resultOK ~= nil
        
        if(result)then
            print('File remove success\n'..path)
        else
            print('File remove error\n'..path..'\n'..errorMsg)
        end
    end
    
    return result
end

function Utils.getAllFilesInDirectory(dirName, baseDir)
    assert(dirName ~= nil)
    assert(baseDir ~= nil)
    
    local result = {}
    
    local fileExists =  Utils.isFileExists(dirName, baseDir)
    
    if(fileExists)then
        
        local path = system.pathForFile(dirName, baseDir)
        
        for fileName in lfs.dir(path) do
            
            if(fileName ~= '.' and fileName ~= '..')then
                table.insert(result, fileName)
            end
        end
        
    end
    
    return result
end

--
--internal functions
--




--
--public functions
--

function getString(data)
    local result = ""
    
    local dataType = type(data)
    
    if( dataType == ELuaType.ELT_NUMBER  or 
        dataType == ELuaType.ELT_STRING  or 
        dataType == ELuaType.ELT_BOOLEAN or
        dataType == ELuaType.ELT_NIL)then
        
        result = tostring(data)
        
    elseif(dataType == ELuaType.ELT_TABLE)then
        
        for key, value in pairs(data)do
            result = result..getString(key)..'='..getString(value)..'\n'
        end
        
    else
        assert(false)
    end
    
    return result
end

function isSimulator()
    return "simulator" == system.getInfo("environment")
end

--- Removes all references to a module.
-- Do not call unrequire on a shared library based module unless you are 100% confidant that nothing uses the module anymore.
-- @param m Name of the module you want removed.
-- @return Returns true if all references were removed, false otherwise.
-- @return If returns false, then this is an error message describing why the references weren't removed.
function unrequire(m)
    
    local result = true
    
    package.loaded[m] = nil
    _G[m] = nil
    
    -- Search for the shared library handle in the registry and erase it
    local registry = debug.getregistry()
    local nMatches, mKey, mt = 0, nil, registry['_LOADLIB']
    
    for key, ud in pairs(registry) do
        if type(key) == 'string' 
            and type(ud) == 'userdata' 
            and getmetatable(ud) == mt 
            and string.find(key, "LOADLIB: .*" .. m) then
            
            nMatches = nMatches + 1
            
            if (nMatches > 1) then
                result = false
                
                print("More than one possible key for module '" .. m .. "'. Can't decide which one to erase.")
                
                break;
            end
            
            mKey = key
        end
    end
    
    if (mKey ~= nil and result) then
        registry[mKey] = nil
    end
    
    return result
end





function getFileExtension(filePath)
    local _, _, fileExtension  = string.match(filePath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    
    return fileExtension
end

function getFileName(filePath)
    local _, fileName, _  = string.match(filePath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    
    return fileName
end


function getFilePath(filePath)
    local filePath, _, _  = string.match(filePath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    
    return filePath
end

function getParentFolder(filePath)
    local parentFolder, fileName = string.match(filePath, "^(.*[\/\\])([^\/\\]+)")
    
    return parentFolder
end

function createParentDirectories(fileName, baseDir)
    assert(fileName ~= nil)
    assert(baseDir  ~= nil)
    
    local directoriesToCreate       = {}
    local parentFolder              = getParentFolder(fileName)
    
    while parentFolder ~= nil do
        table.insert(directoriesToCreate, parentFolder)
        
        parentFolder = getParentFolder(parentFolder)
    end
    
    for i = #directoriesToCreate, 1, -1 do
        local currentFolder = directoriesToCreate[i]
        
        local dirPath = system.pathForFile(currentFolder, baseDir)
        
        local isDirectoryCreate =  lfs.mkdir(dirPath)
        if(isDirectoryCreate == true)then
            print("Directory created\n"..dirPath)
        end
        
    end
end








function getClone(data)
    assert(data ~= nil)
    
    local result = {}
    
    for key, value in pairs(data)do
        
        if(type(value) == 'table')then
            result[key] = getClone(value)
        else
            result[key] = value
        end
        
    end
    
    return result
end