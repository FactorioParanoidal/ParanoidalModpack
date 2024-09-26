Layout = {}

local north = defines.direction.north
local east = defines.direction.east
local south = defines.direction.south
local west = defines.direction.west

local opposite = {[north] = south, [east] = west, [south] = north, [west] = east}
local DX = {[north] = 0, [east] = 1, [south] = 0, [west] = -1}
local DY = {[north] = -1, [east] = 0, [south] = 1, [west] = 0}

local make_connection = function(id, outside_x, outside_y, inside_x, inside_y, direction_out)
	return {
		id = id,
		outside_x = outside_x,
		outside_y = outside_y,
		inside_x = inside_x,
		inside_y = inside_y,
		indicator_dx = DX[direction_out],
		indicator_dy = DY[direction_out],
		direction_in = opposite[direction_out],
		direction_out = direction_out,
	}
end
remote_api.make_connection = make_connection

local layout_generators = {
	['factory-1'] = {
		name = 'factory-1',
		tier = 1,
		inside_size = 32,
		outside_size = 8,
		inside_door_x = 0,
		inside_door_y = 16,
		outside_door_x = 0,
		outside_door_y = 4,
		outside_energy_receiver_type = 'factory-power-input-8',
		overlay_x = 0,
		overlay_y = 3,
		rectangles = {
			{
				x1 = -17, x2 = 17, y1 = -17, y2 = 17, tile = 'factory-wall-1'
			},
			{
				x1 = -16, x2 = 16, y1 = -16, y2 = 16, tile = 'factory-floor'
			},
			{
				x1 = -3, x2 = 3, y1 = 16, y2 = 19, tile = 'factory-wall-1'
			},
			{
				x1 = -2, x2 = 2, y1 = 16, y2 = 19, tile = 'factory-entrance'
			},
		},
		mosaics = {
			{	x1 = -4, x2 = 4, y1 = -4, y2 = 4, tile = 'factory-pattern-1',
			pattern = {
				"++++++++",
				"+      +",
				"+      +",
				"+      +",
				"+      +",
				"+      +",
				"+      +",
				"++++++++",
			}
			},
		},
		connection_tile = 'factory-floor',
		connections = {
			w1 = make_connection("w1", -4.5,-2.5, -16.5,-10.5, west),
			w2 = make_connection("w2", -4.5,-1.5, -16.5,-6.5, west),
			w3 = make_connection("w3", -4.5,1.5, -16.5,6.5, west),
			w4 = make_connection("w4", -4.5,2.5, -16.5,10.5, west),

			e1 = make_connection("e1", 4.5,-2.5, 16.5,-10.5, east),
			e2 = make_connection("e2", 4.5,-1.5, 16.5,-6.5, east),
			e3 = make_connection("e3", 4.5,1.5, 16.5,6.5, east),
			e4 = make_connection("e4", 4.5,2.5, 16.5,10.5, east),

			n1 = make_connection("n1", -2.5,-4.5, -10.5,-16.5, north),
			n2 = make_connection("n2", -1.5,-4.5, -6.5,-16.5, north),
			n3 = make_connection("n3", 1.5,-4.5, 6.5,-16.5, north),
			n4 = make_connection("n4", 2.5,-4.5, 10.5,-16.5, north),

			s1 = make_connection("s1", -2.5,4.5, -10.5,16.5, south),
			s2 = make_connection("s2", -1.5,4.5, -6.5,16.5, south),
			s3 = make_connection("s3", 1.5,4.5, 6.5,16.5, south),
			s4 = make_connection("s4", 2.5,4.5, 10.5,16.5, south),
		},
		overlays = {
			outside_x = 0,
			outside_y = -1,
			outside_w = 8,
			outside_h = 6,
			inside_x = 3.5,
			inside_y = 17.5,
		},
	},
	['factory-2'] = {
		name = 'factory-2',
		tier = 2,
		inside_size = 48,
		outside_size = 12,
		inside_door_x = 0,
		inside_door_y = 24,
		outside_door_x = 0,
		outside_door_y = 6,
		outside_energy_receiver_type = 'factory-power-input-12',
		overlay_x = 0,
		overlay_y = 5,
		rectangles = {
			{
				x1 = -25, x2 = 25, y1 = -25, y2 = 25, tile = 'factory-wall-2'
			},
			{
				x1 = -24, x2 = 24, y1 = -24, y2 = 24, tile = 'factory-floor'
			},
			{
				x1 = -3, x2 = 3, y1 = 24, y2 = 27, tile = 'factory-wall-2'
			},
			{
				x1 = -2, x2 = 2, y1 = 24, y2 = 27, tile = 'factory-entrance'
			},
		},
		mosaics = {
			{	x1 = -6, x2 = 6, y1 = -6, y2 = 6, tile = 'factory-pattern-2',
				pattern = {
					'++++++++++++',
					'+   +  +   +',
					'+ ++++++++ +',
					'+ +      + +',
					'+++      +++',
					'+ +      + +',
					'+ +      + +',
					'+++      +++',
					'+ +      + +',
					'+ ++++++++ +',
					'+   +  +   +',
					'++++++++++++',
				}
			},
		},
		connection_tile = 'factory-floor',
		connections = {
			w1 = make_connection("w1", -6.5,-4.5, -24.5,-18.5, west),
			w2 = make_connection("w2", -6.5,-3.5, -24.5,-14.5, west),
			w3 = make_connection("w3", -6.5,-2.5, -24.5,-6.5, west),
			w4 = make_connection("w4", -6.5,2.5, -24.5,6.5, west),
			w5 = make_connection("w5", -6.5,3.5, -24.5,14.5, west),
			w6 = make_connection("w6", -6.5,4.5, -24.5,18.5, west),

			e1 = make_connection("e1", 6.5,-4.5, 24.5,-18.5, east),
			e2 = make_connection("e2", 6.5,-3.5, 24.5,-14.5, east),
			e3 = make_connection("e3", 6.5,-2.5, 24.5,-6.5, east),
			e4 = make_connection("e4", 6.5,2.5, 24.5,6.5, east),
			e5 = make_connection("e5", 6.5,3.5, 24.5,14.5, east),
			e6 = make_connection("e6", 6.5,4.5, 24.5,18.5, east),

			n1 = make_connection("n1", -4.5,-6.5, -18.5,-24.5, north),
			n2 = make_connection("n2", -3.5,-6.5, -14.5,-24.5, north),
			n3 = make_connection("n3", -2.5,-6.5, -6.5,-24.5, north),
			n4 = make_connection("n4", 2.5,-6.5, 6.5,-24.5, north),
			n5 = make_connection("n5", 3.5,-6.5, 14.5,-24.5, north),
			n6 = make_connection("n6", 4.5,-6.5, 18.5,-24.5, north),

			s1 = make_connection("s1", -4.5,6.5, -18.5,24.5, south),
			s2 = make_connection("s2", -3.5,6.5, -14.5,24.5, south),
			s3 = make_connection("s3", -2.5,6.5, -6.5,24.5, south),
			s4 = make_connection("s4", 2.5,6.5, 6.5,24.5, south),
			s5 = make_connection("s5", 3.5,6.5, 14.5,24.5, south),
			s6 = make_connection("s6", 4.5,6.5, 18.5,24.5, south),
		},
		overlays = {
			outside_x = 0,
			outside_y = -1,
			outside_w = 12,
			outside_h = 10,
			inside_x = 3.5,
			inside_y = 25.5,
		},
	},
	['factory-3'] = {
		name = 'factory-3',
		tier = 3,
		inside_size = 64,
		outside_size = 16,
		inside_door_x = 0,
		inside_door_y = 32,
		outside_door_x = 0,
		outside_door_y = 8,
		outside_energy_receiver_type = 'factory-power-input-16',
		overlay_x = 0,
		overlay_y = 7,
		rectangles = {
			{
				x1 = -33, x2 = 33, y1 = -33, y2 = 33, tile = 'factory-wall-3'
			},
			{
				x1 = -32, x2 = 32, y1 = -32, y2 = 32, tile = 'factory-floor'
			},
			{
				x1 = -3, x2 = 3, y1 = 32, y2 = 35, tile = 'factory-wall-3'
			},
			{
				x1 = -2, x2 = 2, y1 = 32, y2 = 35, tile = 'factory-entrance'
			},
		},
		mosaics = {
			{	x1 = -8, x2 = 8, y1 = -8, y2 = 8, tile = 'factory-pattern-3',
				pattern = {
					'++++++++++++++++',
					'+   +      +   +',
					'+ ++++++++++++ +',
					'+ +   +  +   + +',
					'+++ ++++++++ +++',
					'+ + +      + + +',
					'+ +++      +++ +',
					'+ + +      + + +',
					'+ + +      + + +',
					'+ +++      +++ +',
					'+ + +      + + +',
					'+++ ++++++++ +++',
					'+ +   +  +   + +',
					'+ ++++++++++++ +',
					'+   +      +   +',
					'++++++++++++++++',
				}
			},
		},
		connection_tile = 'factory-floor',
		connections = {
			w1 = make_connection("w1", -8.5,-5.5, -32.5,-26.5, west),
			w2 = make_connection("w2", -8.5,-4.5, -32.5,-22.5, west),
			w3 = make_connection("w3", -8.5,-3.5, -32.5,-10.5, west),
			w4 = make_connection("w4", -8.5,-2.5, -32.5,-6.5, west),
			w5 = make_connection("w5", -8.5,2.5, -32.5,6.5, west),
			w6 = make_connection("w6", -8.5,3.5, -32.5,10.5, west),
			w7 = make_connection("w7", -8.5,4.5, -32.5,22.5, west),
			w8 = make_connection("w8", -8.5,5.5, -32.5,26.5, west),

			e1 = make_connection("e1", 8.5,-5.5, 32.5,-26.5, east),
			e2 = make_connection("e2", 8.5,-4.5, 32.5,-22.5, east),
			e3 = make_connection("e3", 8.5,-3.5, 32.5,-10.5, east),
			e4 = make_connection("e4", 8.5,-2.5, 32.5,-6.5, east),
			e5 = make_connection("e5", 8.5,2.5, 32.5,6.5, east),
			e6 = make_connection("e6", 8.5,3.5, 32.5,10.5, east),
			e7 = make_connection("e7", 8.5,4.5, 32.5,22.5, east),
			e8 = make_connection("e8", 8.5,5.5, 32.5,26.5, east),

			n1 = make_connection("n1", -5.5,-8.5, -26.5,-32.5, north),
			n2 = make_connection("n2", -4.5,-8.5, -22.5,-32.5, north),
			n3 = make_connection("n3", -3.5,-8.5, -10.5,-32.5, north),
			n4 = make_connection("n4", -2.5,-8.5, -6.5,-32.5, north),
			n5 = make_connection("n5", 2.5,-8.5, 6.5,-32.5, north),
			n6 = make_connection("n6", 3.5,-8.5, 10.5,-32.5, north),
			n7 = make_connection("n7", 4.5,-8.5, 22.5,-32.5, north),
			n8 = make_connection("n8", 5.5,-8.5, 26.5,-32.5, north),

			s1 = make_connection("s1", -5.5,8.5, -26.5,32.5, south),
			s2 = make_connection("s2", -4.5,8.5, -22.5,32.5, south),
			s3 = make_connection("s3", -3.5,8.5, -10.5,32.5, south),
			s4 = make_connection("s4", -2.5,8.5, -6.5,32.5, south),
			s5 = make_connection("s5", 2.5,8.5, 6.5,32.5, south),
			s6 = make_connection("s6", 3.5,8.5, 10.5,32.5, south),
			s7 = make_connection("s7", 4.5,8.5, 22.5,32.5, south),
			s8 = make_connection("s8", 5.5,8.5, 26.5,32.5, south),
		},
		overlays = {
			outside_x = 0,
			outside_y = -1,
			outside_w = 16,
			outside_h = 14,
			inside_x = 3.5,
			inside_y = 33.5,
		},
	},
	['factory-4'] = {
		name = 'factory-4',
		tier = 4,
		inside_size = 128,
		outside_size = 32,
		inside_door_x = 0,
		inside_door_y = 64,
		outside_door_x = 0,
		outside_door_y = 16,
		outside_energy_receiver_type = 'factory-power-input-32',
		overlay_x = 0,
		overlay_y = 15,
		rectangles = {
			{
				x1 = -65, x2 = 65, y1 = -65, y2 = 65, tile = 'factory-wall-4'
			},
			{
				x1 = -64, x2 = 64, y1 = -64, y2 = 64, tile = 'factory-floor'
			},
			{
				x1 = -3, x2 = 3, y1 = 64, y2 = 67, tile = 'factory-wall-4'
			},
			{
				x1 = -2, x2 = 2, y1 = 64, y2 = 67, tile = 'factory-entrance'
			},
		},
		mosaics = {
			{	x1 = -16, x2 = 16, y1 = -16, y2 = 16, tile = 'factory-pattern-4',
				pattern = {
					'++++++++++++++++++++++++++++++++',
					'+   +      +   ++   +      +   +',
					'+ ++++++++++++ ++ ++++++++++++ +',
					'+ +   +  +   +    +   +  +   + +',
					'+++ ++++++++ ++++++ ++++++++ +++',
					'+ + +      + +    + +      + + +',
					'+ +++      +++    +++      +++ +',
					'+ + +      + +    + +      + + +',
					'+ + +   ++++++++++++++++   + + +',
					'+ +++   +   +      +   +   +++ +',
					'+ + +   + ++++++++++++ +   + + +',
					'+++ +++++ +   +  +   + +++++ +++',
					'+ +   + +++ ++++++++ +++ +   + +',
					'+ +++++++ + +      + + +++++++ +',
					'+   +   + +++      +++ +   +   +',
					'+++ +   + + +      + + +   + +++',
					'+++ +   + + +      + + +   + +++',
					'+   +   + +++      +++ +   +   +',
					'+ +++++++ + +      + + +++++++ +',
					'+ +   + +++ ++++++++ +++ +   + +',
					'+++ +++++ +   +  +   + +++++ +++',
					'+ + +   + ++++++++++++ +   + + +',
					'+ +++   +   +      +   +   +++ +',
					'+ + +   ++++++++++++++++   + + +',
					'+ + +      + +    + +      + + +',
					'+ +++      +++    +++      +++ +',
					'+ + +      + +    + +      + + +',
					'+++ ++++++++ ++++++ ++++++++ +++',
					'+ +   +  +   +    +   +  +   + +',
					'+ ++++++++++++ ++ ++++++++++++ +',
					'+   +      +   ++   +      +   +',
					'++++++++++++++++++++++++++++++++',
				}
			},
		},
		connection_tile = 'factory-floor',
		connections = {
			w1 = make_connection("w1", -16.5,-13.5, -64.5,-58.5, west),
			w2 = make_connection("w2", -16.5,-12.5, -64.5,-54.5, west),
			w3 = make_connection("w3", -16.5,-11.5, -64.5,-42.5, west),
			w4 = make_connection("w4", -16.5,-10.5, -64.5,-38.5, west),
			w5 = make_connection("w5", -16.5,-5.5, -64.5,-26.5, west),
			w6 = make_connection("w6", -16.5,-4.5, -64.5,-22.5, west),
			w7 = make_connection("w7", -16.5,-3.5, -64.5,-10.5, west),
			w8 = make_connection("w8", -16.5,-2.5, -64.5,-6.5, west),
			w9 = make_connection("w9", -16.5,2.5, -64.5,6.5, west),
			w10 = make_connection("w10", -16.5,3.5, -64.5,10.5, west),
			w11 = make_connection("w11", -16.5,4.5, -64.5,22.5, west),
			w12 = make_connection("w12", -16.5,5.5, -64.5,26.5, west),
			w13 = make_connection("w13", -16.5,10.5, -64.5,38.5, west),
			w14 = make_connection("w14", -16.5,11.5, -64.5,42.5, west),
			w15 = make_connection("w15", -16.5,12.5, -64.5,54.5, west),
			w16 = make_connection("w16", -16.5,13.5, -64.5,58.5, west),

			e1 = make_connection("e1", 16.5,-13.5, 64.5,-58.5, east),
			e2 = make_connection("e2", 16.5,-12.5, 64.5,-54.5, east),
			e3 = make_connection("e3", 16.5,-11.5, 64.5,-42.5, east),
			e4 = make_connection("e4", 16.5,-10.5, 64.5,-38.5, east),
			e5 = make_connection("e5", 16.5,-5.5, 64.5,-26.5, east),
			e6 = make_connection("e6", 16.5,-4.5, 64.5,-22.5, east),
			e7 = make_connection("e7", 16.5,-3.5, 64.5,-10.5, east),
			e8 = make_connection("e8", 16.5,-2.5, 64.5,-6.5, east),
			e9 = make_connection("e9", 16.5,2.5, 64.5,6.5, east),
			e10 = make_connection("e10", 16.5,3.5, 64.5,10.5, east),
			e11 = make_connection("e11", 16.5,4.5, 64.5,22.5, east),
			e12 = make_connection("e12", 16.5,5.5, 64.5,26.5, east),
			e13 = make_connection("e13", 16.5,10.5, 64.5,38.5, east),
			e14 = make_connection("e14", 16.5,11.5, 64.5,42.5, east),
			e15 = make_connection("e15", 16.5,12.5, 64.5,54.5, east),
			e16 = make_connection("e16", 16.5,13.5, 64.5,58.5, east),

			n1 = make_connection("n1", -13.5,-16.5, -58.5,-64.5, north),
			n2 = make_connection("n2", -12.5,-16.5, -54.5,-64.5, north),
			n3 = make_connection("n3", -11.5,-16.5, -42.5,-64.5, north),
			n4 = make_connection("n4", -10.5,-16.5, -38.5,-64.5, north),
			n5 = make_connection("n5", -5.5,-16.5, -26.5,-64.5, north),
			n6 = make_connection("n6", -4.5,-16.5, -22.5,-64.5, north),
			n7 = make_connection("n7", -3.5,-16.5, -10.5,-64.5, north),
			n8 = make_connection("n8", -2.5,-16.5, -6.5,-64.5, north),
			n9 = make_connection("n9", 2.5,-16.5, 6.5,-64.5, north),
			n10 = make_connection("n10", 3.5,-16.5, 10.5,-64.5, north),
			n11 = make_connection("n11", 4.5,-16.5, 22.5,-64.5, north),
			n12 = make_connection("n12", 5.5,-16.5, 26.5,-64.5, north),
			n13 = make_connection("n13", 10.5,-16.5, 38.5,-64.5, north),
			n14 = make_connection("n14", 11.5,-16.5, 42.5,-64.5, north),
			n15 = make_connection("n15", 12.5,-16.5, 54.5,-64.5, north),
			n16 = make_connection("n16", 13.5,-16.5, 58.5,-64.5, north),

			s1 = make_connection("s1", -13.5,16.5, -58.5,64.5, south),
			s2 = make_connection("s2", -12.5,16.5, -54.5,64.5, south),
			s3 = make_connection("s3", -11.5,16.5, -42.5,64.5, south),
			s4 = make_connection("s4", -10.5,16.5, -38.5,64.5, south),
			s5 = make_connection("s5", -5.5,16.5, -26.5,64.5, south),
			s6 = make_connection("s6", -4.5,16.5, -22.5,64.5, south),
			s7 = make_connection("s7", -3.5,16.5, -10.5,64.5, south),
			s8 = make_connection("s8", -2.5,16.5, -6.5,64.5, south),
			s9 = make_connection("s9", 2.5,16.5, 6.5,64.5, south),
			s10 = make_connection("s10", 3.5,16.5, 10.5,64.5, south),
			s11 = make_connection("s11", 4.5,16.5, 22.5,64.5, south),
			s12 = make_connection("s12", 5.5,16.5, 26.5,64.5, south),
			s13 = make_connection("s13", 10.5,16.5, 38.5,64.5, south),
			s14 = make_connection("s14", 11.5,16.5, 42.5,64.5, south),
			s15 = make_connection("s15", 12.5,16.5, 54.5,64.5, south),
			s16 = make_connection("s16", 13.5,16.5, 58.5,64.5, south),

		},
		overlays = {
			outside_x = 0,
			outside_y = -1,
			outside_w = 32,
			outside_h = 30,
			inside_x = 3.5,
			inside_y = 65.5,
		},
	}
}

local function init()
	global.layout_generators = global.layout_generators or layout_generators
end
Layout.init = init

remote_api.add_layout = function(layout)
	init()
	global.layout_generators[layout.name] = layout
end

function has_layout(name)
	return global.layout_generators[name] ~= nil
end
remote_api.has_layout = has_layout
Layout.has_layout = has_layout

local function create_layout(name)
	local layout = global.layout_generators[name]
	if layout then
		return table.deepcopy(layout)
	else
		return nil
	end
end
remote_api.create_layout = create_layout
Layout.create_layout = create_layout
