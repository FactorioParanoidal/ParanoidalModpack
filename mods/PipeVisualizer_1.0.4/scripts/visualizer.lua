local area = require("__flib__.area")
local direction = require("__flib__.direction")
local table = require("__flib__.table")
local mod_gui = require("__core__.lualib.mod-gui")

local constants = require("constants")

local visualizer = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function visualizer.create(player, player_table)
  player_table.enabled = true
  player_table.entity_objects = {}
  player_table.overlay = rendering.draw_rectangle({
    left_top = { x = 0, y = 0 },
    right_bottom = { x = 0, y = 0 },
    filled = true,
    color = { a = player.mod_settings["pv-overlay-opacity"].value },
    surface = player.surface,
    players = { player.index },
  })
  player_table.overlay_area = area.from_dimensions(
    { height = constants.max_viewable_radius * 2, width = constants.max_viewable_radius * 2 },
    player.position
  )

  visualizer.update(player, player_table)

  -- GUI
  local frame_flow = mod_gui.get_frame_flow(player)
  if frame_flow and frame_flow.valid and not frame_flow.pv_window then
    frame_flow.add({ type = "frame", name = "pv_window", style = mod_gui.frame_style, caption = { "gui.pv-mode" } }).add({
      type = "frame",
      style = "inside_shallow_frame_with_padding",
    }).add({
      type = "switch",
      name = "pv_mode_switch",
      left_label_caption = { "gui.pv-fluid" },
      right_label_caption = { "gui.pv-system" },
      left_label_tooltip = { "gui.pv-fluid-description" },
      right_label_tooltip = { "gui.pv-system-description" },
      switch_state = player_table.mode == constants.modes.fluid and "left" or "right",
    })
  end
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function visualizer.update(player, player_table)
  local player_position = {
    x = math.floor(player.position.x),
    y = math.floor(player.position.y),
  }

  -- Update overlay
  local overlay_area = area.center_on(player_table.overlay_area, player.position)
  rendering.set_left_top(player_table.overlay, overlay_area.left_top)
  rendering.set_right_bottom(player_table.overlay, overlay_area.right_bottom)

  -- Compute areas to search based on movement
  local areas = {}
  if player_table.last_position then
    local last_position = player_table.last_position
    --- @type MapPosition
    local delta = {
      x = player_position.x - last_position.x,
      y = player_position.y - last_position.y,
    }

    if delta.x < 0 then
      table.insert(areas, {
        left_top = {
          x = player_position.x - constants.max_viewable_radius,
          y = player_position.y - constants.max_viewable_radius,
        },
        right_bottom = {
          x = last_position.x - constants.max_viewable_radius,
          y = player_position.y + constants.max_viewable_radius,
        },
      })
    elseif delta.x > 0 then
      table.insert(areas, {
        left_top = {
          x = last_position.x + constants.max_viewable_radius,
          y = player_position.y - constants.max_viewable_radius,
        },
        right_bottom = {
          x = player_position.x + constants.max_viewable_radius,
          y = player_position.y + constants.max_viewable_radius,
        },
      })
    end

    if delta.y < 0 then
      table.insert(areas, {
        left_top = {
          x = player_position.x - constants.max_viewable_radius,
          y = player_position.y - constants.max_viewable_radius,
        },
        right_bottom = {
          x = player_position.x + constants.max_viewable_radius,
          y = last_position.y - constants.max_viewable_radius,
        },
      })
    elseif delta.y > 0 then
      table.insert(areas, {
        left_top = {
          x = player_position.x - constants.max_viewable_radius,
          y = last_position.y + constants.max_viewable_radius,
        },
        right_bottom = {
          x = player_position.x + constants.max_viewable_radius,
          y = player_position.y + constants.max_viewable_radius,
        },
      })
    end
  else
    table.insert(areas, overlay_area)
  end

  player_table.last_position = player_position

  -- Render connections
  for _, tile_area in pairs(areas) do
    local entities = player.surface.find_entities_filtered({
      type = constants.entity_types,
      area = tile_area,
    })
    visualizer.draw_entities(player, player_table, entities, { is_overlay = true })
  end
end

--- @class ShapeData
--- @field fluid_system_id number
--- @field entity LuaEntity

