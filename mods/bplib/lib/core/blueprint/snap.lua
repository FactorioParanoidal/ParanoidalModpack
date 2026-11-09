--------------------------------------------------------------------------------
-- SNAPPING
-- Compute how blueprints snap.
--------------------------------------------------------------------------------
local bbox_lib = require("lib.core.math.bbox")
local pos_lib = require("lib.core.math.pos")
local num_lib = require("lib.core.math.numeric")
local strace = require("lib.core.strace")
local table_lib = require("lib.core.table")
local proto_lib = require("lib.core.blueprint.proto")

local lib = {}

local floor = math.floor
local bbox_get = bbox_lib.bbox_get
local pos_get = pos_lib.pos_get
local pos_new = pos_lib.pos_new
local pos_add = pos_lib.pos_add
local pos_blueprint_transform = pos_lib.pos_blueprint_transform
local round = num_lib.round
local ZERO = { 0, 0 }
local pos_rotate_ortho = pos_lib.pos_rotate_ortho
local pos_set = pos_lib.pos_set
local floor_approx = num_lib.floor_approx
local EMPTY = table_lib.EMPTY

---In an absolute grid with squares sized `gx`x`gy` and a global offset of
---`(ox, oy)`, find the square containing the point `(x, y)` and return its
---bounding box.
---@param x number
---@param y number
---@param gx number Horizontal grid size
---@param gy number Vertical grid size
---@param ox number Horizontal grid offset
---@param oy number Vertical grid offset
local function get_absolute_grid_square(x, y, gx, gy, ox, oy)
	local left = floor((x - ox) / gx) * gx + ox
	local top = floor((y - oy) / gy) * gy + oy
	local right = left + gx
	local bottom = top + gy
	return left, top, right, bottom
end
lib.get_absolute_grid_square = get_absolute_grid_square

local function get_box_parity(bbox)
	local l, t, r, b = bbox_get(bbox)
	local px = floor(r - l) % 2
	local py = floor(b - t) % 2
	return px, py
end

---@return number x
---@return number y
local function snap_1x1(bbox, pos)
	local dx_parity, dy_parity = get_box_parity(bbox)
	local x, y = pos_get(pos)
	if dx_parity == 0 then
		x = floor(x + 0.5)
	else
		x = floor(x) + 0.5
	end
	if dy_parity == 0 then
		y = floor(y + 0.5)
	else
		y = floor(y) + 0.5
	end
	return x, y
end
lib.snap_1x1 = snap_1x1

-- TODO: This is a copypasta to avoid circular deps. Refactor later.
local function get_blueprint_entity_pos(
	bp_entity,
	bp_center,
	bp_rot_n,
	flip_horizontal,
	flip_vertical
)
	-- Get bpspace position
	local epos = pos_new(bp_entity.position)
	return pos_blueprint_transform(
		epos,
		bp_center,
		bp_rot_n,
		flip_horizontal,
		flip_vertical
	)
end

local function is_valid_box_snap_point(snap_point, box_parity_x, box_parity_y)
	-- 0 = point, 1 = tile center
	local point_parity_x = floor(snap_point[1] * 2) % 2
	local point_parity_y = floor(snap_point[2] * 2) % 2
	return point_parity_x == box_parity_x and point_parity_y == box_parity_y
end

---@param snap_point MapPosition
---@param snap_entity_pos MapPosition
local function is_valid_entity_snap_point(
	snap_point,
	snap_entity_pos,
	snap_parity_x,
	snap_parity_y
)
	local epos = pos_new(snap_entity_pos)
	pos_add(epos, 1, snap_point)
	local ex, ey = pos_get(epos)
	ex = floor_approx(ex)
	ey = floor_approx(ey)
	return (ex % 2) == snap_parity_x and (ey % 2) == snap_parity_y
end

