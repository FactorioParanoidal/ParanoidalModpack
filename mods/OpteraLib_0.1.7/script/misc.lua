--[[ Copyright (c) 2019 Optera, Eduran
 * Part of Optera's Function Library
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- calculates the distance in tiles between two positions
-- Parameters: LuaPosition, LuaPosition
-- Returns: distance as double
local sqrt = math.sqrt
function get_distance(a, b)
  local x, y = a.x-b.x, a.y-b.y
  return sqrt(x*x+y*y) -- sqrt shouldn't be necessary for comparing distances
end

-- calculates the squared distance in tiles between two positions, slightly faster than get_distance
-- Parameters: LuaPosition, LuaPosition
-- Returns: squared distance as double
function get_distance_squared(a, b)
  local x, y = a.x-b.x, a.y-b.y
  return (x*x+y*y)
end

-- converts ticks into "[hh:]mm:ss" format
-- Parameters: tick (optional)
-- Returns: formated string
local floor = math.floor
local format = string.format
local format_string_1 = "%d:%02d"
local format_string_2 = "%d:%02d:%02d"
function ticks_to_timestring(tick)
	local total_seconds = floor((tick or game.tick)/60)
	local seconds = total_seconds % 60
	local minutes = floor(total_seconds/60)
  if minutes > 59 then
    minutes = minutes % 60
    local hours = floor(total_seconds/3600)
    return format(format_string_2, hours, minutes, seconds)
  else
    return format(format_string_1, minutes, seconds)
  end
end

-- converts arbitrary version string X.Y.Z into xx.yy.zz for comparison
-- Parameters: string in format X.Y.Z
-- Returns: string in format xx.yy.zz
function format_version(version_string)
  if version_string then
    local X, Y, Z = version_string:match("(%d+).(%d+).(%d+)")
    if tonumber(X) and tonumber(Y) and tonumber(Z) then
      return format("%02d.%02d.%02d", X, Y, Z)
    end
  end
end

-- (shallowly) compares two tables by content
-- Parameters: table1, table2
-- Returns: bool
function compare_tables(tb1, tb2)
  if tb1 == tb2 then return true end
  local t1_type = type(tb1)
  if t1_type ~= type(tb2) then return false end
  if t1_type ~= 'table' then return false end

  local keys = {}
  for key1, value1 in pairs(tb1) do
    local value2 = tb2[key1]
    if value2 == nil or value2 ~= value1 then return false end
    keys[key1] = true
  end
  for key2 in pairs(tb2) do
    if not keys[key2] then return false end
  end
  return true
end

return {
  get_distance = get_distance,
  get_distance_squared = get_distance_squared,
  ticks_to_timestring = ticks_to_timestring,
  compare_tables = compare_tables,
  format_version = format_version,
}