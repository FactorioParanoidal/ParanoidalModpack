local add_vector = math2d.position.add
local subtract_vector = math2d.position.subtract
local rotate_vector = math2d.position.rotate_vector

local LINE_COLOR = { r = 0, g = 0.9, b = 0, a = 1 }
local LINE_WIDTH = 4
local HALF_WIDTH = (LINE_WIDTH / 2) / 32  -- 32 pixels per tile
local ARROW_TARGET_OFFSET = { 0, -0.75 }
local ARROW_ORIENTATED_OFFSET = { 0, -4 }

local ResultLocation = {}

---@param player LuaPlayer
function ResultLocation.clear_markers(player)
  -- Clear all old markers belonging to player
  if #game.players == 1 then
    rendering.clear("FactorySearch")
  else
    local objects = rendering.get_all_objects("FactorySearch")
    for _, object in pairs(objects) do
      if object.players[1].index == player.index then
        object.destroy()
      end
    end
  end
end

---@param player LuaPlayer
---@param surface SurfaceName
---@param selection_boxes BoundingBox[]
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
  end
end

---@param player LuaPlayer
---@param surface SurfaceName
---@param selection_box BoundingBox
function ResultLocation.draw_chart_marker(player, surface, selection_box)
  local time_to_live = player.mod_settings["fs-highlight-duration"].value * 60
  rendering.draw_rectangle{
    color = LINE_COLOR,
    width = LINE_WIDTH * 16,
    filled = false,
    left_top = selection_box.left_top,
    right_bottom = selection_box.right_bottom,
    surface = surface,
    time_to_live = time_to_live,
    players = {player},
    render_mode = "chart",
  }
end

---@param player LuaPlayer
---@param surface SurfaceName
---@param position MapPosition
function ResultLocation.draw_arrow(player, surface, position)
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
      target = {entity=character, offset=ARROW_TARGET_OFFSET},
      orientation_target = position,
      oriented_offset = ARROW_ORIENTATED_OFFSET,
      surface = surface,
      time_to_live = player.mod_settings["fs-highlight-duration"].value * 60,
      players = {player},
    }
  end
end

---@param player LuaPlayer
---@param data ResultLocationData
function ResultLocation.highlight(player, data)
  local surface_name = data.surface

  ResultLocation.clear_markers(player)

  -- In case surface was deleted
  if not game.surfaces[surface_name] then return end

  ResultLocation.draw_markers(player, surface_name, data.selection_boxes)
  ResultLocation.draw_arrow(player, surface_name, data.position)
  if helpers.compare_versions(helpers.game_version, "2.0.56") >= 0 then
    ResultLocation.draw_chart_marker(player, surface_name, data.group_selection_box)
  end
end

---@param player LuaPlayer
---@param data ResultLocationData
function ResultLocation.open(player, data)
  local surface_name = data.surface
  local position = data.position
  local zoom_level = player.mod_settings["fs-initial-zoom"].value * player.display_resolution.width / 1920

  player.set_controller{
    type = defines.controllers.remote,
    position = position,
    surface = surface_name,
  }
  player.zoom = zoom_level -- TODO zoom out when showing map tags

  local player_data = storage.players[player.index]
  local refs = player_data.refs
  if not player_data.pinned then
    player.opened = refs.frame
  end
  refs.frame.visible = true

  ResultLocation.highlight(player, data)
end

-- Move arrow to new character when jetpack is activated
local function on_character_swapped_event(data)
  local objects = rendering.get_all_objects("FactorySearch")
  for _, object in pairs(objects) do
    if object.type == "sprite" then
      local target = object.target
      if target and target.entity and target.entity.unit_number == data.old_unit_number then
        object.target = {entity=data.new_character, offset=ARROW_TARGET_OFFSET}
      end
    end
  end
end
remote.add_interface("FactorySearch", {on_character_swapped = on_character_swapped_event})

return ResultLocation