----
-- EMPIRICAL 2x2 SNAPPING OFFSET TABLE
--
-- Given a valid point, relative to the origin, to which the blueprint
-- may snap, this empirical table gives (1) which 2x2 global grid to
-- snap to, in the form of an offset (0,0), (0,1), (1,0), or (1,1)
-- and (2) the nudge value to offset the center point within the snapped
-- grid square.
--
-- The 16 valid snap points are classified in rings of (taxicab) distance
-- from the origin.
--
-- The fields are:
-- [1] = Valid snap point relative to the world origin.
-- [2] = Generic global grid offset to use for this point.
-- [3] = Generic nudge to use for this point.
-- [4] = Mod4 grid offsets for this point, if any.
-- [5] = Mod4 nudges for this point, if any.
--
-- For odd-parity snap points (i.e. points that snap onto a tile rather
-- than the grid), the snapping further depends, for some reason, on the
-- size mod 4 of the blueprint's bounding box along the odd axis.
-- These cases are broken down in the fourth and fifth entries.
-- Cases use the following mapping from mod-4 size to case index:
--
-- For OddxOdd bboxes: (1,1), (3,1), (1,3), (3,3)
-- For EvenxOdd or OddxEven bboxes: (1,e), (3,e) or (e,1), (e,3)
----
local points_and_offsets = {
	---- RING 0
	-- Point 0,0
	{ { 0, 0 }, { 1, 1 }, { 0, 0 } },
	---- RING 1
	-- Point 0.5,0
	{
		{ 0.5, 0 },
		{ 0, 1 },
		{ -0.5, 0 },
		{ { 0, 1 }, { 1, 1 } },
		{
			{ -0.5, 0 },
			{ 0.5, 0 },
		},
	},
	-- Point 0,0.5
	{
		{ 0, 0.5 },
		{ 1, 0 },
		{ 0, -0.5 },
		{ { 1, 0 }, { 1, 1 } },
		{
			{ 0, -0.5 },
			{ 0, 0.5 },
		},
	},
	---- RING 2
	-- Point 1,0
	{ { 1, 0 }, { 0, 1 }, { 0, 0 } },
	-- Point 0.5,0.5
	{
		{ 0.5, 0.5 },
		{ 1, 1 },
		{ 0.5, 0.5 },
		{ { 1, 1 }, { 1, 0 }, { 1, 1 }, { 1, 1 } },
		{ { 0.5, 0.5 }, { 0.5, -0.5 }, { 0.5, 0.5 }, { 0.5, 0.5 } },
	},
	-- Point 0,1
	{ { 0, 1 }, { 1, 0 }, { 0, 0 } },
	---- RING 3
	-- Point 1.5,0
	{
		{ 1.5, 0 },
		{ 0, 1 },
		{ -0.5, 0 },
		{ { 0, 1 }, { 1, 1 } },
		{ { 0.5, 0 }, { -0.5, 0 } },
	},
	-- Point 1,0.5
	{
		{ 1, 0.5 },
		{ 0, 1 },
		{ 0, 0.5 },
		{ { 0, 0 }, { 0, 1 } },
		{
			{ 0, -0.5 },
			{ 0, 0.5 },
		},
	},
	-- Point 0.5,1
	{
		{ 0.5, 1 },
		{ 1, 0 },
		{ 0.5, 0 },
		{ { 1, 0 }, { 1, 0 } },
		{
			{ 0.5, 0 },
			{ 0.5, 0 },
		},
	},
	-- Point 0,1.5
	{
		{ 0, 1.5 },
		{ 1, 0 },
		{ 0, 0.5 },
		{ { 1, 0 }, { 1, 1 } },
		{
			{ 0, 0.5 },
			{ 0, -0.5 },
		},
	},
	---- RING 4
	-- Point 1.5,0.5
	{
		{ 1.5, 0.5 },
		{ 0, 1 },
		{ 0.5, 0.5 },
		{ { 0, 0 }, { 0, 1 }, { 0, 1 }, { 0, 1 } },
		{ { 0.5, -0.5 }, { 0.5, 0.5 }, { 0.5, 0.5 }, { 0.5, 0.5 } },
	},
	-- Point 1,1
	{ { 1, 1 }, { 0, 0 }, { 0, 0 } },
	-- Point 0.5,1.5
	{
		{ 0.5, 1.5 },
		{ 1, 1 },
		{ 0.5, -0.5 },
		{ { 1, 1 }, { 1, 0 }, { 0, 1 }, { 1, 1 } },
		{ { 0.5, -0.5 }, { 0.5, 0.5 }, { -0.5, -0.5 }, { 0.5, -0.5 } },
	},
	---- RING 5
	-- Point 1.5,1
	{ { 1.5, 1 }, { 0, 0 }, { 0.5, 0 } },
	-- Point 1,1.5
	{
		{ 1, 1.5 },
		{ 0, 0 },
		{ 0, 0.5 },
		{ { 0, 0 }, { 0, 1 } },
		{
			{ 0, 0.5 },
			{ 0, -0.5 },
		},
	},
	---- RING 6
	-- Point 1.5,1.5
	{
		{ 1.5, 1.5 },
		{ 0, 1 },
		{ 0.5, -0.5 },
		{
			{ 1, 1 },
			{ 1, 0 },
			{ 0, 1 },
			{ 1, 1 },
		},
		{
			{ 0.5, -0.5 },
			{ -0.5, 0.5 },
			{ 0.5, -0.5 },
			{ -0.5, -0.5 },
		},
	},
}

