--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

local _ = nil

--- @return uint? ticks to wait until next update for this inserter.
local function handleNoUseForFuel()
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    if inserter.to_be_deconstructed() then
        _ = debugLogger and debugLogger("Nothing to do because inserter is marked for deconstruction.", nil)
        return settingsCache.noUseForFuelTicksToWait
    end
    if not iucGetInserterFuelInventory() and not iucGetDropFuelInventory() then
        _ = debugLogger and debugLogger("Nothing to do because inserter and drop target don't use solid fuel.", nil)
        return settingsCache.noUseForFuelTicksToWait
    end
    return nil -- Inserter is powered again.
end

--- @return uint? ticks to wait until next update for this inserter.
local function handleUnpowered()
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    if inserter.energy ~= 0 then
        return nil
    end
    local ownFuelInventory = iucGetInserterFuelInventory()
    if not ownFuelInventory then
        _ = debugLogger and debugLogger("Nothing to do because inserter is unpowered but doesn't use fuel items.", nil)
        return settingsCache.unpoweredNonBurnerTicksToWait
    end
    if not settingsCache.selfRefuelCheatEnabled then
        _ = debugLogger and debugLogger("Nothing to do because burner inserter is unpowered and cheat refueling disabled.", nil)
        return settingsCache.unpoweredBurnerTicksToWait
    end
    if not inserterCheatFuelForSelf() then
        _ = debugLogger and debugLogger("Nothing to do because burner inserter still unpowered after cheat refueling.", nil)
        return settingsCache.unpoweredBurnerTicksToWait
    end
    return nil -- Inserter is powered again.
end

--- @return uint? ticks to wait until next update for this inserter.
local function handleOwnFuelInventoryEmpty()
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    local inserterBurner = iucGetInserterBurner()
    local ownFuelInventory = iucGetInserterFuelInventory()
    if not inserterBurner or not ownFuelInventory or not ownFuelInventory.is_empty() then
        return nil -- Not a burner inserter or fuel inventory isn't empty.
    end
    _ = debugLogger and debugLogger("Inserter fuel inventory empty.", nil)

    local pickupTarget = iucGetPickupEntity()
    if pickupTarget then
        if pickupTarget.burner and pickupTarget.burner.fuel_categories then
            -- Leeching from pickup burner inventory is done by the engine enabled by allow_burner_leech on prototypes.
            _ = debugLogger and debugLogger("Nothing to do because pickup has burner and fuel leeching from pickup for self is handled by engine.", nil)
            return settingsCache.vanillaSelfRefuelTicksToWait
        end
    end

    local handEmpty = not inserter.held_stack.valid_for_read or inserter.held_stack.count == 0
    if not handEmpty then
        -- Wait till hand at drop off position. Then reevaluate.
        local ticksTillAtDrop = calcTicksTillInserterHandIsAtPos(inserter, inserter.drop_position)
        _ = debugLogger and debugLogger("Nothing to do because hand not empty (distance to drop: " .. ticksTillAtDrop .. " ticks).", nil)
        if ticksTillAtDrop < 1 then
            _ = debugLogger and debugLogger("Hand at drop location but still holding item. Probably stuck.", nil)
            return settingsCache.stuckWithItemTicksToWait
        end
        return ticksTillAtDrop + 1
    end
    -- Hand is empty.

    local triedToLeech = false
    local ticksTillAtPickup = calcTicksTillInserterHandIsAtPos(inserter, inserter.pickup_position)
    if ticksTillAtPickup < settingsCache.pickupPosMarginTicks then
        if inserterLeechFuelForSelfFromPickupTarget(ownFuelInventory, inserterBurner.fuel_categories) then
            -- Leeched fuel for self from pickup. Reevaluate when fuel is in own burner inventory.
            local ticksTillFueled = calcTicksTillInserterHandIsAtPos(inserter, inserter.position)
            return ticksTillFueled + 1
        end
        triedToLeech = true
    end
    local ticksTillAtDrop = calcTicksTillInserterHandIsAtPos(inserter, inserter.drop_position)
    if ticksTillAtDrop < settingsCache.pickupPosMarginTicks then
        if inserterLeechFuelForSelfFromDropTarget(ownFuelInventory, inserterBurner.fuel_categories) then
            -- Leeched fuel for self from drop. Reevaluate when fuel is in own burner inventory.
            local ticksTillFueled = calcTicksTillInserterHandIsAtPos(inserter, inserter.position)
            return ticksTillFueled + 1
        end
        triedToLeech = true
    end
    if triedToLeech then
        _ = debugLogger and debugLogger("Nothing leeched found (distance to pickup: " .. ticksTillAtPickup .. " ticks, distance to drop: " .. ticksTillAtDrop .. " ticks).", nil)
        return settingsCache.nothingLeechableFoundTicksToWait
    end

    _ = debugLogger and debugLogger("Waiting till hand at pickup (distance to pickup: " .. ticksTillAtPickup .. " ticks, distance to drop: " .. ticksTillAtDrop .. " ticks).", nil)
    return ticksTillAtPickup - settingsCache.pickupPosMarginTicks + 1
