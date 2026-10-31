local protos = require("__PipeVisualizer-Updated-reforged__.scripts.protos")
local core = require("__PipeVisualizer-Updated-reforged__.scripts.core")

local events = defines.events

-- Remote interface (registered in the main chunk, so other mods can call it from their on_init).
-- The lists are kept in storage across configuration changes.
remote.add_interface("PipeVisualizer", {
  --- @param entity_names string[]
  blacklist = function(entity_names)
    if type(entity_names) ~= "table" then
      return
    end
    storage.blacklist = storage.blacklist or {}
    for _, name in pairs(entity_names) do
      if type(name) == "string" then
        storage.blacklist[name] = true
      end
    end
    protos.invalidate()
  end,
  --- @param entity_type string
  --- @param entity_name string
  pipelist_add = function(entity_type, entity_name)
    if type(entity_type) ~= "string" or type(entity_name) ~= "string" then
      return
    end
    storage.pipelist = storage.pipelist or {}
    storage.pipelist[entity_type] = storage.pipelist[entity_type] or {}
    storage.pipelist[entity_type][entity_name] = true
    protos.invalidate()
  end,
  --- @param entity_type string
  --- @param entity_name string
  complexlist_add = function(entity_type, entity_name)
    if type(entity_type) ~= "string" or type(entity_name) ~= "string" then
      return
    end
    storage.complexlist = storage.complexlist or {}
    storage.complexlist[entity_type] = storage.complexlist[entity_type] or {}
    storage.complexlist[entity_type][entity_name] = true
    protos.invalidate()
  end,
})

-- Settings ---------------------------------------------------------------------------------------

--- @type integer?
local entities_per_tick = nil

--- @param V PvViewer
--- @param player LuaPlayer
local function read_player_settings(V, player)
  local s = player.mod_settings
  V.show_map = s["pv-show-on-map"].value --[[@as boolean]]
  V.color_pumps = s["pv-color-pumps"].value --[[@as boolean]]
end

--- @param player LuaPlayer
--- @return PvViewer
local function viewer_of(player)
  local fresh = storage.viewers[player.index] == nil
  local V = core.viewer(player.index)
  if fresh then
    read_player_settings(V, player)
  end
  return V
end

-- Event subscriptions ----------------------------------------------------------------------------
-- Handlers are registered only while needed; the decision depends on storage alone, so on_load
-- restores exactly the same set.

local on_tick, on_selected, on_position, on_built, on_destroyed, on_rotated

