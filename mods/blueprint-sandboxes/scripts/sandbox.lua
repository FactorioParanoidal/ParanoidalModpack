-- Managing multiple Sandboxes for each Player/Force
local Sandbox = {}

Sandbox.pfx = BPSB.pfx .. "sb-"
local pfxLength = string.len(Sandbox.pfx)

-- GUI Dropdown items for Sandboxes
Sandbox.choices = {
    { "sandbox." .. Sandbox.pfx .. "player-lab" },
    { "sandbox." .. Sandbox.pfx .. "force-lab" },
}

-- Constants to represent indexes for Sandbox.choices
Sandbox.player = 1
Sandbox.force = 2

-- A unique per-Force Sandbox Name
---@param force LuaForce
function Sandbox.NameFromForce(force)
    return Sandbox.pfx .. "f-" .. force.name
end

-- Whether the Force is specific to Blueprint Sandboxes
---@param force LuaForce
function Sandbox.IsSandboxForce(force)
    return string.sub(force.name, 1, pfxLength) == Sandbox.pfx
end

-- Whether something is any type of Sandbox
function Sandbox.IsSandbox(thingWithName)
    return Lab.IsLab(thingWithName)
end

-- Whether something is any type of Sandbox
---@param player LuaPlayer
function Sandbox.IsPlayerInsideSandbox(player)
    return Sandbox.IsSandbox(player.surface)
end

-- Whether a Sandbox choice is allowed
function Sandbox.IsEnabled(selectedSandbox)
    if selectedSandbox == Sandbox.player then
        return true
    elseif selectedSandbox == Sandbox.force then
        return true
    else
        log("Impossible Choice for Sandbox: " .. selectedSandbox)
        return false
    end
end

-- Which Surface Name to use for this Player based on their Selected Sandbox
---@param player LuaPlayer
---@return LuaSurface | nil
function Sandbox.GetOrCreateSandboxSurface(player)
    local playerData = storage.players[player.index]

    if playerData.selectedSandbox == Sandbox.player
    then
        return Lab.GetOrCreateSurface(playerData.labName, playerData.forceName, playerData.sandboxForceName)
    elseif playerData.selectedSandbox == Sandbox.force
    then
        local sandboxForceData = storage.sandboxForces[playerData.sandboxForceName]
        return Lab.GetOrCreateSurface(sandboxForceData.labName, playerData.forceName, playerData.sandboxForceName)
    else
        log("Impossible Choice for Sandbox: " .. playerData.selectedSandbox)
        return
    end
end

---@param player LuaPlayer
local function StoreCursorBlueprint(player, playerData)
    if playerData.transitionaryBlueprintString == nil then
        playerData.transitionaryBlueprintString = Inventory.GetCursorBlueprintString(player)
    end
end

---@param player LuaPlayer
local function RestoreCursorBlueprint(player, playerData)
    if playerData.transitionaryBlueprintString ~= nil then
        if Inventory.WasCursorSafelyCleared(player) then
            player.cursor_stack.import_stack(playerData.transitionaryBlueprintString)
            player.cursor_stack_temporary = true
            playerData.transitionaryBlueprintString = nil
        end
    end
end

---@param player LuaPlayer
local function StorePreSandboxStateBeforeEntrance(player, playerData)
    playerData.preSandboxSurfaceName = player.surface.name
    playerData.preSandboxPosition = player.position
    playerData.preSandboxController = player.controller_type

    if playerData.preSandboxCharacter == nil or player.character ~= nil then
        playerData.preSandboxCharacter = player.character
    end

    -- Sometimes a Player has a volatile Inventory that needs restoring later
    if Inventory.ShouldPersist(player.controller_type) then
        log(player.name .. " has a volatile inventory; must persist it before entrance")
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

    if not Controllers.IsSandboxCompatible(player) then
        StoreCursorBlueprint(player, playerData)

        --[[
        Otherwise, there is a Factorio "bug" that can destroy what was in the Cursor.
        It seems to happen with something from the Inventory being in the Stack, then
        entering the Sandbox, then copying something from the Sandbox, then exiting the
        Sandbox. At this point, the Cursor Stack is still fine and valid, but it seems
        to have lost its original location, so "clearing" it out will destroy it.
        ]]
        player.clear_cursor()
    end
end

