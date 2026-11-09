SPIDERTRON_NAME = {"spe-dynamic-entity-name.spidertron-lowercase"}
SPIDERTRON_NAME_CAPITALISED = {"entity-name.spidertron"}
if script.active_mods["maraxsis"] or script.active_mods["lex-aircraft"] then
  SPIDERTRON_NAME = {"spe-dynamic-entity-name.vehicle-lowercase"}
  SPIDERTRON_NAME_CAPITALISED = {"spe-dynamic-entity-name.vehicle"}
end

---@type event_handler_lib
event_handler = require "event_handler"
util = require "util"
require "scripts.utils"
gui = require "scripts.flib-gui"

local Dock = require "scripts.dock"
local DockGui = require "scripts.dock-gui"
local PatrolGui = require "scripts.patrol-gui"
SpidertronControl = require "scripts.spidertron-control"
PatrolRemote = require "scripts.patrol-remote"
WaypointRendering = require "scripts.waypoint-rendering"


Control = {}

---@alias PlayerIndex uint
---@alias UnitNumber uint
---@alias GameTick uint
---@alias LuaRenderID uint

---@alias WaypointType "none" | "time-passed" | "inactivity" | "full-inventory" | "empty-inventory" | "robots-inactive" | "passenger-present" | "passenger-not-present" | "item-count" | "circuit-condition"
---@alias WaypointIndex uint

---@class Waypoint
---@field type WaypointType
---@field position MapPosition
---@field wait_time uint? In seconds. Only if type is "time-passed" or "inactivity".
---@field item_condition_info {elem: ItemIDAndQualityIDPair?, count: integer, condition: integer}? Only if type is "item-count". If `elem` is nil, all items are considered for condition.
---@field circuit_condition_info {elem: SignalID?, count: integer, condition: integer}? Only if type is "circuit-condition". If `elem` is nil, all signals are considered for condition.
---@field render LuaRenderObject

---@class AtWaypointData
---@field tick_arrived GameTick
---@field tick_inactive GameTick? Only if type is "inactivity".
---@field previous_inventories {trunk: table, ammo: table}? Only if type is "inactivity".
---@field stopped boolean? Default: false. Set to true in on_tick when the spidertron has stopped over the waypoint position.
---@field last_distance number? Used in conjunction with `stopped`.

---@class OnPatrolData
---@field at_waypoint AtWaypointData? If exists, then spidertron is at waypoint.

---@class PatrolData
---@field spidertron LuaEntity
---@field waypoints table<WaypointIndex, Waypoint>
---@field current_index WaypointIndex? Waypoint spidertron is at or travelling to. No inherent correlation to `on_patrol` as we can be in automatic mode with no waypoints, or in manual but with a saved `current_index`.
---@field on_patrol OnPatrolData? If exists, then spidertron is in automatic mode.
---@field hide_gui boolean

---@param spidertron LuaEntity
---@return PatrolData
function get_patrol_data(spidertron)
  local patrol_data = storage.patrol_data[spidertron.unit_number]
  if not patrol_data then
    local player = spidertron.last_user
    local hide_gui = false
    if player then
      hide_gui = not player.mod_settings["sp-show-schedule-pane-by-default"].value
    end
    storage.patrol_data[spidertron.unit_number] = {
      spidertron = spidertron,
      waypoints = {},
      hide_gui = hide_gui,
    }
    patrol_data = storage.patrol_data[spidertron.unit_number]
  end
  return patrol_data
end

RemoteInterface = require "scripts.remote-interface"

local spidertron_names = prototypes.get_entity_filtered{{filter = "type", type = "spider-vehicle"}}
allowed_spidertron_names_array = {}
is_allowed_spidertron_name = {}
for name, _ in pairs(spidertron_names) do
  -- Prevent remote working on constructrons, docked spidertrons from Space Spidertron
  if name ~= "constructron" and name ~= "deconstructron" and name:sub(1, 10) ~= "ss-docked-" then
    table.insert(allowed_spidertron_names_array, name)
    is_allowed_spidertron_name[name] = true
  end
end

