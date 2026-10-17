--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

local isTransportBeltConnectable_types = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["linked-belt"] = true,
    ["splitter"] = true,
    ["lane-splitter"] = true,
    ["loader"] = true,
    ["loader-1x1"] = true,
}
--- @param entity LuaEntity
--- @return boolean
function isTransportBeltConnectable(entity)
    local prototype = entity and entity.prototype
    if not prototype or not isTransportBeltConnectable_types[prototype.type] then
        return false
    end
    return true
end

---@type table<string,defines.inventory[]>
local prototypeFuelSourceInventoryIndexesCache = {}

---@param entity LuaEntity
---@return defines.inventory[]
function getEntityFuelInventories(entity)
    local entityType = entity.type
    local inventoryIndexes = prototypeFuelSourceInventoryIndexesCache[entityType]
    if inventoryIndexes then
        return inventoryIndexes
    end
    inventoryIndexes = {}
    for inventoryIndexIndex = 1, #fuelSourceInventoryIndexes do
        local inventoryIndex = fuelSourceInventoryIndexes[inventoryIndexIndex]
        if entity.get_inventory(inventoryIndex) then
            inventoryIndexes[#inventoryIndexes + 1] = inventoryIndex
        end
    end
    prototypeFuelSourceInventoryIndexesCache[entityType] = inventoryIndexes
    return inventoryIndexes
end

--- @type EntitySearchFilters
local getEntitiesOnTile_filter = {}

--- Might return the wrong entity when called in same tick the inserter was created in.
--- @param surface LuaSurface
--- @param mapPosition MapPosition
--- @return nil|LuaEntity
function getEntitiesOnTile(surface, mapPosition)
    -- Inserters only know a pickup target if the entity at pickup_position has a regular inventory.
    getEntitiesOnTile_filter.position = mapPosition
    return surface.find_entities_filtered(getEntitiesOnTile_filter)
end

--- @param burnRate float
--- @param currentFuel float
--- @param fuelItems ItemCountWithQuality[]
--- @param n uint
--- @return uint ticks till no fuel item left.
function getTicksTillNoFuelItemLeft(burnRate, currentFuel, fuelItems, n)
    local fuelToBurn = currentFuel

    -- Add whole inventory to fuelToBurn:
    for itemIndex = 1, #fuelItems do
        local fuelItemStack = fuelItems[itemIndex]
        local itemFuel = prototypes.item[fuelItemStack.name].fuel_value
        fuelToBurn = fuelToBurn + fuelItemStack.count * itemFuel
    end

    -- Subtract last n items from fuelToBurn:
    for itemIndex = #fuelItems, 1, -1 do
        if n <= 0 then
            break
        end
        local fuelItemStack = fuelItems[itemIndex]
        local itemFuel = prototypes.item[fuelItemStack.name].fuel_value
        local itemCount = math.min(n, fuelItemStack.count)
        fuelToBurn = fuelToBurn - itemCount * itemFuel
        n = n - itemCount
    end

    return math.max(0, math.ceil(fuelToBurn / burnRate))
end

--- @param stack LuaItemStack
--- @param moveCount uint
--- @param inventory LuaInventory
--- @return uint movedCount
function moveItemsFromStackIntoInventory(stack, moveCount, inventory)
    if not stack.valid_for_read or stack.count < 1 or moveCount < 1 then
        return 0
    end
    local originalStackCount = stack.count
    stack.count = moveCount
    local movedCount = inventory.insert(stack)
    stack.count = originalStackCount - movedCount
    return movedCount
end
