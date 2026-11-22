local mod_gui = require("mod-gui")

function gui_add_title(gui, title, button_name, drag_target)
  gui.add({ type = "flow", name = "title_flow" })
  gui.title_flow.add({ type = "label", name = "title", style = "frame_title", caption = title })
  gui.title_flow.add({ type = "empty-widget", name = "filler", style = "bob_draggable_header" })
  gui.title_flow.add({
    type = "sprite-button",
    name = button_name,
    style = "frame_action_button",
    sprite = "utility/close",
  })
  if drag_target then
    gui.title_flow.title.drag_target = gui
    gui.title_flow.filler.drag_target = gui
  end
end

if not bobmods then
  bobmods = {}
end
if not bobmods.inserters then
  bobmods.inserters = {}
end
if not bobmods.logistics then
  bobmods.logistics = {}
end
if not bobmods.logistics.inserters then
  bobmods.logistics.inserters = {}
end
if not bobmods.math then
  bobmods.math = {}
end

function bobmods.math.mod(number, div)
  if number < 0 then
    local newnumber = 0 - number
    local mod = newnumber % div
    return 0 - mod
  else
    return number % div
  end
end

function bobmods.math.floor(number)
  local num
  if number < 0 then
    num = number - 0.1
  else
    num = number + 0.1
  end
  return math.floor(num - bobmods.math.mod(num, 1))
end

function bobmods.math.round(number)
  local num
  if number < 0 then
    num = number - 0.5
  else
    num = number + 0.5
  end
  return math.floor(num - bobmods.math.mod(num, 1))
end

function bobmods.math.offset(number)
  local num = bobmods.math.mod(number, 1)
  if num < 0 then
    if num > -0.5 then
      return num
    else
      return num + 1
    end
  else
    if num < 0.5 then
      return num
    else
      return num - 1
    end
  end
end

bobmods.inserters.long_technology = "bob-long-inserters-1"
bobmods.inserters.long2_technology = "bob-long-inserters-2"
bobmods.inserters.near_technology = "bob-near-inserters"
bobmods.inserters.more_technology = "bob-more-inserters-1"
bobmods.inserters.more2_technology = "bob-more-inserters-2"
bobmods.inserters.offset = 0.2
changed_position_event = script.generate_event_name()

bobmods.inserters.range1_4way = {
  table = {
    { x = 0, y = -1 },
    { x = 1, y = 0 },
    { x = 0, y = 1 },
    { x = -1, y = 0 },
  },
  steps = 4,
}

bobmods.inserters.range1_8way = {
  table = {
    { x = 0, y = -1 },
    { x = 1, y = -1 },
    { x = 1, y = 0 },
    { x = 1, y = 1 },
    { x = 0, y = 1 },
    { x = -1, y = 1 },
    { x = -1, y = 0 },
    { x = -1, y = -1 },
  },
  steps = 8,
}

bobmods.inserters.range2_4way = {
  table = {
    { x = 0, y = -2 },
    { x = 2, y = 0 },
    { x = 0, y = 2 },
    { x = -2, y = 0 },
  },
  steps = 4,
}

bobmods.inserters.range2_8way = {
  table = {
    { x = 0, y = -2 },
    { x = 2, y = -2 },
    { x = 2, y = 0 },
    { x = 2, y = 2 },
    { x = 0, y = 2 },
    { x = -2, y = 2 },
    { x = -2, y = 0 },
    { x = -2, y = -2 },
  },
  steps = 8,
}

bobmods.inserters.range2_16way = {
  table = {
    { x = 0, y = -2 },
    { x = 1, y = -2 },
    { x = 2, y = -2 },
    { x = 2, y = -1 },
    { x = 2, y = 0 },
    { x = 2, y = 1 },
    { x = 2, y = 2 },
    { x = 1, y = 2 },
    { x = 0, y = 2 },
    { x = -1, y = 2 },
    { x = -2, y = 2 },
    { x = -2, y = 1 },
    { x = -2, y = 0 },
    { x = -2, y = -1 },
    { x = -2, y = -2 },
    { x = -1, y = -2 },
  },
  steps = 16,
}

bobmods.inserters.range3_4way = {
  table = {
    { x = 0, y = -3 },
    { x = 3, y = 0 },
    { x = 0, y = 3 },
    { x = -3, y = 0 },
  },
  steps = 4,
}

bobmods.inserters.range3_8way = {
  table = {
    { x = 0, y = -3 },
    { x = 3, y = -3 },
    { x = 3, y = 0 },
    { x = 3, y = 3 },
    { x = 0, y = 3 },
    { x = -3, y = 3 },
    { x = -3, y = 0 },
    { x = -3, y = -3 },
  },
  steps = 8,
}

bobmods.inserters.range3_24way = {
  table = {
    { x = 0, y = -3 },
    { x = 1, y = -3 },
    { x = 2, y = -3 },
    { x = 3, y = -3 },
    { x = 3, y = -2 },
    { x = 3, y = -1 },
    { x = 3, y = 0 },
    { x = 3, y = 1 },
    { x = 3, y = 2 },
    { x = 3, y = 3 },
    { x = 2, y = 3 },
    { x = 1, y = 3 },
    { x = 0, y = 3 },
    { x = -1, y = 3 },
    { x = -2, y = 3 },
    { x = -3, y = 3 },
    { x = -3, y = 2 },
    { x = -3, y = 1 },
    { x = -3, y = 0 },
    { x = -3, y = -1 },
    { x = -3, y = -2 },
    { x = -3, y = -3 },
    { x = -2, y = -3 },
    { x = -1, y = -3 },
  },
  steps = 24,
}

bobmods.inserters.positions = {
  { x = -2, y = -2 },
  { x = -1, y = -2 },
  { x = 0, y = -2 },
  { x = 1, y = -2 },
  { x = 2, y = -2 },

  { x = -2, y = -1 },
  { x = -1, y = -1 },
  { x = 0, y = -1 },
  { x = 1, y = -1 },
  { x = 2, y = -1 },

  { x = -2, y = 0 },
  { x = -1, y = 0 },
  { x = 0, y = 0 },
  { x = 1, y = 0 },
  { x = 2, y = 0 },

  { x = -2, y = 1 },
  { x = -1, y = 1 },
  { x = 0, y = 1 },
  { x = 1, y = 1 },
  { x = 2, y = 1 },

  { x = -2, y = 2 },
  { x = -1, y = 2 },
  { x = 0, y = 2 },
  { x = 1, y = 2 },
  { x = 2, y = 2 },

  { x = -3, y = -3 },
  { x = -2, y = -3 },
  { x = -1, y = -3 },
  { x = 0, y = -3 },
  { x = 1, y = -3 },
  { x = 2, y = -3 },
  { x = 3, y = -3 },

  { x = -3, y = -2 },
  { x = 3, y = -2 },

  { x = -3, y = -1 },
  { x = 3, y = -1 },

  { x = -3, y = 0 },
  { x = 3, y = 0 },

  { x = -3, y = 1 },
  { x = 3, y = 1 },

  { x = -3, y = 2 },
  { x = 3, y = 2 },

  { x = -3, y = 3 },
  { x = -2, y = 3 },
  { x = -1, y = 3 },
  { x = 0, y = 3 },
  { x = 1, y = 3 },
  { x = 2, y = 3 },
  { x = 3, y = 3 },
}

bobmods.inserters.offset_positions = {
  { x = -bobmods.inserters.offset, y = -bobmods.inserters.offset },
  { x = 0, y = -bobmods.inserters.offset },
  { x = bobmods.inserters.offset, y = -bobmods.inserters.offset },

  { x = -bobmods.inserters.offset, y = 0 },
  { x = 0, y = 0 },
  { x = bobmods.inserters.offset, y = 0 },

  { x = -bobmods.inserters.offset, y = bobmods.inserters.offset },
  { x = 0, y = bobmods.inserters.offset },
  { x = bobmods.inserters.offset, y = bobmods.inserters.offset },
}

bobmods.logistics.inserters.range1 = {
  pickup = {
    { x = 0, y = -1 },
    { x = 1, y = 0 },
    { x = 0, y = 1 },
    { x = -1, y = 0 },
  },
  drop = {
    { x = 0, y = 1 },
    { x = -1, y = 0 },
    { x = 0, y = -1 },
    { x = 1, y = 0 },
  },
}

bobmods.logistics.inserters.range2 = {
  pickup = {
    { x = 0, y = -2 },
    { x = 2, y = 0 },
    { x = 0, y = 2 },
    { x = -2, y = 0 },
  },
  drop = {
    { x = 0, y = 2 },
    { x = -2, y = 0 },
    { x = 0, y = -2 },
    { x = 2, y = 0 },
  },
}

bobmods.logistics.inserters.offset_positions = {
  near = {
    { x = 0, y = -bobmods.inserters.offset },
    { x = bobmods.inserters.offset, y = 0 },
    { x = 0, y = bobmods.inserters.offset },
    { x = -bobmods.inserters.offset, y = 0 },
  },
  far = {
    { x = 0, y = bobmods.inserters.offset },
    { x = -bobmods.inserters.offset, y = 0 },
    { x = 0, y = -bobmods.inserters.offset },
    { x = bobmods.inserters.offset, y = 0 },
  },
}

function bobmods.inserters.create_global_table_basic()
  if not storage.bobmods then
    storage.bobmods = {}
  end
  if not storage.bobmods.inserters then
    storage.bobmods.inserters = {}
  end
  if not storage.bobmods.inserters.blacklist then
    storage.bobmods.inserters.blacklist = {}
  end
end

function bobmods.inserters.create_global_table(player_index)
  bobmods.inserters.create_global_table_basic()
  if not storage.bobmods.inserters[player_index] then
    storage.bobmods.inserters[player_index] = {}
  end

  if not storage.bobmods.logistics then
    storage.bobmods.logistics = {}
  end
  if not storage.bobmods.logistics[player_index] then
    storage.bobmods.logistics[player_index] = {}
  end

  if not storage.bobmods.logistics[player_index].enabled then
    storage.bobmods.logistics[player_index].enabled = false
  end
  if not storage.bobmods.logistics[player_index].long_in then
    storage.bobmods.logistics[player_index].long_in = false
  end
  if not storage.bobmods.logistics[player_index].long_out then
    storage.bobmods.logistics[player_index].long_out = false
  end
  if not storage.bobmods.logistics[player_index].near then
    storage.bobmods.logistics[player_index].near = false
  end
  if not storage.bobmods.logistics[player_index].show then
    storage.bobmods.logistics[player_index].show = false
  end

  if not storage.bobmods.logistics[player_index].enabled2 then
    storage.bobmods.logistics[player_index].enabled2 = false
  end
  if not storage.bobmods.logistics[player_index].pickup then
    storage.bobmods.logistics[player_index].pickup = 18
  end
  if not storage.bobmods.logistics[player_index].drop then
    storage.bobmods.logistics[player_index].drop = 8
  end
  if not storage.bobmods.logistics[player_index].offset then
    storage.bobmods.logistics[player_index].offset = 2
  end
