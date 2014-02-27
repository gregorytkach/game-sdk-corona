local lfs = require 'lfs'

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
--if base dir not present - try found in resource directory 
function isFileExists(fileName, baseDir)
    
    assert(fileName ~= nil)
    
    local result = false
    
    if(baseDir == nil)then
        baseDir = system.ResourceDirectory
    end
    
    local filePath = system.pathForFile(fileName, baseDir)
    
    if(filePath ~= nil)then
        local fileHandler = io.open(filePath, "r")
        
        if (fileHandler ~= nil) then 
            io.close(fileHandler)
            
            result = true 
        else
            print(string.format("[WARNING]:Not found file : %s", filePath))
        end 
    else
        print(string.format("[WARNING]:Not found file : %s", fileName))
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
            print("Directory created "..dirPath)
        end
        
    end
end

function getAllFilesInDirectory(dirName, baseDir)
    assert(dirName ~= nil)
    assert(baseDir ~= nil)
    
    local result = {}
    
    if isFileExists(dirName, baseDir)then
        
        local path = system.pathForFile(dirName, baseDir)
        
        for fileName in lfs.dir(path) do
            table.insert(result, fileName)
        end
    end
    
    return result
end

function getIsDirectory(fileName, baseDir)
    assert(fileName ~= nil)
    assert(baseDir ~= nil)
    
    local result = false
    
    local path = system.pathForFile(fileName, baseDir)
    
    local fileHandler = io.open(path, 'r')
    
    local firstByte, errorMessage = fileHandler:read(1)
    
    if(errorMessage ~= nil) then
        result = true
    end
    
    return result
end
