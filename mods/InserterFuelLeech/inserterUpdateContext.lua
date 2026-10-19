--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--- @class InserterUpdateContext
--- @field debugLogger LastInserterLogger?
--- @field inserter LuaEntity
--- @field inserterBurner LuaBurner?
--- @field inserterFuelInventoryInitialized boolean
--- @field inserterFuelInventory LuaInventory?
--- @field pickupEntityInitialized boolean
--- @field pickupEntity LuaEntity?
--- @field pickupBurner LuaBurner?
--- @field pickupFuelInventoryInitialized boolean
--- @field pickupFuelInventory LuaInventory?
--- @field pickupItemStacks LuaItemStack[]?
--- @field dropEntityInitialized boolean
--- @field dropEntity LuaEntity?
--- @field dropBurner LuaBurner?
--- @field dropFuelInventoryInitialized boolean
--- @field dropFuelInventory LuaInventory?
--- @field dropItemStacks LuaItemStack[]?

--- @type InserterUpdateContext
--- @diagnostic disable-next-line: missing-fields -- Initialized by iucPrepareContext.
local iuc = {} -- Inserter Update Context. Table is reused for each inserter update.

--- @param inserter LuaEntity
--- @param debugLogger LastInserterLogger?
--- @return nil
function iucPrepareContext(inserter, debugLogger)
    iuc.debugLogger = debugLogger

    local inserterBurner = inserter.burner
    iuc.inserter = inserter
    iuc.inserterBurner = inserterBurner
    iuc.inserterFuelInventoryInitialized = false
    iuc.inserterFuelInventory = nil

    iuc.pickupEntityInitialized = false
    iuc.pickupEntity = nil
    iuc.pickupBurner = nil
    iuc.pickupFuelInventoryInitialized = false
    iuc.pickupFuelInventory = nil
    iuc.pickupItemStacks = nil

    iuc.dropEntityInitialized = false
    iuc.dropEntity = nil
    iuc.dropBurner = nil
    iuc.dropFuelInventoryInitialized = false
    iuc.dropFuelInventory = nil
    iuc.dropItemStacks = nil
end

--- @return LastInserterLogger?
function iucGetDebugLogger()
    return iuc.debugLogger
end

--- @return LuaEntity
function iucGetInserter()
    return iuc.inserter
end

--- @return LuaBurner?
function iucGetInserterBurner()
    return iuc.inserterBurner
end

--- @return LuaInventory?
function iucGetInserterFuelInventory()
    if iuc.inserterFuelInventoryInitialized then
        return iuc.inserterFuelInventory
    end
    local burner = iuc.inserterBurner
    local inventory = burner and burner.inventory
    iuc.inserterFuelInventoryInitialized = true
    iuc.inserterFuelInventory = inventory
    return inventory
end

--- @return LuaEntity?
function iucGetPickupEntity()
    if iuc.pickupEntityInitialized then
        return iuc.pickupEntity
    end
    local entity = getPickupTargetOfInserter(iuc.inserter)
    iuc.pickupEntityInitialized = true
    iuc.pickupEntity = entity
    iuc.pickupBurner = entity and entity.burner
    return entity
end

--- @return LuaBurner?
function iucGetPickupBurner()
    if iuc.pickupEntityInitialized then
        return iuc.pickupBurner
    end
    local _ = iucGetPickupEntity()
    return iuc.pickupBurner
end

--- @return LuaInventory?
function iucGetPickupFuelInventory()
    if iuc.pickupFuelInventoryInitialized then
        return iuc.pickupFuelInventory
    end
    local burner = iucGetPickupBurner()
    iuc.pickupFuelInventoryInitialized = true
    iuc.pickupFuelInventory = burner and burner.inventory
    return iuc.pickupFuelInventory
end

--- @return LuaItemStack[]
function iucGetPickupItemStacks()
    local itemStacks = iuc.pickupItemStacks
    if not itemStacks then
        local inserter = iuc.inserter
        itemStacks = getItemsOnGround(inserter.surface, inserter.pickup_position, 0.5)
        iuc.pickupItemStacks = itemStacks
    end
    return itemStacks
end

--- @return LuaEntity?
function iucGetDropEntity()
    if iuc.dropEntityInitialized then
        return iuc.dropEntity
    end
    local entity = getDropTargetOfInserter(iuc.inserter)
    iuc.dropEntityInitialized = true
    iuc.dropEntity = entity
    iuc.dropBurner = entity and entity.burner
    return entity
end

--- @return LuaBurner?
function iucGetDropBurner()
    if iuc.dropEntityInitialized then
        return iuc.dropBurner
    end
    local _ = iucGetDropEntity()
    return iuc.dropBurner
end

--- @return LuaInventory?
function iucGetDropFuelInventory()
    if iuc.dropFuelInventoryInitialized then
        return iuc.dropFuelInventory
    end
    local burner = iucGetDropBurner()
    iuc.dropFuelInventoryInitialized = true
    iuc.dropFuelInventory = burner and burner.inventory
    return iuc.dropFuelInventory
end

--- @return LuaItemStack[]
function iucGetDropItemStacks()
    local itemStacks = iuc.dropItemStacks
    if not itemStacks then
        local inserter = iuc.inserter
        itemStacks = getItemsOnGround(inserter.surface, inserter.drop_position, 0.5)
        iuc.dropItemStacks = itemStacks
    end
    return itemStacks
end
