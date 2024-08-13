-- Managing Forces and their Sandbox Forces
local Force = {}

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
    "stack_inserter_capacity_bonus",
    "character_trash_slot_count",
    "maximum_following_robot_count",
    "following_robots_lifetime_modifier",
    "character_running_speed_modifier",
    "artillery_range_modifier",
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
function Force.Init(force)
    if global.forces[force.name]
            or Sandbox.IsSandboxForce(force)
            or #force.players < 1
    then
        log("Skip Force.Init: " .. force.name)
        return
    end

    log("Force.Init: " .. force.name)
    local forceLabName = Lab.NameFromForce(force)
    local sandboxForceName = Sandbox.NameFromForce(force)
    global.forces[force.name] = {
        sandboxForceName = sandboxForceName,
    }
    global.sandboxForces[sandboxForceName] = {
        forceName = force.name,
        hiddenItemsUnlocked = false,
        labName = forceLabName,
        sePlanetaryLabZoneName = nil,
        seOrbitalSandboxZoneName = nil,
    }
end

-- Delete Force's information, if necessary
function Force.Merge(oldForceName, newForce)
    -- Double-check we know about this Force
    local oldForceData = global.forces[oldForceName]
    local newForceData = global.forces[newForce.name]
    if not oldForceData or not newForceData then
        log("Skip Force.Merge: " .. oldForceName .. " -> " .. newForce.name)
        return
    end
    local sandboxForceName = oldForceData.sandboxForceName
    local oldSandboxForceData = global.sandboxForces[sandboxForceName]
    local oldSandboxForce = game.forces[sandboxForceName]

    -- Bounce any Players currently using the older Sandboxes
    if oldSandboxForce then
        for _, player in pairs(oldSandboxForce.players) do
            if Sandbox.IsPlayerInsideSandbox(player) then
                log("Force.Merge must manually change Sandbox Player's Force: " .. player.name .. " -> " .. newForce.name)
                player.force = newForce
            end
        end
    end

    -- Delete the old Force-related Surfaces/Forces
    Lab.DeleteLab(oldSandboxForceData.labName)
    SpaceExploration.DeleteSandbox(oldSandboxForceData, oldSandboxForceData.sePlanetaryLabZoneName)
    SpaceExploration.DeleteSandbox(oldSandboxForceData, oldSandboxForceData.seOrbitalSandboxZoneName)
    if oldSandboxForce then
        log("Force.Merge must merge Sandbox Forces: " .. oldSandboxForce.name .. " -> " .. newForceData.sandboxForceName)
        game.merge_forces(oldSandboxForce, newForceData.sandboxForceName)
    end

    -- Delete the old Force's data
    global.forces[oldForceName] = nil
    global.sandboxForces[sandboxForceName] = nil
end

-- Configure Sandbox Force
function Force.ConfigureSandboxForce(force, sandboxForce)
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
    sandboxForce.manual_mining_speed_modifier = settings.global[Settings.extraMiningSpeed].value

    -- Make research faster/slower based on play-style
    sandboxForce.laboratory_speed_modifier = settings.global[Settings.extraLabSpeed].value

    -- You should have a little more space too
    sandboxForce.character_inventory_slots_bonus =
        force.character_inventory_slots_bonus
        + settings.global[Settings.bonusInventorySlots].value

    return sandboxForce
end

-- Create Sandbox Force, if necessary
function Force.GetOrCreateSandboxForce(force)
    local sandboxForceName = global.forces[force.name].sandboxForceName
    local sandboxForce = game.forces[sandboxForceName]
    if sandboxForce then
        Force.ConfigureSandboxForce(force, sandboxForce)
        return sandboxForce
    end

    log("Creating Sandbox Force: " .. sandboxForceName)
    sandboxForce = game.create_force(sandboxForceName)
    Force.ConfigureSandboxForce(force, sandboxForce)
    Research.Sync(force, sandboxForce)
    return sandboxForce
end

-- For all Forces with Sandboxes, Configure them again
function Force.SyncAllForces()
    for _, force in pairs(game.forces) do
        if not Sandbox.IsSandboxForce(force) then
            local sandboxForce = game.forces[Sandbox.NameFromForce(force)]
            if sandboxForce then
                Force.ConfigureSandboxForce(force, sandboxForce)
            end
        end
    end
end

return Force
