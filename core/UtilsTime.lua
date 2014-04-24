require('sdk.core.Object')

UtilsTime = classWithSuper(Object, 'UtilsTime')

function UtilsTime.makeTimeStamp(dateString, mode)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%p])(%d*)%:?(%d*)";
    
    local xyear 
    local xmonth
    local xday
    local xhour
    local xminute 
    local xseconds 
    local xoffset
    local xoffsethour
    local xoffsetmin
    
    local monthLookup = 
    {
        Jan = 1, 
        Feb = 2, 
        Mar = 3, 
        Apr = 4, 
        May = 5, 
        Jun = 6, 
        Jul = 7, 
        Aug = 8, 
        Sep = 9, 
        Oct = 10, 
        Nov = 11, 
        Dec = 12
    }
    
    local convertedTimestamp    = nil
    local offset                = 0
    
    if mode and mode == "ctime" then
        pattern = "%w+%s+(%w+)%s+(%d+)%s+(%d+)%:(%d+)%:(%d+)%s+(%w+)%s+(%d+)"
        
        local monthName
        local TZName
        
        monthName, xday, xhour, xminute, xseconds, TZName, xyear = string.match(dateString, pattern)
        
        xmonth              = monthLookup[monthName]
        
        convertedTimestamp  = os.time(
        {
            year    = xyear, 
            month   = xmonth,
            day     = xday, 
            hour    = xhour, 
            min     = xminute, 
            sec     = xseconds
        })
    else
        xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin = string.match(dateString, pattern)
        
        convertedTimestamp = os.time(
        {   
            year    = xyear, 
            month   = xmonth,
            day     = xday, 
            hour    = xhour, 
            min     = xminute, 
            sec     = xseconds
        })
        
        if xoffsetHour ~= nil then
            offset = xoffsethour * 60 + xoffsetmin
            if xoffset == "-" then
                offset = offset * -1
            end
        end
    end
    
    return convertedTimestamp + offset
end

