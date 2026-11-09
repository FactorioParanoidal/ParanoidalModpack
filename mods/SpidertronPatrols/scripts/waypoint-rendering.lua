local math2d = require "math2d"

---@param color Color
---@param active boolean?
---@return Color
local function add_alpha(color, active)
  if active then
    return {r = color.r, g = color.g, b = color.b, a = 0.85}
  else
    return {r = color.r, g = color.g, b = color.b, a = 0.55}
  end
end

local WaypointRendering = {}

local BLINK_LENGTH = 30

---@param event EventData.on_tick
local function on_tick(event)
  local tick = event.tick
  for _, player_renders in pairs(storage.blinking_renders) do
    for render_id, render_data in pairs(player_renders) do
      local render = render_data.render
      if render.valid then
        if render_data.toggle_tick == tick then
          render.visible = not render.visible
          player_renders[render_id].toggle_tick = tick + BLINK_LENGTH
        end
      else
        player_renders[render_id] = nil
      end
    end
  end
end

---@param spidertron LuaEntity
---@param player LuaPlayer
---@param create_chart_tags boolean?
local function create_render_paths(spidertron, player, create_chart_tags)
  local patrol_data = get_patrol_data(spidertron)

  local color = add_alpha(spidertron.color, true)
  local surface = player.surface.name
  local force = player.force  --[[@as LuaForce]]

  local waypoints = patrol_data.waypoints
  local number_of_waypoints = #waypoints

  local path_renders = {}
  local blinking_renders = storage.blinking_renders[player.index] or {}
  storage.blinking_renders[player.index] = blinking_renders
  local waypoint_index_to_blink = storage.remotes_in_cursor[player.index]
  if waypoint_index_to_blink == -1 then
    waypoint_index_to_blink = number_of_waypoints
  end

  for i, waypoint in pairs(waypoints) do
    -- First draw waypoint number like in WaypointRendering.update_render_text() in case alt-mode is not on
    local render = rendering.draw_text{
      text = tostring(i),
      surface = surface,
      target = {waypoint.position.x, waypoint.position.y},
      color = color,
      scale = 5,
      alignment = "center",
      vertical_alignment = "middle",
      players = {player},
    }
    table.insert(path_renders, render)
    if i == waypoint_index_to_blink then
      blinking_renders[render.id] = {render = render, toggle_tick = game.tick + BLINK_LENGTH}
    end

    if create_chart_tags then
      local tag = force.add_chart_tag(surface, {
        position = {waypoint.position.x, waypoint.position.y},
        text = tostring(i),
        icon = {type = "virtual", name = "signal-waypoint"}
      })
      if tag then storage.chart_tags[render.id] = {tag} end
    end

    local next_waypoint = waypoints[i + 1]
    if i == number_of_waypoints then
      if number_of_waypoints == 2 then
        -- If there are only 2 waypoints, then we don't need to draw the same line twice
        break
      end
      next_waypoint = waypoints[1]
    end

    if not next_waypoint then
      -- Log warning for very hard to repro bug: https://mods.factorio.com/mod/SpidertronPatrols/discussion/6732897d92c0d6bd25b3aad5
      waypoints[1] = nil
      game.print(serpent.block(waypoints))
      game.print("[SpidertronPatrols] Error: inconsistent waypoint array detected. Please report this on the mod portal discussion page, along with factorio-current.log, this savegame, the previous autosave, and anything that you can remember about the history of your interactions with this spidertron's waypoints.")
      log(serpent.block(waypoints))
      log("[SpidertronPatrols] Error: inconsistent waypoint array detected. Please report this on the mod portal discussion page.")
      break
    end

    local a = waypoint.position
    local b = next_waypoint.position
    local D = util.distance(a, b)
    local d = 1

    if D > d then
      -- Start and end the line a tile out from the waypoint center
      -- so that it doesn't overlap the number
      local vec = math2d.position.get_normalised(math2d.position.subtract(b, a))
      local a2 = math2d.position.add(a, math2d.position.multiply_scalar(vec, d))
      local b2 = math2d.position.subtract(b, math2d.position.multiply_scalar(vec, d))

      render = rendering.draw_line{
        color = color,
        width = 4,
        gap_length = 0.75,
        dash_length = 1.5,
        from = a2,
        to = b2,
        surface = surface,
        players = {player}
      }

      table.insert(path_renders, render)
      if i == waypoint_index_to_blink then
        blinking_renders[render.id] = {render = render, toggle_tick = game.tick + BLINK_LENGTH}
      end

      if create_chart_tags then
        -- Show patrol paths in map view using chart tags
        local tag_spacing = 20
        if D > tag_spacing * 2 then
          a2 = math2d.position.add(a, math2d.position.multiply_scalar(vec, tag_spacing))
          b2 = math2d.position.subtract(b, math2d.position.multiply_scalar(vec, tag_spacing))

          storage.chart_tags[render.id] = create_chart_tag_path(surface, force, a2, b2, tag_spacing)
        end
      end
    end
  end

  local player_renders = storage.path_renders[player.index] or {}
  player_renders[spidertron.unit_number] = path_renders
  storage.path_renders[player.index] = player_renders
