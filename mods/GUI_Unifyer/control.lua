-- DORMANT | local mod_gui = require("mod-gui") -- YARM
local icons = require("icons")
local logging = require("scripts/logging")
local toolbar = require("scripts/toolbar")
local mods = script.active_mods

local watched_windows = {}
for _, entry in ipairs(icons) do
    local owner = entry[1]
    if mods[owner] and (owner == "factoryplanner" or owner == "ModuleInserterEx") then
        watched_windows[owner] = entry
    end
end

-- Keep the original six-tick boundaries, but register no idle worker. The saved
-- queue, not this local flag, is the authority when restoring a multiplayer peer.
local flush
local scheduled = false
local function schedule(want)
    if want ~= scheduled then
        script.on_nth_tick(6, want and flush or nil)
        scheduled = want
    end
end

local function queue(player)
    if not (player and player.valid and player.connected) then return end
    storage.pending_players[player.index] = true
    if not scheduled then schedule(true) end
end

local function update(player, source, fn, ...)
    local ok, err = pcall(fn, player, ...)
    if not ok then logging.error(source, "Error updating panel: " .. tostring(err), player) end
end

-- Called by window owners after their final visibility change. Repaint only
-- the existing button; neither fake an input event nor wait for simulation.
remote.add_interface("GUI_Unifyer", {
    window_changed = function(player_index, owner)
        local entry = watched_windows[owner]
        if not entry then return end
        local player = game.get_player(player_index)
        if player and player.valid then update(player, "Selection", toolbar.refresh_selection, entry) end
    end,
    evo_layout_changed = function(player_index)
        if not mods.EvoUi then return end
        local player = game.get_player(player_index)
        if player and player.valid then update(player, "EvoUi layout", toolbar.refresh_layout) end
    end,
})

flush = function()
    -- Detach before updating. A synchronously raised event belongs to the NEXT
    -- boundary, even for a player already in this batch. Never retry a failed pass.
    local pending = storage.pending_players
    storage.pending_players = {}
    for index in pairs(pending) do
        local player = game.get_player(index)
        if player and player.valid and player.connected then
            update(player, "Tick", toolbar.refresh)
        end
    end
    schedule(next(storage.pending_players) ~= nil)
end

local function queue_all()
    for _, player in pairs(game.connected_players) do queue(player) end
end
local function queue_event(event)
    queue(event.player_index and game.get_player(event.player_index))
end

