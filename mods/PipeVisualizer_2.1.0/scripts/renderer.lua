local flib_bounding_box = require("__flib__/bounding-box")
local flib_math = require("__flib__/math")
local flib_position = require("__flib__/position")
local flib_queue = require("__flib__/queue")

--- @alias RenderObjectID uint64

local function reset()
  rendering.clear(script.mod_name)
  --- @type Queue<RenderObjectID>
  global.render_objects = flib_queue.new()
end

--- @param id RenderObjectID
local function clear_sprite(id)
  if not rendering.is_valid(id) then
    return
  end
  rendering.set_visible(id, false)
  flib_queue.push_back(global.render_objects, id)
end

--- @param args LuaRendering.draw_sprite_param
--- @return RenderObjectID
local function draw_sprite(args)
  --- @type RenderObjectID?
  local id
  repeat
    id = flib_queue.pop_front(global.render_objects)
  until not id or rendering.get_surface(id).index == args.surface and rendering.is_valid(id)

  if not id then
    return rendering.draw_sprite(args)
  end

  rendering.set_sprite(id, args.sprite)
  rendering.set_color(id, args.tint)
  rendering.set_x_scale(id, args.x_scale or 1)
  rendering.set_y_scale(id, args.y_scale or 1)
  rendering.set_render_layer(id, args.render_layer)
  rendering.set_orientation(id, args.orientation or 0)
  rendering.set_target(id, args.target)
  rendering.set_players(id, args.players)
  rendering.set_visible(id, true)

  return id
end

local layers = {
  arrow = "195",
  line = "194",
  underground = "193",
  entity = "192",
}

local pipe_types = {
  ["infinity-pipe"] = true,
  ["pipe-to-ground"] = true,
  ["pipe"] = true,
}

local encoded_directions = {
  [defines.direction.north] = 1,
  [defines.direction.east] = 2,
  [defines.direction.south] = 4,
  [defines.direction.west] = 8,
}

--- @type Color
local default_color = { r = 0.4, g = 0.4, b = 0.4 }
--- @type FluidSystemData
local default_fluid_system = { color = default_color, order = flib_math.max_uint }

local renderer = {}

--- @param it Iterator
--- @param entity_data EntityData
function renderer.draw(it, entity_data)
  local is_complex_type = not pipe_types[entity_data.entity.type]
  if is_complex_type then
    local box = flib_bounding_box.resize(entity_data.entity.selection_box, -0.1)
    entity_data.shape = draw_sprite({
      sprite = "pv-entity-box",
      tint = default_color,
      x_scale = flib_bounding_box.width(box),
      y_scale = flib_bounding_box.height(box),
      render_layer = layers.entity,
      target = flib_bounding_box.center(box),
      surface = entity_data.entity.surface_index,
      players = { it.player_index },
    })
  else
    local box = flib_bounding_box.ceil(entity_data.entity.selection_box)
    entity_data.shape = draw_sprite({
      sprite = "pv-pipe-connections-0",
      tint = default_color,
      x_scale = flib_bounding_box.width(box),
      y_scale = flib_bounding_box.height(box),
      render_layer = layers.line,
      target = entity_data.entity.position,
      surface = entity_data.entity.surface_index,
      players = { it.player_index },
    })
  end
  local shape_fluid_system = default_fluid_system
  local encoded_connections = 0
  for fluid_system_id, connections in pairs(entity_data.connections) do
    local fluid_system_data = it.systems[fluid_system_id]
    if not fluid_system_data then
      goto continue
    end
    if fluid_system_data.order < shape_fluid_system.order then
      shape_fluid_system = fluid_system_data
    end
    local objects = entity_data.connection_objects[fluid_system_id]
    if not objects then
      objects = {}
      entity_data.connection_objects[fluid_system_id] = objects
    end
    for _, connection in pairs(connections) do
      if not connection.target then
        goto inner_continue
      end

      local direction = connection.direction
      if is_complex_type then
        if connection.flow_direction == "input" then
          direction = (direction + 4) % 8 -- Opposite
        end
        local sprite = "pv-fluid-arrow-" .. connection.flow_direction
        if connection.flow_direction ~= "input-output" and not pipe_types[connection.target_owner.type] then
          sprite = "pv-fluid-arrow"
        end
        objects[#objects + 1] = draw_sprite({
          sprite = sprite,
          tint = fluid_system_data.color,
          render_layer = layers.arrow,
          orientation = direction / 8,
          target = connection.shape_position,
          surface = entity_data.entity.surface_index,
          players = { it.player_index },
        })
      else
        encoded_connections = bit32.bor(encoded_connections, encoded_directions[direction])
      end

      if connection.connection_type == "underground" then
        local target_data = it.entities[
          connection.target_owner.unit_number --[[@as uint]]
        ]
        if not target_data then
          goto inner_continue
        end
        local target_fluid_system_connections = target_data.connections[fluid_system_id]
        if not target_fluid_system_connections then
          goto inner_continue
        end
        local target_connection_data = target_fluid_system_connections[connection.target_pipe_connection_index]

        local target_position = target_connection_data.position
        local distance = flib_position.distance(connection.position, target_connection_data.position)
        for i = 1, distance - 1 do
          local target = flib_position.lerp(connection.position, target_position, i / distance)
          objects[#objects + 1] = draw_sprite({
            sprite = "pv-underground-connection",
            tint = fluid_system_data.color,
            render_layer = layers.underground,
            orientation = direction / 8,
            target = target,
            surface = entity_data.entity.surface_index,
            players = { it.player_index },
          })
        end
      end

      ::inner_continue::
    end

    ::continue::
  end
  if entity_data.shape then
    rendering.set_color(entity_data.shape, shape_fluid_system.color)
    if encoded_connections > 0 then
      rendering.set_sprite(entity_data.shape, "pv-pipe-connections-" .. encoded_connections)
    end
  end
end

--- @param entity_data EntityData
function renderer.clear(entity_data)
  clear_sprite(entity_data.shape)
  entity_data.shape = nil
  for _, objects in pairs(entity_data.connection_objects) do
    for _, id in pairs(objects) do
      clear_sprite(id)
    end
  end
  entity_data.connection_objects = {}
end

--- @param iterator Iterator
--- @param entity_data EntityData
--- @param fluid_system_id FluidSystemID
--- @return boolean should_remove
function renderer.clear_system(iterator, entity_data, fluid_system_id)
  local objects = entity_data.connection_objects[fluid_system_id]
  if objects then
    for _, id in pairs(objects) do
      clear_sprite(id)
    end
    entity_data.connection_objects[fluid_system_id] = nil
  end
  local should_remove = not next(entity_data.connection_objects)
  if should_remove then
    clear_sprite(entity_data.shape)
    entity_data.shape = nil
  else
    renderer.update_shape_color(iterator, entity_data)
  end
  return should_remove
end

--- @param iterator Iterator
--- @param entity_data EntityData
function renderer.update_shape_color(iterator, entity_data)
  --- @type FluidSystemData
  local shape_fluid_system = { color = default_color, order = flib_math.max_uint }
  for fluid_system_id in pairs(entity_data.connection_objects) do
    local fluid_system_data = iterator.systems[fluid_system_id]
    if fluid_system_data and fluid_system_data.order < shape_fluid_system.order then
      shape_fluid_system = fluid_system_data
    end
  end
  rendering.set_color(entity_data.shape, shape_fluid_system.color)
end

renderer.on_init = reset
renderer.on_configuration_changed = reset

renderer.reset = reset

return renderer
