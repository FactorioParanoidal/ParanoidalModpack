-- Handles on_player_used_spidertron_remote, on_spider_command_completed, and wait conditions

local SpidertronControl = {}

---@param condition uint
---@param a integer
---@param b integer
---@return boolean?
local function check_condition(condition, a, b)
  -- Using list order: {">", "<", "=", "≥", "≤", "≠"}
  if condition == 1 then
    return a > b
  elseif condition == 2 then
    return a < b
  elseif condition == 3 then
    return a == b
  elseif condition == 4 then
    return a >= b
  elseif condition == 5 then
    return a <= b
  elseif condition == 6 then
    return a ~= b
  end
end

---@param spidertron LuaEntity
---@param position MapPosition
---@param index WaypointIndex?
---@param replace boolean?
function SpidertronControl.on_patrol_command_issued(spidertron, position, index, replace)
  -- Called when remote used and on remote interface call
  local patrol_data = get_patrol_data(spidertron)
  --log("Player used patrol remote on position " .. util.positiontostr(position))

  -- Add to patrol
  if not index then index = #patrol_data.waypoints end
  if replace and next(patrol_data.waypoints) then
    local waypoint = patrol_data.waypoints[index]
    waypoint.position = position
    patrol_data.waypoints[index] = waypoint
  else
    local waypoint = {position = position, type = "none"}
    table.insert(patrol_data.waypoints, index + 1, waypoint)
  end

  -- Since #waypoints >= 1, current_index should be set
  patrol_data.current_index = patrol_data.current_index or 1

  if patrol_data.on_patrol then
    -- Using remote will have set autopilot to the wrong place. Send the spidertron to current_index waypoint instead
    local waypoints = patrol_data.waypoints
    spidertron.autopilot_destination = waypoints[patrol_data.current_index].position
  else
    spidertron.autopilot_destination = nil
  end
  PatrolGui.update_gui_schedule(patrol_data)
  WaypointRendering.update_render_text(spidertron)  -- Inserts text at the position that we have just added
end


---------------------------------------------------------------------------------------------------

---@param spidertron LuaEntity
---@param old_inventories unknown
---@return boolean
local function was_spidertron_inactive(spidertron, old_inventories)
  local old_trunk = old_inventories.trunk
  local old_ammo = old_inventories.ammo
  local new_trunk = spidertron.get_inventory(defines.inventory.spider_trunk).get_contents()
  local new_ammo = spidertron.get_inventory(defines.inventory.spider_ammo).get_contents()

  if not old_trunk or not old_ammo or not table_equals(old_trunk, new_trunk) or not table_equals(old_ammo, new_ammo) then
    old_inventories.trunk = table.deepcopy(new_trunk)
    old_inventories.ammo = table.deepcopy(new_ammo)
    return false
  end
  return true
end

--- Spidertron must be on patrol, and there must be at least one waypoint
---@param spidertron LuaEntity
---@param next_index WaypointIndex?
function SpidertronControl.go_to_next_waypoint(spidertron, next_index)
  local patrol_data = get_patrol_data(spidertron)

  local number_of_waypoints = #patrol_data.waypoints
  if number_of_waypoints > 0 then
    patrol_data.on_patrol.at_waypoint = nil  -- Clear data only relevant when at waypoint

    next_index = next_index or ((patrol_data.current_index) % number_of_waypoints) + 1
    local next_position = patrol_data.waypoints[next_index].position
    spidertron.autopilot_destination = next_position
    patrol_data.current_index = next_index

    PatrolGui.update_gui_button_states(patrol_data)
    -- The spidertron is now walking towards a new waypoint
    script.raise_event("on_spidertron_given_new_destination", {vehicle = spidertron, position = next_position, success = true})
  end
end

function on_tick()
  -- Handles spider stopping
  for _, patrol_data in pairs(storage.patrol_data) do
    local on_patrol_data = patrol_data.on_patrol
    if on_patrol_data and on_patrol_data.at_waypoint and on_patrol_data.at_waypoint.tick_arrived and not on_patrol_data.at_waypoint.stopped and patrol_data.spidertron.valid then
      local spidertron = patrol_data.spidertron
      local waypoint = patrol_data.waypoints[patrol_data.current_index]
      local waypoint_position = waypoint.position

      local distance = util.distance(spidertron.position, waypoint_position)
      local speed = spidertron.speed

      if speed < 0.005 then
        -- Spidertron has stopped
        if distance > 2 then
          -- Spidertron is too far away
          spidertron.teleport(waypoint_position)
        end
        on_patrol_data.at_waypoint.stopped = true
      else
        local last_distance = on_patrol_data.at_waypoint.last_distance
        if distance < 0.3 or (last_distance and distance > last_distance) or speed > 0.4 then
          -- We are either very close, getting further away, or going so fast that we need to stop ASAP
          spidertron.stop_spider()
          on_patrol_data.at_waypoint.last_distance = nil
        else
          on_patrol_data.at_waypoint.last_distance = distance
        end
      end
    end
  end
