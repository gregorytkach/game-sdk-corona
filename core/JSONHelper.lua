JSONHelper = classWithSuper(Object, 'JSONHelper')

--
-- Static fields
--

local json = require('json')

--
-- Properties
--

--
-- Methods
--

function JSONHelper.init(self)
    assert(false, 'Please use it like static class')
end


--returns data from file
--if base dir not specified - try find file in resource directory
function JSONHelper.getDataFrom(fileName, baseDir)
    assert(fileName ~= nil, 'File name must be non nil')
    
    local result = nil
    
    -- set default base dir if none specified
    if baseDir == nil then 
        baseDir = system.ResourceDirectory; 
    end
    
    -- create a file path for corona i/o
    local path = system.pathForFile(fileName, baseDir)
    
    if(path == nil)then
        print(string.format("not found file %s", fileName), ELogLevel.ELL_WARNING)
    else
        -- io.open opens a file at path. returns nil if no file found
        local fileHandler, errorMessage = io.open(path, "r")
        
        if fileHandler == nil then
            print(string.format("cant open file %s for read.\nError: %s", path, errorMessage), ELogLevel.ELL_WARNING)
        else
            -- read all contents of file into a string
            local contents = fileHandler:read("*a")
            -- close the file after using it
            io.close( fileHandler )	
            
            if(contents ~= nil)then
                result = json.decode(contents)
                
                if(result ~= nil and application.debug_io)then
                    print(string.format('Succefully load json data from file \n%s', path))
                end
            end
        end
    end
    
    
    return result
end

--save data to file and returns status
--if file exists - just override it
--if base dir not specified - try save file to documents directory
function JSONHelper.saveDataTo(data, fileName, baseDir)
    assert(data         ~= nil,     'data must be non nil')
    assert(type(data)   =='table',  'data should be a table')
    assert(fileName     ~= nil,     'File name must be non nil')
    
    local result = false
    
    if baseDir == nil then 
        baseDir = system.DocumentsDirectory; 
    end
    
    local content = json.encode(data)
    
    if(content == nil)then
        print('cant encode data to json '..fileName, ELogLevel.ELL_WARNING)
    else
        
        createParentDirectories(fileName, baseDir)
        
        local path = system.pathForFile(fileName, baseDir)
        
        if(path == nil)then
            print('cant save data to file\n'..fileName, ELogLevel.ELL_WARNING)
        else
            
            local fileHandler, errorMessage = io.open(path, "w")
            
            if(fileHandler == nil)then
                print(string.format("cant open file %s for write. Error: %s", path, errorMessage), ELogLevel.ELL_WARNING)
            else
                
                fileHandler:write(content)
                
                io.close(fileHandler)
                
                if(application.debug_io)then
                    print("Save data to file success \n"..path)
                end
                
                result = true
            end
            
        end
    end
    
    return result
end