end

--- @return uint? ticks to wait until next update for this inserter.
local function handleTargetFuelInventoryEmpty()
    local debugLogger = iucGetDebugLogger()
    local inserter = iucGetInserter()
    local dropBurner = iucGetDropBurner()
    local dropFuelInventory = iucGetDropFuelInventory()
    if not dropBurner or not dropFuelInventory or dropFuelInventory.get_item_count() >= settingsCache.targetItemCountMin then
        return nil -- Not a burner inserter or fuel inventory contains more than the required count of items.
    end
    _ = debugLogger and debugLogger(table.concat({"Drop target fuel inventory contains less than ", settingsCache.targetItemCountMin, " items."}), nil)

    local pickupFuelInventory = iucGetPickupFuelInventory()
    if not pickupFuelInventory then
        -- Leeching from anything but pickup burner inventory is done by the engine.
        _ = debugLogger and debugLogger("Nothing to do because pickup has no burner and fuel leeching from normal inventories is handled by the engine.", nil)
        return settingsCache.nothingLeechableFoundTicksToWait
    end

    local handEmpty = not inserter.held_stack.valid_for_read or inserter.held_stack.count == 0
    if not handEmpty then
        _ = debugLogger and debugLogger("Nothing to do because hand not empty.", nil)
        -- Wait till hand at pickup position. Then reevaluate.
        local ticksTillAtDrop = calcTicksTillInserterHandIsAtPos(inserter, inserter.drop_position)
        if ticksTillAtDrop < 1 then
            _ = debugLogger and debugLogger("Hand at drop location but still holding item. Probably stuck.", nil)
            return settingsCache.stuckWithItemTicksToWait
        end
        return ticksTillAtDrop + 1
    end
    -- Hand is empty.

    local ticksTillAtPickup = calcTicksTillInserterHandIsAtPos(inserter, inserter.pickup_position)
    if ticksTillAtPickup < settingsCache.pickupPosMarginTicks then
        if inserterLeechFuelForDropTargetFromPickupTarget(dropFuelInventory, dropBurner.fuel_categories, pickupFuelInventory) then
            -- Leeched fuel for drop target from pickup. Reevaluate when fuel is in drop target's burner inventory.
            local ticksTillAtDrop = calcTicksTillInserterHandIsAtPos(inserter, inserter.drop_position)
            return ticksTillAtDrop + 1
        end
        _ = debugLogger and debugLogger("Nothng leechable found.", nil)
        return settingsCache.nothingLeechableFoundTicksToWait
    end

    -- Wait till at pickup.
    _ = debugLogger and debugLogger("Waiting till hand at pickup.", nil)
    return ticksTillAtPickup - settingsCache.pickupPosMarginTicks + 1