---@param spidertron_id LuaEntity | UnitNumber
function Control.clear_spidertron_waypoints(spidertron_id)
  -- Called on custom-input or whenever the current autopilot_destination is removed or when the spidertron is removed.
  -- Pass in either `spidertron` or `unit_number`
  local patrol_data
  ---@type UnitNumber
  local unit_number
  local hide_gui
  if type(spidertron_id) == "number" then
    ---@cast spidertron_id UnitNumber
    patrol_data = storage.patrol_data[spidertron_id]
    if not patrol_data then return end
    unit_number = spidertron_id
  else
    ---@cast spidertron_id LuaEntity
    patrol_data = get_patrol_data(spidertron_id)
    spidertron_id.autopilot_destination = nil
    unit_number = spidertron_id.unit_number  ---@cast unit_number -?
    hide_gui = patrol_data.hide_gui
  end
  log("Clearing spidertron waypoints for unit number " .. unit_number)
  for _, waypoint in pairs(patrol_data.waypoints) do
    if waypoint.render then
      waypoint.render.destroy()
    end
  end
  patrol_data.waypoints = {}
  PatrolGui.update_gui_schedule(patrol_data)
  WaypointRendering.update_spidertron_render_paths(unit_number)

  storage.patrol_data[unit_number] = nil
  if hide_gui then
    -- Spidertron isn't destroyed, so keep hide_gui
    ---@cast spidertron_id LuaEntity
    local new_waypoint_info = get_patrol_data(spidertron_id)
    new_waypoint_info.hide_gui = hide_gui
  end
end

script.on_event(prototypes.custom_input["sp-delete-all-waypoints"],
  function(event)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "sp-spidertron-patrol-remote" then
      local spidertron_remote_selection = player.spidertron_remote_selection
      if spidertron_remote_selection then
        for _, spidertron in pairs(spidertron_remote_selection) do
          Control.clear_spidertron_waypoints(spidertron)
          spidertron.autopilot_destination = nil
        end
      end
    end
  end
)

-- Detect when the player cancels a spidertron's autopilot_destination
script.on_event({"move-right-custom", --[["move-left-custom",]] "move-up-custom", "move-down-custom"},
  ---@param event EventData.CustomInputEvent
  function(event)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local vehicle = player.vehicle
    if vehicle and vehicle.type == "spider-vehicle" and player.render_mode == defines.render_mode.game then  -- Render mode means player isn't in map view...
      local patrol_data = get_patrol_data(vehicle)
      patrol_data.on_patrol = nil
      PatrolGui.update_gui_switch(patrol_data)
    end
  end
)

---@param event EventData.on_object_destroyed
local function on_object_destroyed(event)
  if event.type ~= defines.target_type.entity then return end
  local unit_number = event.useful_id
  Control.clear_spidertron_waypoints(unit_number)
end


local function process_active_mods()
  local version_string = script.active_mods["base"]
  local version_strings = util.split(version_string, ".")
  local version = {}  ---@type uint[]
  for i=1, #version_strings do
    version[i] = tonumber(version_strings[i])
  end
  storage.base_version = version
end

local function setup()
  process_active_mods()
  ---@type table<UnitNumber, PatrolData>
  storage.patrol_data = {}
  ---@type table<PlayerIndex, table<UnitNumber, table<WaypointIndex, LuaRenderObject>>>
  storage.path_renders = {}
  ---@type table<LuaRenderID, LuaCustomChartTag[]>
  storage.chart_tags = {}
  ---@type table<PlayerIndex, WaypointIndex>
  storage.remotes_in_cursor = {}
  ---@type table<PlayerIndex, table<LuaRenderID, {render: LuaRenderObject, toggle_tick: GameTick}>>
  storage.blinking_renders = {}

  ---@type table<UnitNumber, DockData>
  storage.spidertron_docks = {}
  ---@type table<UnitNumber, UnitNumber>
  storage.spidertrons_docked = {}
  ---@type table<GameTick, UnitNumber[]>
  storage.scheduled_docks_opening = {}

  ---@type table<PlayerIndex, GuiElements>
  storage.open_gui_elements = {}
  ---@type table<PlayerIndex, {button: LuaGuiElement, tick_started: GameTick}>
  storage.player_highlights = {}  -- Indexed by player.index

  RemoteInterface.connect_to_remote_interfaces()
  WaypointRendering.update_render_players()
  --settings_changed()
end

