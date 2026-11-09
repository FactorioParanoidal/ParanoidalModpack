local rro = Muluna.rro

function get_all_matching_name(name) 
    local types = {"entity","item","recipe"}
    local out = {}
    for _,type in pairs(types) do
        local prototype = Muluna.flib_prototypes.find(type,name)
            --if prototype.name == name then
                table.insert(out,prototype)
                
            --end
        
    end
    return out


end

local data_pump_set = table.deepcopy(get_all_matching_name("pump"))

--rro.deep_replace(data_pump_set,"pump","muluna-data-pump")
data_pump_set[1].type = "pump"

Muluna:extend(data_pump_set)

