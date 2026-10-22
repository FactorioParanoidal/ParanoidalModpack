local config = require("config")
local protocache = require("scripts.protocache")
local itemstate = require("scripts.itemstate")
local qualities = require("scripts.quality")
local control = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaControl --

function control:request(item, quality) -- fetch specific item request (Paranoidal: of a quality, nil = normal)
	local count = 0
	local logisticPoint = _(self:requesterPoint())
    
    if logisticPoint:is("valid") then
        local filters = logisticPoint.filters

        if filters then
            _(filters):each(function(__, filter)
                if filter and filter.name == item and filter.count > count and qualities.matches(filter, quality) then
                    count = math.max(count, filter.count)
                end
            end)
        end
    end
	
	return count
end

function control:requesterPoint()
    if self.is_player() and _(self.character):is("valid") then
        return self.character.get_requester_point()
    elseif self.is_player() and _(self.cutscene_character):is("valid") then
        return self.cutscene_character.get_requester_point()
    else
        return self.get_requester_point()
    end
end

-- fetch all requests as a dict[name -> array of CompiledLogisticFilter] (Paranoidal: every quality, in slot order)
function control:logisticSlots()
	local logisticSlots = {}
	local logisticPoint = _(self:requesterPoint())

    if logisticPoint:is("valid") then
        local filters = logisticPoint.filters

        if filters then
            _(filters):each(function(__, filter)
                if filter and filter.name then
                    local list = logisticSlots[filter.name] or {}
                    list[#list + 1] = filter
                    logisticSlots[filter.name] = list
                end
            end)
        end
    end
	
	return logisticSlots
end

-- Paranoidal: optional quality (name, nil = normal) as the last argument.
function control:itemcount(item, includeInv, includeCar, quality)
    if self.is_player() then 
        return self:playeritemcount(item, includeInv, includeCar, quality)
    else
        return self.get_item_count({ name = item, quality = quality or "normal" })
    end
end

-- All qualities of an item in an inventory: fuel and ammo limits count every quality (user decision).
local function countAllQualities(inv, item)
    local count = 0
    for __, content in pairs(inv.get_contents()) do
        if content.name == item then count = count + content.count end
    end
    return count
end

function control:remainingRequest(item, quality)
	return self:request(item, quality) - self:itemcount(item, nil, nil, quality)
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

    local contents = inv.get_contents()
    local contents_converted = {}
    for __, content in pairs(contents) do
        if content.quality == "normal" then
            contents_converted[content.name] = content.count
        end
    end
    return contents_converted
end

-- Paranoidal: contents of every quality as a dict["name|quality" -> {name, quality, count}];
-- for a player without an inventory name: main inventory and cursor.
function control:qualityContents(name)
    local result = {}
    local function add(item, quality, count)
        quality = quality or "normal"
        local key = qualities.key(item, quality)
        local entry = result[key]
        if entry then
            entry.count = entry.count + count
        else
            result[key] = { name = item, quality = quality, count = count }
        end
    end

    local inv = self:inventory(name)
    if _(inv):is("valid") then
        for __, content in pairs(inv.get_contents()) do add(content.name, content.quality, content.count) end
    end
    if name == nil and self.is_player() then
        local cursor_stack = self.cursor_stack
        if cursor_stack and cursor_stack.valid_for_read then
            add(cursor_stack.name, cursor_stack.quality.name, cursor_stack.count)
        end
    end
    return result
end

local function insert(self, name, item, amount, quality)
    if amount <= 0 then return 0 end
    local inv = self:inventory(name)
    if inv then
        -- inv.sort_and_merge()
        quality = quality or "normal"
        local inserted = inv.insert{ name = item, quality = quality, count = amount }
        if inserted < amount then  -- retry for things like furnace ingredients (can be overfilled)
            inserted = inserted + inv.insert{ name = item, quality = quality, count = amount - inserted }
        end
        return inserted
    end
    return 0
end

-- Paranoidal: replace inferior fuel/ammo. One get_contents() call tells which inferior items
-- are present; the original probed every inferior item with find_item_stack (dozens of
-- fuel types in Paranoidal) for every target entity. Inferior items of every quality are replaced
-- and returned to the player at their quality, with their durability/rounds (itemstate).
local function replaceInferior(self, inv, list, item, limit, player, takenFromCar, takenFromTrash, quality)
    if not list or limit <= 0 then return 0 end

    local present = {}
    for __,content in pairs(inv.get_contents()) do
        local qualities = present[content.name] or {}
        qualities[#qualities + 1] = content.quality or "normal"
        present[content.name] = qualities
    end

    local insertedHere = 0
    for __,inferior in ipairs(list) do
        if inferior == item or limit <= 0 then break end

        for __,inferiorQuality in ipairs(present[inferior] or {}) do
            if limit <= 0 then break end
            local transfer = itemstate.begin(inferior, inferiorQuality, {player, self})
            local returnToPlayer = 0
            while limit > 0 do
                local stack = inv.find_item_stack({ name = inferior, quality = inferiorQuality })
                local returnCount = stack and stack.count or 0
                if stack and stack.set_stack{ name = item, quality = quality or "normal", count = limit } then
                    limit = limit - stack.count
                    insertedHere = insertedHere + stack.count
                    returnToPlayer = returnToPlayer + returnCount
                else
                    break
                end
            end

            if returnToPlayer > 0 then
                player:returnItems(inferior, returnToPlayer, takenFromCar, takenFromTrash, inferiorQuality)
            end
            itemstate.finish(transfer, {player})
        end
    end

    return insertedHere
end

-- priority insert with fuel and ammo limits
-- allowed: optional table with true/false per target (fuel, ammo, input, output, modules, roboport, main); missing = allowed
-- quality: optional quality name of the item (nil = normal).
function control:customInsert(player, item, amount, takenFromCar, takenFromTrash, replaceItems, useFuelLimit, useAmmoLimit, useRequestLimit, allowed, quality)
    if amount <= 0 then return 0 end
    allowed = allowed or {}

    local inserted = 0
    local prototype = prototypes.item[item]
    local allowMain = allowed.main ~= false

    if allowed.fuel ~= false and prototype.fuel_category ~= nil then
        local inv = self:inventory("fuel")
        if inv then
            local limit = useFuelLimit and math.min(amount, math.max(0, player:itemLimit(prototype, config.fuelLimitProfiles) - countAllQualities(inv, item))) or amount

            local insertedHere = insert(self, "fuel", item, limit, quality)
            limit = limit - insertedHere

            -- no space left --> replace inferior items
            if replaceItems and limit > 0 then
                insertedHere = insertedHere + replaceInferior(self, inv, protocache.fuelList(prototype.fuel_category), item, limit, player, takenFromCar, takenFromTrash, quality)
            end

            inserted = inserted + insertedHere
            amount = amount - insertedHere
        end
    end

    if amount <= 0 then return inserted end
    if allowed.ammo ~= false and prototype.type == "ammo" then
        local inv = self:inventory("ammo")
        if inv then
            local limit = useAmmoLimit and math.min(amount, math.max(0, player:itemLimit(prototype, config.ammoLimitProfiles) - countAllQualities(inv, item))) or amount

            local insertedHere = insert(self, "ammo", item, limit, quality)
            limit = limit - insertedHere

            -- no space left --> replace inferior items
            if replaceItems and limit > 0 and prototype.ammo_category then
                insertedHere = insertedHere + replaceInferior(self, inv, protocache.ammoList(prototype.ammo_category.name), item, limit, player, takenFromCar, takenFromTrash, quality)
            end

            inserted = inserted + insertedHere
            amount = amount - insertedHere
        end
    end
    
    if amount <= 0 then return inserted end
    if allowed.input ~= false then
        local insertedHere = insert(self, "input", item, amount, quality)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
        if insertedHere > 0 then allowMain = false end
	end
    
    if amount <= 0 then return inserted end
    if allowed.output ~= false and self:recipe():hasProduct(item) then
        local insertedHere = insert(self, "output", item, amount, quality)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
	end

    if amount <= 0 then return inserted end
    if allowed.modules ~= false then
        local insertedHere = insert(self, "modules", item, amount, quality)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
        if insertedHere > 0 then allowMain = false end
    end

    if allowed.roboport ~= false and self.type == "roboport" then
        if amount <= 0 then return inserted end
        local insertedHere = insert(self, "roboport_robot", item, amount, quality)
        inserted = inserted + insertedHere
        amount = amount - insertedHere

        if amount <= 0 then return inserted end
        insertedHere = insert(self, "roboport_material", item, amount, quality)
        inserted = inserted + insertedHere
        amount = amount - insertedHere
    end
    
    if amount <= 0 then return inserted end
    if allowMain then
        local limit = useRequestLimit and math.min(amount, math.max(0, self:remainingRequest(item, quality))) or amount
        local insertedHere = insert(self, "main", item, limit, quality)
        
        inserted = inserted + insertedHere
        amount = amount - insertedHere
	end

    return inserted
end
