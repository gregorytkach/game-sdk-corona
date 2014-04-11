UtilsArray = classWithSuper(Object, 'UtilsArray')

--
-- Properties
--

--
-- Methods
--

function UtilsArray.sortQuick(array, sortBy)
    assert(array    ~= nil)
    assert(sortBy   ~= nil)
        
     for i = 2, #array, 1 do
        local value = array[i]
        
        local indexJ = i - 1
        
        local valueToCompare = array[indexJ]
        
        while indexJ >= 1 and valueToCompare[sortBy] > value[sortBy] do
            array[indexJ + 1] = array[indexJ]
            
            indexJ = indexJ - 1
            
            valueToCompare = array[indexJ]
        end
        
        array[indexJ + 1] = value
    end
    
end