local watch_type_filters = {}
for _, t in pairs(protos.fluid_type_list) do
  watch_type_filters[#watch_type_filters + 1] = { filter = "type", type = t }
end

local built_events = {
  events.on_built_entity,
  events.on_robot_built_entity,
  events.on_space_platform_built_entity,
  events.script_raised_built,
  events.script_raised_revive,
  events.on_entity_cloned,
}
local destroyed_events = {
  events.on_player_mined_entity,
  events.on_robot_mined_entity,
  events.on_space_platform_mined_entity,
  events.on_entity_died,
  events.script_raised_destroy,
}
local rotated_events = { events.on_player_rotated_entity, events.on_player_flipped_entity }

local registered = { tick = false, selected = false, position = false, watch = false }

local function update_subscriptions()
  local tick = storage.pending ~= nil or next(storage.active or {}) ~= nil
  local selected, position, watch = false, false, false
  for _, V in pairs(storage.viewers or {}) do
    if V.mouseover then
      selected = true
    end
    if V.overlay then
      position = true
    end
    if V.mode then
      watch = true
    end
  end
  if tick ~= registered.tick then
    registered.tick = tick
    script.on_event(events.on_tick, tick and on_tick or nil)
  end
  if selected ~= registered.selected then
    registered.selected = selected
    script.on_event(events.on_selected_entity_changed, selected and on_selected or nil)
  end
  if position ~= registered.position then
    registered.position = position
    script.on_event(events.on_player_changed_position, position and on_position or nil)
  end
  if watch ~= registered.watch and #watch_type_filters > 0 then
    registered.watch = watch
    for _, ev in pairs(built_events) do
      if watch then
        script.on_event(ev, on_built, watch_type_filters)
      else
        script.on_event(ev, nil)
      end
    end
    for _, ev in pairs(destroyed_events) do
      if watch then
        script.on_event(ev, on_destroyed, watch_type_filters)
      else
        script.on_event(ev, nil)
      end
    end
    for _, ev in pairs(rotated_events) do
      script.on_event(ev, watch and on_rotated or nil)
    end
  end
end

core.set_notify(update_subscriptions)

-- World changes ----------------------------------------------------------------------------------

--- Queues an entity for a refresh on the next tick, after the engine has rebuilt fluid segments.
--- @param entity LuaEntity
--- @param expand boolean Also refresh its connected neighbours.
local function queue_refresh(entity, expand)
  local unit = entity.unit_number
  if not unit then
    return
  end
  local pending = storage.pending
  if not pending then
    pending = { due = game.tick + 1, list = {}, units = {}, expand = {} }
    storage.pending = pending
    update_subscriptions()
  end
  if not pending.units[unit] then
    pending.units[unit] = true
    pending.list[#pending.list + 1] = entity
  end
  if expand then
    pending.expand[unit] = true
  end
end

--- @param entity LuaEntity
--- @param out LuaEntity[]
local function connected_neighbours(entity, out)
  local fb = entity.fluidbox
  for i = 1, #fb do
    local conns = fb.get_pipe_connections(i)
    for c = 1, #conns do
      local target = conns[c].target
      if target then
        out[#out + 1] = target.owner
      end
    end
  end
end

local function any_viewing()
  for _, V in pairs(storage.viewers) do
    if V.mode then
      return true
    end
  end
  return false
end

local function run_refresh(pending)
  local list = pending.list
  local n = #list
  for i = 1, n do
    local entity = list[i]
    if entity.valid and pending.expand[entity.unit_number] then
      local neighbours = {}
      connected_neighbours(entity, neighbours)
      for j = 1, #neighbours do
        local neighbour = neighbours[j]
        local unit = neighbour.unit_number
        if unit and not pending.units[unit] then
          pending.units[unit] = true
          list[#list + 1] = neighbour
        end
      end
    end
  end
  for _, V in pairs(storage.viewers) do
    if V.mode then
      for i = 1, #list do
        local entity = list[i]
        if entity.valid and protos.info(entity.name) then
          core.refresh(V, entity)
        end
      end
    end
  end
end

on_built = function(e)
  local entity = e.entity or e.destination
  if entity and entity.valid and protos.fluid_names[entity.name] and any_viewing() then
    queue_refresh(entity, true)
  end
end

on_destroyed = function(e)
  local entity = e.entity
  if not (entity and entity.valid and protos.fluid_names[entity.name]) then
    return
  end
  local unit = entity.unit_number
  if not unit or not any_viewing() then
    return
  end
  for _, V in pairs(storage.viewers) do
    if V.mode then
      core.forget(V, unit)
    end
  end
  local neighbours = {}
  connected_neighbours(entity, neighbours)
  for i = 1, #neighbours do
    queue_refresh(neighbours[i], false)
  end
end

on_rotated = function(e)
  local entity = e.entity
  if not (entity and entity.valid and protos.fluid_names[entity.name]) or not any_viewing() then
    return
  end
  queue_refresh(entity, true)
  -- Former neighbours lost a connection; they are adjacent to the entity.
  local box = entity.selection_box
  local nearby = entity.surface.find_entities_filtered({
    area = {
      { box.left_top.x - 1, box.left_top.y - 1 },
      { box.right_bottom.x + 1, box.right_bottom.y + 1 },
    },
    name = protos.fluid_name_list,
  })
  for i = 1, #nearby do
    queue_refresh(nearby[i], false)
  end
end

-- Tick ---------------------------------------------------------------------------------------------

on_tick = function(e)
  local pending = storage.pending
  if pending and e.tick >= pending.due then
    storage.pending = nil
    run_refresh(pending)
  end
  local active = storage.active
  local count = table_size(active)
  if count > 0 then
    if not entities_per_tick then
      entities_per_tick = settings.global["pv-entities-per-tick"].value --[[@as integer]]
    end
    local budget = math.ceil(entities_per_tick / count)
    local viewers = storage.viewers
    for index in pairs(active) do
      local V = viewers[index]
      if not V or not core.work(V, budget) then
        active[index] = nil
      end
    end
  end
  if not storage.pending and not next(active) then
    update_subscriptions()
  end
end

-- Overlay ----------------------------------------------------------------------------------------

local BASE_OVERLAY_SIZE = 225 -- Tiles visible at the widest zoom, plus a margin.

--- @param V PvViewer
--- @param player LuaPlayer
local function open_overlay(V, player)
  local s = player.mod_settings
  local scale = math.min(math.max(s["pv-overlay-scale"].value --[[@as number]], 1), 8)
  if s["pv-allow-ultrawide"].value then
    scale = scale * 2
  end
  local size = BASE_OVERLAY_SIZE * scale
  local resolution = player.display_resolution
  local divisor = math.max(resolution.width, resolution.height) / size
  local w = math.ceil(resolution.width / divisor / 64) * 64 + 32
  local h = math.ceil(resolution.height / divisor / 64) * 64 + 32
  core.overlay_open(
    V,
    player.surface,
    player.position,
    w,
    h,
    player.force_index,
    s["pv-overlay-opacity"].value --[[@as number]]
  )
  player.set_shortcut_toggled("pv-toggle-overlay", true)
end

--- @param V PvViewer
--- @param player LuaPlayer
local function close_overlay(V, player)
  core.clear_all(V)
  player.set_shortcut_toggled("pv-toggle-overlay", false)
end

--- @param e EventData.CustomInputEvent|EventData.on_lua_shortcut
local function on_toggle_overlay(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local entity = player.selected
  if entity and entity.prototype.belt_speed and script.active_mods["belt-visualizer"] then
    return
  end
  local cursor = player.cursor_stack
  if cursor and cursor.valid_for_read and (cursor.is_blueprint_book or cursor.is_blueprint) then
    return
  end
  local V = viewer_of(player)
  if V.overlay then
    close_overlay(V, player)
  else
    open_overlay(V, player)
  end
end

on_position = function(e)
  local V = storage.viewers[e.player_index]
  if not (V and V.overlay) then
    return
  end
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  if player.surface_index ~= V.overlay.surface then
    open_overlay(V, player)
  else
    core.overlay_move(V, player.position)
  end
end

--- Reopens an active overlay (new size, surface, colours or settings).
--- @param player_index uint
local function reopen_overlay(player_index)
  local V = storage.viewers[player_index]
  local player = game.get_player(player_index)
  if V and V.overlay and player then
    open_overlay(V, player)
  end
end

-- Systems and mouse-over -------------------------------------------------------------------------

--- @param e EventData.CustomInputEvent
local function on_visualize_selected(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  core.toggle_selected(viewer_of(player), player.selected)
end

on_selected = function(e)
  local V = storage.viewers[e.player_index]
  if not (V and V.mouseover) or V.mode == "overlay" then
    return
  end
  local player = game.get_player(e.player_index)
  if player then
    core.hover(V, player.selected)
  end
end

--- @param e EventData.CustomInputEvent|EventData.on_lua_shortcut
local function on_toggle_mouseover(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local V = viewer_of(player)
  V.mouseover = not V.mouseover
  player.set_shortcut_toggled("pv-toggle-mouseover", V.mouseover)
  if e.input_name then
    player.create_local_flying_text({
      text = { V.mouseover and "message.pv-mouseover-enabled" or "message.pv-mouseover-disabled" },
      create_at_cursor = true,
    })
  end
  if V.mode == "systems" then
    core.clear_hovered(V)
  end
  update_subscriptions()
end

--- @param e EventData.CustomInputEvent
local function on_color_mode(e)
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local V = viewer_of(player)
  V.by_system = not V.by_system
  player.create_local_flying_text({
    text = { V.by_system and "message.pv-color-by-system" or "message.pv-color-by-fluid" },
    create_at_cursor = true,
  })
  if V.overlay then
    open_overlay(V, player)
  else
    core.rebuild_systems(V)
  end
end

--- @param e EventData.on_lua_shortcut
local function on_lua_shortcut(e)
  local name = e.prototype_name
  if name == "pv-toggle-overlay" then
    on_toggle_overlay(e)
  elseif name == "pv-toggle-mouseover" then
    on_toggle_mouseover(e)
  end
end

-- Players, surfaces, settings --------------------------------------------------------------------

local overlay_settings = { ["pv-overlay-opacity"] = true, ["pv-overlay-scale"] = true, ["pv-allow-ultrawide"] = true }
local drawing_settings = { ["pv-show-on-map"] = true, ["pv-color-pumps"] = true }

--- @param e EventData.on_runtime_mod_setting_changed
local function on_setting_changed(e)
  local name = e.setting
  if name == "pv-entities-per-tick" then
    entities_per_tick = nil
    return
  end
  if not (overlay_settings[name] or drawing_settings[name]) or not e.player_index then
    return
  end
  local V = storage.viewers[e.player_index]
  local player = game.get_player(e.player_index)
  if not (V and player) then
    return
  end
  if drawing_settings[name] then
    read_player_settings(V, player)
    if V.overlay then
      open_overlay(V, player)
    else
      core.rebuild_systems(V)
    end
  elseif V.overlay then
    open_overlay(V, player)
  end
end

--- @param e EventData.on_player_display_resolution_changed|EventData.on_player_changed_surface
local function on_player_view_changed(e)
  reopen_overlay(e.player_index)
end

--- @param e EventData.on_player_removed
local function on_player_removed(e)
  local V = storage.viewers[e.player_index]
  if V then
    core.clear_all(V)
    storage.viewers[e.player_index] = nil
    storage.active[e.player_index] = nil
    update_subscriptions()
  end
end

--- @param e EventData.on_surface_deleted
local function on_surface_deleted(e)
  for index, V in pairs(storage.viewers) do
    local had_overlay = V.overlay ~= nil
    core.drop_surface(V, e.surface_index)
    if had_overlay and not V.overlay then
      local player = game.get_player(index)
      if player then
        player.set_shortcut_toggled("pv-toggle-overlay", false)
      end
    end
  end
  update_subscriptions()
end

-- Lifecycle --------------------------------------------------------------------------------------

local function reset_shortcuts()
  for _, player in pairs(game.players) do
    local V = storage.viewers[player.index]
    player.set_shortcut_toggled("pv-toggle-overlay", false)
    player.set_shortcut_toggled("pv-toggle-mouseover", V ~= nil and V.mouseover)
  end
end

script.on_init(function()
  core.init()
  reset_shortcuts()
  update_subscriptions()
end)

script.on_load(function()
  update_subscriptions()
end)

script.on_configuration_changed(function()
  -- Drawings of an older version are dropped; per-player toggles and the remote lists stay.
  core.init()
  protos.invalidate()
  rendering.clear(script.mod_name)
  for index, V in pairs(storage.viewers) do
    core.forget_all(V)
    local player = game.get_player(index)
    if player then
      read_player_settings(V, player)
    else
      storage.viewers[index] = nil
    end
  end
  storage.active = {}
  storage.pending = nil
  entities_per_tick = nil
  reset_shortcuts()
  update_subscriptions()
end)

script.on_event("pv-visualize-selected", on_visualize_selected)
script.on_event("pv-toggle-overlay", on_toggle_overlay)
script.on_event("pv-toggle-mouseover", on_toggle_mouseover)
script.on_event("pv-color-by-fluid-system", on_color_mode)
script.on_event(events.on_lua_shortcut, on_lua_shortcut)
script.on_event(events.on_runtime_mod_setting_changed, on_setting_changed)
script.on_event(events.on_player_display_resolution_changed, on_player_view_changed)
script.on_event(events.on_player_changed_surface, on_player_view_changed)
script.on_event(events.on_player_removed, on_player_removed)
script.on_event(events.on_surface_deleted, on_surface_deleted)
