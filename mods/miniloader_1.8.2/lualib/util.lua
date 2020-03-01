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
  if entity.type == "loader" and entity.loader_type == "output" then
    return util.opposite_direction(entity.direction)
  end
  if entity.type == "underground-belt" and entity.belt_to_ground_type == "output" then
    return util.opposite_direction(entity.direction)
  end
  return entity.direction
end

-- belt_side returns the "front" side of a loader or underground belt
function util.belt_side(entity)
  if entity.type == "loader" and entity.loader_type == "input" then
    return util.opposite_direction(entity.direction)
  end
  if entity.type == "underground-belt" and entity.belt_to_ground_type == "input" then
    return util.opposite_direction(entity.direction)
  end
  return entity.direction
end

-- miniloader utilities

function util.find_miniloaders(params)
  params.type = "loader"
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
  return entity.surface.find_entities_filtered{
    position = entity.position,
    type = "inserter",
  }
end

function util.update_miniloader(entity, direction, type)
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
  if entity.loader_type == "input" then
    direction = util.opposite_direction(direction)
  end

  for i=1,#inserters do
    inserters[i].direction = direction
    inserters[i].pickup_position = pickup
    inserters[i].drop_position = drop[i]
    inserters[i].direction = direction
  end
end

function util.orientation_from_inserters(entity)
  local find_entities_filtered = entity.surface.find_entities_filtered
  local inserter =
    find_entities_filtered{type = "inserter", position = entity.position}[1] or
    find_entities_filtered{ghost_type = "inserter", position = entity.position}[1]
  if inserter.drop_position.x > inserter.position.x + 0.5 then
    return {direction=defines.direction.east, type="input"}
  elseif inserter.drop_position.x < inserter.position.x - 0.5 then
    return {direction=defines.direction.west, type="input"}
  elseif inserter.drop_position.y > inserter.position.y + 0.5 then
    return {direction=defines.direction.south, type="input"}
  elseif inserter.drop_position.y < inserter.position.y - 0.5 then
    return {direction=defines.direction.north, type="input"}
  elseif inserter.pickup_position.x > inserter.position.x + 0.5 then
    return {direction=defines.direction.west, type="output"}
  elseif inserter.pickup_position.x < inserter.position.x - 0.5 then
    return {direction=defines.direction.east, type="output"}
  elseif inserter.pickup_position.y > inserter.position.y + 0.5 then
    return {direction=defines.direction.north, type="output"}
  elseif inserter.pickup_position.y < inserter.position.y - 0.5 then
    return {direction=defines.direction.south, type="output"}
  end
end

return util