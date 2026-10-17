-- Required by basically everything immediately
BPSB = require("scripts.bpsb")
Settings = require("scripts.settings")
Debug = require("scripts.debug")
Queue = require("scripts.queue")

-- Required by some
Isolation = require("scripts.isolation")
EditorExtensionsCheats = require("scripts.editor-extensions-cheats")
Permissions = require("scripts.permissions")
RemoteView = require("scripts.remote-view")

-- Required, but not ordered importantly
Init = require("scripts.init")
Chat = require("scripts.chat")
Controllers = require("scripts.controllers")
Equipment = require("scripts.equipment")
Factorissimo = require("scripts.factorissimo")
Force = require("scripts.force")
God = require("scripts.god")
Inventory = require("scripts.inventory")
Lab = require("scripts.lab")
Migrate = require("scripts.migrate")
Research = require("scripts.research")
SelectionPlanner = require("scripts.selection-planner")
Teleport = require("scripts.teleport")
Sandbox = require("scripts.sandbox")
SpaceExploration = require("scripts.space-exploration")

-- GUIs, they likely depend on the above
SurfacePropsGUI = require("scripts.surface-props-gui")
ToggleGUI = require("scripts.toggle-gui")

require('scripts.remote-interface')

-- Initializations

script.on_init(function()
    Init.FirstTimeInit()
    Isolation.StoreCurrentLevel()
    Settings.SetupConditionalHandlers()
    SurfacePropsGUI.InitPresets()
    RemoteView.Init()
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    Force.Init(player.force --[[@as LuaForce]])
    Init.Player(player)
end)

script.on_event(defines.events.on_player_removed, function(event)
    local playerData = storage.players[event.player_index]
    Lab.DeleteLab(playerData.labName)
    if playerData.sandboxInventory then
        playerData.sandboxInventory.destroy()
    end
    if playerData.preSandboxInventory then
        playerData.preSandboxInventory.destroy()
    end
    storage.players[event.player_index] = nil
end)

script.on_event(defines.events.on_force_created, function(event)
    Force.Init(event.force)
    if Sandbox.IsSandboxForce(event.force) then
        RemoteView.HideEverythingFromSandboxForce(event.force)
    else
        RemoteView.DetermineVisibilityOfAllSandboxes(event.force)
    end
end)

-- Conditional Event Listeners

script.on_load(function()
    Settings.SetupConditionalHandlers()
    Isolation.StoreCurrentLevel()
    SurfacePropsGUI.InitPresets()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, Settings.OnRuntimeSettingChanged)

-- Important Game Events

script.on_configuration_changed(function(event)
    Migrate.Run()
    Migrate.RecreateGuis()
    Research.SyncAllForces()
    for _, force in pairs(game.forces) do
        if Sandbox.IsSandboxForce(force) then
            Research.EnableSandboxSpecificResearchIfNecessary(force)
        end
    end
    for _, surface in pairs(game.surfaces) do
        if Sandbox.IsSandbox(surface) then
            Lab.ExcludeFromMods(surface)
        end
    end
end)

script.on_event(defines.events.on_player_changed_force, function(event)
    local player = game.players[event.player_index]
    Force.Init(player.force --[[@as LuaForce]])
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
script.on_event(defines.events.on_research_moved, Research.OnResearchReordered)
script.on_event(defines.events.on_research_started, Research.OnResearchStarted)

script.on_event(defines.events.on_player_controller_changed, function(event)
    local player = game.players[event.player_index]
    ToggleGUI.Update(player)
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
    local player = game.players[event.player_index]
    Sandbox.OnPlayerSurfaceChanged(player)
    ToggleGUI.Update(player)
end)

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    RemoteView.HideSurfaceFromAllSandboxes(surface)

    if not Sandbox.IsSandbox(surface) then
        return
    end
    RemoteView.DetermineVisibilityForEveryone(surface)
    Lab.AfterCreate(surface)
    Lab.Equip(surface)
end)

script.on_event(defines.events.on_surface_cleared, function(event)
    local surface = game.surfaces[event.surface_index]
    if not Sandbox.IsSandbox(surface) then
        return
    end
    Lab.Equip(surface)
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
    local surface = game.surfaces[event.surface_index]
    if storage.labSurfaces[surface.name] then
        storage.labSurfaces[surface.name] = nil
    end
end)

script.on_event(defines.events.on_surface_renamed, function(event)
    -- TODO: Renaming surfaces likely doesn't really work
    if storage.labSurfaces[event.old_name] then
        storage.labSurfaces[event.new_name] = storage.labSurfaces[event.old_name]
        storage.labSurfaces[event.old_name] = nil
    end
end)

script.on_event(defines.events.on_marked_for_deconstruction, God.OnMarkedForDeconstruct)
script.on_event(defines.events.on_marked_for_upgrade, God.OnMarkedForUpgrade)
script.on_event(defines.events.on_built_entity, God.OnBuiltEntity, God.onBuiltEntityFilters)
script.on_event(defines.events.script_raised_built, God.OnBuiltEntity, God.onBuiltEntityFilters)
script.on_event(defines.events.on_player_crafted_item, God.OnPlayerCraftedItem)
script.on_event(defines.events.on_player_main_inventory_changed, God.OnInventoryChanged)

script.on_event(defines.events.on_player_selected_area, SelectionPlanner.OnAreaSelected)
script.on_event(defines.events.on_player_alt_selected_area, SelectionPlanner.OnAreaSelected)
script.on_event(defines.events.on_player_reverse_selected_area, SelectionPlanner.OnAreaSelected)
script.on_event(defines.events.on_player_alt_reverse_selected_area, SelectionPlanner.OnAreaSelected)

-- Shortcuts

script.on_event(ToggleGUI.toggleShortcut, ToggleGUI.OnToggleShortcut)
script.on_event(defines.events.on_lua_shortcut, ToggleGUI.OnToggleShortcut)

---@param event EventData.CustomInputEvent
script.on_event(SurfacePropsGUI.cancel, function(event)
    local player = game.players[event.player_index]
    if SurfacePropsGUI.IsOpen(player) then
        SurfacePropsGUI.Destroy(player)
    end
end)

---@param event EventData.CustomInputEvent
script.on_event(SurfacePropsGUI.confirm, function(event)
    local player = game.players[event.player_index]
    if SurfacePropsGUI.IsOpen(player) then
        SurfacePropsGUI.Apply(player)
        player.play_sound({ path = "utility/confirm" })
        SurfacePropsGUI.Destroy(player)
    end
end)

-- GUI
---@param event EventData.on_gui_click
script.on_event(defines.events.on_gui_click, function (event)
    local _ = ToggleGUI.OnGuiClick(event) or SurfacePropsGUI.OnGuiClick(event) or SelectionPlanner.OnGuiClick(event)
end)
---@param event EventData.on_gui_selection_state_changed
script.on_event(defines.events.on_gui_selection_state_changed, function (event)
    local _ = ToggleGUI.OnGuiDropdown(event) or SurfacePropsGUI.OnGuiDropdown(event)
end)
script.on_event(defines.events.on_gui_elem_changed, SelectionPlanner.OnPrototypeSelected)

-- Periodic
script.on_nth_tick(RemoteView.chartAllSandboxesTick, RemoteView.ChartAndGenerateOccupiedSandboxes)

-- Tests
if script.active_mods["factorio-test"] then
    require("__factorio-test__/init")({
        "tests/new-game",
        -- "tests/isolation-full",
        "tests/isolation-none",
        -- "tests/isolation-transition",
        "tests/new-game-post",

        -- "tests/existing-game",

        "tests/god-building",
    })
end