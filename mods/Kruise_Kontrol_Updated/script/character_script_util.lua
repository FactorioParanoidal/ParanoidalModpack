local util = require("util")

util.distance = function(p1, p2)
  local x1 = p1.x or p1[1]
  local y1 = p1.y or p1[2]
  local x2 = p2.x or p2[1]
  local y2 = p2.y or p2[2]
  return (((x1 - x2) ^ 2) + ((y1 - y2) ^ 2)) ^ 0.5
end

util.area = function(position, radius)
  local x = position[1] or position.x
  local y = position[2] or position.y
  return {{x - radius, y - radius}, {x + radius, y + radius}}
end

util.angle = function(position_1, position_2)
  local d_x = (position_2[1] or position_2.x) - (position_1[1] or position_1.x)
  local d_y = (position_2[2] or position_2.y) - (position_1[2] or position_1.y)
  return math.atan2(d_y, d_x)
end

util.get_orientation_to = function(position_1, position_2)

  -- Angle in rads
  local angle = util.angle(position_2, position_1)

  -- Convert to orientation
  local orientation = (angle / (2 * math.pi)) - 0.25
  return orientation % 1
end

return util
