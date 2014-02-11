EScaleType = 
{
    ["EST_MIN"]             = "EST_MIN";
    ["EST_MAX"]             = "EST_MAX";
    ["EST_FILL_HEIGHT"]     = "EST_FILL_HEIGHT";
    ["EST_FILL_WIDTH"]      = "EST_FILL_WIDTH";
    ["EST_NONE"]            = "EST_NONE";
}    

function EScaleType.getScale(scaleType)
    assert(scaleType ~= nil)
    
    local result
    
    if(scaleType == EScaleType.EST_FILL_HEIGHT)then
        result = application.scaleFillHeight
    elseif(scaleType == EScaleType.EST_FILL_WIDTH)then
        result = application.scaleFillWidth
    elseif(scaleType == EScaleType.EST_MIN)then
        result = application.scaleMin
    elseif(scaleType == EScaleType.EST_MAX)then
        result = application.scaleMax
    elseif(scaleType == EScaleType.EST_NONE)then
        result = application.scaleNone
    else
        assert(false)
    end
    
    return result
end