local function config_changed_setup(changed_data)
  process_active_mods()
  -- Only run when this mod was present in the previous save as well. Otherwise, on_init will run.
  local mod_changes = changed_data.mod_changes
  local old_version_string
  if mod_changes and mod_changes["SpidertronPatrols"] and mod_changes["SpidertronPatrols"]["old_version"] then
    old_version_string = mod_changes["SpidertronPatrols"]["old_version"]
  else
    return
  end

  -- Close all spidertron GUIs
  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity then
      local entity = player.opened  --[[@as LuaEntity]]
      if entity and entity.object_name == "LuaEntity" and entity.type == "spider-vehicle" then
        player.opened = nil
      end
    end
  end

  storage.wait_time_defaults = nil

  log("Coming from old version: " .. old_version_string)
  local version_strings = util.split(old_version_string, ".")
  local old_version = {}
  for i=1, #version_strings do
    old_version[i] = tonumber(version_strings[i])
  end

  if old_version[1] == 2 then
    if old_version[2] < 1 then
      -- Pre 2.1
      storage.path_renders = {}
      storage.player_highlights = {}
    end
    if old_version[2] < 3 or (old_version[2] == 3 and old_version[3] < 2) then
      -- Pre 2.3.2
      storage.chart_tags = {}
    end
    if old_version[2] < 4 then
      -- Pre 2.4
      storage.remotes_in_cursor = {}
      storage.blinking_renders = {}
    end
    if old_version[2] < 5 or (old_version[2] == 5 and old_version[3] < 9) then
      local spidertron_waypoints = storage.spidertron_waypoints
      storage.patrol_data = spidertron_waypoints
      storage.spidertron_waypoints = nil

      for _, patrol_data in pairs(storage.patrol_data) do
        if not next(patrol_data.waypoints) then
          patrol_data.current_index = nil
        end
        if patrol_data.on_patrol == false then
          patrol_data.on_patrol = nil
        else
          patrol_data.on_patrol = {}
          if patrol_data.tick_arrived then
            patrol_data.on_patrol.at_waypoint = {
              tick_arrived = patrol_data.tick_arrived,
              tick_inactive = patrol_data.tick_inactive,
              previous_inventories = patrol_data.previous_inventories,
              stopped = patrol_data.stopped,
              last_distance = patrol_data.last_distance,
            }
            patrol_data.tick_arrived = nil  ---@diagnostic disable-line: inject-field
            patrol_data.tick_inactive = nil  ---@diagnostic disable-line: inject-field
            patrol_data.previous_inventories = nil  ---@diagnostic disable-line: inject-field
            patrol_data.stopped = nil  ---@diagnostic disable-line: inject-field
            patrol_data.last_distance = nil  ---@diagnostic disable-line: inject-field
          end
        end
      end
    end
    if old_version[2] < 5 then
      -- Pre 2.5. Has to go at end so that globals can be initialized first.
      reset_render_objects()
    end
    if old_version[2] < 5 or (old_version[2] == 5 and old_version[3] < 8) then
      -- Pre 2.5.8
      reset_render_objects()
    end
    if old_version[2] < 5 or (old_version[2] == 5 and old_version[3] < 11) then
      -- Pre 2.5.11
      storage.spidertrons_docked = {}
      storage.scheduled_dock_replacements = nil
      storage.spidertron_docks = {}
      storage.scheduled_docks_opening = {}
      if settings.startup["sp-enable-dock"].value then
        for _, surface in pairs(game.surfaces) do
          for _, entity in pairs(surface.find_entities_filtered{name="sp-spidertron-dock"}) do
            ---@diagnostic disable-next-line: missing-fields
            Dock.events[defines.events.on_built_entity]({entity = entity})
          end
        end
      end
    end
    if old_version[2] < 5 or (old_version[2] == 5 and old_version[3] < 12) then
      -- Pre 2.5.12
      storage.from_k = nil
    end
    if old_version[2] < 6 then
      -- Pre 2.6
      for _, dock_data in pairs(storage.spidertron_docks) do
        local dock = dock_data.dock
        if dock.valid then
          dock.proxy_target_inventory = defines.inventory.spider_trunk
        end
      end
      local current_tick = game.tick
      for tick, _ in pairs(storage.scheduled_docks_opening) do
        if tick < current_tick then
          storage.scheduled_docks_opening[tick] = nil
        end
      end
    end
  end
end

Control.on_init = setup
Control.on_configuration_changed = config_changed_setup
Control.events = {
  [defines.events.on_object_destroyed] = on_object_destroyed,
}

function reset_render_objects()
  rendering.clear("SpidertronPatrols")
  storage.path_renders = {}
  storage.blinking_renders = {}
  WaypointRendering.update_render_players()
  for _, patrol_data in pairs(storage.patrol_data) do
    local spidertron = patrol_data.spidertron
    if spidertron and spidertron.valid then
      WaypointRendering.update_render_text(patrol_data.spidertron)
    end
  end
  for _, player in pairs(game.players) do
    WaypointRendering.update_player_render_paths(player)
  end
end

commands.add_command("reset-sp-render-objects",
  "Clears all render objects (numbers and lines on the ground) created by Spidertron Patrols and recreates only the objects that are supposed to exist. Use whenever render objects are behaving unexpectedly or have been permanently left behind due to a mod bug or incompatibility.",
  function()
    reset_render_objects()
    game.print("Render objects reset")
  end
)

event_handler.add_libraries{
  gui --[[@as event_handler]],
  Control,
  RemoteInterface,
  Dock,
  DockGui,
  PatrolGui,
  PatrolRemote,
  SpidertronControl,
  WaypointRendering
}