end

local function inserter_name(entity)
  local kind = entity.type
  if kind == "inserter" then return entity.name end
  if kind == "entity-ghost" and entity.ghost_type == "inserter" then return entity.ghost_name end
end

local function editable_inserter(entity)
  local name = entity and entity.valid and inserter_name(entity)
  return name and not storage.bobmods.inserters.blacklist[name] and prototypes.entity[name].allow_custom_vectors
end

local hotkeys = {
  ["bob-inserter-pickup-rotate"] = "rotate_pickup",
  ["bob-inserter-drop-rotate"] = "rotate_drop",
  ["bob-inserter-pickup-range"] = "pickup_range",
  ["bob-inserter-drop-range"] = "drop_range",
  ["bob-inserter-long"] = "long_range",
  ["bob-inserter-near"] = "near_range",
}
for event_name, action in pairs(hotkeys) do
  script.on_event(event_name, function(event)
    local player = game.get_player(event.player_index)
    local entity = player.selected
    if editable_inserter(entity) and player.can_reach_entity(entity) then
      bobmods.inserters[action](entity, player)
    end
  end)
end

script.on_event("bob-inserter-open-gui", function(event)
  local player = game.get_player(event.player_index)
  local entity = player.selected
  if editable_inserter(entity) and player.can_reach_entity(entity) then
    bobmods.inserters.open_gui(entity, player, "center")
  else
    bobmods.inserters.delete_gui(event.player_index)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type ~= defines.gui_type.entity then return end
  local entity = event.entity
  local player = game.get_player(event.player_index)
  if editable_inserter(entity) and settings.get_player_settings(player)["bobmods-inserters-gui-position"].value ~= "off" then
    bobmods.inserters.open_gui(entity, player, "left")
  else
    bobmods.inserters.delete_gui(event.player_index)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local session = storage.bobmods.inserters[event.player_index]
  if not (session and session.gui) then return end
  if (session.position == "center" and event.gui_type == defines.gui_type.custom and event.element == session.gui)
    or (session.position == "left" and event.gui_type == defines.gui_type.entity and event.entity == session.entity) then
    bobmods.inserters.delete_gui(event.player_index)
  end
end)

local button_indices = {}
for i = 1, #bobmods.inserters.positions do button_indices["button" .. i] = i end
local preset_fields = {
  bob_logistics_inserter_enabled = "enabled", bob_logistics_inserter_enabled2 = "enabled2",
  bob_logistics_inserter_long_in = "long_in", bob_logistics_inserter_long_out = "long_out",
  bob_logistics_inserter_near = "near",
}

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local element = event.element
  if not element.valid then return end
  local name = element.name
  local i, field = button_indices[name], preset_fields[name]
  if not (i or field) then return end
  local player_index, parent = event.player_index, element.parent
  local player = game.get_player(player_index)
  local preset = storage.bobmods.logistics and storage.bobmods.logistics[player_index]
  if field then
    if not preset then return end
    local frame = player.gui.left.bob_logistics_inserter_gui
    if not (frame and parent == frame.table) then return end
    local checked = element.state
    preset[field] = checked
    if field == "enabled" or field == "enabled2" then
      if checked then preset[field == "enabled" and "enabled2" or "enabled"] = false end
      bobmods.logistics.create_gui(player_index)
    end
    return
  end

  local session = storage.bobmods.inserters[player_index]
  local kind = parent and session and (parent == session.pickup and "pickup" or parent == session.drop and "drop"
    or parent == session.offset and "offset")
  if kind then
    if kind == "offset" and not bobmods.inserters.offset_positions[i] then return end
    local entity = session.entity
    if editable_inserter(entity) and player.can_reach_entity(entity) then
      bobmods.inserters.apply_gui_position(entity, player, kind, i)
      -- The engine toggled the clicked checkbox before dispatch. A listener can
      -- change the final position, so restore that button as well as the selection.
      local selected = session.selected_buttons
      if element.valid and selected then
        local checked = selected[kind] == i
        if element.state ~= checked then element.state = checked end
      end
    else
      bobmods.inserters.delete_gui(player_index)
    end
    return
  end

  -- The public draw_gui API can draw identical names in another mod's window.
  -- Only the instance under this player's actual placement-preset frame is ours.
  if not preset then return end
  local frame = player.gui.left.bob_logistics_inserter_gui
  local grid = frame and frame.main_table
  if not (parent and grid) then return end
  local drop = grid.drop.table
  if parent == grid.pickup.bob_logistics_pickup then
    bobmods.inserters.draw_button_position_check(parent, bobmods.inserters.positions[i])
    preset.pickup = i
  elseif parent == drop.bob_logistics_drop then
    bobmods.inserters.draw_button_position_check(parent, bobmods.inserters.positions[i])
    preset.drop = i
  elseif drop.offset and parent == drop.offset.bob_logistics_offset and bobmods.inserters.offset_positions[i] then
    bobmods.inserters.draw_button_offset_check(parent, bobmods.inserters.offset_positions[i])
    preset.offset = i
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not element.valid then return end
  local player_index, name = event.player_index, element.name
  if name == "bob_inserter_gui_close" then
    local session = storage.bobmods.inserters[player_index]
    local parent = element.parent
    if session and session.gui and parent and parent.parent == session.gui then
      bobmods.inserters.delete_gui(player_index)
    end
  elseif name == "bob_logistics_inserter_button" and element.get_mod() == script.mod_name then
    local preset = storage.bobmods.logistics[player_index]
    preset.show = not preset.show
    bobmods.logistics.show_gui_options(player_index)
  end
end)

script.on_event({ defines.events.on_player_rotated_entity, defines.events.on_player_flipped_entity }, function(event)
  local session = storage.bobmods.inserters[event.player_index]
  if session and session.entity == event.entity and event.entity.valid then
    local player = game.get_player(event.player_index)
    if player.can_reach_entity(event.entity) then
      bobmods.inserters.refresh_position_checkboxes(event.entity, player)
    end
  end
end)

local ENFORCE_SWEEP_INTERVAL = 2
local enforce_ticking, enforce_sweeping = false, false
local last_sweep_tick

local function enforce_on_tick(event)
  bobmods.inserters.enforce_tick(event.tick)
  bobmods.inserters.update_tick_handler()
end

local function sweep_on_tick(event)
  bobmods.inserters.enforce_sweep(event.tick)
  bobmods.inserters.update_tick_handler()
end

-- Pending work needs the next tick; an otherwise idle sweep only needs even ticks.
-- Restore the same subscriptions on load using only saved state.
function bobmods.inserters.update_tick_handler()
  local s = storage.bob_enforce
  local pending = not (s and s.filled) or s.pending[1] ~= nil
  local sweep = not pending and s.list[1] ~= nil
  if pending ~= enforce_ticking then
    enforce_ticking = pending
    script.on_event(defines.events.on_tick, pending and enforce_on_tick or nil)
  end
  if sweep ~= enforce_sweeping then
    enforce_sweeping = sweep
    script.on_nth_tick(ENFORCE_SWEEP_INTERVAL, sweep and sweep_on_tick or nil)
  end
end

local gui_ticking = false
local update_gui_tick
local function editor_index(players)
  local active = players.active_editors
  if not active then
    -- Compatibility with saves made before the editor index existed.
    active = {}
    players.active_editors = active
    for index, session in pairs(players) do
      if type(index) == "number" and session.gui then active[index] = true end
    end
  end
  return active
end

local function check_editors()
  bobmods.inserters.create_global_table_basic()
  local players = storage.bobmods.inserters
  for index in pairs(editor_index(players)) do
    local player = game.get_player(index)
    local session = players[index]
    local gui, entity = session and session.gui, session and session.entity
    if not (player and gui and gui.valid and entity and entity.valid
      and player.opened == (session.position == "left" and entity or gui)
      and player.can_reach_entity(entity)) then
      bobmods.inserters.delete_gui(index)
    end
  end
  update_gui_tick()
end

update_gui_tick = function()
  local players = storage.bobmods and storage.bobmods.inserters
  local active = players and players.active_editors
  local wanted = not active or next(active) ~= nil
  if wanted ~= gui_ticking then
    gui_ticking = wanted
    script.on_nth_tick(20, wanted and check_editors or nil)
  end
end

local function init_editor_index()
  bobmods.inserters.create_global_table_basic()
  storage.bobmods.inserters.active_editors = {}
end

script.on_configuration_changed(function()
  init_editor_index()
  for _, player in pairs(game.players) do
    bobmods.inserters.create_global_table(player.index)
    if player.gui.center.bob_inserter_gui then
      player.gui.center.bob_inserter_gui.destroy()
    end
    bobmods.inserters.delete_gui(player.index)
    bobmods.logistics.create_gui_button(player.index)
    player.gui.center.visible = true
  end
  bobmods.inserters.enforce_fill()
  bobmods.inserters.update_tick_handler()
  update_gui_tick()
end)

script.on_init(function()
  init_editor_index()
  for _, player in pairs(game.players) do
    bobmods.inserters.create_global_table(player.index)
    bobmods.logistics.create_gui_button(player.index)
  end
  bobmods.inserters.enforce_fill()
  bobmods.inserters.update_tick_handler()
  update_gui_tick()
end)

script.on_load(function()
  bobmods.inserters.update_tick_handler()
  update_gui_tick()
end)

script.on_event(defines.events.on_player_created, function(event)
  bobmods.inserters.create_global_table(event.player_index)
  bobmods.logistics.create_gui_button(event.player_index)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  bobmods.inserters.create_global_table(event.player_index)
  bobmods.logistics.create_gui_button(event.player_index)
end)

