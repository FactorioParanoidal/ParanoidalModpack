-- Managing multiple Sandboxes for each Player/Force
local Sandbox = {}

Sandbox.pfx = BPSB.pfx .. "sb-"

-- GUI Dropdown items for Sandboxes
Sandbox.choices = {
    { "sandbox." .. Sandbox.pfx .. "player-lab" },
    { "sandbox." .. Sandbox.pfx .. "force-lab" },
    { "sandbox." .. Sandbox.pfx .. "force-lab-space-exploration" },
    { "sandbox." .. Sandbox.pfx .. "force-orbit-space-exploration" },
}
if not SpaceExploration.enabled then
    Sandbox.choices[3] = { "sandbox." .. Sandbox.pfx .. "space-exploration-disabled" }
    Sandbox.choices[4] = { "sandbox." .. Sandbox.pfx .. "space-exploration-disabled" }
end

-- Constants to represent indexes for Sandbox.choices
Sandbox.player = 1
Sandbox.force = 2
Sandbox.forcePlanetaryLab = 3
Sandbox.forceOrbitalSandbox = 4

-- A unique per-Force Sandbox Name
function Sandbox.NameFromForce(force)
    return Sandbox.pfx .. "f-" .. force.name
end

-- Whether the Force is specific to Blueprint Sandboxes
function Sandbox.IsSandboxForce(force)
    -- return string.sub(force.name, 1, pfxLength) == Sandbox.pfx
    return not not global.sandboxForces[force.name]
end

-- Whether something is any type of Sandbox
function Sandbox.IsSandbox(thingWithName)
    return Lab.IsLab(thingWithName)
            or SpaceExploration.IsSandbox(thingWithName)
end

-- Whether something is any type of Sandbox
function Sandbox.IsPlayerInsideSandbox(player)
    return global.players[player.index].preSandboxPosition ~= nil
            and Sandbox.IsSandbox(player.surface)
end

-- Whether a Sandbox choice is allowed
function Sandbox.IsEnabled(selectedSandbox)
    if selectedSandbox == Sandbox.player then
        return true
    elseif selectedSandbox == Sandbox.force then
        return true
    elseif selectedSandbox == Sandbox.forceOrbitalSandbox then
        return SpaceExploration.enabled
    elseif selectedSandbox == Sandbox.forcePlanetaryLab then
        return SpaceExploration.enabled
    else
        log("Impossible Choice for Sandbox: " .. selectedSandbox)
        return false
    end
end

-- Which Surface Name to use for this Player based on their Selected Sandbox
function Sandbox.GetOrCreateSandboxSurface(player, sandboxForce)
    local playerData = global.players[player.index]

    if playerData.selectedSandbox == Sandbox.player
    then
        return Lab.GetOrCreateSurface(playerData.labName, sandboxForce)
    elseif playerData.selectedSandbox == Sandbox.force
    then
        return Lab.GetOrCreateSurface(global.sandboxForces[sandboxForce.name].labName, sandboxForce)
    elseif SpaceExploration.enabled
            and playerData.selectedSandbox == Sandbox.forceOrbitalSandbox
    then
        return SpaceExploration.GetOrCreateOrbitalSurfaceForForce(player, sandboxForce)
    elseif SpaceExploration.enabled
            and playerData.selectedSandbox == Sandbox.forcePlanetaryLab
    then
        return SpaceExploration.GetOrCreatePlanetarySurfaceForForce(player, sandboxForce)
    else
        log("Impossible Choice for Sandbox: " .. playerData.selectedSandbox)
        return
    end
end

