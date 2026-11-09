local PatrolRemote = {}

---@type table<PlayerIndex, GameTick>
local replace_this_tick = {}  -- Shouldn't desync as long as comparison is only made to current tick

---@param selected LuaEntity?
---@param position MapPosition
---@return MapPosition
local function snap_waypoint_position(selected, position)
  -- Snap position to center of dock, or center of tile
  if selected and (
    selected.name:sub(0, 19) == "sp-spidertron-dock-" or
    (selected.name == "entity-ghost" and selected.ghost_name:sub(0, 19) == "sp-spidertron-dock-")
  ) then
    return selected.position
  else
    return {x = math.floor(position.x) + 0.5, y = math.floor(position.y) + 0.5}
  end
end


---@param event EventData.on_player_used_spidertron_remote
local function on_player_used_spidertron_remote(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local spidertrons = player.spidertron_remote_selection or {}
  local single_spidertron_selected = #spidertrons == 1
  for _, spidertron in pairs(spidertrons) do
    if not is_allowed_spidertron_name[spidertron.name] then return end

    local remote = player.cursor_stack

    if remote and remote.valid_for_read and remote.name == "sp-spidertron-patrol-remote" then
      local position = snap_waypoint_position(player.selected, event.position)
      local replace_waypoint = replace_this_tick[event.player_index] == event.tick

      local waypoint_index = storage.remotes_in_cursor[player.index]
      local patrol_data = get_patrol_data(spidertron)
      local number_of_waypoints = #patrol_data.waypoints
      if single_spidertron_selected and waypoint_index and waypoint_index ~= -1 then
        waypoint_index = math.min(number_of_waypoints + 1, waypoint_index)
        if replace_waypoint then
          storage.remotes_in_cursor[player.index] = waypoint_index
        else
          storage.remotes_in_cursor[player.index] = waypoint_index + 1
        end
      else
        waypoint_index = number_of_waypoints
      end
      SpidertronControl.on_patrol_command_issued(spidertron, position, waypoint_index, replace_waypoint)
    else
      local patrol_data = get_patrol_data(spidertron)
      patrol_data.on_patrol = nil
      PatrolGui.update_gui_switch(patrol_data)
    end
  end
end

--- For Maraxsis, when clicking with remote connected to spidertron on a different surface
function on_player_right_clicked(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local spidertrons = player.spidertron_remote_selection or {}
  local all_spidertrons_on_other_surfaces = true
  for _, spidertron in pairs(spidertrons) do
    if player.surface == spidertron.surface then
      all_spidertrons_on_other_surfaces = false
      break
    end
  end
  if all_spidertrons_on_other_surfaces then
    on_player_used_spidertron_remote{
      name = defines.events.on_player_used_spidertron_remote,
      tick = event.tick,
      player_index = event.player_index,
      position = event.cursor_position,
    }
  end
end

script.on_event(prototypes.custom_input["sp-replace-previous-waypoint"],
  function(event)
    replace_this_tick[event.player_index] = event.tick
    on_player_right_clicked(event)
  end
)

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param waypoint_index WaypointIndex?
function PatrolRemote.give_remote(player, spidertron, waypoint_index)
  if not player.is_cursor_empty() then
    local cleared = player.clear_cursor()
    if not cleared then return end
  end
  local cursor = player.cursor_stack
  if not cursor then return end
  if not is_allowed_spidertron_name[spidertron.name] then return end

  cursor.set_stack("sp-spidertron-patrol-remote")
  player.spidertron_remote_selection = {spidertron}

  if waypoint_index then
    storage.remotes_in_cursor[player.index] = waypoint_index
  else
    storage.remotes_in_cursor[player.index] = -1  -- Represents last waypoint
  end
end

PatrolRemote.events = {
  [defines.events.on_player_used_spidertron_remote] = on_player_used_spidertron_remote,
  [prototypes.custom_input["sp-use-item-custom"]] = on_player_right_clicked
}

return PatrolRemote