script.on_event({ defines.events.on_player_left_game, defines.events.on_player_controller_changed }, function(event)
  bobmods.inserters.delete_gui(event.player_index)
end)

script.on_event(defines.events.on_player_removed, function(event)
  local index = event.player_index
  bobmods.inserters.delete_gui(index)
  storage.bobmods.inserters[index] = nil
  if storage.bobmods.logistics then storage.bobmods.logistics[index] = nil end
end)

script.on_event({ defines.events.on_research_finished, defines.events.on_research_reversed }, function(event)
  if
    event.research.name == bobmods.inserters.long_technology
    or event.research.name == bobmods.inserters.long2_technology
    or event.research.name == bobmods.inserters.near_technology
    or event.research.name == bobmods.inserters.more_technology
    or event.research.name == bobmods.inserters.more2_technology
  then
    for _, player in pairs(event.research.force.connected_players) do
      local session = storage.bobmods.inserters[player.index]
      local entity, gui = session and session.entity, session and session.gui
      if gui and gui.valid and editable_inserter(entity)
        and player.opened == (session.position == "left" and entity or gui) and player.can_reach_entity(entity) then
        bobmods.inserters.open_gui(entity, player, session.position)
      end
      if player.gui.left.bob_logistics_inserter_gui then bobmods.logistics.show_gui_options(player.index) end
    end
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  local entity, index = event.entity, event.player_index
  local preset = storage.bobmods.logistics and storage.bobmods.logistics[index]
  if preset and (preset.enabled or preset.enabled2) and editable_inserter(entity) then
    bobmods.logistics.set_positions(entity, index)
  end
  bobmods.inserters.enforce_and_track(entity)
end, { { filter = "type", type = "inserter" }, { filter = "ghost_type", type = "inserter" } })
-- Paranoidal: the filter above; before, every entity and ghost a player built ran this handler.

-- Paranoidal: positions from blueprints and pasted settings are limited by the force's research,
-- like the position GUI. Unresearched range/diagonals/near offset are reduced to the nearest allowed.
local function _enforce_allowed(x, y, t)
  local ax, ay = math.abs(x), math.abs(y)
  local r, m = math.max(ax, ay), math.min(ax, ay)
  if r == 0 then
    return true
  elseif r == 1 then
    return m == 0 or t.more
  elseif r == 2 then
    return t.long and (m == 0 or (m == 2 and t.more) or (m == 1 and t.more2))
  elseif r == 3 then
    return t.long2 and (m == 0 or (m == 3 and t.more) or ((m == 1 or m == 2) and t.more2))
  end
  return false
end

local function _enforce_sign(v)
  return v > 0 and 1 or (v < 0 and -1 or 0)
end

-- pos: integer tile position in normal form; vertical: inserter faces north/south.
local function _enforce_clamp(pos, t, vertical)
  local x, y = pos.x, pos.y
  local rmax = t.long2 and 3 or 2
  x = _enforce_sign(x) * math.min(math.abs(x), rmax)
  y = _enforce_sign(y) * math.min(math.abs(y), rmax)
  local guard = 0
  while not _enforce_allowed(x, y, t) and guard < 10 do
    guard = guard + 1
    local ax, ay = math.abs(x), math.abs(y)
    local keep_y = ay > ax or (ay == ax and vertical)
    if keep_y and x ~= 0 then
      x = 0
    elseif not keep_y and y ~= 0 then
      y = 0
    elseif x ~= 0 then
      x = x - _enforce_sign(x)
    else
      y = y - _enforce_sign(y)
    end
  end
  return { x = x, y = y }
end

local function researched(techs, name)
  local tech = techs[name]
  return tech ~= nil and tech.researched
end

local function _enforce_research_table(force, techs, more2)
  techs = techs or force.technologies
  if more2 == nil then more2 = researched(techs, bobmods.inserters.more2_technology) end
  local t = {
    long = researched(techs, bobmods.inserters.long_technology),
    long2 = researched(techs, bobmods.inserters.long2_technology),
    more = researched(techs, bobmods.inserters.more_technology),
    more2 = more2,
    near = researched(techs, bobmods.inserters.near_technology),
  }
  t.full = t.long and t.long2 and t.more and t.more2 and t.near
  return t
end

local function research_full(techs)
  return researched(techs, bobmods.inserters.more2_technology)
    and researched(techs, bobmods.inserters.long2_technology)
    and researched(techs, bobmods.inserters.more_technology)
    and researched(techs, bobmods.inserters.long_technology)
    and researched(techs, bobmods.inserters.near_technology)
end

local read_enforce_positions

-- cache (optional): force index -> research table, reused within one batch of checks.
-- Returns false when the inserter is checked against an incomplete research set (worth re-checking later),
-- true when its force has everything researched, nil when the entity is not subject to the check.
-- dry: only report; the second return value tells whether the positions exceed the research.
-- Paranoidal: whether an inserter prototype is subject to the check, cached per name. Prototypes are fixed
-- for the session, so the cache is the same on every client. Slim inserters have their own default
-- geometry and are skipped; larger ones (nco-InserterCranes) use the normal form.
local _enforce_eligible_cache = {}
local function _enforce_eligible(name)
  local ok = _enforce_eligible_cache[name]
  if ok == nil then
    local proto = prototypes.entity[name]
    ok = false
    if proto and proto.allow_custom_vectors then
      local width, height = proto.tile_width, proto.tile_height
      if width ~= 0 and height ~= 0 then ok = (width == 1 and height == 1) and 1 or 2 end
    end
    _enforce_eligible_cache[name] = ok
  end
  return ok
end

function bobmods.inserters.enforce_research(entity, cache, dry)
  if not (entity and entity.valid) then
    return
  end
  local name = inserter_name(entity)
  local size = name and _enforce_eligible(name)
  if not size or storage.bobmods.inserters.blacklist[name] then return end

  local force = entity.force
  local t, techs, more2
  if cache then
    local index = force.index
    t = cache[index]
    if not t then
      t = _enforce_research_table(force)
      cache[index] = t
    end
  else
    techs = force.technologies
    more2 = researched(techs, bobmods.inserters.more2_technology)
    -- Before the last diagonal research, a normal cardinal layout only needs this one lookup.
    if more2 then t = _enforce_research_table(force, techs, more2) end
  end
  if t and t.full then return true end

  local pickup, drop, offset, vertical = read_enforce_positions(entity, size)
  if not pickup then return false, false end
  t = t or _enforce_research_table(force, techs, more2)

  local new_pickup = _enforce_clamp(pickup, t, vertical)
  local new_drop = _enforce_clamp(drop, t, vertical)
  local new_offset = offset
  if new_drop.x ~= drop.x or new_drop.y ~= drop.y then
    new_offset = calculate_new_drop_offset(drop, offset, new_drop)
  end
  if not t.near then
    -- Without near inserters an offset may only point away from the inserter (the default far one).
    local function far_ok(tile, off)
      return off == 0 or (tile ~= 0 and _enforce_sign(tile) == _enforce_sign(off))
    end
    if not (far_ok(new_drop.x, new_offset.x) and far_ok(new_drop.y, new_offset.y)) then
      new_offset = bobmods.logistics.set_range(new_drop, bobmods.inserters.offset)
    end
  end

  local function same(a, b)
    return math.abs(a.x - b.x) < 0.01 and math.abs(a.y - b.y) < 0.01
  end
  local changed = not (same(pickup, new_pickup) and same(drop, new_drop) and same(offset, new_offset))
  if changed and not dry then
    set_both_positions(entity, new_pickup, combine_drop_position(new_drop, new_offset))
  end
  return false, changed
end

-- Check only the blueprint's actual target on the following tick. The slow sweep still
-- catches direct writes to tracked inserters, which have no universal engine event.
-- Grandfathered positions survive until ordinary entity-to-entity settings are pasted.

local function _enforce_state()
  local s = storage.bob_enforce
  if not s then
    s = { list = {}, ids = {}, set = {}, pos = 1, pending = {}, grand = {} }
    storage.bob_enforce = s
  end
  s.grand = s.grand or {}
  s.reach = nil -- obsolete blueprint cursor cache, no longer needed by pending areas
  return s
end

local function _enforce_is_grand(entity)
  local s = storage.bob_enforce
  local id = entity.unit_number
  return s and id and s.grand and s.grand[id] or false
end

local function _enforce_track(entity)
  local id = entity.unit_number
  if not id then
    return
  end
  local s = storage.bob_enforce or _enforce_state()
  if not s.set[id] then
    s.set[id] = true
    local n = #s.list + 1
    s.list[n] = entity
    s.ids[n] = id
    if n == 1 then bobmods.inserters.update_tick_handler() end
  end
end

local function _enforce_and_track(entity, cache)
  if not (entity and entity.valid) or _enforce_is_grand(entity) then return false end
  local status, changed = bobmods.inserters.enforce_research(entity, cache)
  if status == false and entity.valid and entity.type == "inserter" then
    _enforce_track(entity)
  end
  return changed == true
end
bobmods.inserters.enforce_and_track = _enforce_and_track

-- One-time registration of already built inserters (existing save, new game). Inserters already
-- beyond the research are only remembered as kept, everything else goes to the sweep list.
local function _enforce_fill()
  local s = _enforce_state()
  if s.filled then
    return
  end
  s.filled = true
  bobmods.inserters.create_global_table_basic()
  local cache = {}
  local forces = {}
  for _, force in pairs(game.forces) do
    local t = _enforce_research_table(force)
    cache[force.index] = t
    if not t.full then
      forces[#forces + 1] = force
    end
  end
  if #forces == 0 then
    return
  end
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ type = "inserter", force = forces })) do
      local status, exceeds = bobmods.inserters.enforce_research(entity, cache, true)
      if status == false and entity.unit_number then
        if exceeds then
          s.grand[entity.unit_number] = true
        else
          _enforce_track(entity)
        end
      end
    end
  end
end

