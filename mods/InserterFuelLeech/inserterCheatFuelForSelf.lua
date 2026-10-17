--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]
local _ = nil

--- @param ownFuelInventory LuaInventory
--- @return boolean
local function inserterCheatFuelForSelfFromOwnHand(ownFuelInventory)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    _ = debugLogger and debugLogger("Trying to cheat leech fuel from own hand...", nil)
    local handStack = inserter.held_stack
    if not handStack.valid_for_read then
        _ = debugLogger and debugLogger("Hand is empty.", nil)
        return false
    end
    _ = debugLogger and debugLogger("Held stack:", handStack)
    local insertedCount = moveItemsFromStackIntoInventory(handStack, handStack.count, ownFuelInventory)
    if insertedCount > 0 then
        _ = debugLogger and debugLogger("Cheat-leeched " .. insertedCount .. " " .. handStack.name .. " from own hand.", nil)
        return true
    end
    _ = debugLogger and debugLogger("No fuel leeched from own hand.", nil)
    return false
end

--- @param ownFuelInventory LuaInventory
--- @param itemsOnTile LuaEntity[]
--- @return boolean
local function inserterCheatFuelForSelfFromGround(ownFuelInventory, itemsOnTile)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    for i = 1, #itemsOnTile do
        local itemOnTile = itemsOnTile[i]
        local stack = itemOnTile.stack
        local moveCount = math.min(1, getInserterMovableCountOfItemStack(stack, inserter, nil))
        local movedCount = moveItemsFromStackIntoInventory(stack, moveCount, ownFuelInventory)
        if movedCount > 0 then
            _ = debugLogger and debugLogger("Got " .. stack.name .. " from ground.", nil)
            return true
        end
        _ = debugLogger and debugLogger("Got nothing from ground.", {itemStack = stack, moveCount = moveCount, movedCount = movedCount})
    end
    _ = debugLogger and debugLogger("No fuel leeched from ground.", nil)
    return false
end

--- @param ownFuelInventory LuaInventory
--- @param srcBelt LuaEntity
--- @return boolean
local function inserterCheatFuelForSelfFromBelt(ownFuelInventory, srcBelt)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    for lineIndex = 1, srcBelt.get_max_transport_line_index() do
        local srcLine = srcBelt.get_transport_line(lineIndex)
        for itemIndex = 1, #srcLine do
            local itemStack = srcLine[itemIndex]
            local moveCount = math.min(1, getInserterMovableCountOfItemStack(itemStack, inserter, nil))
            local movedCount = moveItemsFromStackIntoInventory(itemStack, moveCount, ownFuelInventory)
            if movedCount > 0 then
                _ = debugLogger and debugLogger("Got " .. itemStack.name .. " from transport line #" .. lineIndex .. ".", nil)
                return true
            end
        end
    end
    _ = debugLogger and debugLogger("No fuel leeched from belt.", nil)
    return false
end

--- @param ownFuelInventory LuaInventory
--- @param srcEntity LuaEntity
--- @return boolean
local function inserterCheatFuelForSelfFromEntityInventories(ownFuelInventory, srcEntity)
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    local inventoryIndexes = getEntityFuelInventories(srcEntity)
    for inventoryIndexIndex = 1, #inventoryIndexes do
        local inventoryIndex = inventoryIndexes[inventoryIndexIndex]
        local srcInventory = srcEntity.get_inventory(inventoryIndex)
        if srcInventory then
            _ = debugLogger and debugLogger("Trying to get fuel from inventory " .. inventoryIndex .. ".", nil)
            for itemIndex = 1, #srcInventory do
                local itemStack = srcInventory[itemIndex]
                local moveCount = math.min(1, getInserterMovableCountOfItemStack(itemStack, inserter, nil))
                local movedCount = moveItemsFromStackIntoInventory(itemStack, moveCount, ownFuelInventory)
                if movedCount > 0 then
                    _ = debugLogger and debugLogger("Got " .. itemStack.name .. " from inventory #" .. inventoryIndex .. ".", nil)
                    return true
                end
            end
        end
    end
    _ = debugLogger and debugLogger("No fuel leeched from entity.", nil)
    return false
end

--- @param ownFuelInventory LuaInventory
--- @return boolean
local function inserterCheatFuelForSelfFromPickupTarget(ownFuelInventory)
    local debugLogger = iucGetDebugLogger()
    _ = debugLogger and debugLogger("Trying to cheat leech fuel from pickup target...", nil)
    local pickupTarget = iucGetPickupEntity()
    if not pickupTarget then
        _ = debugLogger and debugLogger("Inserter picks up from ground.", nil)
        local itemsOnTile = iucGetPickupItemStacks()
        return inserterCheatFuelForSelfFromGround(ownFuelInventory, itemsOnTile)
    end
    if isTransportBeltConnectable(pickupTarget) then
        _ = debugLogger and debugLogger("Inserter pickup belt:", pickupTarget)
        return inserterCheatFuelForSelfFromBelt(ownFuelInventory, pickupTarget)
    end
    _ = debugLogger and debugLogger("Inserter pickup target:", pickupTarget)
    return inserterCheatFuelForSelfFromEntityInventories(ownFuelInventory, pickupTarget)
end

--- @param ownFuelInventory LuaInventory
--- @return boolean
local function inserterCheatFuelForSelfFromDropTarget(ownFuelInventory)
    local debugLogger = iucGetDebugLogger()
    if not settingsCache.selfLeechFromDropEnabled then
        _ = debugLogger and debugLogger("Leeching fuel from drop target is disabled.", nil)
        return false
    end
    _ = debugLogger and debugLogger("Trying to cheat leech fuel from drop target...", nil)
    local dropTarget = iucGetDropEntity()
    if not dropTarget then
        _ = debugLogger and debugLogger("Inserter drops on ground.", nil)
        local itemsOnTile = iucGetDropItemStacks()
        return inserterCheatFuelForSelfFromGround(ownFuelInventory, itemsOnTile)
    end
    if isTransportBeltConnectable(dropTarget) then
        _ = debugLogger and debugLogger("Inserter drop belt:", dropTarget)
        return inserterCheatFuelForSelfFromBelt(ownFuelInventory, dropTarget)
    end
    _ = debugLogger and debugLogger("Inserter drop target:", dropTarget)
    return inserterCheatFuelForSelfFromEntityInventories(ownFuelInventory, dropTarget)
end

--- @return boolean
function inserterCheatFuelForSelf()
    local ownFuelInventory = iucGetInserterFuelInventory()
    return ownFuelInventory and (false
        or inserterCheatFuelForSelfFromOwnHand(ownFuelInventory)
        or inserterCheatFuelForSelfFromPickupTarget(ownFuelInventory)
        or inserterCheatFuelForSelfFromDropTarget(ownFuelInventory)
    ) or false
end
