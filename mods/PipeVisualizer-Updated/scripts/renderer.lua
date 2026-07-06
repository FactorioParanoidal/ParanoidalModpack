local flib_bounding_box = require("__flib__.bounding-box")
local flib_math = require("__flib__.math")
local flib_position = require("__flib__.position")
local flib_queue = require("__flib__.queue")

--- @alias RenderObjectID uint64

local function reset()
  rendering.clear(script.mod_name)
  --- @type flib.Queue<RenderObjectID>
  storage.render_objects = flib_queue.new()
end

--- @param obj LuaRenderObject
local function clear_sprite(obj)
  if not obj.valid then
    return
  end
  obj.visible = false
  flib_queue.push_back(storage.render_objects, obj)
end

--- @param args LuaRendering.draw_sprite_param
--- @return LuaRenderObject
local function draw_sprite(args)
  --- @type LuaRenderObject?
  local obj
  repeat
    obj = flib_queue.pop_front(storage.render_objects)
  until not obj or obj.valid and obj.surface.index == args.surface

  if not obj then
    return rendering.draw_sprite(args)
  end
  obj.sprite = args.sprite
  obj.color = args.tint
  obj.x_scale = args.x_scale or 1
  obj.y_scale = args.y_scale or 1
  obj.render_layer = args.render_layer
  obj.orientation = args.orientation or 0
  obj.target = args.target
  obj.players = args.players
  obj.visible = true
  obj.render_mode = args.render_mode or "game"

  return obj
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
local default_fluid_system = { color = default_color, from_hover = false, order = flib_math.max_uint }

local renderer = {}

--- @type float
local direction_divisor = defines.direction.east * 4

local function is_valid_pipe_entity(ent)
  local pipe_type = pipe_types[ent.type]
  if pipe_type == true then
    return pipe_type
  end
  if storage.pipelist[ent.type] and type(storage.pipelist[ent.type]) == "table" then
    return storage.pipelist[ent.type][ent.name]
  end
end

local function is_specific_complex_entity(ent)
  if storage.complexlist[ent.type] and type(storage.complexlist[ent.type]) == "table" then
    return storage.complexlist[ent.type][ent.name]
  end
end

