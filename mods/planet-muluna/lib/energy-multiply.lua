local get_energy_value = require("__flib__.data-util").get_energy_value

local Public = {}

function Public.multiply_energy(value,factor) 
    if type(value) == "string" then
        local val,suffix=get_energy_value(value)
        return val*factor .. suffix 
    else
        return value*factor
    end
    
end


return Public