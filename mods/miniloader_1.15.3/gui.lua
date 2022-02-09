local circuit = require "circuit"
local event = require "lualib.event"
local ontick = require "lualib.ontick"
local util = require "lualib.util"

-- how often to poll ControlBehavior settings when a miniloader-inserter GUI is open
local POLL_INTERVAL = 15

local function create_lane_swap_gui(parent, entity, is_right_side)
  local frame = parent.add{
    type = "frame",
    name = "miniloader_lane_swap",
    direction = "horizontal",
    anchor = {
      gui = defines.relative_gui_type.inserter_gui,
      position = defines.relative_gui_position.top,
    },
  }
  local inner_frame = frame.add{
    type = "frame",
    name = "content",
    style = "inside_shallow_frame_with_padding",
  }
  inner_frame.style.horizontally_stretchable = false
  local flow = inner_frame.add{
    type = "flow",
    direction = "horizontal",
  }
  flow.style.horizontal_spacing = 20
  flow.add{
    type = "label",
    caption = {"miniloader-gui.configuring-lane"},
  }
  flow.add{
    type = "switch",
    name = "miniloader_lane_switch",
    switch_state = is_right_side and "right" or "left",
    left_label_caption = {"gui-splitter.left"},
    right_label_caption = {"gui-splitter.right"},
  }
  return frame
end

local monitored_entities

local function should_monitor_entity(entity)
  return util.is_miniloader_inserter(entity)
end

local function monitor_open_guis(_)
  for k, entity in pairs(monitored_entities) do
    if entity.valid then
      circuit.sync_filters(entity)
      circuit.sync_behavior(entity)
    else
      monitored_entities[k] = nil
    end
  end
  if not next(monitored_entities) then
    ontick.unregister(monitor_open_guis)
  end
end

local opening_filter_gui = false

local function on_gui_opened(ev)
  local entity = ev.entity
  if not entity or not should_monitor_entity(entity) then
    return
  end
  monitored_entities[ev.player_index] = entity
  ontick.register(monitor_open_guis, POLL_INTERVAL)

  if util.is_output_miniloader_inserter(entity) then
    local player = game.get_player(ev.player_index)
    local relative = player.gui.relative
    local inserters = util.get_loader_inserters(entity)
    create_lane_swap_gui(relative, entity, entity == inserters[2])
  end
end

local function on_gui_closed(ev)
  local entity = ev.entity

  if not entity or not should_monitor_entity(entity) then
    return
  end

  circuit.sync_behavior(entity)
  circuit.sync_filters(entity)
  monitored_entities[ev.player_index] = nil

  local player = game.get_player(ev.player_index)
  if player.gui.relative.miniloader_lane_swap then
    player.gui.relative.miniloader_lane_swap.destroy()
  end
end

local function on_gui_switch_state_changed(ev)
  local element = ev.element
  if element.name == "miniloader_lane_switch" then
    local player = game.get_player(ev.player_index)
    local entity = player.opened
    if not util.is_output_miniloader_inserter(entity) then
      return
    end
    local inserters = util.get_loader_inserters(entity)
    player.opened = element.switch_state == "left" and inserters[1] or inserters[2]
  end
end

local M = {}

function M.on_init()
  global.gui = {
    monitored_entities = {},
  }
  M.on_load()
end

function M.on_load()
  if not global.gui then
    return -- expect on_configuration_changed
  end
  monitored_entities = global.gui.monitored_entities
  if next(monitored_entities) then
    ontick.register(monitor_open_guis, POLL_INTERVAL)
  end
  event.register(defines.events.on_gui_opened, on_gui_opened)
  event.register(defines.events.on_gui_closed, on_gui_closed)
  event.register(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)
end

function M.on_configuration_changed()
  if not global.gui then
    global.gui = {
      monitored_entities = {},
    }
  end
  M.on_load()
end

return M
