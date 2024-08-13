-- Required by basically everything immediately
BPSB = require("scripts.bpsb")
Events = require("scripts.events")
Settings = require("scripts.settings")
Debug = require("scripts.debug")
Queue = require("scripts.queue")

-- Required by some
Illusion = require("scripts.illusion")
EditorExtensionsCheats = require("scripts.editor-extensions-cheats")

-- Required, but not ordered importantly
Init = require("scripts.init")
Chat = require("scripts.chat")
Equipment = require("scripts.equipment")
Factorissimo = require("scripts.factorissimo")
Force = require("scripts.force")
God = require("scripts.god")
Inventory = require("scripts.inventory")
Lab = require("scripts.lab")
Migrate = require("scripts.migrate")
Research = require("scripts.research")
Resources = require("scripts.resources")
Tiles = require("scripts.tiles")
ToggleGUI = require("scripts.toggle-gui")

-- Required by Sandbox
SpaceExploration = require("scripts.space-exploration")

-- Requires SpaceExploration method immediately
Sandbox = require("scripts.sandbox")

require('scripts.remote-interface')

-- Initializations

script.on_init(function()
    Init.FirstTimeInit()
    Settings.SetupConditionalHandlers()
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    log("on_player_created index: " .. event.player_index)
    Force.Init(player.force)
    Init.Player(player)
end)

script.on_event(defines.events.on_player_removed, function(event)
    local playerData = global.players[event.player_index]
    log("on_player_removed index: " .. event.player_index)
    Lab.DeleteLab(playerData.labName)
    if playerData.sandboxInventory then
        playerData.sandboxInventory.destroy()
    end
    if playerData.preSandboxInventory then
        playerData.preSandboxInventory.destroy()
    end
    global.players[event.player_index] = nil
end)

script.on_event(defines.events.on_force_created, function(event)
    log("on_force_created name: " .. event.force.name)
    Force.Init(event.force)
end)

-- Conditional Event Listeners

script.on_load(Settings.SetupConditionalHandlers)

script.on_event(defines.events.on_runtime_mod_setting_changed, Settings.OnRuntimeSettingChanged)

-- Important Game Events

script.on_configuration_changed(function(event)
    for _, sandboxForceData in pairs(global.sandboxForces) do
        -- Ensure that new automatic recipes aren't hidden
        sandboxForceData.hiddenItemsUnlocked = false
    end
    --[[ TODO:
            There's a bug related to this section if a Player is currently
            inside of a Sandbox while loading a Save where the Configuration
            Changed. The above hiddenItemsUnlocked flag is reset, since for
            some reason the Recipes will have disappeared again, but of
            course there's nothing here to enable them again!
            That's because the enabling code doesn't seem to work anywhere
            outside of right-after the Player has been swapped to their
            Sandbox Force (see the to-do over there).
            Currently, if that same code is used here, the flag will be true,
            but the Recipes are still hidden, so they'll be stuck hidden!
    ]]

    Migrate.Run()
    Research.SyncAllForces()
end)

script.on_event(defines.events.on_player_changed_force, function(event)
    local player = game.players[event.player_index]
    Force.Init(player.force)
    Sandbox.OnPlayerForceChanged(player)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    Force.Init(event.destination)
    Force.Merge(event.source_name, event.destination)
end)

script.on_event(defines.events.on_player_promoted, function(event)
    local player = game.players[event.player_index]
    ToggleGUI.Update(player)
end)

script.on_event(defines.events.on_player_demoted, function(event)
    local player = game.players[event.player_index]
    ToggleGUI.Update(player)
end)

script.on_event(defines.events.on_console_chat, Chat.OnChat)

script.on_event(defines.events.on_research_finished, Research.OnResearched)
script.on_event(defines.events.on_research_reversed, Research.OnResearched)
script.on_event(defines.events.on_research_started, Research.OnResearchStarted)

script.on_event(defines.events.on_player_changed_surface, function(event)
    local player = game.players[event.player_index]
    Sandbox.OnPlayerSurfaceChanged(player)
    ToggleGUI.Update(player)
end)

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    local _ = Lab.AfterCreate(surface) or SpaceExploration.AfterCreate(surface)
    local _ =  Lab.Equip(surface) or SpaceExploration.Equip(surface)