--- @class DrawEntitiesOptions
--- @field is_overlay boolean
--- @field fluid_system_ids number[]

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param entities LuaEntity[]
--- @param options DrawEntitiesOptions
function visualizer.draw_entities(player, player_table, entities, options)
  local entity_objects = player_table.entity_objects
  --- @type table<number, ShapeData>
  local shapes_to_draw = {}
  local overlay_area = player_table.overlay_area
  local fluid_colors = global.fluid_colors
  --- @type table<number, Color>
  local fluid_system_colors = player_table.fluid_system_colors
  local fluid_system_color_index = player_table.fluid_system_color_index
  --- @type table<number, number[]>
  local fluid_system_uncolored_entities = {}
  local fluid_system_ids = options.fluid_system_ids

  for _, entity in pairs(entities) do
    local fluidbox = entity.fluidbox
    local unit_number = entity.unit_number
    if fluidbox and #fluidbox > 0 and not entity_objects[unit_number] then
      --- @type number?
      local fluid_system_id = nil
      local this_entity_objects = {}
      for fluidbox_index = 1, #fluidbox do
        local this_fluid_system_id = fluidbox.get_fluid_system_id(fluidbox_index)
        if this_fluid_system_id and (not fluid_system_ids or fluid_system_ids[this_fluid_system_id]) then
          fluid_system_id = this_fluid_system_id
          -- Get the color
          local color = fluid_system_colors[fluid_system_id]
          if not color then
            if player_table.mode == constants.modes.fluid then
              --- @type Fluid|FluidBoxFilter|nil
              local fluid = fluidbox[fluidbox_index] or fluidbox.get_filter(fluidbox_index)
              if fluid then
                color = fluid_colors[fluid.name]
              end
            else
              fluid_system_color_index = fluid_system_color_index + 1
              color = constants.system_colors[fluid_system_color_index] or constants.default_color
            end
            if color then
              -- Update fluid system color
              fluid_system_colors[fluid_system_id] = color
              -- Retroactively apply colors to other entities in this fluid system
              for _, unit_number in pairs(fluid_system_uncolored_entities[fluid_system_id] or {}) do
                for _, id in pairs(entity_objects[unit_number] or {}) do
                  rendering.set_color(id, color)
                end
              end
              fluid_system_uncolored_entities[fluid_system_id] = nil
            else
              color = constants.default_color
              local uncolored_entities = table.get_or_insert(fluid_system_uncolored_entities, fluid_system_id, {})
              table.insert(uncolored_entities, unit_number)
            end
          end

          local entity_direction = entity.direction
          local entity_position = entity.position

          for _, connection in pairs(fluidbox.get_connections(fluidbox_index)) do
            local neighbour = connection.owner
            local neighbour_position = neighbour.position

            local is_southeast = neighbour_position.x > (entity_position.x + 0.99)
              or neighbour_position.y > (entity_position.y + 0.99)
            local is_underground_connection = entity.type == "pipe-to-ground"
              and neighbour.type == "pipe-to-ground"
              and entity_direction == direction.opposite(neighbour.direction)
              and entity_direction
                == direction.opposite(direction.from_positions(entity_position, neighbour_position, true))

            if is_southeast then
              -- Draw connection line
              local offset = { 0, 0 }
              if is_underground_connection then
                if entity.direction == defines.direction.north or entity.direction == defines.direction.south then
                  offset = { 0, -0.125 }
                else
                  offset = { -0.125, 0 }
                end
              end
              table.insert(
                this_entity_objects,
                rendering.draw_line({
                  color = color,
                  width = 5,
                  gap_length = is_underground_connection and 0.25 or 0,
                  dash_length = is_underground_connection and 0.25 or 0,
                  from = entity,
                  from_offset = offset,
                  to = neighbour,
                  surface = neighbour.surface,
                  players = { player.index },
                })
              )
            elseif
              options.is_overlay -- Don't do this if we're using hover mode
              and is_underground_connection
              and not area.contains_position(overlay_area, neighbour_position)
            then
              -- Iterate the neighbour to draw the underground connection line
              table.insert(entities, neighbour)
            end
          end
        end
      end

      shapes_to_draw[unit_number] = { fluid_system_id = fluid_system_id, entity = entity }
      entity_objects[unit_number] = this_entity_objects
    end
  end

  -- Now draw shapes, so they are on top
  for unit_number, shape_data in pairs(shapes_to_draw) do
    local color = fluid_system_colors[shape_data.fluid_system_id] or constants.default_color
    local entity = shape_data.entity
    local shape_type = constants.type_to_shape[entity.type]
    if shape_type == "square" then
      table.insert(
        entity_objects[unit_number],
        rendering.draw_rectangle({
          left_top = entity,
          left_top_offset = { -0.2, -0.2 },
          right_bottom = entity,
          right_bottom_offset = { 0.2, 0.2 },
          color = color,
          filled = true,
          target = entity,
          surface = entity.surface,
          players = { player.index },
        })
      )
    elseif shape_type == "circle" then
      table.insert(
        entity_objects[unit_number],
        rendering.draw_circle({
          color = color,
          radius = 0.2,
          filled = true,
          target = entity,
          surface = entity.surface,
          players = { player.index },
        })
      )
    elseif shape_type == "diamond" then
      table.insert(
        entity_objects[unit_number],
        rendering.draw_polygon({
          color = color,
          vertices = {
            { target = entity, target_offset = { 0, -0.28 } },
            { target = entity, target_offset = { 0.28, -0 } },
            { target = entity, target_offset = { -0.28, 0 } },
            { target = entity, target_offset = { 0, 0.28 } },
          },
          filled = true,
          target = entity,
          surface = entity.surface,
          players = { player.index },
        })
      )
    end
  end

  player_table.fluid_system_color_index = fluid_system_color_index
end

--- @param player_table PlayerTable
function visualizer.destroy(player, player_table)
  player_table.enabled = false
  if player_table.overlay then
    rendering.destroy(player_table.overlay)
    player_table.overlay = nil
  end
  for _, objects in pairs(player_table.entity_objects) do
    for _, id in pairs(objects) do
      rendering.destroy(id)
    end
  end
  player_table.entity_objects = {}
  player_table.fluid_system_colors = {}
  player_table.fluid_system_color_index = 0
  player_table.last_position = nil

  -- GUI
  local frame_flow = mod_gui.get_frame_flow(player)
  if frame_flow and frame_flow.valid and frame_flow.pv_window and frame_flow.pv_window.valid then
    frame_flow.pv_window.destroy()
  end
end

return visualizer