--- @param it Iterator
--- @param entity_data EntityData
function renderer.draw(it, entity_data)
  local is_complex_type = (not is_valid_pipe_entity(entity_data.entity)) or is_specific_complex_entity(entity_data.entity) --pipe_types[entity_data.entity.type]
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
    entity_data.mapshape = draw_sprite({
      sprite = "pv-entity-box",
      tint = default_color,
      x_scale = flib_bounding_box.width(box),
      y_scale = flib_bounding_box.height(box),
      render_layer = "arrow",
      target = flib_bounding_box.center(box),
      surface = entity_data.entity.surface_index,
      players = { it.player_index },
      render_mode = "chart"
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
    entity_data.mapshape = draw_sprite({
      sprite = "pv-pipe-connections-0",
      tint = default_color,
      x_scale = flib_bounding_box.width(box),
      y_scale = flib_bounding_box.height(box),
      render_layer = "arrow",
      target = entity_data.entity.position,
      surface = entity_data.entity.surface_index,
      players = { it.player_index },
      render_mode = "chart"
    })
  end
  local shape_fluid_system = default_fluid_system
  local encoded_connections = 0
  local found_connections = false
  for fluid_system_id, connections in pairs(entity_data.connections) do
    found_connections = true
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
        if connection.flow_direction ~= "input-output" and ((not is_valid_pipe_entity(connection.target_owner)) or is_specific_complex_entity(connection.target_owner)) then --pipe_types[connection.target_owner.type] then
          sprite = "pv-fluid-arrow"
        end
        objects[#objects + 1] = draw_sprite({
          sprite = sprite,
          tint = fluid_system_data.color,
          render_layer = layers.arrow,
          orientation = direction / direction_divisor,
          target = connection.shape_position,
          surface = entity_data.entity.surface_index,
          players = { it.player_index },
        })
        objects[#objects + 1] = draw_sprite({
          sprite = sprite,
          tint = fluid_system_data.color,
          render_layer = "arrow",
          y_scale = 4,
          x_scale = 4,
          orientation = direction / direction_divisor,
          target = connection.shape_position,
          surface = entity_data.entity.surface_index,
          players = { it.player_index },
          render_mode = "chart",
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
            orientation = direction / direction_divisor,
            target = target,
            surface = entity_data.entity.surface_index,
            players = { it.player_index },
          })
          objects[#objects + 1] = draw_sprite({
            sprite = "pv-underground-connection",
            tint = fluid_system_data.color,
            render_layer = "arrow",
            y_scale = 4,
            x_scale = 4,
            orientation = direction / direction_divisor,
            target = target,
            surface = entity_data.entity.surface_index,
            players = { it.player_index },
            render_mode = "chart",
          })
        end
      end

      ::inner_continue::
    end

    ::continue::
  end
  if entity_data.shape then
    local sett = settings.get_player_settings(it.player_index)
    if sett["pv-color-pumps"].value and not found_connections then
      local fluidbox = entity_data.fluidbox
      if #fluidbox == 1 then
        shape_fluid_system = it.systems[fluidbox.get_fluid_segment_id(1) or "none"] or default_fluid_system
      end
    end
    entity_data.shape.color = shape_fluid_system.color
    if encoded_connections > 0 then
      entity_data.shape.sprite = "pv-pipe-connections-" .. encoded_connections
    end
  end
  if entity_data.mapshape then
    local sett = settings.get_player_settings(it.player_index)
    if sett["pv-color-pumps"].value and not found_connections then
      local fluidbox = entity_data.fluidbox
      if #fluidbox == 1 then
        shape_fluid_system = it.systems[fluidbox.get_fluid_segment_id(1) or "none"] or default_fluid_system
      end
    end
    entity_data.mapshape.color = shape_fluid_system.color
    if encoded_connections > 0 then
      entity_data.mapshape.sprite = "pv-pipe-connections-" .. encoded_connections .. "-chart"
    end
  end
end

--- @param entity_data EntityData
function renderer.clear(entity_data)
  clear_sprite(entity_data.shape)
  clear_sprite(entity_data.mapshape)
  entity_data.shape = nil
  entity_data.mapshape = nil
  for _, objects in pairs(entity_data.connection_objects) do
    for _, obj in pairs(objects) do
      clear_sprite(obj)
    end
  end
  entity_data.connection_objects = {}
end

--- @param iterator Iterator
--- @param entity_data EntityData
--- @param fluid_system_id FluidSystemID | "none"
--- @return boolean should_remove
function renderer.clear_system(iterator, entity_data, fluid_system_id)
  local objects = entity_data.connection_objects[fluid_system_id]
  if objects then
    for _, obj in pairs(objects) do
      clear_sprite(obj)
    end
    entity_data.connection_objects[fluid_system_id] = nil
  end
  local should_remove = not next(entity_data.connection_objects)
  if should_remove then
    clear_sprite(entity_data.shape)
    clear_sprite(entity_data.mapshape)
    entity_data.shape = nil
    entity_data.mapshape = nil
  else
    renderer.update_shape_color(iterator, entity_data)
  end
  return should_remove
end

--- @param iterator Iterator
--- @param entity_data EntityData
function renderer.update_shape_color(iterator, entity_data)
  --- @type FluidSystemData
  local shape_fluid_system = { color = default_color, from_hover = false, order = flib_math.max_uint }
  for fluid_system_id in pairs(entity_data.connection_objects) do
    local fluid_system_data = iterator.systems[fluid_system_id]
    if fluid_system_data and fluid_system_data.order < shape_fluid_system.order then
      shape_fluid_system = fluid_system_data
    end
  end
  entity_data.shape.color = shape_fluid_system.color
  entity_data.mapshape.color = shape_fluid_system.color
end

renderer.on_init = reset
renderer.on_configuration_changed = reset

renderer.reset = reset

return renderer
