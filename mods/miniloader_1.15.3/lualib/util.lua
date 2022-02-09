local util = {}

-- Position adjustments

function util.moveposition(position, offset)
  return {x=position.x + offset.x, y=position.y + offset.y}
end

function util.offset(direction, longitudinal, orthogonal)
  if direction == defines.direction.north then
    return {x=orthogonal, y=-longitudinal}
  end

  if direction == defines.direction.south then
    return {x=-orthogonal, y=longitudinal}
  end

  if direction == defines.direction.east then
    return {x=longitudinal, y=orthogonal}
  end

  if direction == defines.direction.west then
    return {x=-longitudinal, y=-orthogonal}
  end
end

-- BoundingBox utilities

--[[
  +----------------------+
  |                      |
  |                      |
  |                      |
  |       O              |
  |                      |
  +----------------------+
]]
function util.rotate_box(box, direction)
  local left = box.left_top.x
  local top = box.left_top.y
  local right = box.right_bottom.x
  local bottom = box.right_bottom.y

  if direction == defines.direction.north then
    return box
  elseif direction == defines.direction.east then
    -- 90 degree rotation
    return {
      left_top = {x=-bottom, y=left},
      right_bottom = {x=-top, y=right},
    }
  elseif direction == defines.direction.south then
    -- 180 degree rotation
    return {
      left_top = {x=-right, y=-bottom},
      right_bottom = {x=-left, y=-top},
    }
  elseif direction == defines.direction.west then
    -- 270 degree rotation
    return {
      left_top = {x=top, y=-right},
      right_bottom = {x=bottom, y=-left},
    }
  else
    error('invalid direction passed to rotate_box')
  end
end

function util.move_box(box, offset)
  return {
    left_top = util.moveposition(box.left_top, offset),
    right_bottom = util.moveposition(box.right_bottom, offset),
  }
end

function util.expand_box(box, size)
  return {
    left_top = { x = box.left_top.x - size, y = box.left_top.y - size },
    right_bottom = { x = box.right_bottom.x + size, y = box.right_bottom.y + size },
  }
end

function util.entity_key(entity)
  return entity.surface.name.."@"..entity.position.x..","..entity.position.y
end

-- Direction utilities

function util.is_ns(direction)
  return direction == 0 or direction == 4
end

function util.is_ew(direction)
  return direction == 2 or direction == 6
end

function util.opposite_direction(direction)
  if direction >= 4 then
    return direction - 4
  end
  return direction + 4
end

-- orientation utilities

-- hood_side returns the "back" or hood side of a loader or underground belt
function util.hood_side(entity)
  if entity.type == "loader-1x1" and entity.loader_type == "output" then
    return util.opposite_direction(entity.direction)
  end
  if entity.type == "underground-belt" and entity.belt_to_ground_type == "output" then
    return util.opposite_direction(entity.direction)
  end
  return entity.direction
end

-- belt_side returns the "front" side of a loader or underground belt
function util.belt_side(entity)
  if entity.type == "loader-1x1" and entity.loader_type == "input" then
    return util.opposite_direction(entity.direction)
  end
  if entity.type == "underground-belt" and entity.belt_to_ground_type == "input" then
    return util.opposite_direction(entity.direction)
  end
  return entity.direction
end

-- miniloader utilities