---@param w integer Width of blueprint bbox in tiles
---@param h integer Height of blueprint bbox in tiles
---@return MapPosition offset
---@return MapPosition nudge
---@return MapPosition snap_point
local function find_global_grid_offset(
	w,
	h,
	snap_entity_pos,
	snap_parity_x,
	snap_parity_y
)
	local box_parity_x, box_parity_y = w % 2, h % 2
	for i = 1, #points_and_offsets do
		local pain = points_and_offsets[i]
		local point = pain[1]
		local offset = pain[2]
		local nudge = pain[3] or EMPTY
		local offsets = pain[4]
		local nudges = pain[5]
		local valid_box = is_valid_box_snap_point(point, box_parity_x, box_parity_y)
		local valid_entity = is_valid_entity_snap_point(
			point,
			snap_entity_pos,
			snap_parity_x,
			snap_parity_y
		)
		if valid_box and valid_entity then
			-- Mod-4 subcases
			local w_mod_4, h_mod_4 = w % 4, h % 4
			local case = nil
			if w_mod_4 == 1 and h_mod_4 == 1 then
				case = 1
			elseif w_mod_4 == 3 and h_mod_4 == 1 then
				case = 2
			elseif w_mod_4 == 1 and h_mod_4 == 3 then
				case = 3
			elseif w_mod_4 == 3 and h_mod_4 == 3 then
				case = 4
			elseif box_parity_x == 0 and h_mod_4 == 1 then
				case = 1
			elseif box_parity_x == 0 and h_mod_4 == 3 then
				case = 2
			elseif box_parity_y == 0 and w_mod_4 == 1 then
				case = 1
			elseif box_parity_y == 0 and w_mod_4 == 3 then
				case = 2
			end
			---@diagnostic disable-next-line: undefined-field
			if case and offsets then offset = offsets[case] end
			---@diagnostic disable-next-line: undefined-field
			if case and nudges then nudge = nudges[case] end
			---@diagnostic disable-next-line: need-check-nil
			local grid_offset_x, grid_offset_y = offset[1], offset[2]
			---@diagnostic disable-next-line: need-check-nil
			local nudge_x, nudge_y = nudge[1] or 0, nudge[2] or 0
			strace.trace(
				"BPLIB: SNAP: point",
				point,
				"is valid with offset",
				grid_offset_x,
				grid_offset_y,
				"nudge",
				nudge_x,
				nudge_y,
				"mod4s",
				w_mod_4,
				h_mod_4,
				"case",
				case
			)
			-- game.print({
			-- 	"",
			-- 	"Point is ",
			-- 	serpent.line(point),
			-- 	" size is ",
			-- 	w,
			-- 	"x",
			-- 	h,
			-- 	" (mod4 case ",
			-- 	case,
			-- 	": ",
			-- 	w_mod_4,
			-- 	",",
			-- 	h_mod_4,
			-- 	") global grid offset is ",
			-- 	grid_offset_x,
			-- 	",",
			-- 	grid_offset_y,
			-- 	" nudge is ",
			-- 	nudge_x,
			-- 	",",
			-- 	nudge_y,
			-- })
			return { grid_offset_x, grid_offset_y }, { nudge_x, nudge_y }, point
		end
	end

	-- This should never happen.
	error("LOGIC ERROR: No valid global grid offset found.")