end)

script.on_event(defines.events.on_surface_cleared, function(event)
    return Lab.Equip(game.surfaces[event.surface_index])
            or SpaceExploration.Equip(game.surfaces[event.surface_index])
end)

script.on_event(defines.events.on_chunk_generated, function(event)
    local equipmentData = global.equipmentInProgress[event.surface.name]
    if equipmentData then
        Equipment.BuildBlueprint(
                equipmentData.stack,
                equipmentData.surface,
                equipmentData.forceName
        )
    end
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
    local surface = game.surfaces[event.surface_index]
    if global.labSurfaces[surface.name] then
        global.labSurfaces[surface.name] = nil
    end
    local surfaceData = global.seSurfaces[surface.name]
    if surfaceData then
        local sandboxForceData = global.sandboxForces[surfaceData.sandboxForceName]
        SpaceExploration.PreDeleteSandbox(sandboxForceData, surface.name)
    end
end)

script.on_event(defines.events.on_surface_renamed, function(event)
    -- TODO: Renaming surfaces likely doesn't really work
    if global.labSurfaces[event.old_name] then
        global.labSurfaces[event.new_name] = global.labSurfaces[event.old_name]
        global.labSurfaces[event.old_name] = nil
    end
    local surfaceData = global.seSurfaces[event.old_name]
    if surfaceData then
        local sandboxForceData = global.sandboxForces[surfaceData.sandboxForceName]
        if sandboxForceData.sePlanetaryLabZoneName == event.old_name then
            sandboxForceData.sePlanetaryLabZoneName = event.new_name
        end
        if sandboxForceData.seOrbitalSandboxZoneName == event.old_name then
            sandboxForceData.seOrbitalSandboxZoneName = event.new_name
        end
        global.seSurfaces[event.new_name] = global.seSurfaces[event.old_name]
        global.seSurfaces[event.old_name] = nil
    end
end)

script.on_event(defines.events.on_marked_for_deconstruction, God.OnMarkedForDeconstruct)
script.on_event(defines.events.on_marked_for_upgrade, God.OnMarkedForUpgrade)
script.on_event(defines.events.on_built_entity, function(event)
    God.OnBuiltEntity(event.created_entity)
end, God.onBuiltEntityFilters)
script.on_event(defines.events.script_raised_built, function(event)
    God.OnBuiltEntity(event.entity)
end, God.onBuiltEntityFilters)
script.on_event(defines.events.on_player_crafted_item, God.OnPlayerCraftedItem)
script.on_event(defines.events.on_player_main_inventory_changed, God.OnInventoryChanged)

script.on_event(defines.events.on_player_setup_blueprint, Illusion.OnBlueprintSetup)

-- TODO: on_entity_settings_pasted

script.on_event(defines.events.on_player_selected_area, function(event)
    Resources.OnAreaSelected(event, true)
end)
script.on_event(defines.events.on_player_alt_selected_area, function(event)
    Resources.OnAreaSelected(event, false)
end)

-- Internal

script.on_event(Events.on_daylight_changed_event, function(event)
    log("on_daylight_changed_event from player: " .. event.player_index)
    for _, player in pairs(game.players) do
        if player.index ~= event.player_index
                and player.surface.name == event.surface_name
        then
            ToggleGUI.Update(player)
        end
    end
end)

-- Shortcuts

script.on_event(ToggleGUI.toggleShortcut, ToggleGUI.OnToggleShortcut)
script.on_event(defines.events.on_lua_shortcut, ToggleGUI.OnToggleShortcut)

-- GUI

script.on_event(defines.events.on_gui_click, ToggleGUI.OnGuiClick)
script.on_event(defines.events.on_gui_value_changed, ToggleGUI.OnGuiValueChanged)
script.on_event(defines.events.on_gui_selection_state_changed, ToggleGUI.OnGuiDropdown)

script.on_event(defines.events.on_gui_closed, function(event)
    if (event.gui_type == defines.gui_type.blueprint_library) then
        -- We know this won't work, but we'll do it to print a message anyway
        Illusion.OnBlueprintGUIClosed(event)
    elseif (event.gui_type == defines.gui_type.item) then
        Illusion.OnBlueprintGUIClosed(event)
    end
end)
