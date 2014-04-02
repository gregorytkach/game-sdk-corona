require('sdk.core.ELuaType')

local lfs = require 'lfs'


--
--internal functions
--

local function isFileExistsInternal(path)
    local result = false
    
    --todo: change open to get attributes
    
    local fileHandler, errorMessage = io.open(path, "r")
    
    if (fileHandler ~= nil) then 
        io.close(fileHandler)
        
        result = true 
    else
        print(string.format("Not found file : %s \n %s", path, errorMessage), ELogLevel.ELL_WARNING)
    end 
    
    return result
end

local function getAllFilesInternal(path)
    local result = {}
    
    for fileName in lfs.dir(path) do
        table.insert(result, fileName)
    end
    
    return result
end

local function getIsDirectoryInternal(filePath)
    return  lfs.attributes(filePath, "mode") == "directory"
end

local function removeDirectoryInternal(path)
    assert(path ~= nil)
    
    if(not isFileExistsInternal(path))then
        print('Dir not exists. Nothing to remove.\n'..path, ELogLevel.ELL_WARNING)
        return true
    end
    
    assert(getIsDirectoryInternal(path))
    
    local result = true
    
    local filesInDir = getAllFilesInternal(path)
    
    for _, fileName in ipairs(filesInDir) do
        
        if(fileName ~= '.' and fileName ~= '..')then
            
            local filePath = path..'/'..fileName
            
            if(getIsDirectoryInternal(filePath))then
                
                result = removeDirectoryInternal(filePath)
                
                if(result)then
                    print('Dir remove success:')
                    print(filePath)
                else
                    break
                end
            else
                
                local resultOK, errorMsg = os.remove(filePath)
                
                result = resultOK ~= nil
                
                if( result)then
                    print('File remove success:\n'..filePath)
                else
                    print('File remove error\n'..filePath..'\n'..errorMsg)
                    
                    break
                end
                
            end
        end
    end
    
    if(result)then
        local resultOK, errorMsg = os.remove(path)
        
        result = resultOK ~= nil
        
        if(result)then
            print('Dir remove success\n'..path)
        else
            print('Dir remove error\n'..path..'\n'..errorMsg)
        end
        
    end
    
    return result
end

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

--check is file exists
--WARNING: do not use for check directory. For windows it not works properly
--if base dir not present - try found in resource directory 
function isFileExists(fileName, baseDir)
    
    assert(fileName ~= nil)
    
    local result = false
    
    if(baseDir == nil)then
        baseDir = system.ResourceDirectory
    end
    
    local filePath = system.pathForFile(fileName, baseDir)
    
    if(filePath ~= nil)then
        result = isFileExistsInternal(filePath)
    else
        print(string.format("Not found file : %s", fileName), ELogLevel.ELL_WARNING)
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

function getAllFilesInDirectory(dirName, baseDir)
    assert(dirName ~= nil)
    assert(baseDir ~= nil)
    
    local result = {}
    
    local needCheckFile = application.platform_type == EPlatformType.EPT_UNIX
    
    local fileExists = true
    
    if(needCheckFile)then
        fileExists = isFileExists(dirName, baseDir)
    end
    
    if(fileExists)then
        
        local path = system.pathForFile(dirName, baseDir)
        
        result = getAllFilesInternal(path)
    end
    
    return result
end


--returns true if path is directory
--if path not exists -> for unix returns false, for windows returns true
function getIsDirectory(fileName, baseDir)
    --    assert(fileName ~= nil)
    --    assert(baseDir ~= nil)
    --    
    --    local result = false
    --    
    --    local path = system.pathForFile(fileName, baseDir)
    --    
    --    local fileHandler, _ = io.open(path, 'r')
    --    
    --    if(fileHandler == nil)then
    --        
    --        if(application.platform_type == EPlatformType.EPT_WIN)then
    --            result = true 
    --        end
    --        
    --    else
    --        
    --        local _, errorMessage = fileHandler:read(1)
    --        io.close(fileHandler)
    --        
    --        if(errorMessage ~= nil) then
    --            result = true
    --        end
    --    end
    --    
    --    return result
    
    assert(fileName ~= nil)
    assert(baseDir ~= nil)
    
    local result = false
    
    local path = system.pathForFile(fileName, baseDir)
    
    result = getIsDirectoryInternal(path)
    
    return result
end



-- remove directory recursively
-- return true if remove success
function removeDirectory(fileName, baseDir)
    if(not isFileExists(fileName, baseDir))then
        print('Dir not exists. Nothing to remove.\n'..fileName, ELogLevel.ELL_WARNING)
        
        return true
    end
    
    assert(getIsDirectory(fileName, baseDir))
    
    local result =  removeDirectoryInternal(system.pathForFile(fileName, baseDir))
    
    return result
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
