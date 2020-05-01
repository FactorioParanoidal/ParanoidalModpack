--[[
  Wires can be placed in the following ways:

  1) player clicks with a green-wire or red-wire
  2) construction robot revives a ghost
  3) a mod script (e.g. Nanobots) revives a ghost
  4) a player clicks with a blueprint over an existing entity

  Relevant events:
  on_selected_entity_changed: before 1
  on_player_cursor_stack_changed: after 1
  on_robot_built_entity: 2
  on_built_entity: 3
  on_put_item: 4
  on_tick: after 4
]]

local M = {}

local blueprint = require "lualib.blueprint"
local event = require "lualib.event"
local util = require "lualib.util"

M.on_wire_added = script.generate_event_name()
M.on_wire_removed = script.generate_event_name()

-- how often to poll circuit network connections when the player is holding wire over an entity
local POLL_INTERVAL = 15

local monitored_players

--[[
  CCD === CircuitConnectionDefinition

  selected_ccd_set_for[player_index] = {
    [ccd_key] = {
      wire = ...,
      target_entity = ...,
      source_circuit_id = ...,
      target_circuit_id = ...
    },
    ...
  }
]]
local selected_ccd_set_for

local function ccd_key(ccd)
  --do return ccd.wire.."-"..ccd.source_circuit_id.."-"..ccd.target_circuit_id.."-"..ccd.target_entity.unit_number end
  return (ccd.wire - 2)
    + (ccd.source_circuit_id - 1) * 2
    + (ccd.target_circuit_id - 1) * 4
    + ccd.target_entity.unit_number * 8
end

local function ccd_set(entity)
  local ccds = entity.circuit_connection_definitions
  if not ccds then
    return {}
  end

  local out = {}
  for i=1,#ccds do
    out[ccd_key(ccds[i])] = ccds[i]
  end
  return out
end

