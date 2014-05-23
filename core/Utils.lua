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

function Utils.isSimulator()
    return "simulator" == system.getInfo("environment")
end


function Utils.getPlatformType()
    local result = system.getInfo("platformName")
    
    return result
end


--
-- io
--

local notReadableExtentionsAndroid = 
{
    'html', 
    'htm', 
    '3gp', 
    'm4v', 
    'mp4', 
    'png', 
    'jpg',  
    'rtf'
}

--check is file exists
--WARNING: do not use for check directory. For windows it not works properly
--if base dir not present - try found in resource directory 
function Utils.isFileExists(fileName, baseDir)
    
    assert(fileName ~= nil)
    
    local result = false
    
    if(baseDir == nil)then
        print('Utils:isFileExists. base dir not specified. Use resource dir by default', ELogLevel.ELL_WARNING)
        baseDir = system.ResourceDirectory
    end
    
    local filePath = system.pathForFile(fileName, baseDir)
    
    if(application.platform_type == EPlatformType.EPT_ANDROID) then
        
        local fileExtension = getFileExtension(fileName)
        
        if(table.indexOf(notReadableExtentionsAndroid, fileExtension) ~= nil and baseDir == system.ResourceDirectory)then
            --android not found this file
            --returns true for avoid asertion
            result = true
        end
    end
    
    if(not result and filePath ~= nil)then
        local mode =    lfs.attributes(filePath, "mode")
        result = mode ~= nil
    end
    
    if(not result)then
        print(string.format("Not found file : %s", tostring(filePath)), ELogLevel.ELL_WARNING)
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
        
        if(application.debug_io)then
            if(result)then
                print('File remove success\n'..path)
            else
                print('File remove error\n'..path..'\n'..errorMsg)
            end
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
--public functions
--
function getString(data, ignoreTables)
    local result = ""
    
    local dataType = type(data)
    
    if( dataType == ELuaType.ELT_NUMBER  or 
        dataType == ELuaType.ELT_STRING  or 
        dataType == ELuaType.ELT_BOOLEAN or
        dataType == ELuaType.ELT_NIL     or
        dataType == ELuaType.ELT_FUNCTION)then
        
        result = tostring(data)..' ('..dataType..')'
        
    elseif(dataType == ELuaType.ELT_TABLE)then
        
        if(ignoreTables == nil)then
            ignoreTables = {}
        end
        
        if(table.indexOf(ignoreTables, data) == nil)then
            table.insert(ignoreTables, data)
            
            result = result..'\n'..dataType..':\n'
            for key, value in pairs(data)do
                result = result..getString(key, ignoreTables)..'\t\t=\t\t'..getString(value, ignoreTables)..',\n'
            end
        end
    elseif(dataType == ELuaType.ELT_USERDATA)then
        --do nothing
        result = result..' ('..dataType..')'
    else
        assert(false)
    end
    
    return result
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

function getFilenameWithoutExtention(filePath)
    local result = nil
    
    local fileExtension = getFileExtension(filePath)
    
    result  = string.gsub(filePath, "."..fileExtension, "")
    
    return result
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
        if(isDirectoryCreate == true and application.debug_io)then
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

--todo: review
function vardump(value, depth, key)
    local linePrefix = ""
    local spaces = ""
    
    if key ~= nil then
        linePrefix = "["..key.."] = "
    end
    
    if depth == nil then
        depth = 0
    else
        depth = depth + 1
        for i=1, depth do spaces = spaces .. "  " end
    end
    
    if type(value) == 'table' then
        mTable = getmetatable(value)
        if mTable == nil then
            print(spaces ..linePrefix.."(table) ")
        else
            print(spaces .."(metatable) ")
            value = mTable
        end
        for tableKey, tableValue in pairs(value) do
            vardump(tableValue, depth, tableKey)
        end
    elseif  type(value)         == 'function'   or
        type(value)         == 'thread'     or
        type(value)         == 'userdata'   or
        value               == nil
	then
        print(spaces..tostring(value))
    else
        print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
    end
end