local function _enforce_blueprint_paste(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local name = inserter_name(entity)
  if not name or not _enforce_eligible(name) or storage.bobmods.inserters.blacklist[name]
    or _enforce_is_grand(entity) or research_full(entity.force.technologies) then return end
  local pending = _enforce_state().pending
  pending[#pending + 1] = { tick = event.tick, entity = entity }
  if #pending == 1 then bobmods.inserters.update_tick_handler() end
end

-- Only already-saved requests from the old implementation use a spatial query.
local function _enforce_legacy_area(p, cache)
  local surface, force = game.surfaces[p.surface], game.forces[p.force]
  if not (surface and surface.valid and force and force.valid) then return cache end
  local research = cache[p.force] or _enforce_research_table(force)
  cache[p.force] = research
  if not research.full then
    for _, entity in pairs(surface.find_entities_filtered({ area = p.area, type = "inserter", force = force })) do
      if _enforce_and_track(entity, cache) then cache = {} end
    end
  end
  return cache
end

local function _enforce_tick(tick)
  local s = storage.bob_enforce
  if not (s and s.filled) then
    -- Saves where on_configuration_changed did not run for this code (same mod version).
    _enforce_fill()
    s = storage.bob_enforce
  end

  local pending = s.pending
  if pending[1] then
    -- Detach the batch: synchronous adjustment listeners can append new work.
    s.pending = {}
    local cache = {}
    for _, p in ipairs(pending) do
      if p.tick >= tick then
        s.pending[#s.pending + 1] = p
      elseif p.area then
        cache = _enforce_legacy_area(p, cache)
      elseif _enforce_and_track(p.entity, cache) then
        cache = {} -- a listener may change research before the next target
      end
    end
  end
  if tick % ENFORCE_SWEEP_INTERVAL == 0 then bobmods.inserters.enforce_sweep(tick) end
end
bobmods.inserters.enforce_tick = _enforce_tick

function bobmods.inserters.enforce_sweep(tick)
  local s = storage.bob_enforce
  -- A subscription change can overlap the current even tick. Step only once.
  if last_sweep_tick == tick or not s.list[1] then return end
  last_sweep_tick = tick
  local list, ids = s.list, s.ids
  local n = #list
  local pos = s.pos <= n and s.pos or 1
  local entity, id = list[pos], ids[pos]
  if entity.valid and not (s.grand and s.grand[id]) and bobmods.inserters.enforce_research(entity) == false then
    s.pos = pos + 1
  else
    -- Reentrant build listeners may append while positions are being adjusted.
    n = #list
    s.set[id] = nil
    list[pos], ids[pos] = list[n], ids[n]
    list[n], ids[n] = nil, nil
    s.pos = n == 1 and 1 or pos
  end
end
bobmods.inserters.enforce_fill = _enforce_fill

local function _enforce_built(event)
  _enforce_and_track(event.entity)
end
local _enforce_filter = { { filter = "type", type = "inserter" }, { filter = "ghost_type", type = "inserter" } }
script.on_event(defines.events.on_robot_built_entity, _enforce_built, _enforce_filter)
script.on_event(defines.events.script_raised_built, _enforce_built, _enforce_filter)
script.on_event(defines.events.script_raised_revive, _enforce_built, _enforce_filter)
script.on_event(defines.events.on_entity_cloned, function(event)
  local src, dst = event.source, event.destination
  if src and src.valid and dst and dst.valid and dst.unit_number and _enforce_is_grand(src) then
    storage.bob_enforce.grand[dst.unit_number] = true -- a moved kept inserter stays kept
    return
  end
  _enforce_and_track(dst)
end, { { filter = "type", type = "inserter" } })
script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local dst = event.destination
  if dst and dst.valid and dst.unit_number and storage.bob_enforce and storage.bob_enforce.grand then
    storage.bob_enforce.grand[dst.unit_number] = nil -- the player replaced its settings explicitly
  end
  _enforce_and_track(dst)
end)
script.on_event(defines.events.on_blueprint_settings_pasted, _enforce_blueprint_paste)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "bobmods-inserters-button-enable" then
    bobmods.logistics.create_gui_button(event.player_index)
  end
end)

function tech_unlocked(force, tech)
  local technology = force.technologies[tech]
  if technology then
    return technology.researched
  end
end

---private function, used by slimDropOffset andslimPickupOffset
local ZERO_OFFSET = { x = 0, y = 0 }
function _slimOffset(entity, l)
  -- Callers only read the offset; ordinary inserters share the immutable zero vector.
  local proto = entity.prototype
  if proto.tile_height ~= 0 or proto.tile_width ~= 1 then return ZERO_OFFSET end
  local o = { x = 0, y = 0 }
  do
    -- this calculation is tested with mod arrow-inserter and slim-inserters
    if entity.direction == defines.direction.north then
      o.y = -0.5 + l
    elseif entity.direction == defines.direction.south then
      o.y = 0.5 - l
    elseif entity.direction == defines.direction.east then
      o.x = 0.5 - l
    elseif entity.direction == defines.direction.west then
      o.x = -0.5 + l
    end
  end
  return o
end

function slimDropOffset(entity)
  return _slimOffset(entity, 1)
end

function slimPickupOffset(entity)
  return _slimOffset(entity, 0)
end

-- Paranoidal: inserters larger than 1x1 (e.g. nco-InserterCranes 2x2 and 6x2) are mapped to the
-- 1x1 normal form by removing the extra body size on each axis. Coordinates inside the body span
-- map to 0; when mapping back, 0 keeps the current in-span coordinate (the chosen column).
local big_shifts = {}
local function _bigShift(entity)
  local ghost = entity.type == "entity-ghost"
  local name = ghost and entity.ghost_name or entity.name
  local shifts = big_shifts[name]
  if shifts == nil then
    local proto = ghost and entity.ghost_prototype or entity.prototype
    local w, h = proto.tile_width, proto.tile_height
    shifts = false
    if w and h and (w > 1 or h > 1) then
      shifts = { normal = { x = (w - 1) / 2, y = (h - 1) / 2 },
        rotated = { x = (h - 1) / 2, y = (w - 1) / 2 } }
    end
    big_shifts[name] = shifts
  end
  if not shifts then return nil end
  local d = entity.direction
  return (d == defines.direction.east or d == defines.direction.west) and shifts.rotated or shifts.normal
end

local function _bigToNormal(c, s)
  if c > s + 0.01 then
    return c - s
  elseif c < -s - 0.01 then
    return c + s
  end
  return 0
end

local function _bigFromNormal(n, s, prev)
  if n > 0.01 then
    return n + s
  elseif n < -0.01 then
    return n - s
  end
  if math.abs(prev) <= s + 0.01 then
    return prev
  end
  local base = (s % 1 == 0) and 0 or 0.5
  return prev < 0 and -base or base
end

local function _relToNormal(entity, abs, o, snap)
  local position = entity.position
  local rel = { x = abs.x - position.x, y = abs.y - position.y }
  local s = _bigShift(entity)
  if s then
    rel.x, rel.y = _bigToNormal(rel.x, s.x), _bigToNormal(rel.y, s.y)
    if snap then
      -- pickup has no near/far offset in the grid (crane default pickup is 1.7 = tile + 0.2)
      rel.x, rel.y = bobmods.math.round(rel.x), bobmods.math.round(rel.y)
    end
  end
  rel.x, rel.y = rel.x + o.x, rel.y + o.y
  return rel
end

local function _normalToAbs(entity, newpos, o, current_abs)
  local position = entity.position
  local rel = { x = newpos.x - o.x, y = newpos.y - o.y }
  local s = _bigShift(entity)
  if s then
    rel.x = _bigFromNormal(rel.x, s.x, current_abs.x - position.x)
    rel.y = _bigFromNormal(rel.y, s.y, current_abs.y - position.y)
  end
  return { x = position.x + rel.x, y = position.y + rel.y }
end

local function cardinal_neighbour(x, y)
  return (x == 0 and math.abs(y) == 1) or (y == 0 and math.abs(x) == 1)
end

local function normal_drop_axis(distance, cross)
  -- Factorio stores positions on a fixed-point grid. Accept only a narrow
  -- neighbourhood of the ordinary outward offset, well inside the same tile.
  return cross == 0 and (math.abs(distance) == 1 or math.abs(math.abs(distance) - 1.2) < 0.005)
end

read_enforce_positions = function(entity, size)
  local position, pickup, drop = entity.position, entity.pickup_position, entity.drop_position
  local px, py = pickup.x - position.x, pickup.y - position.y
  local dx, dy = drop.x - position.x, drop.y - position.y
  if size == 1 then
    if cardinal_neighbour(px, py) and (normal_drop_axis(dx, dy) or normal_drop_axis(dy, dx)) then return end
  else
    local shift = _bigShift(entity)
    if shift then
      px, py = _bigToNormal(px, shift.x), _bigToNormal(py, shift.y)
      dx, dy = _bigToNormal(dx, shift.x), _bigToNormal(dy, shift.y)
    end
  end
  local direction = entity.direction
  return { x = bobmods.math.round(px), y = bobmods.math.round(py) },
    { x = bobmods.math.round(dx), y = bobmods.math.round(dy) },
    bobmods.inserters.normalise_tile_offset({ x = bobmods.math.offset(dx), y = bobmods.math.offset(dy) }),
    direction == defines.direction.north or direction == defines.direction.south
end

function get_pickup_position(entity)
  return _relToNormal(entity, entity.pickup_position, slimPickupOffset(entity), true)
end

function get_drop_position(entity)
  return _relToNormal(entity, entity.drop_position, slimDropOffset(entity))
end

function split_drop_position(full_drop_position)
  local drop_position = { x = bobmods.math.round(full_drop_position.x), y = bobmods.math.round(full_drop_position.y) }
  local drop_offset = { x = bobmods.math.offset(full_drop_position.x), y = bobmods.math.offset(full_drop_position.y) }
  return drop_position, drop_offset
end

function get_split_drop_position(entity)
  local full_drop_position = get_drop_position(entity)
  local drop_position = { x = bobmods.math.round(full_drop_position.x), y = bobmods.math.round(full_drop_position.y) }
  local drop_offset = { x = bobmods.math.offset(full_drop_position.x), y = bobmods.math.offset(full_drop_position.y) }
  return drop_position, drop_offset
end

function get_drop_tile_position(entity)
  local full_drop_position = get_drop_position(entity)
  return { x = bobmods.math.round(full_drop_position.x), y = bobmods.math.round(full_drop_position.y) }
end

function get_drop_offset_position(entity)
  local full_drop_position = get_drop_position(entity)
  return { x = bobmods.math.offset(full_drop_position.x), y = bobmods.math.offset(full_drop_position.y) }
end

function combine_drop_position(drop_position, drop_offset)
  return { x = drop_position.x + drop_offset.x, y = drop_position.y + drop_offset.y }
end

function set_pickup_position(entity, newpos)
  local o = slimPickupOffset(entity)
  local original_positions = { drop_position = entity.drop_position, pickup_position = entity.pickup_position }
  local new_positions = {
    drop_position = { x = original_positions.drop_position.x, y = original_positions.drop_position.y },
    pickup_position = _normalToAbs(entity, newpos, o, original_positions.pickup_position),
  }
  entity.pickup_position = new_positions.pickup_position
  entity.direction = entity.direction -- set direction to force update
  script.raise_event(
    changed_position_event,
    { entity = entity, new_positions = new_positions, original_positions = original_positions }
  ) -- Raise positions changed event.
  script.raise_event(
    defines.events.on_bobs_inserter_adjusted,
    { entity = entity, new_positions = new_positions, original_positions = original_positions }
  ) -- Raise positions changed event.
end

function set_drop_position(entity, newpos)
  local o = slimDropOffset(entity)
  local original_positions = { drop_position = entity.drop_position, pickup_position = entity.pickup_position }
  local new_positions = {
    drop_position = _normalToAbs(entity, newpos, o, original_positions.drop_position),
    pickup_position = { x = original_positions.pickup_position.x, y = original_positions.pickup_position.y },
  }
  entity.drop_position = new_positions.drop_position
  entity.direction = entity.direction -- set direction to force update
  script.raise_event(
    changed_position_event,
    { entity = entity, new_positions = new_positions, original_positions = original_positions }
  ) -- Raise positions changed event.
  script.raise_event(
    defines.events.on_bobs_inserter_adjusted,
    { entity = entity, new_positions = new_positions, original_positions = original_positions }
  ) -- Raise positions changed event.
end

function set_split_drop_position(entity, new_position, new_offset)
  return set_drop_position(entity, combine_drop_position(new_position, new_offset))
end

function set_both_positions(entity, newpickup, newdrop)
  local od = slimDropOffset(entity)
  local op = slimPickupOffset(entity)
  local original_positions = { drop_position = entity.drop_position, pickup_position = entity.pickup_position }
  local new_positions = {
    drop_position = _normalToAbs(entity, newdrop, od, original_positions.drop_position),
    pickup_position = _normalToAbs(entity, newpickup, op, original_positions.pickup_position),
  }
  entity.drop_position = new_positions.drop_position
  entity.pickup_position = new_positions.pickup_position
  entity.direction = entity.direction -- set direction to force update
  script.raise_event(
    changed_position_event,
    { entity = entity, new_positions = new_positions, original_positions = original_positions }
  ) -- Raise positions changed event.
  script.raise_event(
    defines.events.on_bobs_inserter_adjusted,
    { entity = entity, new_positions = new_positions, original_positions = original_positions }
  ) -- Raise positions changed event.
end

function check_position(pos1, pos2)
  return math.abs(pos1.x - pos2.x) < 0.1 and math.abs(pos1.y - pos2.y) < 0.1
end

function bobmods.inserters.normalise_tile_offset(tile_offset)
  local new_offset = { x = 0, y = 0 }
  if tile_offset.x > 0.01 then
    new_offset.x = bobmods.inserters.offset
  end
  if tile_offset.x < -0.01 then
    new_offset.x = -bobmods.inserters.offset
  end
  if tile_offset.y > 0.01 then
    new_offset.y = bobmods.inserters.offset
  end
  if tile_offset.y < -0.01 then
    new_offset.y = -bobmods.inserters.offset
  end
  return new_offset
end

function bobmods.logistics.set_range(position_in, range)
  local position = { x = 0, y = 0 }
  if position_in.x > 0.1 then
    position.x = range
  elseif position_in.x < -0.1 then
    position.x = -range
  else
    position.x = 0
  end
  if position_in.y > 0.1 then
    position.y = range
  elseif position_in.y < -0.1 then
    position.y = -range
  else
    position.y = 0
  end
  return position
end

function calculate_new_drop_offset(drop_position, drop_offset, new_position)
  local new_offset = { x = drop_offset.x, y = drop_offset.y }

  if (drop_position.x > 0 and new_position.x < 0) or (drop_position.x < 0 and new_position.x > 0) then
    new_offset.x = 0 - drop_offset.x
  elseif drop_position.x == 0 and new_position.x ~= 0 then
    if (new_position.x > 0 and drop_position.y > 0) or (new_position.x < 0 and drop_position.y < 0) then
      new_offset.x = drop_offset.y
    else
      new_offset.x = 0 - drop_offset.y
    end
  elseif drop_position.x ~= 0 and new_position.x == 0 then
    new_offset.x = 0
  end

  if (drop_position.y > 0 and new_position.y < 0) or (drop_position.y < 0 and new_position.y > 0) then
    new_offset.y = 0 - drop_offset.y
  elseif drop_position.y == 0 and new_position.y ~= 0 then
    if (new_position.y > 0 and drop_position.x > 0) or (new_position.y < 0 and drop_position.x < 0) then
      new_offset.y = drop_offset.x
    else
      new_offset.y = 0 - drop_offset.x
    end
  elseif drop_position.y ~= 0 and new_position.y == 0 then
    new_offset.y = 0
  end

  return bobmods.inserters.normalise_tile_offset(new_offset)
end

function bobmods.logistics.set_positions(entity, player_index)
  if storage.bobmods.logistics[player_index].enabled then
    local force = game.players[player_index].force

    local long_unlocked = tech_unlocked(force, bobmods.inserters.long_technology)
    local more_unlocked = tech_unlocked(force, bobmods.inserters.more_technology)
    local near_unlocked = tech_unlocked(force, bobmods.inserters.near_technology)

    local long_in = storage.bobmods.logistics[player_index].long_in
    local long_out = storage.bobmods.logistics[player_index].long_out
    local near = storage.bobmods.logistics[player_index].near

    local pickup_position = get_pickup_position(entity)
    local drop_position, drop_offset = get_split_drop_position(entity)

    if long_unlocked then
      if more_unlocked then
        if long_in then
          pickup_position = bobmods.logistics.set_range(pickup_position, 2)
        else
          pickup_position = bobmods.logistics.set_range(pickup_position, 1)
        end
        if long_out then
          drop_position = bobmods.logistics.set_range(drop_position, 2)
        else
          drop_position = bobmods.logistics.set_range(drop_position, 1)
        end
      else
        if long_in then
          pickup_position = bobmods.logistics.set_range(pickup_position, 2)
          drop_position = bobmods.logistics.set_range(drop_position, 2)
        else
          pickup_position = bobmods.logistics.set_range(pickup_position, 1)
          drop_position = bobmods.logistics.set_range(drop_position, 1)
        end
      end
    end

    if near_unlocked then
      if near then
        drop_offset = bobmods.logistics.set_range(drop_position, -bobmods.inserters.offset)
      else
        drop_offset = bobmods.logistics.set_range(drop_position, bobmods.inserters.offset)
      end
    end
    local full_drop_position = combine_drop_position(drop_position, drop_offset)
    set_both_positions(entity, pickup_position, full_drop_position)
  end

  if
    storage.bobmods.logistics[player_index].enabled2
    and not game.players[player_index].is_cursor_blueprint()
  then
    -- Paranoidal: read directly instead of remote.call into this same mod; copies as remote.call returned.
    local function copy(p)
      return p and { x = p.x, y = p.y }
    end
    local pickup_position = copy(bobmods.inserters.positions[storage.bobmods.logistics[player_index].pickup])
    local drop_position = copy(bobmods.inserters.positions[storage.bobmods.logistics[player_index].drop])
    local drop_offset = copy(bobmods.inserters.offset_positions[storage.bobmods.logistics[player_index].offset])

    -- treat south as up, because inserters are backwards.
    if entity.direction == defines.direction.south then
      pickup_position = pickup_position
      drop_position = drop_position
      drop_offset = drop_offset
    elseif entity.direction == defines.direction.west then
      pickup_position = { x = -pickup_position.y, y = pickup_position.x }
      drop_position = { x = -drop_position.y, y = drop_position.x }
      drop_offset = { x = -drop_offset.y, y = drop_offset.x }
    elseif entity.direction == defines.direction.north then
      pickup_position = { x = -pickup_position.x, y = -pickup_position.y }
      drop_position = { x = -drop_position.x, y = -drop_position.y }
      drop_offset = { x = -drop_offset.x, y = -drop_offset.y }
    elseif entity.direction == defines.direction.east then
      pickup_position = { x = pickup_position.y, y = -pickup_position.x }
      drop_position = { x = drop_position.y, y = -drop_position.x }
      drop_offset = { x = drop_offset.y, y = -drop_offset.x }
    end

    local near_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.near_technology)
    if not near_unlocked then
      local old_drop_position, old_drop_offset = get_split_drop_position(entity)
      drop_offset = calculate_new_drop_offset(old_drop_position, old_drop_offset, drop_position)
    end
    local full_drop_position = combine_drop_position(drop_position, drop_offset)
    set_both_positions(entity, pickup_position, full_drop_position)
  end
