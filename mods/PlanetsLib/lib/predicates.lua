--- Library of functions to make more detailed filters 
--- 
local Public = {}

--- Generates a simple comparison predicate
function Public.compare(comparison, value)
    if comparison == "<" then
        return function(other) return other < value end
    elseif comparison == "<=" then
        return function(other) return other <= value end
    elseif comparison == ">" then
        return function(other) return other > value end
    elseif comparison == ">=" then
        return function(other) return other >= value end
    elseif comparison == "==" then
        return function(other) return other == value end
    elseif comparison == "~=" then
        return function(other) return other ~= value end
    else
        error("Unsupported comparison operator: " .. tostring(comparison))
    end
end

function Public.equals(value)
    return Public.compare("==", value) 
end

return Public