end

local ZERO_DIRECTION = 0 --[[@as defines.direction]]

---@param snap_entity BlueprintEntity
local function get_snap_entity_geometry(
	snap_entity,
	bp_center,
	bp_rot_n,
	flip_horizontal,
	flip_vertical
)
	-- XXX: TYPES: FMTK string union bug
	---@diagnostic disable-next-line: param-type-mismatch
	local proto = proto_lib.get_prototype_geometry(snap_entity.name)
	if (not proto) or (proto.build_grid_size ~= 2) then
		error(
			"LOGIC ERROR: snap entity "
				.. snap_entity.name
				.. " is not a valid 2x2 snap entity"
		)
	end

	-- Determine parities
	local snap_parity_x, snap_parity_y = 1, 1
	if proto.parity_table then
		local parity_table = proto.parity_table
		local parity_entry = parity_table[snap_entity.direction or ZERO_DIRECTION]
			or parity_table[ZERO_DIRECTION]
		if parity_entry then
			snap_parity_x, snap_parity_y = parity_entry[1], parity_entry[2]
		end
	end
	-- Swap x and y parities if the blueprint is rotated.
	if bp_rot_n % 2 == 1 then
		snap_parity_x, snap_parity_y = snap_parity_y, snap_parity_x
	end

	local snap_entity_pos = get_blueprint_entity_pos(
		snap_entity,
		bp_center,
		bp_rot_n,
		flip_horizontal,
		flip_vertical
	)
	return snap_entity_pos, snap_parity_x, snap_parity_y
end

local function snap_2x2(
	pos,
	bbox,
	snap_entity,
	bp_center,
	bp_rot_n,
	flip_horizontal,
	flip_vertical,
	debug_render_surface
)
	local x, y = pos_get(pos)
	local l, t, r, b = bbox_get(bbox)
	local w = floor_approx(r - l)
	local h = floor_approx(b - t)
	local snap_entity_pos, parity_x, parity_y = get_snap_entity_geometry(
		snap_entity,
		bp_center,
		bp_rot_n,
		flip_horizontal,
		flip_vertical
	)
	local offset, nudge =
		find_global_grid_offset(w, h, snap_entity_pos, parity_x, parity_y)
	local ox, oy = pos_get(offset)
	local gl, gt, gr, gb = get_absolute_grid_square(x, y, 2, 2, ox, oy)
	if debug_render_surface then
		-- Debug: draw green box around computed absolute gridsquare
		rendering.draw_rectangle({
			color = { r = 0, g = 1, b = 0, a = 1 },
			width = 3,
			filled = false,
			left_top = { gl, gt },
			right_bottom = { gr, gb },
			surface = debug_render_surface,
			time_to_live = 1800,
		})
	end
	local square_center = pos_new((gl + gr) / 2, (gt + gb) / 2)
	if nudge then pos_add(square_center, 1, nudge) end
	return square_center
end
lib.snap_2x2 = snap_2x2

---@param cursor_pos MapPosition Cursor position in world space.
---@param bbox BoundingBox Transformed bpspace bbox.
---@param snap_entity BlueprintEntity|nil Entity governing snapping, if any
---@param bp_center? MapPosition Blueprint center in bpspace.
---@param bp_rot_n? int Blueprint rotation in 90 degree increments.
---@param flip_horizontal? boolean?
---@param flip_vertical? boolean?
---@param debug_render_surface LuaSurface? If given, debug graphics will be drawn on the given surface showing blueprint placement computations.
---@return MapPosition snap_point The snap point to use.
function lib.find_snap_point(
	cursor_pos,
	bbox,
	snap_entity,
	bp_center,
	bp_rot_n,
	flip_horizontal,
	flip_vertical,
	debug_render_surface
)
	if snap_entity then
		local snapped_pos = snap_2x2(
			cursor_pos,
			bbox,
			snap_entity,
			bp_center or ZERO,
			bp_rot_n or 0,
			flip_horizontal or false,
			flip_vertical or false,
			debug_render_surface
		)
		return snapped_pos
	else
		local x, y = snap_1x1(bbox, cursor_pos)
		return { x, y }
	end
end

return lib