end

function bobmods.inserters.apply_gui_position(entity, player, kind, index)
  if kind == "pickup" then
    set_pickup_position(entity, bobmods.inserters.positions[index])
  elseif kind == "drop" then
    local new_position = bobmods.inserters.positions[index]
    local drop, offset = get_split_drop_position(entity)
    set_split_drop_position(entity, new_position, calculate_new_drop_offset(drop, offset, new_position))
  else
    set_split_drop_position(entity, get_drop_tile_position(entity), bobmods.inserters.offset_positions[index])
  end
  -- A synchronous position listener may replace the window or destroy the entity.
  bobmods.inserters.refresh_position_checkboxes(entity, player)
end

function bobmods.inserters.rotate_position(force, pickup_position)
  local more_unlocked = tech_unlocked(force, bobmods.inserters.more_technology)
  local more2_unlocked = tech_unlocked(force, bobmods.inserters.more2_technology)
  local rotation = 1
  local position

  -- Decide which position table to use
  if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
    if more2_unlocked then
      position = bobmods.inserters.range3_24way
    elseif more_unlocked then
      position = bobmods.inserters.range3_8way
    else
      position = bobmods.inserters.range3_4way
    end
  elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
    if more2_unlocked then
      position = bobmods.inserters.range2_16way
    elseif more_unlocked then
      position = bobmods.inserters.range2_8way
    else
      position = bobmods.inserters.range2_4way
    end
  else
    if more_unlocked then
      position = bobmods.inserters.range1_8way
    else
      position = bobmods.inserters.range1_4way
    end
  end

  -- Find current rotation
  for i, new_position in ipairs(position.table) do
    if check_position(pickup_position, new_position) then
      rotation = i
      break
    end
  end
  -- Rotate
  rotation = rotation + 1
  if rotation > position.steps then
    rotation = rotation - position.steps
  end

  return position.table[rotation]