end

---@param surface SurfaceIdentification
---@param force LuaForce
---@param from MapPosition
---@param to MapPosition
---@param tag_spacing number
---@return LuaCustomChartTag[]
function create_chart_tag_path(surface, force, from, to, tag_spacing)
  local vec = math2d.position.subtract(to, from)
  local dist = math2d.position.vector_length(vec)

  local steps = dist / tag_spacing
  steps = math.floor(steps + 0.5) --round to nearest int
  local step_dist = dist / steps

  local step_vec = math2d.position.multiply_scalar(math2d.position.get_normalised(vec), step_dist)

  local pos = from
  local tags = {}
  for _ = 1, steps + 1 do
    local tag = force.add_chart_tag(surface, {position = pos, icon = {type = "virtual", name = "signal-orange-dot"}})
    if tag then table.insert(tags, tag) end
    pos = math2d.position.add(pos, step_vec)
  end

  return tags
end

---@param player LuaPlayer
function WaypointRendering.update_player_render_paths(player)
  -- Clear up any previous renders
  local player_renders = storage.path_renders[player.index]
  if player_renders then
    -- There are render ids to cleanup
    for _, path_renders in pairs(player_renders) do
      for _, render in pairs(path_renders) do
        local render_id = render.id
        render.destroy()
        if storage.chart_tags[render_id] then
          for _, tag in pairs(storage.chart_tags[render_id]) do
            if tag and tag.valid then tag.destroy() end
          end
          storage.chart_tags[render_id] = nil
        end
      end
    end
    storage.path_renders[player.index] = nil
  end

  -- Create new path renders if necessary
  local rendered_spidertrons = {}  -- Ensure that we don't render the same spidertron's path twice if it falls into multiple of the following categories
  local cursor_stack = player.cursor_stack
  local spidertron_remote_selection = player.spidertron_remote_selection
  if cursor_stack and cursor_stack.valid_for_read
      and (cursor_stack.name == "sp-spidertron-patrol-remote")
      and spidertron_remote_selection then
    for _, spidertron in pairs(spidertron_remote_selection) do
      create_render_paths(spidertron, player, true)
      rendered_spidertrons[spidertron.unit_number] = true
    end
  end
  local vehicle = player.vehicle
  if vehicle and vehicle.type == "spider-vehicle" and not rendered_spidertrons[vehicle.unit_number] then
    create_render_paths(vehicle, player, false)
    rendered_spidertrons[vehicle.unit_number] = true
  end
  local opened = player.opened  --[[@as LuaEntity]]
  if opened and player.opened_gui_type == defines.gui_type.entity and opened.type == "spider-vehicle" and not rendered_spidertrons[opened.unit_number] then
    create_render_paths(opened, player, false)
    rendered_spidertrons[opened.unit_number] = true
  end
  local selected = player.selected
  if selected and selected.type == "spider-vehicle" and not rendered_spidertrons[selected.unit_number] then
    create_render_paths(selected, player, false)
  end
end

---@param event EventData.on_player_cursor_stack_changed | EventData.on_player_driving_changed_state | EventData.on_selected_entity_changed
local function need_to_update_player_render_paths(event)
  local player = game.get_player(event.player_index)  ---@cast player -?

  if event.name == defines.events.on_player_cursor_stack_changed then
    local remote = player.cursor_stack
    if not remote or not remote.valid_for_read or remote.name ~= "sp-spidertron-patrol-remote" then
      storage.remotes_in_cursor[player.index] = nil
    end
  end
  WaypointRendering.update_player_render_paths(player)
end

