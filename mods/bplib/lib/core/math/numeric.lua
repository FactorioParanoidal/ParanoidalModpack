local floor = math.floor
local ceil = math.ceil
local abs = math.abs

local lib = {}

---Round to nearest factor of `bracket`.
---@param v number The value to round.
---@param bracket? number The rounding bracket. Defaults to 1.
local function round(v, bracket)
	bracket = bracket or 1
	local sign = (v >= 0 and 1) or -1
	return floor(v / bracket + 0.5) * bracket
end
lib.round = round

---Format a number of ticks in the form "HHvhMMvmSSvs" where a second is
---60 ticks.
---@param ticks uint The number of ticks.
function lib.format_ticks(ticks)
	local seconds = floor(ticks / 60)
	local minutes = floor(seconds / 60)
	local hours = floor(minutes / 60)
	seconds = seconds % 60
	minutes = minutes % 60
	if minutes == 0 and hours == 0 then
		return string.format("%ds", seconds)
	elseif hours == 0 then
		return string.format("%dm%02ds", minutes, seconds)
	else
		return string.format("%dh%02dm%02ds", hours, minutes, seconds)
	end
end

---Format a tick as T+ or T- relative to a given T.
---@param ticks uint The number of ticks.
---@param reference uint The reference tick.
function lib.format_tick_relative(ticks, reference)
	if ticks >= reference then
		return "T+" .. lib.format_ticks(ticks - reference)
	elseif ticks < reference then
		return "T-" .. lib.format_ticks(reference - ticks)
	end
end

---Clamp a numeric value between min and max.
---@param value number? The value to clamp.
---@param min number The minimum value.
---@param max number The maximum value.
---@param default number The default value if nil.
---@return number clamped The clamped value.
function lib.clamp(value, min, max, default)
	value = value or default
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

---If a number is very close to an integer, return that integer. Else return
---the floor.
---@param x number The number to floor.
---@return integer floored The floored value.
local function floor_approx(x)
	local top = ceil(x)
	if abs(top - x) < 0.001 then
		return top
	else
		return floor(x)
	end
end
lib.floor_approx = floor_approx

---If a number is very close to an integer, return that integer. Else return
---the ceil.
---@param x number The number to ceil.
---@return number ceiled The ceiled value.
function lib.ceil_approx(x)
	local bot = floor(x)
	if abs(bot - x) < 0.001 then
		return bot
	else
		return ceil(x)
	end
end

-- Round floorwards to the nearest Factorio tile.
function lib.floor_tile(x) return floor_approx(x - 0.5) end

---Explicit boolean conversion.
---@param x any
---@return boolean
function lib.Boolean(x)
	if x then
		return true
	else
		return false
	end
end

return lib