local function diff_sets(old, new)
  local removed = {}
  for old_key, ccd in pairs(old) do
    if not new[old_key] then
      removed[#removed+1] = ccd
    end
  end

  local added = {}
  for new_key, ccd in pairs(new) do
    if not old[new_key] then
      added[#added+1] = ccd
    end
  end
  return removed, added
end

local function raise_on_wire_added(entity, ccd)
  local ev = {
    entity = entity,
    wire = ccd.wire,
    target_entity = ccd.target_entity,
    source_circuit_id = ccd.source_circuit_id,
    target_circuit_id = ccd.target_circuit_id,
  }
  script.raise_event(M.on_wire_added, ev)
end

local function raise_on_wire_removed(entity, ccd)
  local ev = {
    entity = entity,
    wire = ccd.wire,
    target_entity = ccd.target_entity,
    source_circuit_id = ccd.source_circuit_id,
    target_circuit_id = ccd.target_circuit_id,
  }
  script.raise_event(M.on_wire_removed, ev)
end

local function check_for_circuit_changes(entity, old, new)
  if not old or not new then
    return
  end

  local removed, added = diff_sets(old, new)
  for _, ccd in ipairs(removed) do
    raise_on_wire_removed(entity, ccd)
  end
  for _, ccd in ipairs(added) do
    raise_on_wire_added(entity, ccd)
  end
end

local function check_selection_for_player(player_index)
  local selected = game.players[player_index].selected
  if selected and selected.valid then
    local new = ccd_set(selected)
    check_for_circuit_changes(selected, selected_ccd_set_for[player_index], new)
    selected_ccd_set_for[player_index] = new
  end
end

local function check_selection_for_all(ev)
  if ev.tick % POLL_INTERVAL ~= 0 then
    return
  end

  -- check only players who we believe to have a selected entity
  for player_index in pairs(selected_ccd_set_for) do
    check_selection_for_player(player_index)
  end
end

local function start_monitoring_selected_entity(player_index)
  local selected = game.players[player_index].selected
  if selected then
    selected_ccd_set_for[player_index] = ccd_set(selected)
    event.register(defines.events.on_tick, check_selection_for_all)
    return
  end
  selected_ccd_set_for[player_index] = nil
  if not next(selected_ccd_set_for) then
    event.unregister(defines.events.on_tick, check_selection_for_all)
  end
end

local function on_selected_entity_changed(ev)
  local player_index = ev.player_index
  if not monitored_players[player_index] then
    return
  end

  if ev.last_entity then
    local new = ccd_set(ev.last_entity)
    check_for_circuit_changes(ev.last_entity, selected_ccd_set_for[player_index], new)
  end

  start_monitoring_selected_entity(player_index)
end

local function stop_monitoring_player_selection(player_index)
  -- one last check since we will no longer be monitoring this player's selection
  check_selection_for_player(player_index)

  monitored_players[player_index] = nil
  if not next(monitored_players) then
    event.unregister(defines.events.on_selected_entity_changed, on_selected_entity_changed)
  end

  selected_ccd_set_for[player_index] = nil
  if not next(selected_ccd_set_for) then
    event.unregister(defines.events.on_tick, check_selection_for_all)
  end
end

local function start_monitoring_player_selection(player_index)
  monitored_players[player_index] = true
  start_monitoring_selected_entity(player_index)
  event.register(defines.events.on_selected_entity_changed, on_selected_entity_changed)
end

local function on_player_cursor_stack_changed(ev)
  local player_index = ev.player_index
  local cursor_stack = game.players[player_index].cursor_stack
  if cursor_stack.valid_for_read then
    local name = cursor_stack.name
    if name == "red-wire" or name == "green-wire" then
      if monitored_players[player_index] then
        -- already monitoring, probably placed a wire
        check_selection_for_player(player_index)
      else
        start_monitoring_player_selection(player_index)
      end
      return
    end
  end
  stop_monitoring_player_selection(player_index)
end

local function on_built_entity(ev)
  local entity = ev.created_entity
  local ccds = entity.circuit_connection_definitions or {}
  for _, ccd in ipairs(ccds) do
    raise_on_wire_added(entity, ccd)
  end
end

local function on_entity_mined(ev)
  local entity = ev.entity
  if entity.valid then
    for _, ccd in ipairs(entity.circuit_connection_definitions or {}) do
      raise_on_wire_removed(entity, ccd)
    end
  end
end

local function setup_after_blueprint_placed(preexisting_entities)
  local before_ccd_set_for = {}
  for i=1,#preexisting_entities do
    local entity = preexisting_entities[i]
    before_ccd_set_for[i] = ccd_set(entity)
  end

  local function handler(_)
    for i=1,#preexisting_entities do
      local entity = preexisting_entities[i]
      -- any of the entities may have become invalid due to other scripting
      if entity.valid then
        local new = ccd_set(entity)
        check_for_circuit_changes(entity, before_ccd_set_for[i], new)
      end
    end
    event.unregister(defines.events.on_tick, handler)
  end
  event.register(defines.events.on_tick, handler)
end

local function on_put_item(ev)
  if ev.mod_name == 'Bluebuild' then return end
  local player = game.players[ev.player_index]
  if not player.cursor_stack then
    log("on_put_item event sent from "..ev.mod_name.." while player cursor_stack is empty")
    return
  end
  if not blueprint.is_setup_bp(player.cursor_stack) then return end
  local bp = player.cursor_stack
  local bp_area = blueprint.bounding_box(bp)
  local surface_area = util.move_box(
    util.rotate_box(bp_area, ev.direction),
    ev.position
  )
  local preexisting_entities = player.surface.find_entities(surface_area)
  -- check again at the end of this tick, after blueprint has been placed
  setup_after_blueprint_placed(preexisting_entities)
end

function M.on_init()
  global.monitored_players = {}
  global.selected_ccd_set_for = {}
  M.on_load()
end

function M.on_load()
  if global.monitored_players then
    monitored_players = global.monitored_players
    if next(monitored_players) then
      event.register(defines.events.on_selected_entity_changed, on_selected_entity_changed)
    end
  end

  if global.selected_ccd_set_for then
    selected_ccd_set_for = global.selected_ccd_set_for
    if next(selected_ccd_set_for) then
      event.register(defines.events.on_tick, check_selection_for_all)
    end
  end

  event.register(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
  event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity}, on_built_entity)
  event.register(
    {defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died},
    on_entity_mined
  )
  event.register(defines.events.on_put_item, on_put_item)
end

return M