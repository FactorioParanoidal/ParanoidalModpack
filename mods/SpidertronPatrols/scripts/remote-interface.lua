local RemoteInterface = {}

local function remote_interface_assign_waypoints(spidertron, waypoints)
  for _, waypoint in pairs(waypoints) do
    SpidertronControl.on_patrol_command_issued(spidertron, waypoint.position)
  end
end

remote.add_interface("SpidertronPatrols", {
  clear_waypoints = function(unit_number) Control.clear_spidertron_waypoints(unit_number) end,
  add_waypoints = function(spidertron, waypoints) remote_interface_assign_waypoints(spidertron, waypoints) end,
  get_waypoints = function(spidertron) get_patrol_data(spidertron) end,  -- deprecated
  get_patrol_data = function(spidertron) get_patrol_data(spidertron) end,
  set_on_patrol = function(spidertron, on_patrol) PatrolGui.set_on_patrol(on_patrol, spidertron, get_patrol_data(spidertron)) end,
  give_patrol_remote = function(player, spidertron, waypoint_index)  -- waypoint_index is optional
    PatrolRemote.give_remote(player, spidertron, waypoint_index)
  end,
})

local function spidertron_replaced(event)
  -- Called in response to Spidertron Weapon Switcher or Spidertron Enhancements event
  local previous_unit_number = event.old_spidertron.unit_number
  local spidertron = event.new_spidertron
  if storage.patrol_data[previous_unit_number] then
    storage.patrol_data[spidertron.unit_number] = storage.patrol_data[previous_unit_number]
    storage.patrol_data[spidertron.unit_number].spidertron = spidertron
    storage.patrol_data[previous_unit_number] = nil
  end

  for player_index, path_render_info in pairs(storage.path_renders) do
    if path_render_info[previous_unit_number] then
      path_render_info[spidertron.unit_number] = path_render_info[previous_unit_number]
      path_render_info[previous_unit_number] = nil
    end
  end
  WaypointRendering.update_spidertron_render_paths(spidertron.unit_number)

  if storage.spidertrons_docked[previous_unit_number] then
    local dock_unit_number = storage.spidertrons_docked[previous_unit_number]
    storage.spidertrons_docked[spidertron.unit_number] = dock_unit_number
    storage.spidertrons_docked[previous_unit_number] = nil
    dock_data = storage.spidertron_docks[dock_unit_number]
    if dock_data then
      local connected_spidertron = dock_data.connected_spidertron
      if connected_spidertron then
        storage.spidertron_docks[dock_unit_number].connected_spidertron = spidertron
      end
    end
  end

  script.register_on_object_destroyed(spidertron)
end

function RemoteInterface.connect_to_remote_interfaces()
  if remote.interfaces["SpidertronWeaponSwitcher"] then
    local on_spidertron_switched = remote.call("SpidertronWeaponSwitcher", "get_events").on_spidertron_switched
    script.on_event(on_spidertron_switched, spidertron_replaced)
  end
end
RemoteInterface.on_load = RemoteInterface.connect_to_remote_interfaces

if prototypes.custom_event["on_spidertron_replaced"] then
  script.on_event("on_spidertron_replaced", spidertron_replaced)
end

-- Used to be raised by SpidertronEnhancements
if prototypes.custom_event["on_player_disconnected_spider_remote"] then
  script.on_event(prototypes.custom_event["on_player_disconnected_spider_remote"], function(event)
    ---@diagnostic disable-next-line: undefined-field
    local player = game.get_player(event.player_index)
    if player then
      WaypointRendering.update_player_render_paths(player)
    end
  end)
end

-- Milestones will ignore it if spiderling is disabled
remote.add_interface("SpidertronPatrolsMilestones", {
  milestones_preset_addons = function()
    return {
      ["Spidertron Patrols"] = {
        required_mods = {"SpidertronPatrols"},
        milestones = {
            {type="group", name="Progress"},
            {type="item",  name="sp-spiderling", quantity=1},
        }
      }
    }
  end
})

return RemoteInterface
