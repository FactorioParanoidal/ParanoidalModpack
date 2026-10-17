--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--- @param inserter LuaEntity
--- @param itemName string
--- @param itemQualityLevel integer
--- @return boolean
function isItemAllowedByInserterFilter(inserter, itemName, itemQualityLevel)
    if not inserter.use_filters then
        return true
    end
    local filterMode = inserter.inserter_filter_mode
    if not filterMode then
        return true
    end
    local itemIsInList = false
    for i = 1, inserter.filter_slot_count, 1 do
        local filter = inserter.get_filter(i)
        if isFilterMatching(filter, itemName, itemQualityLevel) then
            itemIsInList = true
            break
        end
    end
    local itemIsAllowed = (filterMode == "whitelist") == itemIsInList
    return itemIsAllowed
end

--- @param stack LuaItemStack
--- @param inserter LuaEntity
--- @param dstInventory LuaInventory?
--- @param allowedFuelCategories table<string,true>?
--- @return uint
function getInserterMovableCountOfItemStack(stack, inserter, dstInventory, allowedFuelCategories)
    if not stack.valid_for_read or stack.count == 0 then
        return 0
    end
    if allowedFuelCategories and not allowedFuelCategories[prototypes.item[stack.name].fuel_category] then
        return 0
    end
    if not isItemAllowedByInserterFilter(inserter, stack.name, stack.quality.level) then
        return 0
    end
    local insertableCount = dstInventory and dstInventory.get_insertable_count(stack) or stack.count
    if insertableCount == 0 then
        return 0
    end
    local maxStackSize = inserter.inserter_target_pickup_count
    return math.min(maxStackSize, stack.count, insertableCount)
end

--- @param srcInventory LuaInventory
--- @param inserter LuaEntity
--- @param dstInventory LuaInventory
--- @return LuaItemStack?, uint?
function getFirstInserterMovableStackOfInventory(srcInventory, inserter, dstInventory)
    for i = 1, #srcInventory, 1 do
        local stack = srcInventory[i]
        local count = getInserterMovableCountOfItemStack(stack, inserter, dstInventory)
        if count > 0 then
            return stack, count
        end
    end
    return nil, nil
end

--- @param stack LuaItemStack The stack might become invalid due to moving it.
--- @param inserter LuaEntity
--- @return uint movedCount, string movedName
function moveItemsFromStackIntoInserterHand(stack, inserter)
    local handStack = inserter.held_stack
    if not handStack.valid or not stack.valid_for_read or stack.count < 1 then
        return 0, ""
    end
    local movedName = stack.name
    local oldHandCount = handStack.count
    handStack.transfer_stack(stack)
    local movedCount = handStack.count - oldHandCount
    return movedCount, movedName
end

--- Might return the wrong entity when called in same tick the inserter was created in.
--- @param inserter LuaEntity
--- @return nil|LuaEntity
function getPickupTargetOfInserter(inserter)
    local pickupTarget = inserter.pickup_target
    if pickupTarget then
        return pickupTarget
    end
    -- Inserters only know a pickup target if the entity at pickup_position has a regular inventory.
    return getEntitiesOnTile(inserter.surface, inserter.pickup_position)[1] -- nil if none found
end

--- Might return the wrong entity when called in same tick the inserter was created in.
--- @param inserter LuaEntity
--- @return nil|LuaEntity
function getDropTargetOfInserter(inserter)
    local dropTarget = inserter.drop_target
    if dropTarget then
        return dropTarget
    end
    -- Inserters only know a pickup target if the entity at pickup_position has a regular inventory.
    return getEntitiesOnTile(inserter.surface, inserter.drop_position)[1] -- nil if none found
end

--- @param inserter LuaEntity
--- @param destinationPos MapPosition
--- @return uint
function calcTicksTillInserterHandIsAtPos(inserter, destinationPos)
    local granularity = settingsCache.vectorGranularity
    local basePosX, basePosY = granularizeMapPos(inserter.position, granularity)
    local handPos = inserter.held_stack_position
    local handPosX, handPosY = granularizeAndRebaseMapPos(handPos, granularity, basePosX, basePosY)
    local destPosX, destPosY = granularizeAndRebaseMapPos(destinationPos, granularity, basePosX, basePosY)

    local inserterPrototype = prototypes.entity[inserter.name]
    local extensionSpeed = inserterPrototype.get_inserter_extension_speed(inserter.quality)
    local rotationSpeed = inserterPrototype.get_inserter_rotation_speed(inserter.quality)

    local turns, extensionDiff = calcVectorMinTurnsAndExtension(handPosX, handPosY, destPosX, destPosY, granularity)
    local tuernTicks = turns / rotationSpeed
    local extensionTicks = extensionDiff / extensionSpeed
    return round(math.max(tuernTicks, extensionTicks), 1)
end

--- @param inserter LuaEntity
--- @return uint
function calcTicksTillInserterHasDeliveredAndIsAtPickup(inserter)
    local dropPos = inserter.drop_position
    local dropDist = calcTicksTillInserterHandIsAtPos(inserter, dropPos)
    local pickupPos = inserter.pickup_position
    local dropToDestDist = math.max(0, util.distance(dropPos, pickupPos))
    local totalDist = math.ceil(dropToDestDist + dropDist)
    return math.max(1, totalDist)
end
