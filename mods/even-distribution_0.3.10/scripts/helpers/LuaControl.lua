local control = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaControl --

function control:itemcount(...)
    if self.is_player() then 
        return self:playeritemcount(...) 
    else
        return self.get_item_count(...)
    end
end

function control:requests(...)
    if self.is_player() then 
        return _(self.character):entityrequests(...) 
    else
        return self:entityrequests(...) 
    end
end

function control:request(...)
    if self.is_player() then 
        return _(self.character):entityrequest(...) 
    else
        return self:entityrequest(...) 
    end
end

function control:remainingRequest(item)
	return self:request(item) - self.get_item_count(item)
end

function control:inventory(name)
    if name == nil or name == "main" then -- get main inventory
        return self.get_main_inventory()

    elseif name == "input" then
        return self.get_inventory(defines.inventory.furnace_source) or
               self.get_inventory(defines.inventory.assembling_machine_input) or
               self.get_inventory(defines.inventory.lab_input) or
               self.get_inventory(defines.inventory.rocket_silo_rocket)
    
    elseif name == "output" then
        return self.get_output_inventory()
    
    elseif name == "modules" then
        return self.get_module_inventory()
    end
    
    -- get specific inventory
    return self.get_inventory(defines.inventory[name])
end

function control:contents(name)
    if name == nil and self.is_player() then 
        return self:playercontents() 
    end

    local inv = self:inventory(name)
    if _(inv):isnot("valid") then return {} end
    return inv.get_contents()
end