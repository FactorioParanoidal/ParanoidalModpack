local pos_lib = require("lib.core.math.pos")
local num_lib = require("lib.core.math.numeric")

local round = num_lib.round
local pos_get = pos_lib.pos_get
local pos_set = pos_lib.pos_set
local type = _G.type
local floor = math.floor

local lib = {}

local min = math.min
local max = math.max

local dir_N = defines.direction.north
local dir_S = defines.direction.south
local dir_E = defines.direction.east
local dir_W = defines.direction.west

--- Get the four corners of any bbox.
---@param bbox BoundingBox
---@return number left
---@return number top
---@return number right
---@return number bottom
local function bbox_get(bbox)
	local lt, rb
	if bbox.left_top then
		lt, rb = bbox.left_top, bbox.right_bottom
	else
		lt, rb = bbox[1], bbox[2]
	end
	---@cast lt MapPosition
	---@cast rb MapPosition
	if lt.x then
		if rb.x then
			local l = lt.x --[[@as number]]
			local t = lt.y --[[@as number]]
			local r = rb.x --[[@as number]]
			return l, t, r, rb.y --[[@as number]]
		else
			local l = lt.x --[[@as number]]
			local t = lt.y --[[@as number]]
			local r = rb[1] --[[@as number]]
			return l, t, r, rb[2] --[[@as number]]
		end
	else
		if rb.x then
			local l = lt[1] --[[@as number]]
			local t = lt[2] --[[@as number]]
			local r = rb.x --[[@as number]]
			return l, t, r, rb.y --[[@as number]]
		else
			local l = lt[1] --[[@as number]]
			local t = lt[2] --[[@as number]]
			local r = rb[1] --[[@as number]]
			return l, t, r, rb[2] --[[@as number]]
		end
	end
end
lib.bbox_get = bbox_get

--- Mutate a bbox, setting its corners.
---@param bbox BoundingBox
---@param left number
---@param top number
---@param right number
---@param bottom number
---@return BoundingBox bbox The mutated bbox.
local function bbox_set(bbox, left, top, right, bottom)
	local lt, rb
	if bbox.left_top then
		lt, rb = bbox.left_top, bbox.right_bottom
	else
		lt, rb = bbox[1], bbox[2]
	end
	---@cast lt MapPosition
	---@cast rb MapPosition
	if lt.x then
		if rb.x then
			lt.x, lt.y, rb.x, rb.y = left, top, right, bottom
		else
			lt.x, lt.y, rb[1], rb[2] = left, top, right, bottom
		end
	else
		if rb.x then
			lt[1], lt[2], rb.x, rb.y = left, top, right, bottom
		else
			lt[1], lt[2], rb[1], rb[2] = left, top, right, bottom
		end
	end
	return bbox
end
lib.bbox_set = bbox_set

---Create a new bbox, optionally cloning an existing one. If not provided,
---the new bbox has all coordinate zeroed.
---@param bbox_or_l BoundingBox|number|nil
---@param t? number
---@param r? number
---@param b? number
---@return [ [number, number], [number, number] ] #The new bbox.
local function bbox_new(bbox_or_l, t, r, b)
	if type(bbox_or_l) == "table" then
		bbox_or_l, t, r, b = bbox_get(bbox_or_l)
	end
	if bbox_or_l then
		return {
			{
				bbox_or_l,
				t --[[@as number]],
			},
			{
				r --[[@as number]],
				b --[[@as number]],
			},
		}
	else
		return { { 0, 0 }, { 0, 0 } }
	end
end
lib.bbox_new = bbox_new

---Normalize the points of a bbox, ensuring that the left is always less than
---the right, and the top is always less than the bottom.
---@param l number
---@param t number
---@param r number
---@param b number
local function bbox_normalize(l, t, r, b)
	if l > r then
		l, r = r, l
	end
	if t > b then
		t, b = b, t
	end
	return l, t, r, b
end
lib.bbox_normalize = bbox_normalize