-- Convert the Player to Remote-view, save their previous State, and view Selected Sandbox
---@param player LuaPlayer
function Sandbox.View(player)
    local playerData = storage.players[player.index]
    if Sandbox.IsPlayerInsideSandbox(player) then return end

    local surface = Sandbox.GetOrCreateSandboxSurface(player)
    if surface == nil then
        log("Completely Unknown Sandbox Surface, cannot use")
        return
    end

    -- Store the Player's previous State (that must be referenced to Exit)
    StorePreSandboxStateBeforeEntrance(player, playerData)
    Controllers.StoreRemoteView(player, playerData)

    -- Harmlessly begin by Remotely Viewing the Sandbox
    player.set_controller({
        type = defines.controllers.remote,
        surface = surface,
        position = playerData.lastSandboxPositions[surface.name],
    })
end

-- Convert the Player to God-mode, save their previous State, and enter Selected Sandbox
---@param player LuaPlayer
function Sandbox.Enter(player)
    local playerData = storage.players[player.index]
    if Sandbox.IsPlayerInsideSandbox(player) then return end

    local canBeSafelyReplaced = Controllers.CanBeSafelyReplaced(player)
    if canBeSafelyReplaced ~= true then
        player.create_local_flying_text({
            text = {"", {"messages.sandbox-unsafe-to-replace-controller"}, ": ", canBeSafelyReplaced},
            position = player.position,
        })
        return
    end

    Controllers.StoreRemoteView(player, playerData)
    if not Controllers.SafelyCloseRemoteView(player) then
        player.create_local_flying_text({
            text = {"messages.sandbox-unsafe-to-close-remote-view"},
            position = player.position,
        })
        return
    end

    local surface = Sandbox.GetOrCreateSandboxSurface(player)
    if surface == nil then
        log("Completely Unknown Sandbox Surface, cannot use")
        return
    end

    -- Store the Player's previous State (that must be referenced to Exit)
    StorePreSandboxStateBeforeEntrance(player, playerData)

    local character = player.character
    -- Stop walking to prevent character from moving while in Sandbox
    if character and character.walking_state.walking then
        character.walking_state = {
            walking = false,
            direction = character.walking_state.direction,
        }
    end

    -- Harmlessly detach the Player from their Character
    player.set_controller({ type = defines.controllers.god })
    if character and not character.associated_player then
        player.associate_character(character)
    end

    -- Harmlessly teleport their God-body to the Sandbox
    Teleport.ToPositionOnSurface(player, surface, playerData.lastSandboxPositions[surface.name] or { 0, 0 })
end

-- Convert the Player to their previous State, and leave Selected Sandbox
---@param player LuaPlayer
function Sandbox.Exit(player)
    local playerData = storage.players[player.index]

    if not Sandbox.IsPlayerInsideSandbox(player) then
        log("Already outside Sandbox")
        return
    end

    -- Remember where they left off
    playerData.lastSandboxPositions[player.surface.name] = player.position

    local preSandboxSurface = playerData.preSandboxSurfaceName and game.surfaces[playerData.preSandboxSurfaceName]
    if not Controllers.IsUsingRemoteView(player) and not preSandboxSurface then
        playerData.preSandboxSurfaceName = nil
        log(player.name .. " has no last known Surface, so they cannot exit the Sandbox normally")
        player.print{"messages.sandbox-exiting-without-known-entrace"}
        Controllers.RestoreLastController(player, playerData)
        return
    end

    -- Harmlessly teleport them out of the Sandbox
    Teleport.ToPositionOnSurface(
        player,
        playerData.preSandboxSurfaceName,
        playerData.preSandboxPosition or { 0, 0 }
    )
    Controllers.SafelyCloseRemoteView(player)
end

-- Keep a Player's God-state, but change between Selected Sandboxes
---@param player LuaPlayer
function Sandbox.Transfer(player)
    local playerData = storage.players[player.index]

    if not Sandbox.IsPlayerInsideSandbox(player) then
        log(player.name .. " was outside Sandbox, so cannot be transferred")
        return
    end

    local surface = Sandbox.GetOrCreateSandboxSurface(player)
    if surface == nil then
        log("Completely Unknown Sandbox Surface, cannot use")
        return
    end

    log(player.name .. " transferring Sandboxes: " .. player.surface.name .. " -> " .. surface.name)
    playerData.lastSandboxPositions[player.surface.name] = player.position
    Teleport.ToPositionOnSurface(player, surface, playerData.lastSandboxPositions[surface.name] or { 0, 0 })
