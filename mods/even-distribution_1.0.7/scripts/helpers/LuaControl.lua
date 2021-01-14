local config = require("config")
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
        return self.get_main_inventory() or
               (self.type == "container" and self.get_inventory(defines.inventory.chest)) or
               (self.type == "logistic-container" and self.get_inventory(defines.inventory.chest)) or
               (self.type == "car" and self.get_inventory(defines.inventory.car_trunk)) or
               (self.type == "spider-vehicle" and self.get_inventory(defines.inventory.car_trunk)) or
               (self.type == "cargo-wagon" and self.get_inventory(defines.inventory.cargo_wagon)) or
               (self.type == "rocket-silo" and self.get_inventory(defines.inventory.rocket_silo_rocket))

    elseif name == "input" then
        return (self.type == "furnace" and self.get_inventory(defines.inventory.furnace_source)) or
               (self.type == "assembling-machine" and self.get_inventory(defines.inventory.assembling_machine_input)) or
               (self.type == "lab" and self.get_inventory(defines.inventory.lab_input)) or
               (self.type == "rocket-silo" and self.get_inventory(defines.inventory.assembling_machine_input))
    
    elseif name == "output" then
        return self.get_output_inventory()
    
    elseif name == "modules" then
        return self.get_module_inventory()
    
    elseif name == "ammo" then
        return (self.type == "ammo-turret" and self.get_inventory(defines.inventory.turret_ammo)) or
               (self.type == "car" and self.get_inventory(defines.inventory.car_ammo)) or
               (self.type == "spider-vehicle" and self.get_inventory(defines.inventory.car_ammo)) or
               (self.type == "artillery-wagon" and self.get_inventory(defines.inventory.artillery_wagon_ammo)) or
               (self.type == "artillery-turret" and self.get_inventory(defines.inventory.artillery_turret_ammo)) or
               (self.type == "character" and self.get_inventory(defines.inventory.character_ammo)) or
               (self.type == "character" and self.get_inventory(defines.inventory.editor_ammo))
    
    elseif name == "fuel" then
        return self.get_fuel_inventory()
    
    elseif name == "burnt_result" then
        return self.get_burnt_result_inventory()
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

local function insert(self, name, item, amount)
    if amount <= 0 then return 0 end
    local inv = self:inventory(name)
    if inv then
        -- inv.sort_and_merge()
        local inserted = inv.insert{ name = item, count = amount }
        if inserted < amount then  -- retry for things like furnace ingredients (can be overfilled)
            inserted = inserted + inv.insert{ name = item, count = amount - inserted }
        end
        return inserted
    end
    return 0
end

-- priority insert with fuel and ammo limits
function control:customInsert(player, item, amount, takenFromCar, takenFromTrash, replaceItems, useFuelLimit, useAmmoLimit, useRequestLimit, allowed)
    if amount <= 0 then return 0 end

    local inserted = 0
    local prototype = _(game.item_prototypes[item])

    -- allow/disallow insertion into specific inventories by passing table with true/false values (default is allow)
    allowed = _({
        fuel     = true, -- set default values
        ammo     = true,
        input    = true,
        output   = true,
        modules  = true,
        roboport = true,
        main     = true,
    }):set(allowed or {}):toPlain()
    
    if allowed.fuel and prototype:is("fuel") then
        local inv = self:inventory("fuel")
        if inv then
            local limit = useFuelLimit and math.min(amount, math.max(0, player:itemLimit(prototype, config.fuelLimitProfiles) - inv.get_item_count(item))) or amount

            local insertedHere = insert(self, "fuel", item, limit)
            limit = limit - insertedHere

            -- no space left --> replace inferior items
            if replaceItems and limit > 0 then
                for __,inferiorFuel in pairs(global.fuelList[prototype.fuel_category]) do
                    if inferiorFuel.name == prototype.name or limit <= 0 then break end

                    local returnToPlayer = 0
                    while limit > 0 do
                        local stack = inv.find_item_stack(inferiorFuel.name)
                        local returnCount = stack and stack.count or 0
                        if stack and stack.set_stack{ name = item, count = limit } then
                            limit = limit - stack.count
                            insertedHere = insertedHere + stack.count
                            returnToPlayer = returnToPlayer + returnCount
                        else
                            break
                        end
                    end

                    if returnToPlayer > 0 then
                        player:returnItems(inferiorFuel.name, returnToPlayer, takenFromCar, takenFromTrash)
                    end
                end
            end

            inserted = inserted + insertedHere
            amount = amount - insertedHere
        end
    end

    if amount <= 0 then return inserted end
	if allowed.ammo and prototype:is("ammo") then
        local inv = self:inventory("ammo")
        if inv then
            local limit = useAmmoLimit and math.min(amount, math.max(0, player:itemLimit(prototype, config.ammoLimitProfiles) - inv.get_item_count(item))) or amount

            local insertedHere = insert(self, "ammo", item, limit)
            limit = limit - insertedHere

            -- no space left --> replace inferior items
            if replaceItems and limit > 0 then
                for __,inferiorAmmo in pairs(global.ammoList[prototype.get_ammo_type().category]) do
                    if inferiorAmmo.name == prototype.name or limit <= 0 then break end

                    local returnToPlayer = 0
                    while limit > 0 do
                        local stack = inv.find_item_stack(inferiorAmmo.name)
                        local returnCount = stack and stack.count or 0
                        if stack and stack.set_stack{ name = item, count = limit } then
                            limit = limit - stack.count
                            insertedHere = insertedHere + stack.count
                            returnToPlayer = returnToPlayer + returnCount
                        else
                            break
                        end
                    end
                    
                    if returnToPlayer > 0 then
                        player:returnItems(inferiorAmmo.name, returnToPlayer, takenFromCar, takenFromTrash)
                    end
                end
            end

            inserted = inserted + insertedHere
            amount = amount - insertedHere
        end
    end
    
    if amount <= 0 then return inserted end
    if allowed.input then
        local insertedHere = insert(self, "input", item, amount)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
        if insertedHere > 0 then allowed.main = false end
	end
    
    if amount <= 0 then return inserted end
    if allowed.output and self:recipe():hasProduct(item) then
        local insertedHere = insert(self, "output", item, amount)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
	end

    if amount <= 0 then return inserted end
    if allowed.modules then
        local insertedHere = insert(self, "modules", item, amount)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
        if insertedHere > 0 then allowed.main = false end
    end

    if allowed.roboport and self.type == "roboport" then
        if amount <= 0 then return inserted end
        local insertedHere = insert(self, "roboport_robot", item, amount)
        inserted = inserted + insertedHere
        amount = amount - insertedHere

        if amount <= 0 then return inserted end
        insertedHere = insert(self, "roboport_material", item, amount)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
    end
    
    if amount <= 0 then return inserted end
    if allowed.main then
        local limit = useRequestLimit and math.min(amount, math.max(0, self:remainingRequest(item))) or amount
        local insertedHere = insert(self, "main", item, limit)
        
        inserted = inserted + insertedHere
        amount = amount - insertedHere
	end

    return inserted
end