---Sets the points of a bounding box directly, making sure they are normalized
---first.
---@param bbox BoundingBox
---@param l number
---@param t number
---@param r number
---@param b number
---@return BoundingBox bbox The mutated bbox.
local function bbox_setn(bbox, l, t, r, b)
	if l > r then
		l, r = r, l
	end
	if t > b then
		t, b = b, t
	end
	return bbox_set(bbox, l, t, r, b)
end
lib.bbox_setn = bbox_setn

---Extend a bbox to contain another bbox, mutating the first.
---@param bbox1 BoundingBox
---@param bbox2 BoundingBox
---@return BoundingBox bbox1 The first bbox, extended to contain the second.
local function bbox_union(bbox1, bbox2)
	local l1, t1, r1, b1 = bbox_get(bbox1)
	local l2, t2, r2, b2 = bbox_get(bbox2)
	return bbox_set(bbox1, min(l1, l2), min(t1, t2), max(r1, r2), max(b1, b2))
end
lib.bbox_union = bbox_union

---Extend a bbox to contain the given point. Does nothing if the point is
---already in the box.
---@param bbox BoundingBox
---@param x_or_point number|MapPosition X-coordinate of point.
---@param y? number Y-coordinate of point.
---@return BoundingBox bbox The given bbox appropriately mutated.
local function bbox_add_point(bbox, x_or_point, y)
	local x = x_or_point
	if type(x_or_point) == "table" then
		x, y = pos_get(x_or_point)
	end
	if (not x) or not y then return bbox end
	---@cast x number
	local l, t, r, b = bbox_get(bbox)
	return bbox_set(bbox, min(l, x), min(t, y), max(r, x), max(b, y))
end
lib.bbox_add_point = bbox_add_point

---Grow a bbox by the given amount in the given ortho direction.
---@param bbox BoundingBox
---@param dir defines.direction
---@param amount number
---@return BoundingBox bbox The mutated bbox.
local function bbox_extend_ortho(bbox, dir, amount)
	local l, t, r, b = bbox_get(bbox)
	if dir == dir_N then
		t = t - amount
	elseif dir == dir_S then
		b = b + amount
	elseif dir == dir_E then
		r = r + amount
	elseif dir == dir_W then
		l = l - amount
	end
	return bbox_set(bbox, l, t, r, b)
end
lib.bbox_extend_ortho = bbox_extend_ortho

---Measure the distance of the given point along the given orthogonal axis
---of the given bounding box. The direction indicates the positive measurement
---axis, with the zero point of the axis being on the opposite side of the box.
---@param bbox BoundingBox
---@param direction defines.direction One of the four cardinal directions. Other directions will give invalid results.
---@param point MapPosition
---@return number distance The distance along the axis.
local function bbox_measure_ortho(bbox, direction, point)
	local l, t, r, b = bbox_get(bbox)
	local x, y = pos_get(point)
	if direction == dir_N then
		return b - y
	elseif direction == dir_S then
		return y - t
	elseif direction == dir_E then
		return x - l
	elseif direction == dir_W then
		return r - x
	else
		error("dist_ortho_bbox: Invalid direction")
	end
end
lib.bbox_measure_ortho = bbox_measure_ortho

---Rotate a bbox orthogonally (in increments of 90 degrees) counterclockwise
---around an origin. Mutates the given bbox.
---@param bbox BoundingBox
---@param origin MapPosition
---@param count int Rotates by `count * 90` degrees counterclockwise. May be negative to rotate clockwise.
---@return BoundingBox bbox The mutated bbox.
local function bbox_rotate_ortho(bbox, origin, count)
	local l, t, r, b = bbox_get(bbox)
	local ox, oy = pos_get(origin)

	-- Normalize count to be within 0 to 3
	count = (count % 4 + 4) % 4

	if count == 1 then
		-- 90 degrees counterclockwise
		return bbox_setn(
			bbox,
			ox - (oy - t),
			oy - (r - ox),
			ox - (oy - b),
			oy - (l - ox)
		)
	elseif count == 2 then
		-- 180 degrees counterclockwise
		return bbox_setn(
			bbox,
			ox - (r - ox),
			oy - (b - oy),
			ox - (l - ox),
			oy - (t - oy)
		)
	elseif count == 3 then
		-- 270 degrees counterclockwise (or 90 degrees clockwise)
		return bbox_setn(
			bbox,
			ox + (oy - b),
			oy + (l - ox),
			ox + (oy - t),
			oy + (r - ox)
		)
	else
		-- 0 degrees (no rotation)
		return bbox
	end
