local add_vector = math2d.position.add
local subtract_vector = math2d.position.subtract
local rotate_vector = math2d.position.rotate_vector

local LINE_COLOR = { r = 0, g = 0.9, b = 0, a = 1 }
local LINE_WIDTH = 4
local HALF_WIDTH = (LINE_WIDTH / 2) / 32  -- 32 pixels per tile
local ARROW_TARGET_OFFSET = { 0, -0.75 }
local ARROW_ORIENTATED_OFFSET = { 0, -4 }

local ResultLocation = {}

function ResultLocation.clear_markers(player)
  -- Clear all old markers belonging to player
  if #game.players == 1 then
    rendering.clear("FactorySearch")
  else
    local ids = rendering.get_all_ids("FactorySearch")
    for _, id in pairs(ids) do
      if rendering.get_players(id)[1].index == player.index then
        rendering.destroy(id)
      end
    end
  end
end

function ResultLocation.draw_markers(player, surface, selection_boxes)
  local time_to_live = player.mod_settings["fs-highlight-duration"].value * 60
  -- Draw new markers
  for _, selection_box in pairs(selection_boxes) do
    if selection_box.orientation then
      local angle = selection_box.orientation * 360

      -- Four corners
      local left_top = selection_box.left_top
      local right_bottom = selection_box.right_bottom
      local right_top = {x = right_bottom.x, y = left_top.y}
      local left_bottom = {x = left_top.x, y = right_bottom.y}

      -- Extend the end of each line by HALF_WIDTH so that corners are still right angles despite `width`
      local lines = {
        {from = {x = left_top.x - HALF_WIDTH, y = left_top.y}, to = {x = right_top.x + HALF_WIDTH, y = right_top.y}},  -- Top
        {from = {x = left_bottom.x - HALF_WIDTH, y = left_bottom.y}, to = {x = right_bottom.x + HALF_WIDTH, y = right_bottom.y}},  -- Bottom
        {from = {x = left_top.x, y = left_top.y - HALF_WIDTH}, to = {x = left_bottom.x, y = left_bottom.y + HALF_WIDTH}},  -- Left
        {from = {x = right_top.x, y = right_top.y - HALF_WIDTH}, to = {x = right_bottom.x, y = right_bottom.y + HALF_WIDTH}},  -- Right
      }

      local center = {x = (left_top.x + right_bottom.x) / 2, y = (left_top.y + right_bottom.y) / 2}
      for _, line in pairs(lines) do
        -- Translate each point to origin, rotate, then translate back
        local rotated_from = add_vector(rotate_vector(subtract_vector(line.from, center), angle), center)
        local rotated_to = add_vector(rotate_vector(subtract_vector(line.to, center), angle), center)

        rendering.draw_line{
          color = LINE_COLOR,
          width = LINE_WIDTH,
          from = rotated_from,
          to = rotated_to,
          surface = surface,
          time_to_live = time_to_live,
          players = {player},
        }
      end
    else
      rendering.draw_rectangle{
        color = LINE_COLOR,
        width = LINE_WIDTH,
        filled = false,
        left_top = selection_box.left_top,
        right_bottom = selection_box.right_bottom,
        surface = surface,
        time_to_live = time_to_live,
        players = {player},
      }
    end
    --[[game.get_surface(surface).create_entity{
      name = "highlight-box",
      position = {0, 0},  -- Ignored by game
      bounding_box = selection_box,
      box_type = "copy",  -- Green
      render_player_index = player.index,
      time_to_live = 600,

    }]]
  end
end

function ResultLocation.draw_arrows(player, surface, position)
  local character = player.character
  if (not character) and remote.interfaces["space-exploration"] then
    character = remote.call("space-exploration", "get_player_character", { player = player })
  end
  if character and character.surface.name == surface and not (character.position.x == position.x and character.position.y == position.y) then
    -- Skip arrow if positions are identical (i.e. target is character)
    rendering.draw_sprite{
      sprite = "fs_arrow",
      x_scale = 1,
      y_scale = 1,
      target = character,
      target_offset = ARROW_TARGET_OFFSET,
      orientation_target = position,
      oriented_offset = ARROW_ORIENTATED_OFFSET,
      surface = surface,
      time_to_live = player.mod_settings["fs-highlight-duration"].value * 60,
      players = {player},
    }
  end
end

function ResultLocation.highlight(player, data)
  local surface_name = data.surface

  ResultLocation.clear_markers(player)
  ResultLocation.draw_markers(player, surface_name, data.selection_boxes)
  ResultLocation.draw_arrows(player, surface_name, data.position)
end

function ResultLocation.open(player, data)
  local surface_name = data.surface
  local position = data.position
  local zoom_level = player.mod_settings["fs-initial-zoom"].value

  -- If using factorissimo-2-notnotmelon, take the player to the outer position of the factory
  if surface_name ~= player.surface.name and surface_name:sub(1, 14) == "factory-floor-" and remote.interfaces["factorissimo"] then
    local factory
    while surface_name:sub(1, 14) == "factory-floor-" do
      factory = remote.call("factorissimo", "find_surrounding_factory", {name = surface_name}, position)
      surface_name = factory.outside_surface.name
      position = {x = factory.outside_x, y = factory.outside_y}
    end
    if factory.building then  -- May not exist if building was mined or destroyed
      data.surface = surface_name
      data.position = position
      data.selection_boxes = {[1] = factory.building.selection_box}
    end
  end
  local remote_view_used = false
  if remote.interfaces["space-exploration"] and remote.interfaces["space-exploration"]["remote_view_is_unlocked"] and
    remote.call("space-exploration", "remote_view_is_unlocked", { player = player }) then
    -- If Space Exploration's remote view is an option, then always use it
    if surface_name == "nauvis" then
      surface_name = "Nauvis"
    end
    --if remote.call("space-exploration", "get_zone_from_name", {zone_name = surface_name}) then
      remote.call("space-exploration", "remote_view_start", {player = player, zone_name = surface_name, position = position})
      if remote.call("space-exploration", "remote_view_is_active", { player = player }) then
        -- remote_view_start worked
        remote_view_used = true
        player.close_map()
        player.zoom = zoom_level
      end
    end
  if not remote_view_used then
    if surface_name == player.surface.name then
      player.zoom_to_world(position, zoom_level)
    else
      player.play_sound{path = "utility/cannot_build"}
      player.create_local_flying_text{text = {"search-gui.wrong-surface"}, create_at_cursor = true}
    end
  end

  ResultLocation.highlight(player, data)
end

-- Move arrow to new character when jetpack is activated
local function on_character_swapped_event(data)
  local ids = rendering.get_all_ids("FactorySearch")
  for _, id in pairs(ids) do
    local target = rendering.get_target(id)
    if target and target.entity and target.entity.unit_number == data.old_unit_number then
      rendering.set_target(id, data.new_character, ARROW_TARGET_OFFSET)
    end
  end
end
remote.add_interface("FactorySearch", {on_character_swapped = on_character_swapped_event})

return ResultLocation