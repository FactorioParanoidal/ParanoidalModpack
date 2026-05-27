local table_insert = table.insert

local cliffs = {}

local function scale_bounding_box(bb, scale)
	local orientation = bb[3] or 0
	scale = scale or 1
	return
	{
		{scale*bb[1][1], scale*bb[1][2]},
		{scale*bb[2][1], scale*bb[2][2]},
		orientation
	}
end

local sqrt2 = 1.4142135623730951
local function rotbb(x, y, size, intersect)
	local dist = size / 2 * sqrt2
	local y_ratio = intersect / size
	local x_ratio = 1 - y_ratio
	local x_dist = x_ratio * dist
	local y_dist = y_ratio * dist
	local cx = x + size / 2
	local cy = y + size / 2
	return {{cx - x_dist, cy - y_dist}, {cx + x_dist, cy + y_dist}, 1/8}
end

local function cliff_orientation(collision_box, scale)
	return scale_bounding_box(collision_box, scale)
end

local cliff_data = {
	["north-to-south"] = cliff_orientation({{-1.0, -2.0}, {1.0,  2.0}}),
	["west-to-east"]   = cliff_orientation({{-2.0, -1.5}, {2.0,  1.5}}),
	["east-to-west"]   = cliff_orientation({{-2.0, -0.5}, {2.0,  0.5}}),
	["south-to-north"] = cliff_orientation({{-1.0, -2.0}, {1.0,  2.0}}),
	["west-to-north"]  = cliff_orientation(rotbb(-3.5, -3, 4.5, 3)),
	["north-to-east"]  = cliff_orientation(rotbb(-1, -3, 4.5, 1.5)),
	["east-to-south"]  = cliff_orientation(rotbb(-1, -0.5, 3.5, 2.5)),
	["south-to-west"]  = cliff_orientation(rotbb(-2.5, -0.5, 3.5, 1)),
	["west-to-south"]  = cliff_orientation(rotbb(-3.5, -1.5, 4.5, 1.5)),
	["north-to-west"]  = cliff_orientation(rotbb(-2.5, -3, 3.5, 2.5)),
	["east-to-north"]  = cliff_orientation(rotbb(-1, -3, 3.5, 1)),
	["south-to-east"]  = cliff_orientation(rotbb(-1, -1.5, 4.5, 3)),
	["west-to-none"]   = cliff_orientation(rotbb(-3, -1.5, 3, 2)),
	["none-to-east"]   = cliff_orientation(rotbb(0, -1.5, 3, 1)),
	["east-to-none"]   = cliff_orientation(rotbb(0, -0.5, 2.5, 2)),
	["none-to-west"]   = cliff_orientation(rotbb(-2.5, -0.5, 2.51, 0.5)),
	["north-to-none"]  = cliff_orientation(rotbb(-1, -2.5, 3, 1)),
	["none-to-south"]  = cliff_orientation(rotbb(-1, -0.5, 3, 2.5)),
	["south-to-none"]  = cliff_orientation(rotbb(-2, -0.5, 3, 0.5)),
	["none-to-north"]  = cliff_orientation(rotbb(-2, -2.5, 3, 2)),
}

cliffs.cliff_data = cliff_data

local function collision_box(x1, y1, x2, y2)
	local t = {}
	for x = x1, x2 do
		for y = y1, y2 do
			table_insert(t, {x, y})
		end
	end
	return t
end

cliffs.hardcoded_collisions = {
	["north-to-south"] = collision_box(-1, -2, 0, 2),
	["west-to-east"]   = collision_box(-2, -1, 1, 1),
	["east-to-west"]   = collision_box(-2, 0, 1, 0),
	["south-to-north"] = collision_box(-1, -2, 0, 2),
	["west-to-north"]  = {
		{-1, -3},
		{-2, -2}, {-1, -2}, {0, -2},
		{-3, -1}, {-2, -1}, {-1, -1}, {0, -1},
		{-4, 0}, {-3, 0}, {-2, 0}, {-1, 0},
		{-3, 1}, {-2, 1},
	},
	["north-to-east"]  = {
		{0, -3},
		{-1, -2}, {0, -2}, {1, -2},
		{-1, -1}, {0, -1}, {1, -1}, {2, -1},
		{0, 0}, {1, 0}, {2, 0}, {3, 0},
		{1, 1}, {2, 1},
	},
	["east-to-south"]  = {
		{0, 0}, {1, 0}, {2, 0},
		{-1, 1}, {0, 1}, {1, 1}, {2, 1},
		{-1, 2}, {0, 2}, {1, 2},
		{-1, 3}, {0, 3},
	},
	["south-to-west"]  = {
		{-3, 0}, {-2, 0}, {-1, 0},
		{-3, 1}, {-2, 1}, {-1, 1}, {0, 1},
		{-2, 2}, {-1, 2}, {0, 2},
		{-1, 3}, {0, 3},
	},
	["west-to-south"]  = {
		{-3, -1}, {-2, -1},
		{-4, 0}, {-3, 0}, {-2, 0}, {-1, 0},
		{-3, 1}, {-2, 1}, {-1, 1}, {0, 1},
		{-2, 2}, {-1, 2}, {0, 2},
		{-1, 3},
	},
	["north-to-west"]  = {
		{-1, -3}, {0, -3},
		{-2, -2}, {-1, -2}, {0, -2},
		{-3, -1}, {-2, -1}, {-1, -1}, {0, -1},
		{-3, 0}, {-2, 0}, {-1, 0},
	},
	["east-to-north"]  = {
		{-1, -3}, {0, -3},
		{-1, -2}, {0, -2}, {1, -2},
		{-1, -1}, {0, -1}, {1, -1}, {2, -1},
		{0, 0}, {1, 0}, {2, 0},
	},
	["south-to-east"]  = {
		{1, -1}, {2, -1},
		{0, 0}, {1, 0}, {2, 0}, {3, 0},
		{-1, 1}, {0, 1}, {1, 1}, {2, 1},
		{-1, 2}, {0, 2}, {1, 2},
		{0, 3},
	},
	["west-to-none"]   = {
		{-2, -1}, {-1, -1},
		{-3, 0}, {-2, 0}, {-1, 0},
		{-3, 1}, {-2, 1},
	},
	["none-to-east"]   = {
		{0, -1}, {1, -1},
		{0, 0}, {1, 0}, {2, 0},
		{1, 1}, {2, 1},
	},
	["east-to-none"]   = {
		{1, 0}, {2, 0},
		{0, 1}, {1, 1},
		{0, 2},
	},
	["none-to-west"]   = {
		{-3, 0}, {-2, 0},
		{-2, 1}, {-1, 1},
		{-1, 2},
	},
	["north-to-none"]  = {
		{-1, -2}, {0, -2},
		{-1, -1}, {0, -1}, {1, -1},
		{0, 0}, {1, 0}
	},
	["none-to-south"]  = {
		{0, 0}, {1, 0},
		{-1, 1}, {0, 1}, {1, 1},
		{-1, 2}, {0, 2},
	},
	["south-to-none"]  = {
		{-2, 0}, {-1, 0},
		{-2, 1}, {-1, 1}, {0, 1},
		{-1, 2}, {0, 2},
	},
	["none-to-north"]  = {
		{-1, -2}, {0, -2},
		{-2, -1}, {-1, -1}, {0, -1},
		{-2, 0}, {-1, 0},
	},
}

return cliffs