end

--- @return uint? ticks to wait until next update for this inserter.
local function getTicksTillInserterFuelInventoryEmpty()
    local inserter = iucGetInserter()
    local inserterBurner = iucGetInserterBurner()
    if not inserterBurner then
        return nil
    end
    local inserterPrototype = prototypes.entity[inserter.name]
    if not inserterPrototype then
        return nil
    end
    local inserterFuelInventory = iucGetInserterFuelInventory()
    if not inserterFuelInventory then
        return nil
    end
    local burnRate = inserterPrototype.get_max_energy_usage(inserter.quality)
    local currentFuel = inserterBurner.remaining_burning_fuel
    local fuelItems = inserterFuelInventory.get_contents()
    return getTicksTillNoFuelItemLeft(burnRate, currentFuel, fuelItems, 0)
end

--- @return uint? ticks to wait until next update for this inserter.
local function getTicksTillDropFuelInventoryEmpty()
    local dropEntity = iucGetDropEntity()
    if not dropEntity then
        return nil
    end
    local dropBurner = iucGetDropBurner()
    if not dropBurner then
        return nil
    end
    local dropPrototype = prototypes.entity[dropEntity.name]
    if not dropPrototype then
        return nil
    end
    local dropFuelInventory = iucGetDropFuelInventory()
    if not dropFuelInventory then
        return nil
    end
    local burnRate = dropPrototype.get_max_energy_usage(dropEntity.quality)
    local currentFuel = dropBurner.remaining_burning_fuel
    local fuelItems = dropFuelInventory.get_contents()
    return getTicksTillNoFuelItemLeft(burnRate, currentFuel, fuelItems, settingsCache.targetItemCountMin)
end

--- @return uint ticks to wait until next update for this inserter.
local function handleNoFuelNeededRightNow()
    local debugLogger = iucGetDebugLogger()

    local ticksTillInserterFuelInventoryEmpty = getTicksTillInserterFuelInventoryEmpty()
    if ticksTillInserterFuelInventoryEmpty then
        _ = debugLogger and debugLogger("Ticks till inserter has no fuel items left: " .. formatTickForLog(ticksTillInserterFuelInventoryEmpty) .. ".", nil)
    else
        _ = debugLogger and debugLogger("Inserter doesn't need fuel.", nil)
        ticksTillInserterFuelInventoryEmpty = settingsCache.noUseForFuelTicksToWait
    end

    local ticksTillDropFuelInventoryEmpty = getTicksTillDropFuelInventoryEmpty()
    if ticksTillDropFuelInventoryEmpty then
        _ = debugLogger and debugLogger("Ticks till drop target has no fuel items left: " .. formatTickForLog(ticksTillDropFuelInventoryEmpty) .. ".", nil)
    else
        _ = debugLogger and debugLogger("Drop target doesn't need fuel.", nil)
        ticksTillDropFuelInventoryEmpty = settingsCache.noUseForFuelTicksToWait
    end

    return math.min(ticksTillInserterFuelInventoryEmpty, ticksTillDropFuelInventoryEmpty, settingsCache.noUseForFuelTicksToWait)
end

--- @param inserter LuaEntity
--- @param debugLogger LastInserterLogger?
--- @return uint ticks to wait until next call to this function for this inserter.
function updateInserter(inserter, debugLogger)
    iucPrepareContext(inserter, debugLogger)
    local ticksToWait = handleNoUseForFuel()
        or handleUnpowered()
        or handleOwnFuelInventoryEmpty()
        or handleTargetFuelInventoryEmpty()
        or handleNoFuelNeededRightNow()
    if ticksToWait >= settingsCache.ticksToWaitMinForVariation then
        ticksToWait = ticksToWait + math.random(settingsCache.ticksToWaitVariation)
    end
    return ticksToWait
end
