--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--- @type defines.inventory[]
fuelSourceInventoryIndexes = {
    defines.inventory.fuel,
    defines.inventory.assembling_machine_dump,
    defines.inventory.assembling_machine_input,
    defines.inventory.assembling_machine_output,
    defines.inventory.burnt_result,
    defines.inventory.car_trunk,
    defines.inventory.cargo_landing_pad_main,
    defines.inventory.cargo_landing_pad_trash,
    defines.inventory.cargo_unit,
    defines.inventory.cargo_wagon,
    defines.inventory.chest,
    defines.inventory.furnace_result,
    defines.inventory.furnace_source,
    defines.inventory.hub_main,
    defines.inventory.hub_trash,
    defines.inventory.logistic_container_trash,
    defines.inventory.rocket_silo_input,
    defines.inventory.rocket_silo_output,
    defines.inventory.rocket_silo_rocket,
    defines.inventory.rocket_silo_trash,
    defines.inventory.spider_trash,
    defines.inventory.spider_trunk,
}

---@return nil
local function deduplicateFuelSourceInventoryIndexes()
    local indexesSet = {}
    for indexIndex = 1, #fuelSourceInventoryIndexes do
        indexesSet[fuelSourceInventoryIndexes[indexIndex]] = true
    end
    fuelSourceInventoryIndexes = {}
    for index, _ in pairs(indexesSet) do
        fuelSourceInventoryIndexes[#fuelSourceInventoryIndexes + 1] = index
    end
end
deduplicateFuelSourceInventoryIndexes()

---@param qualityId QualityID?
---@return LuaQualityPrototype?
function resolveQuality(qualityId)
    if type(qualityId) ~= "string" then
        return qualityId
    end
    return prototypes.quality[qualityId]
end

--- @type table<string?,true?>
local inserterTypes = nil
--- @type table<string?,boolean?>
local itemFueledInserterTypes = nil
--- @type table<string?,boolean?>
local nonItemFueledInserterTypes = nil

local function initInserterTypes()
    inserterTypes = {}
    itemFueledInserterTypes = {}
    nonItemFueledInserterTypes = {}
    for _, prototype in pairs(prototypes.entity) do
        if prototype.type == "inserter" then
            inserterTypes[prototype.name] = true
            if prototype.burner_prototype then
                itemFueledInserterTypes[prototype.name] = true
            else
                nonItemFueledInserterTypes[prototype.name] = true
            end
        end
    end
end

---@return table<string?,boolean?>
function getInserterTypes()
    if not inserterTypes then
        initInserterTypes()
    end
    return inserterTypes
end

---@return table<string?,boolean?>
function getItemFueledInserterTypes()
    if not itemFueledInserterTypes then
        initInserterTypes()
    end
    return itemFueledInserterTypes
end

---@return table<string?,boolean?>
function getNonItemFueledInserterTypes()
    if not nonItemFueledInserterTypes then
        initInserterTypes()
    end
    return nonItemFueledInserterTypes
end
