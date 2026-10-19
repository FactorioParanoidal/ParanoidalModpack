-- Managing Forces and their Sandbox Forces
local Force = {}

-- TODO: Consider new copy function file:///home/cameron/src/factorio/factorio_expansion/doc-html/classes/LuaForce.html#copy_from

-- Properties from the original Force that are synced to the Sandbox Force (in not-all-tech mode)
Force.syncedProperties = {
    -- "manual_mining_speed_modifier", Forcibly set
    "manual_crafting_speed_modifier",
    -- "laboratory_speed_modifier", Forcibly set
    "laboratory_productivity_bonus",
    "worker_robots_speed_modifier",
    "worker_robots_battery_modifier",
    "worker_robots_storage_bonus",
    "inserter_stack_size_bonus",
    "bulk_inserter_capacity_bonus",
    "belt_stack_size_bonus",
    "character_trash_slot_count",
    "maximum_following_robot_count",
    "following_robots_lifetime_modifier",
    "character_running_speed_modifier",
    "artillery_range_modifier",
    "beacon_distribution_modifier",
    "character_build_distance_bonus",
    "character_item_drop_distance_bonus",
    "character_reach_distance_bonus",
    "character_resource_reach_distance_bonus",
    "character_item_pickup_distance_bonus",
    "character_loot_pickup_distance_bonus",
    -- "character_inventory_slots_bonus", Set with a bonus
    "character_health_bonus",
    "mining_drill_productivity_bonus",
    "train_braking_force_bonus",
}

-- Setup Force, if necessary
---@param force LuaForce
function Force.Init(force)
    if storage.forces[force.name]
            or Sandbox.IsSandboxForce(force)
            or #force.players < 1
    then
        return
    end

    local forceLabName = Lab.NameFromForce(force)
    local sandboxForceName = Sandbox.NameFromForce(force)
    storage.forces[force.name] = {
        sandboxForceName = sandboxForceName,
    }
    storage.sandboxForces[sandboxForceName] = {
        forceName = force.name,
        hiddenItemsUnlocked = false,
        labName = forceLabName,
    }
end

-- Delete Force's information, if necessary
---@param oldForceName ForceID
---@param newForce LuaForce
function Force.Merge(oldForceName, newForce)
    -- Double-check we know about this Force
    local oldForceData = storage.forces[oldForceName]
    local newForceData = storage.forces[newForce.name]
    if not oldForceData or not newForceData then
        log("Skip Force.Merge: " .. oldForceName .. " -> " .. newForce.name)
        return
    end
    local sandboxForceName = oldForceData.sandboxForceName
    local oldSandboxForceData = storage.sandboxForces[sandboxForceName]
    local oldSandboxForce = game.forces[sandboxForceName]

    -- Bounce any Players currently using the older Sandboxes
    if oldSandboxForce then
        for _, player in pairs(oldSandboxForce.players) do
            if Sandbox.IsPlayerInsideSandbox(player) then
                log("Force.Merge must manually change Sandbox Player's Force: " .. player.name .. " -> " .. newForce.name)
                player.force = newForce
                Sandbox.Exit(player)
            end
        end
    end

    -- Delete the old Force-related Surfaces/Forces
    Lab.DeleteLab(oldSandboxForceData.labName)
    if oldSandboxForce then
        log("Force.Merge must merge Sandbox Forces: " .. oldSandboxForce.name .. " -> " .. newForceData.sandboxForceName)
        game.merge_forces(oldSandboxForce, newForceData.sandboxForceName)
    end

    -- Delete the old Force's data
    storage.forces[oldForceName] = nil
    storage.sandboxForces[sandboxForceName] = nil
end

-- Configure Sandbox Force
---@param force LuaForce
---@param sandboxForce LuaForce
local function ConfigureSandboxForce(force, sandboxForce)
    log("Syncing Forces: " .. force.name .. " -> " .. sandboxForce.name)
    -- TODO: Ideally, lock the Space Platform; but Cheat Mode forcefully enables

    -- Ensure the two Forces don't attack each other
    force.set_cease_fire(sandboxForce, true)
    sandboxForce.set_cease_fire(force, true)

    -- Sync a few properties just in case, but only if they should be linked
    if not settings.global[Settings.allowAllTech].value then
        for _, property in pairs(Force.syncedProperties) do
            sandboxForce[property] = force[property]
        end
    end

    -- Counteract Space Exploration's slow Mining Speed for Gods
    sandboxForce.manual_mining_speed_modifier = settings.global[Settings.extraMiningSpeed].value --[[@as number]]

    -- You should have a little more space too
    sandboxForce.character_inventory_slots_bonus =
        force.character_inventory_slots_bonus
        + settings.global[Settings.bonusInventorySlots].value

    return sandboxForce
end

-- Create Sandbox Force, if necessary
---@param force LuaForce
function Force.GetOrCreateSandboxForce(force)
    local sandboxForceName = storage.forces[force.name].sandboxForceName
    local sandboxForce = game.forces[sandboxForceName]
    if sandboxForce then
        ConfigureSandboxForce(force, sandboxForce)
        return sandboxForce
    end

    log("Creating a new Sandbox Force: " .. force.name .. " -> " .. sandboxForceName)
    sandboxForce = game.create_force(sandboxForceName)
    ConfigureSandboxForce(force, sandboxForce)
    Research.Sync(force, sandboxForce)
    return sandboxForce
end

-- Sandbox Force for a Force
---@param force LuaForce
---@return LuaForce | nil
function Force.GetSandboxForce(force)
    if Sandbox.IsSandboxForce(force) then return force end
    local forceData = storage.forces[force.name]
    if not forceData then return end
    return game.forces[forceData.sandboxForceName]
end

-- Force for a Player, even if they're on the Sandbox Force for now
---@param player LuaPlayer
---@return LuaForce
function Force.GetPlayerMainForce(player)
    local playerData = storage.players[player.index]
    return game.forces[playerData.forceName] or player.force
end

-- Sandbox Force for a Player, if it exists, even if they're on the Sandbox Force for now
---@param player LuaPlayer
---@return LuaForce | nil
function Force.GetPlayerSandboxForce(player)
    local playerData = storage.players[player.index]
    return game.forces[playerData.sandboxForceName]
end

-- Force or Sandbox Force, depending on Isolation
---@param player LuaPlayer
---@return LuaForce
function Force.GetAppropriateForceForSandbox(player)
    local force = player.force --[[@as LuaForce]]
    if Isolation.IsFull() then
        local mainForce = Force.GetPlayerMainForce(player)
        force = Force.GetOrCreateSandboxForce(mainForce)
    elseif Isolation.IsNone() then
        force = Force.GetPlayerMainForce(player)
    end
    return force
end

-- For all Forces with Sandboxes, Configure them again
function Force.SyncAllForces()
    for _, force in pairs(game.forces) do
        if not Sandbox.IsSandboxForce(force) then
            local sandboxForce = game.forces[Sandbox.NameFromForce(force)]
            if sandboxForce then
                ConfigureSandboxForce(force, sandboxForce)
            end
        end
    end
end

return Force