local function initialize()
    logging.invalidate()
    storage.player = nil -- Legacy frame flags; layout now reconciles against live elements.
    storage.window_states = nil -- Legacy cache: selection now only reads the live window.
    storage.pending_players = storage.pending_players or {}
    local registry, logger = {}, game.get_player(1)
    logging.info("Init", "Starting init_button_array", logger)
    logging.info("Buttons", "Starting build_button_array", logger)
    for _, entry in ipairs(icons) do
        if mods[entry[1]] then
            logging.debug("Buttons", "Adding button for mod: " .. entry[1], logger)
            registry[#registry + 1] = entry
        end
    end
    logging.info("Buttons", "Completed build_button_array with " .. #registry .. " buttons", logger)
    storage.gubuttonarray = registry
    logging.info("Init", "Completed init_button_array", logger)
    queue_all()
    schedule(next(storage.pending_players) ~= nil)
end

local function on_setting(event)
    local index = event.player_index
    if event.setting == "gu_enable_logging" or event.setting == "gu_log_level" then logging.invalidate(index) end
    if not index then queue_all(); return end
    local player = game.get_player(index)
    queue(player)
    if event.setting == "inserter-throughput-enabled" and player and player.valid then
        toolbar.throughput_changed(player)
    end
end

local function on_joined(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    logging.invalidate(player.index)
    -- Player-created buttons and earlier join handlers are ready. Finish before
    -- the first playable frame, even if BnL has paused the simulation.
    storage.pending_players[player.index] = nil
    update(player, "Join", toolbar.refresh)
    schedule(next(storage.pending_players) ~= nil)
end

local function on_removed(event)
    local index = event.player_index
    storage.pending_players[index] = nil
    schedule(next(storage.pending_players) ~= nil)
    logging.invalidate(index)
end

--[=[ DORMANT: YARM
local function cycle_yarm(player)
    local flow = mod_gui.get_button_flow(player)
    local all, none, warnings = flow.YARM_filter_all, flow.YARM_filter_none, flow.YARM_filter_warnings
    if all and none and warnings then
        if all.visible then all.visible = false; none.visible = true
        elseif none.visible then none.visible = false; warnings.visible = true
        elseif warnings.visible then warnings.visible = false; all.visible = true end
    end
end
]=]

local function on_click(event)
    local player = event.player_index and game.get_player(event.player_index)
    if not player or not player.valid then return end
    local element = event.element
    local name = element and element.valid and element.name
    --[=[ DORMANT: YARM
    if mods.YARM and (name == "YARM_filter_all" or name == "YARM_filter_none" or name == "YARM_filter_warnings") then
        cycle_yarm(player)
    end
    ]=]
    if name == "module_inserter_config_button" then
        local interface = remote.interfaces.ModuleInserterEx
        if interface and interface.toggle_gui then remote.call("ModuleInserterEx", "toggle_gui", player.index) end
    end
    -- Other owners can mutate any of the watched windows on an unrelated click.
    queue(player)
    --[=[ DORMANT: clock, pycoalprocessing, SolarRatio, CitiesOfEarth, automatic-belt-direction
    if mods.clock then
        local frame = player.gui.top.mod_gui_top_frame
        local inner = frame and frame.mod_gui_inner_frame
        local clock = inner and inner.clock_gui
        if clock then clock.style = clock.visible and "todo_button_default_snouz_selected" or "todo_button_default_snouz" end
    end
    if not (element and element.valid) then return end
    name = element.name -- a remote owner may have replaced or renamed it
    local root, frame
    if mods.pycoalprocessing and name == "pywiki" then root, frame = "screen", "wiki_frame"
    elseif mods.SolarRatio and name == "niet-sr-guibutton" then root, frame = "center", "niet-sr-guiframe"
    elseif mods.CitiesOfEarth and name == "coe_button_show_targets" then root, frame = "center", "coe_choose_target" end
    if root and element.style.name == settings.get_player_settings(player)["gu_button_style_setting"].value .. "_selected" then
        local window = player.gui[root][frame]
        if window then window.destroy() end
    end
    if mods["automatic-belt-direction"] and name == "abdgui" then
        local original = player.gui.top.abdgui
        local sprite = original and original.sprite == "abd-gui-on" and "abd_on_button" or "abd_off_button"
        element.sprite = sprite
        element.tooltip = {"guiu." .. sprite}
    end
    ]=]
end

script.on_init(initialize)
script.on_configuration_changed(initialize)
script.on_load(function()
    -- Old saves can reach on_load before configuration change; never write storage here.
    schedule(storage.pending_players ~= nil and next(storage.pending_players) ~= nil)
end)
script.on_event({defines.events.on_research_finished, defines.events.on_rocket_launched}, queue_all)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_setting)
script.on_event({defines.events.on_gui_closed, defines.events.on_gui_confirmed, defines.events.on_gui_opened,
    defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed,
    defines.events.on_player_changed_surface}, queue_event)
if mods["Paranoidal-factorissimo-4"] then
    -- The owner adds/removes the dispatcher button according to the new force's research.
    script.on_event(defines.events.on_player_changed_force, queue_event)
end
script.on_event(defines.events.on_player_joined_game, on_joined)
script.on_event(defines.events.on_player_removed, on_removed)
script.on_event(defines.events.on_gui_click, on_click)
script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    if player and player.valid then toolbar.cursor_changed(player) end
end)
--[=[ DORMANT: Hive_Mind, Hive_Mind_Remastered
if mods.Hive_Mind or mods.Hive_Mind_Remastered then
    script.on_event({defines.events.on_player_gun_inventory_changed, defines.events.on_player_died}, queue_event)
end
]=]

--[=[ DORMANT: visual-signals, Teleportation_Redux, PersonalTeleporter
local function on_built(event)
    local entity = event.entity or event.destination
    if not entity or not entity.valid then return end
    local name = entity.name
    if name == "gui-signal-display" and mods["visual-signals"] then
        queue_all()
    elseif name == "teleportation-beacon" and mods.Teleportation_Redux and not storage.Teleportation_Redux_built then
        storage.Teleportation_Redux_built = true
        queue_all()
    elseif name == "Teleporter_Beacon" and mods.PersonalTeleporter and not storage.PersonalTeleporter_built then
        storage.PersonalTeleporter_built = true
        queue_all()
    end
end
local build_filters = {}
if mods["visual-signals"] then build_filters[#build_filters + 1] = {filter="name", name="gui-signal-display"} end
if mods.Teleportation_Redux then build_filters[#build_filters + 1] = {filter="name", name="teleportation-beacon"} end
if mods.PersonalTeleporter then build_filters[#build_filters + 1] = {filter="name", name="Teleporter_Beacon"} end
if #build_filters > 0 then
    script.on_event(defines.events.on_built_entity, on_built, build_filters)
    script.on_event(defines.events.on_robot_built_entity, on_built, build_filters)
    script.on_event(defines.events.on_entity_cloned, on_built, build_filters)
end
]=]