end

function bobmods.inserters.rotate_pickup(entity, player)
  local pickup_position = get_pickup_position(entity)
  pickup_position = bobmods.inserters.rotate_position(player.force, pickup_position)
  set_pickup_position(entity, pickup_position)
  if entity == storage.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end

function bobmods.inserters.rotate_drop(entity, player)
  local drop_position, drop_offset = get_split_drop_position(entity)
  local new_position = bobmods.inserters.rotate_position(player.force, drop_position)
  local new_offset = calculate_new_drop_offset(drop_position, drop_offset, new_position)
  set_split_drop_position(entity, new_position, new_offset)
  if entity == storage.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end

local function length_option(force)
  if tech_unlocked(force, bobmods.inserters.long2_technology) then return 3 end
  if tech_unlocked(force, bobmods.inserters.long_technology) then return 1 end
end

local function next_range(position, option)
  local distance = math.max(math.abs(position.x), math.abs(position.y))
  if distance > 2.1 then return 1 end
  if distance > 1.1 then return option end
  return 2
end

function bobmods.inserters.pickup_range(entity, player)
  local option = length_option(player.force)
  if not option then return end
  local pickup = get_pickup_position(entity)
  set_pickup_position(entity, bobmods.logistics.set_range(pickup, next_range(pickup, option)))
  bobmods.inserters.refresh_position_checkboxes(entity, player)
end

function bobmods.inserters.drop_range(entity, player)
  local option = length_option(player.force)
  if not option then return end
  local drop, offset = get_split_drop_position(entity)
  set_split_drop_position(entity, bobmods.logistics.set_range(drop, next_range(drop, option)), offset)
  bobmods.inserters.refresh_position_checkboxes(entity, player)
end

function bobmods.inserters.long_range(entity, player)
  local option = length_option(player.force)
  if not option then return end
  local pickup = get_pickup_position(entity)
  local drop, offset = get_split_drop_position(entity)
  local range = next_range(pickup, option)
  set_both_positions(entity, bobmods.logistics.set_range(pickup, range),
    combine_drop_position(bobmods.logistics.set_range(drop, range), offset))
  bobmods.inserters.refresh_position_checkboxes(entity, player)
end

function bobmods.inserters.near_range(entity, player)
  if not tech_unlocked(player.force, bobmods.inserters.near_technology) then return end
  local drop_position, drop_offset = get_split_drop_position(entity)

  do
    if
      (drop_offset.x == 0 and drop_offset.y == 0)
      or (drop_offset.x == 0 and drop_position.x ~= 0)
      or (drop_offset.y == 0 and drop_position.y ~= 0)
    then
      drop_offset = bobmods.inserters.normalise_tile_offset({ x = drop_position.x, y = drop_position.y })
    else
      if drop_position.x ~= 0 then
        drop_offset.x = 0 - drop_offset.x
      end
      if drop_position.y ~= 0 then
        drop_offset.y = 0 - drop_offset.y
      end
    end

    if
      (drop_position.y ~= 0 and drop_position.x ~= 0)
      and (
        (
          ((drop_position.x > 0 and drop_offset.x < 0) or (drop_offset.x > 0 and drop_position.x < 0)) -- x near
          and ((drop_position.y > 0 and drop_offset.y > 0) or (drop_offset.y < 0 and drop_position.y < 0))
        ) -- y far
        or (
          ((drop_position.x > 0 and drop_offset.x > 0) or (drop_offset.x < 0 and drop_position.x < 0)) -- x far
          and ((drop_position.y > 0 and drop_offset.y < 0) or (drop_offset.y > 0 and drop_position.y < 0))
        ) -- y near
      )
    then
      drop_offset = bobmods.inserters.normalise_tile_offset({ x = drop_position.x, y = drop_position.y })
    end
  end

  set_split_drop_position(entity, drop_position, drop_offset)
  if entity == storage.bobmods.inserters[player.index].entity then
    bobmods.inserters.refresh_position_checkboxes(entity, player)
  end
end

function bobmods.logistics.destroy_gui_button(player_index)
  local player = game.players[player_index]

  -- remove legacy GUI
  if player.gui.top.bob_logistics_inserter_gui then
    player.gui.top.bob_logistics_inserter_gui.destroy()
  end

  -- remove legacy button
  if player.gui.top.bob_logistics_inserter_button then
    player.gui.top.bob_logistics_inserter_button.destroy()
  end

  local gui = player.gui.top
  local flow = gui.mod_gui_button_flow or (gui.mod_gui_top_frame and gui.mod_gui_top_frame.mod_gui_inner_frame)

  if flow and flow.bob_logistics_inserter_button then
    flow.bob_logistics_inserter_button.destroy()
    -- Remove empty frame if we're the only thing there, remove the parent frame if we just removed the only child
    if #flow.children_names == 0 then
      local parent = flow.parent
      flow.destroy()
      if parent and parent.name ~= "top" and #parent.children_names == 0 then
        parent.destroy()
      end
    end
  end
end

function bobmods.logistics.create_gui_button(player_index)
  bobmods.logistics.destroy_gui_button(player_index)

  -- Paranoidal's GUI Unifier excludes this button. Do not create it just to have it removed.
  if script.active_mods["GUI_Unifyer"] then return end

  local player = game.players[player_index]

  if not settings.get_player_settings(player)["bobmods-inserters-button-enable"].value then
    return
  end

  mod_gui.get_button_flow(player).add({
    type = "sprite-button",
    name = "bob_logistics_inserter_button",
    tooltip = { "gui.bob-inserter-open-gui" },
    sprite = "item/fast-inserter",
    style = "mod_gui_button",
    visible = settings.get_player_settings(player)["bobmods-inserters-button-enable"].value,
  })
end

function bobmods.logistics.show_gui_options(player_index)
  local player = game.players[player_index]

  if player.gui.left.bob_logistics_inserter_gui then
    player.gui.left.bob_logistics_inserter_gui.destroy()
  end

  if storage.bobmods.logistics[player_index].show then
    bobmods.logistics.create_gui(player_index)
  end
end

function bobmods.logistics.create_gui(player_index)
  local player = game.players[player_index]
  local long_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.long_technology)
  local more_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.more_technology)
  local near_unlocked = tech_unlocked(game.players[player_index].force, bobmods.inserters.near_technology)

  if player.gui.left.bob_logistics_inserter_gui then
    player.gui.left.bob_logistics_inserter_gui.destroy()
  end

  if not settings.get_player_settings(player)["bobmods-inserters-button-enable"].value then
    return
  end

  local gui = player.gui.left.add({ type = "frame", name = "bob_logistics_inserter_gui", direction = "vertical" })
  gui.style.bottom_padding = 8
  gui.style.vertically_stretchable = false
  gui.style.horizontally_stretchable = false

  gui.add({ type = "table", name = "table", column_count = 1, style = "bob_table" })

  if long_unlocked or near_unlocked then
    gui.table.add({
      type = "checkbox",
      name = "bob_logistics_inserter_enabled",
      state = storage.bobmods.logistics[player_index].enabled,
      caption = { "gui.bob-logistics-enabled" },
    })
  end
  if storage.bobmods.logistics[player_index].enabled then
    if long_unlocked then
      if more_unlocked then
        gui.table.add({
          type = "checkbox",
          name = "bob_logistics_inserter_long_in",
          state = storage.bobmods.logistics[player_index].long_in,
          caption = { "gui.bob-logistics-pickup" },
        })
        gui.table.add({
          type = "checkbox",
          name = "bob_logistics_inserter_long_out",
          state = storage.bobmods.logistics[player_index].long_out,
          caption = { "gui.bob-logistics-drop" },
        })
      else
        gui.table.add({
          type = "checkbox",
          name = "bob_logistics_inserter_long_in",
          state = storage.bobmods.logistics[player_index].long_in,
          caption = { "gui.bob-logistics-long" },
        })
      end
    end
    if near_unlocked then
      gui.table.add({
        type = "checkbox",
        name = "bob_logistics_inserter_near",
        state = storage.bobmods.logistics[player_index].near,
        caption = { "gui.bob-logistics-near" },
      })
    end
  end

  do -- Paranoidal: was "if remote.interfaces.bobinserters", the own interface (always present)
    gui.table.add({
      type = "checkbox",
      name = "bob_logistics_inserter_enabled2",
      state = storage.bobmods.logistics[player_index].enabled2,
      caption = { "gui.bob-logistics-enabled2" },
    })
    if storage.bobmods.logistics[player_index].enabled2 then
      bobmods.inserters.remote_interface.draw_gui({
        player_index = player_index,
        gui = gui,
        name = "bob_logistics",
        pickup = storage.bobmods.logistics[player_index].pickup,
        drop = storage.bobmods.logistics[player_index].drop,
        offset = storage.bobmods.logistics[player_index].offset,
      })
    end
  end
end

function bobmods.inserters.delete_gui(player_index)
  local players = storage.bobmods.inserters
  local session = players[player_index]
  local gui = session and session.gui
  if session then
    session.entity, session.gui, session.pickup, session.drop, session.offset = nil, nil, nil, nil, nil
    session.selected_buttons = nil
  end
  local active = players.active_editors
  if active then active[player_index] = nil end
  if gui and gui.valid then gui.destroy() end
  update_gui_tick()
end