-- Convert the Player to God-mode, save their previous State, and enter Selected Sandbox
function Sandbox.Enter(player)
    local playerData = global.players[player.index]

    if Sandbox.IsPlayerInsideSandbox(player) then
        log("Already inside Sandbox: " .. playerData.insideSandbox)
        return
    end

    if player.stashed_controller_type
            and player.stashed_controller_type ~= defines.controllers.editor
    then
        player.print("You are already detached from your Character, so you cannot enter a Sandbox. Return to your Character first.")
        return
    end

    local sandboxForce = Force.GetOrCreateSandboxForce(game.forces[playerData.forceName])
    local surface = Sandbox.GetOrCreateSandboxSurface(player, sandboxForce)
    if surface == nil then
        log("Completely Unknown Sandbox Surface, cannot use")
        return
    end
    log("Entering Sandbox: " .. surface.name)

    -- Store some temporary State to use once inside the Sandbox
    local inputBlueprint = Inventory.GetCursorBlueprintString(player)

    --[[
    Otherwise, there is a Factorio "bug" that can destroy what was in the Cursor.
    It seems to happen with something from the Inventory being in the Stack, then
    entering the Sandbox, then copying something from the Sandbox, then exiting the
    Sandbox. At this point, the Cursor Stack is still fine and valid, but it seems
    to have lost its original location, so "clearing" it out will destroy it.
    ]]
    player.clear_cursor()

    -- Store the Player's previous State (that must be referenced to Exit)
    playerData.insideSandbox = playerData.selectedSandbox
    playerData.preSandboxForceName = player.force.name
    playerData.preSandboxCharacter = player.character
    playerData.preSandboxController = player.controller_type
    playerData.preSandboxPosition = player.position
    playerData.preSandboxSurfaceName = player.surface.name
    playerData.preSandboxCheatMode = player.cheat_mode

    -- Sometimes a Player has a volatile Inventory that needs restoring later
    if Inventory.ShouldPersist(playerData.preSandboxController) then
        playerData.preSandboxInventory = Inventory.Persist(
                player.get_main_inventory(),
                playerData.preSandboxInventory
        )
    else
        if playerData.preSandboxInventory then
            playerData.preSandboxInventory.destroy()
            playerData.preSandboxInventory = nil
        end
    end

    -- Harmlessly detach the Player from their Character
    player.set_controller({ type = defines.controllers.god })

    -- Harmlessly teleport their God-body to the Sandbox
    player.teleport(playerData.lastSandboxPositions[surface.name] or { 0, 0 }, surface)

    -- Swap to the new Force; it has different bonuses!
    player.force = sandboxForce

    -- Since the Sandbox might have Cheat Mode enabled, EditorExtensions won't receive an Event for this otherwise
    if player.cheat_mode then
        player.cheat_mode = false
    end

    -- Enable Cheat mode _afterwards_, since EditorExtensions will alter the Force (now the Sandbox Force) based on this
    player.cheat_mode = true

    -- Harmlessly ensure our own Recipes are enabled
    -- TODO: It's unclear why this must happen _after_ the above code
    Research.EnableSandboxSpecificResearch(sandboxForce)

    -- Now that everything has taken effect, restoring the Inventory is safe
    Inventory.Restore(
            playerData.sandboxInventory,
            player.get_main_inventory()
    )

    -- Then, restore the Blueprint in the Cursor
    if inputBlueprint then
        player.cursor_stack.import_stack(inputBlueprint)
        player.cursor_stack_temporary = true
    end
end