end

-- Update Sandboxes Player if a Player actually changes Forces (outside of this mod)
---@param player LuaPlayer
function Sandbox.OnPlayerForceChanged(player)
    local playerData = storage.players[player.index]
    if not playerData then return end
    local force = player.force --[[@as LuaForce]]
    if not Sandbox.IsSandboxForce(force)
            and playerData.forceName ~= force.name
    then
        log("Storing changed Player's Force: " .. player.name .. " -> " .. force.name)
        playerData.forceName = force.name

        local sandboxForceName = Sandbox.NameFromForce(force)
        playerData.sandboxForceName = sandboxForceName
        local labData = storage.labSurfaces[playerData.labName]
        if labData then
            labData.sandboxForceName = sandboxForceName
        end

        local labSurface = game.surfaces[playerData.labName]
        if labSurface then
            local labForce = Force.GetOrCreateSandboxForce(force)
            Lab.AssignEntitiesToForce(labSurface, labForce)
        end

        if Isolation.IsFull() and Sandbox.IsPlayerInsideSandbox(player) then
            player.print{"messages.sandbox-force-changed-while-in-sandbox"}
            playerData.preSandboxForceName = force.name
            Sandbox.Exit(player)
        end
    end
end

-- Determine whether the Player is inside a known Sandbox
---@param player LuaPlayer
---@param surface LuaSurface
function Sandbox.GetSandboxChoiceFor(player, surface)
    local playerData = storage.players[player.index]
    if playerData.labName and surface.name == playerData.labName then
        return Sandbox.player
    end

    local sandboxForce = storage.sandboxForces[playerData.sandboxForceName]
    if sandboxForce and surface.name == sandboxForce.labName then
        return Sandbox.force
    end

    if Factorissimo.IsFactory(surface) then
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

---@param player LuaPlayer
local function StorePreSandboxStateOnArrival(player, playerData)
    if playerData.preSandboxForceName == nil then
        if Sandbox.IsSandboxForce(player.force --[[@as LuaForce]]) then
            log(player.name .. " entered a Sandbox as the Sandbox Force; assuming the player force")
            playerData.preSandboxForceName = "player"
        else
            playerData.preSandboxForceName = player.force.name
        end
    end

    if player.permission_group then
        if Permissions.IsSandboxPermissions(player.permission_group.name) then
            log(player.name .. " entered a Sandbox with the Sandbox Permissions; assuming none")
            playerData.preSandboxPermissionGroupId = nil
        else
            playerData.preSandboxPermissionGroupId = player.permission_group.name
        end
    else
        playerData.preSandboxPermissionGroupId = nil
    end

    if playerData.preSandboxCheatMode == nil then
        playerData.preSandboxCheatMode = player.cheat_mode
    end

    if playerData.preSandboxSurfaceList == nil then
        playerData.preSandboxSurfaceList = player.game_view_settings.show_surface_list
    end
end

---@param player LuaPlayer
local function EnableSandboxFeatures(player)
    if Isolation.IsFull() then
        -- Swap to the new Force; it has different bonuses!
        local mainForce = Force.GetPlayerMainForce(player)
        local sandboxForce = Force.GetOrCreateSandboxForce(mainForce)
        player.force = sandboxForce


        -- Since the Sandbox might have Cheat Mode enabled, EditorExtensions won't receive an Event for this otherwise
        if player.cheat_mode then player.cheat_mode = false end
        -- Enable Cheat mode _afterwards_, since EditorExtensions will alter the Force (now the Sandbox Force) based on this
        player.cheat_mode = true
    end

    -- Ensure our own Recipes are enabled
    local appropriateForce = Force.GetAppropriateForceForSandbox(player)
    Research.EnableSandboxSpecificResearchIfNecessary(appropriateForce)
end