function bobmods.inserters.open_gui(entity, player, position)
  local player_index = player.index
  bobmods.inserters.delete_gui(player_index)

  local players = storage.bobmods.inserters
  local globtable = players[player_index]
  globtable.entity = entity
  globtable.position = position
  local prototype = entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype

  local long_unlocked = tech_unlocked(player.force, bobmods.inserters.long_technology)
  local long2_unlocked = tech_unlocked(player.force, bobmods.inserters.long2_technology)
  local more_unlocked = tech_unlocked(player.force, bobmods.inserters.more_technology)
  local more2_unlocked = tech_unlocked(player.force, bobmods.inserters.more2_technology)
  local near_unlocked = tech_unlocked(player.force, bobmods.inserters.near_technology)

  local pickup_position = get_pickup_position(entity)
  local full_drop_position = get_drop_position(entity)
  local drop_position = { x = bobmods.math.round(full_drop_position.x), y = bobmods.math.round(full_drop_position.y) }
  local offset_position = bobmods.inserters.normalise_tile_offset({
    x = bobmods.math.offset(full_drop_position.x),
    y = bobmods.math.offset(full_drop_position.y),
  })

  local gui
  if position == "left" then
    gui = player.gui.relative.add({
      type = "frame",
      name = "bob_inserter_gui",
      direction = "vertical",
      caption = { "gui.bob-named-inserter-gui", prototype.localised_name },
    })
    gui.anchor = {
      gui = defines.relative_gui_type.inserter_gui,
      position = defines.relative_gui_position[settings.get_player_settings(player)["bobmods-inserters-gui-position"].value],
    }

    globtable.pickup, globtable.drop, globtable.offset = bobmods.inserters.draw_inserter_gui_main_table(
      gui,
      "bob_inserter_gui",
      pickup_position,
      drop_position,
      offset_position,
      long_unlocked,
      long2_unlocked,
      more_unlocked,
      more2_unlocked,
      near_unlocked
    )
  else
    gui = player.gui.screen.add({ type = "frame", name = "bob_inserter_gui", direction = "vertical" })
    gui_add_title(
      gui,
      { "gui.bob-named-inserter-gui", prototype.localised_name },
      "bob_inserter_gui_close",
      true
    )
    local main_table_target = gui

    if settings.get_player_settings(player)["bobmods-inserters-show-window"].value ~= "off" then
      local entity_flow = gui
      local frame_width = 400
      if settings.get_player_settings(player)["bobmods-inserters-show-window"].value == "left" then
        gui.title_flow.title.caption = { "gui.bob-inserter-gui" }
        main_table_target = gui.add({ type = "flow", name = "main_flow", style = "horizontal_flow" })
        gui.main_flow.style.horizontal_spacing = 12
        entity_flow = gui.main_flow.add({ type = "table", name = "entity_flow", style = "bob_table", column_count = 1 })
        entity_flow.add({
          type = "label",
          name = "entity_name",
          style = "heading_2_label",
          caption = prototype.localised_name,
        })
        frame_width = 148
      end

      entity_flow.add({ type = "frame", name = "entity_frame", style = "inside_shallow_frame" })
      entity_flow.entity_frame.style.width = frame_width
      entity_flow.entity_frame.style.height = 148
      entity_flow.entity_frame.style.horizontally_stretchable = false
      entity_flow.entity_frame.add({ type = "entity-preview", name = "entity_preview", style = "entity_button_base" })
      entity_flow.entity_frame.entity_preview.style.width = frame_width
      entity_flow.entity_frame.entity_preview.style.height = 148
      entity_flow.entity_frame.entity_preview.entity = entity
    end

    globtable.pickup, globtable.drop, globtable.offset = bobmods.inserters.draw_inserter_gui_main_table(
      main_table_target,
      "bob_inserter_gui",
      pickup_position,
      drop_position,
      offset_position,
      long_unlocked,
      long2_unlocked,
      more_unlocked,
      more2_unlocked,
      near_unlocked
    )

    gui.auto_center = true
  end

  gui.style.bottom_padding = 8
  gui.style.vertically_stretchable = false
  gui.style.horizontally_stretchable = false
  globtable.gui = gui
  editor_index(players)[player_index] = true
  update_gui_tick()
  if position == "center" then player.opened = gui end
end

function bobmods.inserters.draw_inserter_gui_main_table(
  gui,
  name,
  pickup_position,
  drop_position,
  offset_position,
  long_unlocked,
  long2_unlocked,
  more_unlocked,
  more2_unlocked,
  near_unlocked
)
  local isshort = false
  local islong = false
  local islong2 = false

  if pickup_position.x > 2.1 or pickup_position.x < -2.1 or pickup_position.y > 2.1 or pickup_position.y < -2.1 then
    islong2 = true
  elseif pickup_position.x > 1.1 or pickup_position.x < -1.1 or pickup_position.y > 1.1 or pickup_position.y < -1.1 then
    islong = true
  else
    isshort = true
  end
  if drop_position.x > 2.1 or drop_position.x < -2.1 or drop_position.y > 2.1 or drop_position.y < -2.1 then
    islong2 = true
  elseif drop_position.x > 1.1 or drop_position.x < -1.1 or drop_position.y > 1.1 or drop_position.y < -1.1 then
    islong = true
  else
    isshort = true
  end

  local main_table = gui.add({ type = "table", name = "main_table", column_count = 2, style = "bob_table" })
  main_table.style.horizontal_spacing = 12

  main_table.add({
    type = "label",
    name = "pickup_label",
    style = "heading_2_label",
    caption = { "gui.bob-inserter-pickup" },
  })
  main_table.add({
    type = "label",
    name = "drop_label",
    style = "heading_2_label",
    caption = { "gui.bob-inserter-drop" },
  })

  main_table.add({ type = "frame", name = "pickup", style = "inside_shallow_frame_with_padding" })
  main_table.add({ type = "frame", name = "drop", style = "inside_shallow_frame_with_padding" })
  main_table.drop.add({ type = "table", name = "table", column_count = 3, style = "bob_table" })

  local column_count = 5

  if long2_unlocked or islong2 then
    column_count = 7
  elseif long_unlocked or islong then
    column_count = 5
  else
    column_count = 3
  end

  local gui_pickup = main_table.pickup.add({
    type = "table",
    name = name .. "_pickup",
    column_count = column_count,
    style = "bob_table",
  })
  local gui_drop = main_table.drop.table.add({
    type = "table",
    name = name .. "_drop",
    column_count = column_count,
    style = "bob_table",
  })
  local gui_offset = nil

  bobmods.inserters.draw_button_grid(
    gui_pickup,
    pickup_position,
    "bob_inserter_checkbox_pickup",
    long_unlocked,
    more_unlocked,
    islong,
    long2_unlocked,
    more2_unlocked,
    islong2,
    isshort
  )
  bobmods.inserters.draw_button_grid(
    gui_drop,
    drop_position,
    "bob_inserter_checkbox_drop",
    long_unlocked,
    more_unlocked,
    islong,
    long2_unlocked,
    more2_unlocked,
    islong2,
    isshort
  )

  if near_unlocked then
    main_table.drop.table.add({ type = "label", name = "spacer2", caption = "     " })
    main_table.drop.table.add({ type = "table", name = "offset", column_count = 1, style = "bob_table" })
    main_table.drop.table.offset.add({
      type = "label",
      name = "entity_name",
      caption = { "gui.bob-inserter-offset" },
      style = "heading_2_label",
    })
    gui_offset = main_table.drop.table.offset.add({
      type = "table",
      name = name .. "_offset",
      column_count = 3,
      style = "bob_table",
    })
    bobmods.inserters.draw_offset_grid(gui_offset, offset_position)
  end
  return gui_pickup, gui_drop, gui_offset
end