end

local function handle_wait_timers()
  for _, patrol_data in pairs(storage.patrol_data) do
    if patrol_data.on_patrol and patrol_data.on_patrol.at_waypoint and patrol_data.spidertron.valid then
      -- Spidertron is waiting
      local spidertron = patrol_data.spidertron
      local waypoint = patrol_data.waypoints[patrol_data.current_index]
      local waypoint_type = waypoint.type

      local at_waypoint_data = patrol_data.on_patrol.at_waypoint  ---@cast at_waypoint_data -?

      if waypoint_type == "none" then
        -- Can happen if waypoint type is changed whilst spidertron is at waypoint
        SpidertronControl.go_to_next_waypoint(spidertron)
      elseif waypoint_type == "time-passed" or waypoint_type == "submerge" then
        if (game.tick - at_waypoint_data.tick_arrived) >= waypoint.wait_time * 60 then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "inactivity" then
        at_waypoint_data.previous_inventories = at_waypoint_data.previous_inventories or {}
        if was_spidertron_inactive(spidertron, at_waypoint_data.previous_inventories) then
          if (game.tick - at_waypoint_data.tick_inactive) >= waypoint.wait_time * 60 then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          at_waypoint_data.tick_inactive = game.tick
        end
      elseif waypoint_type == "full-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_full() then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "empty-inventory" then
        if spidertron.get_inventory(defines.inventory.spider_trunk).is_empty() then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "empty-trash" then
        local trash_inventory = spidertron.get_inventory(defines.inventory.spider_trash)
        if trash_inventory then
          if trash_inventory.is_empty() then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          -- Spidertron prototype no longer has a trash inventory, so reset its waypoint type
          waypoint.type = "none"
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "item-count" then
        local inventory = spidertron.get_inventory(defines.inventory.spider_trunk)  ---@cast inventory -?
        local item_condition_info = waypoint.item_condition_info  ---@cast item_condition_info -?
        local item_count = inventory.get_item_count(item_condition_info.elem) or 0
        if check_condition(item_condition_info.condition, item_count, item_condition_info.count) then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "fuel-full" then
        local fuel_inventory = spidertron.get_fuel_inventory()
        if fuel_inventory then
          if fuel_inventory.is_full() then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          -- Spidertron prototype no longer allows fuel, so reset its waypoint type
          waypoint.type = "none"
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "circuit-condition" then
        local circuit_condition_info = waypoint.circuit_condition_info  ---@cast circuit_condition_info -?
        local dock_unit_number = storage.spidertrons_docked[spidertron.unit_number]
        if dock_unit_number then
          local dock_data = storage.spidertron_docks[dock_unit_number]
          local dock = dock_data and dock_data.dock
          if dock and dock.valid then
            local signal_count = 0
            if circuit_condition_info.elem and circuit_condition_info.elem.name then
              signal_count = dock.get_signal(circuit_condition_info.elem, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
            else
              local signals = dock.get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
              for _, signal in pairs(signals or {}) do
                signal_count = signal_count + signal.count
              end
            end
            if check_condition(circuit_condition_info.condition, signal_count, circuit_condition_info.count) then
              SpidertronControl.go_to_next_waypoint(spidertron)
            end
          end
        end
      elseif waypoint_type == "robots-inactive" then
        local logistic_cell = spidertron.logistic_cell
        if logistic_cell then
          local logistic_network = logistic_cell.logistic_network
          -- Always wait some time in case "Enable logistics while moving" is false
          if (game.tick - at_waypoint_data.tick_arrived) >= 120 and (not logistic_network or not next(logistic_network.construction_robots)) then
            SpidertronControl.go_to_next_waypoint(spidertron)
          end
        else
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "passenger-present" then
        if spidertron.get_driver() or spidertron.get_passenger() then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      elseif waypoint_type == "passenger-not-present" then
        if not (spidertron.get_driver() or spidertron.get_passenger()) then
          SpidertronControl.go_to_next_waypoint(spidertron)
        end
      end
    end
  end
end
script.on_nth_tick(5, handle_wait_timers)

---@param event EventData.on_spider_command_completed
local function on_spider_command_completed(event)
  local spidertron = event.vehicle
  local patrol_data = get_patrol_data(spidertron)
  if patrol_data.on_patrol then
    if not patrol_data.current_index then
      -- Command was not issued by Spidertron Patrols, so disable patrol mode
      PatrolGui.set_on_patrol(false, spidertron, patrol_data)
      return
    end
    local waypoints = patrol_data.waypoints
    local waypoint = waypoints[patrol_data.current_index]
    local waypoint_type = waypoint.type

    script.raise_event("on_spidertron_patrol_waypoint_reached", {
      spidertron = spidertron,
      waypoint = waypoint,
    })

    if waypoint_type == "none" or ((waypoint_type == "time-passed" or waypoint_type == "inactivity") and waypoint.wait_time == 0) then
      SpidertronControl.go_to_next_waypoint(spidertron)
    else
      patrol_data.on_patrol.at_waypoint = {
        tick_arrived = game.tick,
      }
      PatrolGui.update_gui_button_states(patrol_data)
    end
  end
end

---@param event EventData.on_entity_settings_pasted
local function on_entity_settings_pasted(event)
  local source = event.source
  local destination = event.destination
  if source.type == "spider-vehicle" and destination.type == "spider-vehicle" then

    -- Erase render ids from receiving spidertron
    local destination_waypoint_info = get_patrol_data(destination)
    for _, waypoint in pairs(destination_waypoint_info.waypoints) do
      waypoint.render.destroy()
    end

    local patrol_data = util.table.deepcopy(get_patrol_data(source))
    patrol_data.spidertron = destination
    patrol_data.on_patrol = table.deepcopy(destination_waypoint_info.on_patrol)
    if patrol_data.on_patrol then
      patrol_data.on_patrol.at_waypoint = nil
    end

    -- Erase all render objects so that new ones can be recreated by WaypointRendering.update_render_text
    for _, waypoint in pairs(patrol_data.waypoints) do
      waypoint.render = nil
    end

    storage.patrol_data[destination.unit_number] = patrol_data
    PatrolGui.update_gui_schedule(patrol_data)
    WaypointRendering.update_render_text(destination)  -- Inserts text at the position that we have just added
  end
end

---@param event EventData.on_player_setup_blueprint
local function on_player_setup_blueprint(event)
  local player = game.get_player(event.player_index)  ---@cast player -?

  ---@type LuaItemStack | LuaRecord
  local blueprint = event.stack
  if not blueprint then
    blueprint = event.record  -- Blueprint in library is being reassigned
  end
  if not blueprint then
    player.print("[Spidertron Patrols] No blueprint item found when setting up blueprint. Please report this.")
    return
  end
  local count = blueprint.get_blueprint_entity_count()
  if count == 0 then return end

  for index, entity in pairs(event.mapping.get() --[[@as table<UnitNumber, LuaEntity>]]) do
    if entity.valid and entity.type == "spider-vehicle" then
      local patrol_data = storage.patrol_data[entity.unit_number]
      if patrol_data then
        if index <= count then
          local waypoints = table.deepcopy(patrol_data.waypoints)
          for _, waypoint in pairs(waypoints) do
            waypoint.render = nil
          end
          local waypoint_tags = {
            waypoints = waypoints,
            hide_gui = patrol_data.hide_gui
          }
          --log(serpent.line(waypoint_tags))
          blueprint.set_blueprint_entity_tag(index, "spidertron_patrol_data", waypoint_tags)
        end
      end
    end
  end
end

local function on_spidertron_revived(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.type ~= "spider-vehicle" then return end

  local tags = event.tags
  if not tags then return end
  local spidertron_patrol_data = tags.spidertron_patrol_data
  if not spidertron_patrol_data then return end

  local patrol_data = get_patrol_data(entity)
  patrol_data.waypoints = spidertron_patrol_data.waypoints
  if #patrol_data.waypoints >= 1 then
    patrol_data.current_index = 1
  end
  patrol_data.hide_gui = spidertron_patrol_data.hide_gui
  WaypointRendering.update_render_text(entity)
end

SpidertronControl.events = {
  [defines.events.on_tick] = on_tick,
  [defines.events.on_spider_command_completed] = on_spider_command_completed,
  [defines.events.on_entity_settings_pasted] = on_entity_settings_pasted,
  [defines.events.on_player_setup_blueprint] = on_player_setup_blueprint,
  [defines.events.on_built_entity] = on_spidertron_revived,
  [defines.events.on_robot_built_entity] = on_spidertron_revived,
  [defines.events.script_raised_revive] = on_spidertron_revived,
}

return SpidertronControl