-- Convert the Player to their previous State, and leave Selected Sandbox
function Sandbox.Exit(player)
    local playerData = global.players[player.index]

    if not Sandbox.IsPlayerInsideSandbox(player) then
        log("Already outside Sandbox")
        return
    end
    log("Exiting Sandbox: " .. player.surface.name)

    -- Store some temporary State to use once outside the Sandbox
    local outputBlueprint = Inventory.GetCursorBlueprintString(player)

    -- Remember where they left off
    playerData.lastSandboxPositions[player.surface.name] = player.position

    -- Attach the Player back to their original Character (also changes force)
    Sandbox.RecoverPlayerCharacter(player, playerData)

    -- Swap to their original Force (in case they're not sent back to a Character)
    player.force = playerData.preSandboxForceName

    -- Toggle Cheat mode _afterwards_, just in case EditorExtensions ever listens to this Event
    player.cheat_mode = playerData.preSandboxCheatMode or false

    -- Sometimes a Player is already a God (like in Sandbox), and their Inventory wasn't on a body
    if Inventory.ShouldPersist(playerData.preSandboxController) then
        Inventory.Restore(
                playerData.preSandboxInventory,
                player.get_main_inventory()
        )
    end

    -- Reset the Player's previous State
    playerData.insideSandbox = nil
    playerData.preSandboxForceName = nil
    playerData.preSandboxCharacter = nil
    playerData.preSandboxController = nil
    playerData.preSandboxPosition = nil
    playerData.preSandboxSurfaceName = nil
    playerData.preSandboxCheatMode = nil
    if playerData.preSandboxInventory then
        playerData.preSandboxInventory.destroy()
        playerData.preSandboxInventory = nil
    end

    -- Potentially, restore the Blueprint in the Cursor
    if outputBlueprint and Inventory.WasCursorSafelyCleared(player) then
        player.cursor_stack.import_stack(outputBlueprint)
        player.cursor_stack_temporary = true
    end
end

-- Ensure the Player has a Character to go back to
function Sandbox.RecoverPlayerCharacter(player, playerData)
    -- Typical situation, there wasn't a Character, or there was a valid one
    if (not playerData.preSandboxCharacter) or playerData.preSandboxCharacter.valid then
        player.teleport(playerData.preSandboxPosition, playerData.preSandboxSurfaceName)
        player.set_controller({
            type = playerData.preSandboxController,
            character = playerData.preSandboxCharacter
        })
        return
    end

    -- Space Exploration deletes and recreates Characters; check that out next
    local fromSpaceExploration = SpaceExploration.GetPlayerCharacter(player)
    if fromSpaceExploration and fromSpaceExploration.valid then
        player.teleport(fromSpaceExploration.position, fromSpaceExploration.surface.name)
        player.set_controller({
            type = defines.controllers.character,
            character = fromSpaceExploration
        })
        return
    end

    -- We might at-least have a Surface to go back to
    if playerData.preSandboxSurfaceName and game.surfaces[playerData.preSandboxSurfaceName] then
        player.print("Unfortunately, your previous Character was lost, so it had to be recreated.")
        player.teleport(playerData.preSandboxPosition, playerData.preSandboxSurfaceName)
        local recreated = game.surfaces[playerData.preSandboxSurfaceName].create_entity {
            name = "character",
            position = playerData.preSandboxPosition,
            force = playerData.preSandboxForceName,
            raise_built = true,
        }
        player.set_controller({
            type = playerData.preSandboxController,
            character = recreated
        })
        return
    end

    -- Otherwise, we need a completely clean slate :(
    player.print("Unfortunately, your previous Character was completely lost, so you must start anew.")
    player.teleport({ 0, 0 }, "nauvis")
    local recreated = game.surfaces["nauvis"].create_entity {
        name = "character",
        position = { 0, 0 },
        force = playerData.preSandboxForceName,
        raise_built = true,
    }
    player.set_controller({
        type = playerData.preSandboxController,
        character = recreated
    })
end

-- Keep a Player's God-state, but change between Selected Sandboxes
function Sandbox.Transfer(player)
    local playerData = global.players[player.index]

    if not Sandbox.IsPlayerInsideSandbox(player) then
        log("Outside Sandbox, cannot transfer")
        return
    end

    local sandboxForce = Force.GetOrCreateSandboxForce(game.forces[playerData.forceName])
    local surface = Sandbox.GetOrCreateSandboxSurface(player, sandboxForce)
    if surface == nil then
        log("Completely Unknown Sandbox Surface, cannot use")
        return
    end

    log("Transferring to Sandbox: " .. surface.name)
    playerData.lastSandboxPositions[player.surface.name] = player.position
    player.teleport(playerData.lastSandboxPositions[surface.name] or { 0, 0 }, surface)

    playerData.insideSandbox = playerData.selectedSandbox
end

-- Update Sandboxes Player if a Player actually changes Forces (outside of this mod)
function Sandbox.OnPlayerForceChanged(player)
    local playerData = global.players[player.index]
    local force = player.force
    if not Sandbox.IsSandboxForce(force)
            and playerData.forceName ~= force.name
    then
        log("Storing changed Player's Force: " .. player.name .. " -> " .. force.name)
        playerData.forceName = force.name

        local sandboxForceName = Sandbox.NameFromForce(force)

        playerData.sandboxForceName = sandboxForceName
        local labData = global.labSurfaces[playerData.labName]
        if labData then
            labData.sandboxForceName = sandboxForceName
        end

        if Sandbox.IsPlayerInsideSandbox(player) then
            player.print("Your Force changed, so you have been removed from your Sandbox")
            playerData.preSandboxForceName = force.name
            Sandbox.Exit(player)
        end
        player.print("Your Force changed, so you might have to Reset your Lab")
    end
end

-- Determine whether the Player is inside a known Sandbox
function Sandbox.GetSandboxChoiceFor(player, surface)
    local playerData = global.players[player.index]
    if surface.name == playerData.labName then
        return Sandbox.player
    elseif surface.name == global.sandboxForces[playerData.sandboxForceName].labName then
        return Sandbox.force
    elseif surface.name == global.sandboxForces[playerData.sandboxForceName].seOrbitalSandboxZoneName then
        return Sandbox.forceOrbitalSandbox
    elseif surface.name == global.sandboxForces[playerData.sandboxForceName].sePlanetaryLabZoneName then
        return Sandbox.forcePlanetaryLab
    elseif Factorissimo.IsFactory(surface) then
        local outsideSurface = Factorissimo.GetOutsideSurfaceForFactory(
                surface,
                player.position
        )
        if outsideSurface then
            return Sandbox.GetSandboxChoiceFor(player, outsideSurface)
        end
    end
    return nil
end

-- Update whether the Player is inside a known Sandbox
function Sandbox.OnPlayerSurfaceChanged(player)
    if Sandbox.IsPlayerInsideSandbox(player) then
        global.players[player.index].insideSandbox = Sandbox.GetSandboxChoiceFor(player, player.surface)
    end
end

-- Enter, Exit, or Transfer a Player across Sandboxes
function Sandbox.Toggle(player_index)
    local player = game.players[player_index]
    local playerData = global.players[player.index]

    if Factorissimo.IsFactoryInsideSandbox(player.surface, player.position) then
        player.print("You are inside of a Factory, so you cannot change Sandboxes")
        return
    end

    if not Sandbox.IsEnabled(playerData.selectedSandbox) then
        playerData.selectedSandbox = Sandbox.player
    end

    if Sandbox.IsPlayerInsideSandbox(player)
            and playerData.insideSandbox ~= playerData.selectedSandbox
    then
        Sandbox.Transfer(player)
    elseif Sandbox.IsPlayerInsideSandbox(player) then
        Sandbox.Exit(player)
    else
        SpaceExploration.ExitRemoteView(player)
        Sandbox.Enter(player)
    end
end

return Sandbox