function util.find_miniloaders(params)
  params.type = "loader-1x1"
  local entities = params.surface.find_entities_filtered(params)
  local out = {}
  for i=1,#entities do
    local ent = entities[i]
    if util.is_miniloader(ent) then
      out[#out+1] = ent
    end
  end
  return out
end

function util.is_miniloader(entity)
  return string.find(entity.name, "miniloader%-loader$") ~= nil
end

function util.is_miniloader_inserter(entity)
  return util.is_miniloader_inserter_name(entity.name)
end

function util.is_miniloader_inserter_name(name)
  return name:find("miniloader%-inserter$") ~= nil
end

function util.is_output_miniloader_inserter(inserter)
  local orientation = util.orientation_from_inserter(inserter)
  return orientation and orientation.type == "output"
end

-- 60 items/second / 60 ticks/second / 8 items/tile = X tiles/tick
local BELT_SPEED_FOR_60_PER_SECOND = 60/60/8
function util.num_inserters(entity)
  return math.ceil(entity.prototype.belt_speed / BELT_SPEED_FOR_60_PER_SECOND) * 2
end

function util.pickup_position(entity)
  if entity.loader_type == "output" then
    return util.moveposition(entity.position, util.offset(entity.direction, -0.8, 0))
  end
  return util.moveposition(entity.position, util.offset(entity.direction, -0.2, 0))
end

local moveposition = util.moveposition
local offset = util.offset
-- drop positions for input  (belt->chest) = { 0.7, +-0.25}, { 0.9, +-0.25}, {1.1, +-0.25}, {1.3, +-0.25}
-- drop positions for output (chest->belt) = {-0.2, +-0.25}, {-0.0, +-0.25}, {0.1, +-0.25}, {0.3, +-0.25}
function util.drop_positions(entity)
  local base_offset = 1.2
  if entity.loader_type == "output" then
    base_offset = base_offset - 1
  end
  local out = {}
  local dir = entity.direction
  local p1 = moveposition(entity.position, offset(dir, base_offset, -0.25))
  local p2 = moveposition(p1, offset(dir, 0, 0.5))
  out[1] = p1
  out[2] = p2
  for i=1,3 do
    local j = i * 2 + 1
    out[j  ] = moveposition(p1, offset(dir, -0.20*i, 0))
    out[j+1] = moveposition(p2, offset(dir, -0.20*i, 0))
  end
  for i=0,3 do
    local j = i * 2 + 9
    out[j  ] = moveposition(p1, offset(dir, -0.20*i, 0))
    out[j+1] = moveposition(p2, offset(dir, -0.20*i, 0))
  end
  return out
end

function util.get_loader_inserters(entity)
  local out = {}
  for _, e in pairs(entity.surface.find_entities_filtered{
    position = entity.position,
    type = "inserter",
  }) do
    if util.is_miniloader_inserter(e) then
      out[#out+1] = e
    end
  end
  return out
end

local function update_miniloader_ghost(ghost, direction, type)
  local position = ghost.position
  -- We should normally destroy the ghost and recreate it facing the right direction,
  -- but destroying an entity during its on_built_entity handler makes for compatibility
  -- headaches.

  -- add offset within tile to inform orientation_from_inserters that this ghost is preconfigured
  if type == "input" then
    ghost.pickup_position = moveposition(position, offset(direction, 0.25, 0.25))
    ghost.drop_position = moveposition(position, offset(direction, 1, 0.25))
  else
    ghost.pickup_position = moveposition(position, offset(direction, -1, 0.25))
    ghost.drop_position = moveposition(position, offset(direction, 0.25, 0.25))
  end
end

function util.update_miniloader(entity, direction, type)
  if entity.type == "entity-ghost" and entity.ghost_type == "inserter" then
    return update_miniloader_ghost(entity, direction, type)
  end
  if entity.loader_type ~= type then
    entity.rotate()
  end
  entity.direction = direction
  util.update_inserters(entity)
end

function util.update_inserters(entity)
  local inserters = util.get_loader_inserters(entity)
  local pickup = util.pickup_position(entity)
  local drop = util.drop_positions(entity)
  local direction = entity.direction
  local loader_type = entity.loader_type
  if loader_type == "input" then
    direction = util.opposite_direction(direction)
  end

  for i=1,#inserters do
    inserters[i].direction = direction
    inserters[i].pickup_position = pickup
    inserters[i].drop_position = drop[i]
    inserters[i].direction = direction
    if loader_type == "input" then
      inserters[i].pickup_target = entity
    else
      inserters[i].drop_target = entity
    end
  end
end

function util.select_main_inserter(surface, position)
  local inserters = surface.find_entities_filtered{type = "inserter", position = position}
  if not next(inserters) then
    inserters = surface.find_entities_filtered{ghost_type = "inserter", position = position}
  end

  if not next(inserters) then return nil end
  for _, inserter in ipairs(inserters) do
    if inserter.pickup_target == nil and inserter.drop_target == nil then
      return inserter
    end
  end
  return inserters[1]
end

function util.orientation_from_bp_inserter(bp_inserter)
  local position_x = bp_inserter.position.x
  local position_y = bp_inserter.position.y
  local drop_position_x = bp_inserter.drop_position.x + position_x
  local drop_position_y = bp_inserter.drop_position.y + position_y
  local pickup_position_x = bp_inserter.pickup_position.x + position_x
  local pickup_position_y = bp_inserter.pickup_position.y + position_y
  if drop_position_x == position_x or drop_position_y == position_y then
    return nil -- freshly placed with no inherited positions
  elseif drop_position_x > position_x + 0.5 then
    return {direction=defines.direction.east, type="input"}
  elseif drop_position_x < position_x - 0.5 then
    return {direction=defines.direction.west, type="input"}
  elseif drop_position_y > position_y + 0.5 then
    return {direction=defines.direction.south, type="input"}
  elseif drop_position_y < position_y - 0.5 then
    return {direction=defines.direction.north, type="input"}
  elseif pickup_position_x > position_x + 0.5 then
    return {direction=defines.direction.west, type="output"}
  elseif pickup_position_x < position_x - 0.5 then
    return {direction=defines.direction.east, type="output"}
  elseif pickup_position_y > position_y + 0.5 then
    return {direction=defines.direction.north, type="output"}
  elseif pickup_position_y < position_y - 0.5 then
    return {direction=defines.direction.south, type="output"}
  end
end

function util.orientation_from_inserter(inserter)
  if inserter.drop_position.x == inserter.position.x and inserter.drop_position.y == inserter.position.y then
    return nil -- freshly placed with no inherited positions
  elseif inserter.drop_position.x > inserter.position.x + 0.5 then
    return {direction=defines.direction.east, type="input"}
  elseif inserter.drop_position.x < inserter.position.x - 0.5 then
    return {direction=defines.direction.west, type="input"}
  elseif inserter.drop_position.y > inserter.position.y + 0.5 then
    return {direction=defines.direction.south, type="input"}
  elseif inserter.drop_position.y < inserter.position.y - 0.5 then
    return {direction=defines.direction.north, type="input"}
  elseif inserter.pickup_position.x > inserter.position.x + 0.5 then
    return {direction=defines.direction.west, type="output", is_secondary=inserter.drop_position.y < inserter.position.y}
  elseif inserter.pickup_position.x < inserter.position.x - 0.5 then
    return {direction=defines.direction.east, type="output", is_secondary=inserter.drop_position.y > inserter.position.y}
  elseif inserter.pickup_position.y > inserter.position.y + 0.5 then
    return {direction=defines.direction.north, type="output", is_secondary=inserter.drop_position.x > inserter.position.x}
  elseif inserter.pickup_position.y < inserter.position.y - 0.5 then
    return {direction=defines.direction.south, type="output", is_secondary=inserter.drop_position.x < inserter.position.x}
  end
end

function util.orientation_from_inserters(entity)
  local inserter = util.select_main_inserter(entity.surface, entity.position)
  return util.orientation_from_inserter(inserter)
end

function util.rebuild_belt(entity)
  local surface = entity.surface
  local name = entity.name
  local protos = game.get_filtered_entity_prototypes{{filter="type", type=entity.type}}
  local temporary_replacement
  for proto_name in pairs(protos) do
    if proto_name ~= name and proto_name ~= "__self" then
      temporary_replacement = proto_name
      break
    end
  end
  if not temporary_replacement then return false end

  local last_user = entity.last_user
  local params = {
    name = temporary_replacement,
    position = entity.position,
    direction = entity.direction,
    force = entity.force,
    fast_replace = true,
    spill = false,
    create_build_effect_smoke = false,
    type = entity.type:find("loader") and entity.loader_type
      or entity.type == "underground-belt" and entity.belt_to_ground_type,
  }

  surface.create_entity(params)
  params.name = name
  local belt = surface.create_entity(params)

  if belt then
    belt.last_user = last_user
    return true
  else
    return false
  end
end

local control_behavior_keys = {
  "circuit_condition", "logistic_condition", "connect_to_logistic_network",
  "circuit_read_hand_contents", "circuit_mode_of_operation", "circuit_hand_read_mode", "circuit_set_stack_size", "circuit_stack_control_signal",
}

function util.capture_settings(ghost)
  local control_behavior = ghost.get_or_create_control_behavior()
  local control_behavior_state = {}
  for _, key in pairs(control_behavior_keys) do
    control_behavior_state[key] = control_behavior[key]
  end

  local filters = {}
  for i=1,ghost.filter_slot_count do
    filters[i] = ghost.get_filter(i)
  end

  return {
    control_behavior = control_behavior_state,
    filters = filters,
  }
end

function util.apply_settings(settings, inserter)
  local limit = math.min(inserter.filter_slot_count, #settings.filters)
  for i = 1, limit do
    inserter.set_filter(i, settings.filters[i])
  end
  local control_behavior = inserter.get_or_create_control_behavior()
  for k, v in pairs(settings.control_behavior) do
    control_behavior[k] = v
  end
end


return util