function bobmods.inserters.draw_offset_grid(gui, position)
  gui.add({ type = "checkbox", name = "button1", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button2", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button3", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button4", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button5", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button6", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button7", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button8", state = false, style = "bob_inserter_checkbox_small" })
  gui.add({ type = "checkbox", name = "button9", state = false, style = "bob_inserter_checkbox_small" })

  bobmods.inserters.draw_button_offset_check(gui, position)
end

function bobmods.inserters.draw_button_grid(gui, position, style, long, more, islong, long2, more2, islong2, isshort)
  if long2 or islong2 then
    if more then
      gui.add({ type = "checkbox", name = "button26", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank26", state = false, style = "bob_inserter_blank" })
    end
    if more2 then
      gui.add({ type = "checkbox", name = "button27", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank27", state = false, style = "bob_inserter_blank" })
    end
    if more2 then
      gui.add({ type = "checkbox", name = "button28", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank28", state = false, style = "bob_inserter_blank" })
    end
    gui.add({ type = "checkbox", name = "button29", state = false, style = style })
    if more2 then
      gui.add({ type = "checkbox", name = "button30", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank30", state = false, style = "bob_inserter_blank" })
    end
    if more2 then
      gui.add({ type = "checkbox", name = "button31", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank31", state = false, style = "bob_inserter_blank" })
    end
    if more then
      gui.add({ type = "checkbox", name = "button32", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank32", state = false, style = "bob_inserter_blank" })
    end
  end

  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button33", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank33", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 or long or islong then
    if more and (long or islong) then
      gui.add({ type = "checkbox", name = "button1", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank1", state = false, style = "bob_inserter_blank" })
    end
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button2", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank2", state = false, style = "bob_inserter_blank" })
    end
    if long or islong then
      gui.add({ type = "checkbox", name = "button3", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank3", state = false, style = "bob_inserter_blank" })
    end
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button4", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank4", state = false, style = "bob_inserter_blank" })
    end
    if more and (long or islong) then
      gui.add({ type = "checkbox", name = "button5", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank5", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button34", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank34", state = false, style = "bob_inserter_blank" })
    end
  end

  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button35", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank35", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button6", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank6", state = false, style = "bob_inserter_blank" })
    end
  end
  if more and (long or long2 or isshort) then
    gui.add({ type = "checkbox", name = "button7", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank7", state = false, style = "bob_inserter_blank" })
  end
  if long or long2 or isshort then
    gui.add({ type = "checkbox", name = "button8", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank8", state = false, style = "bob_inserter_blank" })
  end
  if more and (long or long2 or isshort) then
    gui.add({ type = "checkbox", name = "button9", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank9", state = false, style = "bob_inserter_blank" })
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button10", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank10", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button36", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank36", state = false, style = "bob_inserter_blank" })
    end
  end

  if long2 or islong2 then
    gui.add({ type = "checkbox", name = "button37", state = false, style = style })
  end
  if long2 or islong2 or long or islong then
    if long or islong then
      gui.add({ type = "checkbox", name = "button11", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank11", state = false, style = "bob_inserter_blank" })
    end
  end
  if long or long2 or isshort then
    gui.add({ type = "checkbox", name = "button12", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank12", state = false, style = "bob_inserter_blank" })
  end
  gui.add({ type = "checkbox", name = "middle", state = false, style = "bob_inserter_middle" })
  if long or long2 or isshort then
    gui.add({ type = "checkbox", name = "button14", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank14", state = false, style = "bob_inserter_blank" })
  end
  if long2 or islong2 or long or islong then
    if long or islong then
      gui.add({ type = "checkbox", name = "button15", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank15", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 then
    gui.add({ type = "checkbox", name = "button38", state = false, style = style })
  end

  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button39", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank39", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button16", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank16", state = false, style = "bob_inserter_blank" })
    end
  end
  if more and (long or long2 or isshort) then
    gui.add({ type = "checkbox", name = "button17", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank17", state = false, style = "bob_inserter_blank" })
  end
  if long or long2 or isshort then
    gui.add({ type = "checkbox", name = "button18", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank18", state = false, style = "bob_inserter_blank" })
  end
  if more and (long or long2 or isshort) then
    gui.add({ type = "checkbox", name = "button19", state = false, style = style })
  else
    gui.add({ type = "checkbox", name = "blank19", state = false, style = "bob_inserter_blank" })
  end
  if long2 or islong2 or long or islong then
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button20", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank20", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button40", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank40", state = false, style = "bob_inserter_blank" })
    end
  end

  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button41", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank41", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 or long or islong then
    if more and (long or islong) then
      gui.add({ type = "checkbox", name = "button21", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank21", state = false, style = "bob_inserter_blank" })
    end
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button22", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank22", state = false, style = "bob_inserter_blank" })
    end
    if long or islong then
      gui.add({ type = "checkbox", name = "button23", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank23", state = false, style = "bob_inserter_blank" })
    end
    if more2 and (long or islong) then
      gui.add({ type = "checkbox", name = "button24", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank24", state = false, style = "bob_inserter_blank" })
    end
    if more and (long or islong) then
      gui.add({ type = "checkbox", name = "button25", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank25", state = false, style = "bob_inserter_blank" })
    end
  end
  if long2 or islong2 then
    if more2 then
      gui.add({ type = "checkbox", name = "button42", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank42", state = false, style = "bob_inserter_blank" })
    end
  end

  if long2 or islong2 then
    if more then
      gui.add({ type = "checkbox", name = "button43", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank43", state = false, style = "bob_inserter_blank" })
    end
    if more2 then
      gui.add({ type = "checkbox", name = "button44", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank44", state = false, style = "bob_inserter_blank" })
    end
    if more2 then
      gui.add({ type = "checkbox", name = "button45", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank45", state = false, style = "bob_inserter_blank" })
    end
    gui.add({ type = "checkbox", name = "button46", state = false, style = style })
    if more2 then
      gui.add({ type = "checkbox", name = "button47", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank47", state = false, style = "bob_inserter_blank" })
    end
    if more2 then
      gui.add({ type = "checkbox", name = "button48", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank48", state = false, style = "bob_inserter_blank" })
    end
    if more then
      gui.add({ type = "checkbox", name = "button49", state = false, style = style })
    else
      gui.add({ type = "checkbox", name = "blank49", state = false, style = "bob_inserter_blank" })
    end
  end

  bobmods.inserters.draw_button_position_check(gui, position)
end

function bobmods.inserters.draw_button_position_check(gui, position)
  for i, new_position in ipairs(bobmods.inserters.positions) do
    local button = gui["button" .. i]
    if button then
      local state = check_position(position, new_position) == true
      if button.state ~= state then button.state = state end
    end
  end
end

function bobmods.inserters.draw_button_offset_check(gui, position)
  for i, new_position in ipairs(bobmods.inserters.offset_positions) do
    local button = gui["button" .. i]
    if button then
      local state = check_position(position, new_position) == true
      if button.state ~= state then button.state = state end
    end
  end
end

local function grid_index(positions, step)
  local rows = {}
  for i, position in ipairs(positions) do
    local x, y = math.floor(position.x / step + 0.5), math.floor(position.y / step + 0.5)
    rows[y] = rows[y] or {}
    rows[y][x] = i
  end
  return rows
end
local tile_index = grid_index(bobmods.inserters.positions, 1)
local offset_index = grid_index(bobmods.inserters.offset_positions, bobmods.inserters.offset)
local button_names = {}
for name, index in pairs(button_indices) do button_names[index] = name end

local function selected_index(position, positions, rows, step)
  local y = math.floor(position.y / step + 0.5)
  local row = rows[y]
  local i = row and row[math.floor(position.x / step + 0.5)]
  return i and check_position(position, positions[i]) and i or false
end

local function refresh_grid(gui, kind, position, selected, positions, rows, step, sync)
  if not (gui and gui.valid) then return end
  if sync then
    -- First refresh of an editor loaded from an older save: reconcile all actual states once.
    sync(gui, position)
  end
  local before, after = selected[kind], selected_index(position, positions, rows, step)
  if before and before ~= after then
    local old = gui[button_names[before]]
    if old and old.state then old.state = false end
  end
  if after then
    local new = gui[button_names[after]]
    if new and not new.state then new.state = true end
  end
  selected[kind] = after
end

function bobmods.inserters.refresh_position_checkboxes(entity, player)
  if not (entity.valid and player.valid) then return end
  local session = storage.bobmods.inserters[player.index]
  if not (session and session.entity == entity and session.gui and session.gui.valid) then return end
  local selected = session.selected_buttons
  local sync = not selected
  if sync then
    selected = {}
    session.selected_buttons = selected
  end
  local pickup = get_pickup_position(entity)
  local drop, offset = get_split_drop_position(entity)
  local positions = bobmods.inserters.positions
  local sync_tiles = sync and bobmods.inserters.draw_button_position_check or nil
  refresh_grid(session.pickup, "pickup", pickup, selected, positions, tile_index, 1, sync_tiles)
  refresh_grid(session.drop, "drop", drop, selected, positions, tile_index, 1, sync_tiles)
  refresh_grid(session.offset, "offset", offset, selected, bobmods.inserters.offset_positions, offset_index,
    bobmods.inserters.offset, sync and bobmods.inserters.draw_button_offset_check or nil)
end

bobmods.inserters.remote_interface = {
  --[[
This function will draw the inserters grid GUI as used in the GUI added by this mod in any GUI you choose. This mod will not respond to those buttons being pressed.
This function takes the following variables:
gui: The GUI element to draw this GUI inside of.
name: The name prefix for the main 3 tables.
player_index: obvious
pickup: the index in table bobmods.inserters.positions to define the pickup location.
drop: the index in table bobmods.inserters.positions to define the drop location.
offset: the index in table bobmods.inserters.offset_positions to define the offset location within the drop tile.
]]
  --
  draw_gui = function(data)
    local force = game.players[data.player_index].force
    bobmods.inserters.draw_inserter_gui_main_table(
      data.gui,
      data.name,
      bobmods.inserters.positions[data.pickup],
      bobmods.inserters.positions[data.drop],
      bobmods.inserters.offset_positions[data.offset],
      tech_unlocked(force, bobmods.inserters.long_technology),
      tech_unlocked(force, bobmods.inserters.long2_technology),
      tech_unlocked(force, bobmods.inserters.more_technology),
      tech_unlocked(force, bobmods.inserters.more2_technology),
      tech_unlocked(force, bobmods.inserters.near_technology)
    )
  end,

  --[[
This function will refresh the GUI checkboxes, designed to refresh a drawn GUI grid after you click one of it's buttons.
This function takes the following variables:
gui: the GUI table that the buttons are drawn inside of.
position: the index in table bobmods.inserters.positions to define the pickup/drop location.
]]
  --
  draw_button_position_check = function(data)
    bobmods.inserters.draw_button_position_check(data.gui, bobmods.inserters.positions[data.position])
  end,

  --[[
This function will refresh the GUI checkboxes, designed to refresh a drawn GUI grid after you click one of it's buttons.
This function takes the following variables:
gui: the GUI table that the buttons are drawn inside of.
position: the index in table bobmods.inserters.offset_positions to define the offset location.
]]
  --
  draw_button_offset_check = function(data)
    bobmods.inserters.draw_button_offset_check(data.gui, bobmods.inserters.offset_positions[data.position])
  end,

  --[[
This function will take the value position in the bobmods.inserters.positions table, and return the coordinates.
]]
  --
  get_position = function(data)
    return bobmods.inserters.positions[data.position]
  end,

  --[[
This function will take the value position in the bobmods.inserters.offset_positions table, and return the coordinates.
]]
  --
  get_offset = function(data)
    return bobmods.inserters.offset_positions[data.position]
  end,

  --[[
Pass this function the name of an inserter, and it will be ignored.
EG: remote.call("bobinserters", "blacklist_inserter", "burner-inserter") will blacklist the burner inserter.
]]
  --
  blacklist_inserter = function(data)
    bobmods.inserters.create_global_table_basic()
    storage.bobmods.inserters.blacklist[data] = true
  end,
  --[[
Pass this function a table of names of inserters, and they will be ignored.
EG: remote.call("bobinserters", "blacklist_inserters", {"burner-inserter"}) will blacklist the burner inserter.
]]
  --
  blacklist_inserters = function(data)
    bobmods.inserters.create_global_table_basic()
    for i, inserter in pairs(data) do
      storage.bobmods.inserters.blacklist[inserter] = true
    end
  end,
  --[[
Pass this function a table of names of inserters to remove them from the blacklist.
]]
  --
  unblacklist_inserters = function(data)
    bobmods.inserters.create_global_table_basic()
    for i, inserter in pairs(data) do
      storage.bobmods.inserters.blacklist[inserter] = nil
    end
  end,
  --[[
Returns the ID number of the custom event
Triggered event returns the following table: {entity = entity, new_positions = {drop_position = {x,y}, pickup_position = {x,y}}, original_positions = {drop_position = {x,y}, pickup_position = {x,y}}}
]]
  --
  get_changed_position_event_id = function()
    return changed_position_event
  end,
}
remote.add_interface("bobinserters", bobmods.inserters.remote_interface)
