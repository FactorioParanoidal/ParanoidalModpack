--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]
local _ = nil

--- @param fuelInventory LuaInventory
--- @param fuelCategories table<string,true>
--- @param itemsOnTile LuaEntity[]
--- @return boolean
local function inserterLeechFuelFromGround(fuelInventory, fuelCategories, itemsOnTile)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    for i = 1, #itemsOnTile do
        local stack = itemsOnTile[i].stack
        local moveCount = getInserterMovableCountOfItemStack(stack, inserter, fuelInventory, fuelCategories)
        if moveCount > 0 then
            local movedCount, movedName = moveItemsFromStackIntoInserterHand(stack, inserter)
            if movedCount > 0 then
                _ = debugLogger and debugLogger("Got " .. movedCount .. " " .. movedName .. " from ground.", nil)
                return true
            end
        end
    end
    return false
end

--- @param fuelInventory LuaInventory
--- @param fuelCategories table<string,true>
--- @param srcBelt LuaEntity
--- @return boolean
local function inserterLeechFuelFromBelt(fuelInventory, fuelCategories, srcBelt)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    for lineIndex = 1, srcBelt.get_max_transport_line_index() do
        local srcLine = srcBelt.get_transport_line(lineIndex)
        for itemIndex = 1, #srcLine do
            local stack = srcLine[itemIndex]
            local moveCount = getInserterMovableCountOfItemStack(stack, inserter, fuelInventory, fuelCategories)
            if moveCount > 0 then
                local movedCount, movedName = moveItemsFromStackIntoInserterHand(stack, inserter)
                if movedCount > 0 then
                    _ = debugLogger and debugLogger("Got " .. movedCount .. " " .. movedName .. " from transport line #" .. lineIndex .. ".", nil)
                    return true
                end
            end
        end
    end
    return false
end

--- @param fuelInventory LuaInventory
--- @param fuelCategories table<string,true>
--- @param srcEntity LuaEntity
--- @return boolean
local function inserterLeechFuelFromEntityInventories(fuelInventory, fuelCategories, srcEntity)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    local inventoryIndexes = getEntityFuelInventories(srcEntity)
    for inventoryIndexIndex = 1, #inventoryIndexes do
        local inventoryIndex = inventoryIndexes[inventoryIndexIndex]
        local srcInventory = srcEntity.get_inventory(inventoryIndex)
        if srcInventory then
            _ = debugLogger and debugLogger("Trying to get fuel from inventory " .. inventoryIndex .. ".", nil)
            for itemIndex = 1, #srcInventory do
                local stack = srcInventory[itemIndex]
                local moveCount = getInserterMovableCountOfItemStack(stack, inserter, fuelInventory, fuelCategories)
                if moveCount > 0 then
                    local movedCount, movedName = moveItemsFromStackIntoInserterHand(stack, inserter)
                    if movedCount > 0 then
                        _ = debugLogger and debugLogger("Got " .. movedCount .. " " .. movedName .. " from inventory #" .. inventoryIndex .. ".", nil)
                        return true
                    end
                end
            end
        end
    end
    return false
end

--- @param ownFuelInventory LuaInventory
--- @param fuelCategories table<string,true>
--- @return boolean
function inserterLeechFuelForSelfFromPickupTarget(ownFuelInventory, fuelCategories)
    local debugLogger = iucGetDebugLogger()
    _ = debugLogger and debugLogger("Trying to leech fuel from pickup target...", nil)
    local pickupTarget = iucGetPickupEntity()
    if not pickupTarget then
        _ = debugLogger and debugLogger("Inserter picks up from ground.", nil)
        local itemsOnTile = iucGetPickupItemStacks()
        return inserterLeechFuelFromGround(ownFuelInventory, fuelCategories, itemsOnTile)
    end
    if isTransportBeltConnectable(pickupTarget) then
        _ = debugLogger and debugLogger("Inserter pickup belt:", pickupTarget)
        return inserterLeechFuelFromBelt(ownFuelInventory, fuelCategories, pickupTarget)
    end
    _ = debugLogger and debugLogger("Inserter pickup target:", pickupTarget)
    return inserterLeechFuelFromEntityInventories(ownFuelInventory, fuelCategories, pickupTarget)
end

--- @param ownFuelInventory LuaInventory
--- @param fuelCategories table<string,true>
--- @return boolean
function inserterLeechFuelForSelfFromDropTarget(ownFuelInventory, fuelCategories)
    local debugLogger = iucGetDebugLogger()
    if not settingsCache.selfLeechFromDropEnabled then
        _ = debugLogger and debugLogger("Leeching fuel from drop target is disabled.", nil)
        return false
    end
    _ = debugLogger and debugLogger("Trying to leech fuel from drop target...", nil)
    local dropTarget = iucGetDropEntity()
    if not dropTarget then
        _ = debugLogger and debugLogger("Inserter drops on ground.", nil)
        local itemsOnTile = iucGetDropItemStacks()
        return inserterLeechFuelFromGround(ownFuelInventory, fuelCategories, itemsOnTile)
    end
    if isTransportBeltConnectable(dropTarget) then
        _ = debugLogger and debugLogger("Inserter drop belt:", dropTarget)
        return inserterLeechFuelFromBelt(ownFuelInventory, fuelCategories, dropTarget)
    end
    _ = debugLogger and debugLogger("Inserter drop target:", dropTarget)
    return inserterLeechFuelFromEntityInventories(ownFuelInventory, fuelCategories, dropTarget)
end

--- @param fuelInventory LuaInventory
--- @param fuelCategories table<string,true>
--- @param srcInventory LuaInventory
--- @return boolean
function inserterLeechFuelForDropTargetFromPickupTarget(fuelInventory, fuelCategories, srcInventory)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    for itemIndex = 1, #srcInventory do
        local stack = srcInventory[itemIndex]
        local moveCount = getInserterMovableCountOfItemStack(stack, inserter, fuelInventory, fuelCategories)
        if moveCount > 0 then
            local movedCount, movedName = moveItemsFromStackIntoInserterHand(stack, inserter)
            if movedCount > 0 then
                _ = debugLogger and debugLogger("Got " .. movedCount .. " " .. movedName .. " from pickup fuel inventory.", nil)
                return true
            end
        end
    end
    return false
end