end
lib.bbox_rotate_ortho = bbox_rotate_ortho

---Flip a bbox horizontally across the vertical line given by the `x` parameter.
---The bbox need not intersect with the vertical line.
---@param bbox BoundingBox
---@param x number?
---@return BoundingBox bbox The mutated bbox.
local function bbox_flip_horiz(bbox, x)
	local l, t, r, b = bbox_get(bbox)
	if not x then x = (l + r) / 2 end
	local dx1 = x - l
	local dx2 = r - x
	return bbox_set(bbox, x - dx2, t, x + dx1, b)
end
lib.bbox_flip_horiz = bbox_flip_horiz

---Flip a bbox vertically across the horizontal line given by the `y` parameter.
---The bbox need not intersect with the horizontal line.
---@param bbox BoundingBox
---@param y number?
---@return BoundingBox bbox The mutated bbox.
local function bbox_flip_vert(bbox, y)
	local l, t, r, b = bbox_get(bbox)
	if not y then y = (t + b) / 2 end
	local dy1 = y - t
	local dy2 = b - y
	return bbox_set(bbox, l, y - dy2, r, y + dy1)
end
lib.bbox_flip_vert = bbox_flip_vert

---Translate a bbox by the given vector. Mutates the given bbox.
---@param bbox BoundingBox
---@param factor number
---@param pos_or_dx MapPosition|number
---@param dy? number
local function bbox_translate(bbox, factor, pos_or_dx, dy)
	local dx = 0.0
	if type(pos_or_dx) == "table" then
		dx, dy = pos_get(pos_or_dx)
	else
		dx = pos_or_dx --[[@as number]]
	end
	local l, t, r, b = bbox_get(bbox)
	---@cast dx number
	---@cast dy number
	dx = dx * factor
	dy = dy * factor
	return bbox_set(bbox, l + dx, t + dy, r + dx, b + dy)
end
lib.bbox_translate = bbox_translate

---Determine if a bbox contains a position.
---@param bbox BoundingBox
---@param pos MapPosition
---@return boolean
local function bbox_contains(bbox, pos)
	local l, t, r, b = bbox_get(bbox)
	local x, y = pos_get(pos)
	return (x >= l) and (x <= r) and (y >= t) and (y <= b)
end
lib.bbox_contains = bbox_contains

---Round a bbox outward, attempting to ignore epsilons.
---@param bbox BoundingBox
---@return BoundingBox bbox The mutated bbox.
local function bbox_round(bbox)
	local l, t, r, b = bbox_get(bbox)
	return bbox_set(bbox, round(l, 1), round(t, 1), round(r, 1), round(b, 1))
end
lib.bbox_round = bbox_round

---Set the position to be the center of the given bbox.
---@param pos MapPosition
---@param bbox BoundingBox
local function pos_set_center(pos, bbox)
	local l, t, r, b = bbox_get(bbox)
	local cx, cy = (l + r) / 2, (t + b) / 2
	return pos_set(pos, cx, cy)
end
lib.pos_set_center = pos_set_center

---Set the given bbox to cover the given position (1x1 area).
---@param bbox BoundingBox
---@param pos MapPosition
---@return BoundingBox bbox The mutated bbox.
local function bbox_from_pos(bbox, pos)
	local x, y = pos_get(pos)
	x = floor(x)
	y = floor(y)
	return bbox_set(bbox, x, y, x + 1, y + 1)
end
lib.bbox_from_pos = bbox_from_pos

---Set the given bbox to be centered on the given point with the given size.
---@param bbox BoundingBox
---@param center MapPosition
---@param dx number
---@param dy number
local function bbox_around(bbox, center, dx, dy)
	local cx, cy = pos_get(center)
	return bbox_set(bbox, cx - dx / 2, cy - dy / 2, cx + dx / 2, cy + dy / 2)
end
lib.bbox_around = bbox_around

return lib