---@param unit_number UnitNumber
function WaypointRendering.update_spidertron_render_paths(unit_number)
  for player_index, player_renders in pairs(storage.path_renders) do
    if player_renders[unit_number] then
      local player = game.get_player(player_index)  ---@cast player -?
      WaypointRendering.update_player_render_paths(player)
    end
  end
end

---@param spidertron LuaEntity
function WaypointRendering.update_render_text(spidertron)
  -- Updates numbered text on ground for given spidertron
  local patrol_data = get_patrol_data(spidertron)

  local viewing_players = storage.render_players
  local is_at_least_one_player = not not next(viewing_players)

  local color = add_alpha(spidertron.color)

  -- Re-render all waypoints
  for i, waypoint in pairs(patrol_data.waypoints) do
    local render = waypoint.render
    if render and render.valid and render.surface ~= spidertron.surface then
      -- If spidertron was teleported cross-surface
      render.destroy()
    end
    if render and render.valid then
      render.text = i
      render.color = color
      render.target = waypoint.position
    else
      -- We need to create the text
      render = rendering.draw_text{
        text = tostring(i),
        surface = spidertron.surface,
        target = {waypoint.position.x, waypoint.position.y},
        color = color,
        scale = 5,
        alignment = "center",
        vertical_alignment = "middle",
        only_in_alt_mode = true,
        players = viewing_players,
        forces = {spidertron.force}
      }
      render.visible = is_at_least_one_player  -- TODO test this in `draw_text` call
      waypoint.render = render
    end
  end
  WaypointRendering.update_spidertron_render_paths(spidertron.unit_number)
end


function WaypointRendering.update_render_players()
  -- Called when a player joins or changes the associated setting
  local render_players = {}
  for _, player in pairs(game.players) do
    if player.mod_settings["sp-show-waypoint-numbers-in-alt-mode"].value then
      table.insert(render_players, player)
    end
  end
  local is_at_least_one_player = not not next(render_players)

  for _, patrol_data in pairs(storage.patrol_data) do
    for _, waypoint in pairs(patrol_data.waypoints) do
      local render = waypoint.render
      if render and render.valid then
        render.players = render_players
        -- If render_players is empty then we need to hide the text: empty player list means as visible to all
        render.visible = is_at_least_one_player
      end
    end
  end

  storage.render_players = render_players
end

---@param event EventData.on_runtime_mod_setting_changed
local function on_runtime_mod_setting_changed(event)
  if event.setting_type == "runtime-per-user" then
    if event.setting == "sp-show-waypoint-numbers-in-alt-mode" then
      WaypointRendering.update_render_players()
    end
  end
end

---@param event EventData.script_raised_teleported
local function on_spidertron_teleported(event)
  -- Redraw patrol paths on new surface if teleported cross-surface (e.g. Maraxsis submarines)
  local spidertron = event.entity
  if spidertron.type ~= "spider-vehicle" then return end
  if spidertron.surface.index == event.old_surface_index then return end
  WaypointRendering.update_render_text(spidertron)
end

---@param event EventData.on_entity_color_changed
local function on_spidertron_color_changed(event)
  local spidertron = event.entity
  if spidertron.type ~= "spider-vehicle" then return end
  WaypointRendering.update_render_text(spidertron)
end

WaypointRendering.events = {
  [defines.events.on_tick] = on_tick,
  [defines.events.on_player_cursor_stack_changed] = need_to_update_player_render_paths,
  --[defines.events.on_player_configured_spider_remote] = need_to_update_player_render_paths,  TODO replace?
  [defines.events.on_player_driving_changed_state] = need_to_update_player_render_paths,
  [defines.events.on_selected_entity_changed] = need_to_update_player_render_paths,
  [defines.events.on_player_changed_surface] = need_to_update_player_render_paths,
  [defines.events.on_player_joined_game] = WaypointRendering.update_render_players,
  [defines.events.on_player_removed] = WaypointRendering.update_render_players,
  [defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
  [defines.events.on_entity_color_changed] = on_spidertron_color_changed,
}
-- Maraxsis
if prototypes.custom_event["maraxsis-on-submerged"] then
  WaypointRendering.events[prototypes.custom_event["maraxsis-on-submerged"]] = on_spidertron_teleported
else
  WaypointRendering.events[defines.events.script_raised_teleported] = on_spidertron_teleported
end

return WaypointRendering