---@param player LuaPlayer
local function EnforceSandboxPermissions(player)
    if Isolation.IsFull() then
        -- Set some Permissions so the Player cannot affect their other Surfaces
        local newPermissions = Permissions.GetOrCreate(player)
        if newPermissions then
            log("Setting new Player Permissions: " .. player.name .. " -> " .. newPermissions.name)
            player.permission_group = newPermissions
        end

        -- This list allows creating platforms (which is blocked by permissions) and no other surfaces (since this isn't their force)
        player.game_view_settings.show_surface_list = false
    elseif Isolation.IsNone() then
        local visibleNonSandboxSurfaces = 0
        for _, surface in pairs(game.surfaces) do
            if not Sandbox.IsSandbox(surface) and not player.force.get_surface_hidden(surface) then
                visibleNonSandboxSurfaces = visibleNonSandboxSurfaces + 1
            end
        end
        player.game_view_settings.show_surface_list = visibleNonSandboxSurfaces > 1
    end
end

---@param player LuaPlayer
local function RestoreSandboxState(player, playerData)
    if Controllers.IsGod(player) then
        if not playerData.sandboxInventory then
            playerData.sandboxInventory = Inventory.Initialize(player.get_main_inventory())
        end
        Inventory.Restore(
                playerData.sandboxInventory,
                player.get_main_inventory()
        )
    end

    RestoreCursorBlueprint(player, playerData)
end

---@param player LuaPlayer
local function RestorePreSandboxController(player, playerData)
    -- When exiting directly to a Remote View, we first need to restore the physical settings (if they exist)
    if Controllers.IsUsingRemoteView(player) and player.physical_controller_type ~= playerData.preSandboxController then
        Controllers.StoreRemoteView(player, playerData)
        Controllers.SafelyCloseRemoteView(player)
    end
    Controllers.RestoreLastController(player, playerData)

    -- Sometimes a Player is already a God (like in Sandbox), and their Inventory wasn't on a body
    if Inventory.ShouldPersist(player.controller_type) and playerData.preSandboxInventory then
        Inventory.Restore(
                playerData.preSandboxInventory,
                player.get_main_inventory()
        )
    end
    if playerData.preSandboxInventory then
        playerData.preSandboxInventory.destroy()
        playerData.preSandboxInventory = nil
    end
end

---@param player LuaPlayer
local function RestorePreSandboxPermissions(player, playerData)
    -- Don't let anyone attempt to edit Surface Properties of other Surfaces!
    SurfacePropsGUI.Destroy(player)

    -- Swap to their original Force (in case they're not sent back to a Character)
    if playerData.preSandboxForceName and player.force.name ~= playerData.preSandboxForceName then
        player.force = playerData.preSandboxForceName
    end

    -- Toggle Cheat mode _afterwards_, just in case EditorExtensions ever listens to this Event
    local desiredCheatMode = playerData.preSandboxCheatMode or false
    if player.cheat_mode ~= desiredCheatMode then
        player.cheat_mode = desiredCheatMode
    end

    -- Swap to their original Permissions
    local playerPermissions = player.permission_group
    local storedPermissionsId = playerData.preSandboxPermissionGroupId
    if storedPermissionsId then
        if not playerPermissions or playerPermissions.group_id ~= storedPermissionsId then
            log("Restoring Player Permissions: " .. player.name .. " -> " .. storedPermissionsId)
            player.permission_group = game.permissions.get_group(storedPermissionsId)
        end
    else
        if playerPermissions and Permissions.IsSandboxPermissions(playerPermissions.name) then
            log("Removing Player Permissions: " .. player.name)
            player.permission_group = nil
        end
    end

    -- Swap to their original surface-list setting
    local desiredSurfaceList = playerData.preSandboxSurfaceList or true
    if player.game_view_settings.show_surface_list ~= desiredSurfaceList then
        player.game_view_settings.show_surface_list = desiredSurfaceList
    end

    -- Potentially lock the Research again
    Research.DisableSandboxSpecificResearchIfNecessary(player.force --[[@as LuaForce]])
end

local function CleanStates(playerData)
    -- Cleanup some restored states that may go stale and cannot be relied on later
    playerData.preSandboxForceName = nil
    playerData.preSandboxCheatMode = nil
    playerData.preSandboxSurfaceList = nil
    playerData.preSandboxPermissionGroupId = nil

    -- Cleanup some unused states that may go stale and cannot be relied on later
    playerData.preSandboxCharacter = nil
    playerData.preSandboxController = nil
    playerData.preSandboxPosition = nil
    playerData.preSandboxSurfaceName = nil
end

-- Is it likely that Swap to God can work?
---@param player LuaPlayer
---@return boolean
function Sandbox.CanEnter(player)
    if Isolation.IsNone() then return false end
    if player.physical_controller_type ~= defines.controllers.character then return false end
    return Controllers.IsUsingRemoteView(player)
end

-- Convert the Player to God-mode, save their previous State, and enter Selected Sandbox
---@param player LuaPlayer
function Sandbox.SwapToGod(player)
    local playerData = storage.players[player.index]
    if not Sandbox.IsPlayerInsideSandbox(player) then return end

    -- Remember where they left off
    local surface = player.surface
    playerData.lastSandboxPositions[surface.name] = player.position
    StoreCursorBlueprint(player, playerData)

    -- Get back to their real/physical controllers so we can save them
    local canBeSafelyReplaced = Controllers.CanBeSafelyReplaced(player)
    if canBeSafelyReplaced ~= true then
        player.create_local_flying_text({
            text = {"", {"messages.sandbox-unsafe-to-replace-controller"}, ": ", canBeSafelyReplaced},
            position = player.position,
        })
        return
    end
    if not Controllers.SafelyCloseRemoteView(player) then
        player.create_local_flying_text({
            text = {"messages.sandbox-unsafe-to-close-remote-view"},
            position = player.position,
        })
        return
    end

    -- Store the Player's previous State (that must be referenced to Exit)
    StorePreSandboxStateBeforeEntrance(player, playerData)

    -- Harmlessly detach the Player from their Character
    local character = player.character
    player.set_controller({ type = defines.controllers.god })
    if character and not character.associated_player then
        player.associate_character(character)
    end

    -- Harmlessly teleport their God-body back to the Sandbox
    Teleport.ToPositionOnSurface(player, surface, playerData.lastSandboxPositions[surface.name] or { 0, 0 })

    -- Restore states again
    RestoreSandboxState(player, playerData)
end

-- Update whether the Player is inside a known Sandbox
---@param player LuaPlayer
function Sandbox.OnPlayerSurfaceChanged(player)
    local playerData = storage.players[player.index]
    local insideSandbox = Sandbox.GetSandboxChoiceFor(player, player.surface)
    local lastKnownSandbox = playerData.insideSandbox

    local wasInSandbox = lastKnownSandbox ~= nil
    local nowInSandbox = not not insideSandbox

    playerData.insideSandbox = insideSandbox

    if not wasInSandbox and nowInSandbox then
        log(player.name .." entered a Sandbox: " .. player.surface.name)

        if not Controllers.IsSandboxSupported(player) then
            log(player.name .. " entered a Sandbox with the Controller ID " .. player.controller_type .. "; bailing out.")
            player.create_local_flying_text({
                text = {"messages.sandbox-entrace-from-unsupported-controller"},
                position = player.position,
            })
        end

        StorePreSandboxStateOnArrival(player, playerData)
        EnableSandboxFeatures(player)
        EnforceSandboxPermissions(player)
        RestoreSandboxState(player, playerData)
        player.force.chart_all(player.surface)

    elseif wasInSandbox and not nowInSandbox then
        log(player.name .. " exiting last known Sandbox " .. lastKnownSandbox .. " to new Surface: " .. player.surface.name)

        StoreCursorBlueprint(player, playerData)
        RestorePreSandboxController(player, playerData)
        RestorePreSandboxPermissions(player, playerData)
        RestoreCursorBlueprint(player, playerData)
        Controllers.RestoreRemoteView(player, playerData)
        CleanStates(playerData)

    elseif wasInSandbox and nowInSandbox then
        log(player.name .. " transferred from last known Sandbox " .. lastKnownSandbox .. " to new Surface: " .. player.surface.name)

        player.force.chart_all(player.surface)
    end
end

-- Enter, Exit, or Transfer a Player across Sandboxes
function Sandbox.Toggle(player_index)
    local player = game.players[player_index]
    local playerData = storage.players[player.index]

    if Factorissimo.IsFactoryInsideSandbox(player.surface, player.position) then
        player.create_local_flying_text({
            text = {"messages.factorissimo-cannot-change-sandbox"},
            position = player.position,
        })
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
        if Isolation.IsFull() then
            Sandbox.Enter(player)
        elseif Isolation.IsNone() then
            Sandbox.View(player)
        end
    end
end

return Sandbox
