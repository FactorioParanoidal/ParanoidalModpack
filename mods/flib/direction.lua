local flib_math = require("__flib__.math")

--- Functions for working with directions.
--- ```lua
--- local flib_direction = require("__flib__.direction")
--- ```
--- @class flib_direction
local flib_direction = {}

--- Calculate the opposite direction.
--- @param direction defines.direction
--- @return defines.direction
function flib_direction.opposite(direction)
  return (direction + 8) % 16 --[[@as defines.direction]]
end

--- Calculate the next four-way or eight-way direction.
--- @param direction defines.direction
--- @param eight_way? boolean
--- @return defines.direction
function flib_direction.next(direction, eight_way)
  return (direction + (eight_way and 2 or 4)) % 16 --[[@as defines.direction]]
end

--- Calculate the previous four-way or eight-way direction.
--- @param direction defines.direction
--- @param eight_way? boolean
--- @return defines.direction
function flib_direction.previous(direction, eight_way)
  return (direction + (eight_way and -2 or -4)) % 16 --[[@as defines.direction]]
end

--- Calculate an orientation from a direction.
--- @param direction defines.direction
--- @return RealOrientation
function flib_direction.to_orientation(direction)
  return direction / 16 --[[@as RealOrientation]]
end

--- Calculate the direction of travel from the source to the target.
--- @param source MapPosition
--- @param target MapPosition
--- @param round? boolean If true, round to the nearest `defines.direction`.
--- @return defines.direction
function flib_direction.from_positions(source, target, round)
  local deg = math.deg(math.atan2(target.y - source.y, target.x - source.x))
  local direction = (deg + 90) / 22.5
  if direction < 0 then
    direction = direction + 16
  end
  if round then
    direction = flib_math.round(direction)
  end
  return direction --[[@as defines.direction]]
end

return flib_direction
