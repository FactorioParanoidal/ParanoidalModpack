local F = '__factorissimo-2-notnotmelon__';
local alt_graphics = settings.startup['Factorissimo2-alt-graphics'].value and '-alt' or ''
require('circuit-connector-sprites')

local function cwc0()
	return {shadow = {red = {0,0},green = {0,0}}, wire = {red = {0,0},green = {0,0}}}
end
local function cc0()
	return get_circuit_connector_sprites({0,0},nil,1)
end
local function blank()
	return {
		filename = F..'/graphics/nothing.png',
		priority = 'high',
		width = 1,
		height = 1,
	}
end
local function ablank()
	return {
		filename = F..'/graphics/nothing.png',
		priority = 'high',
		width = 1,
		height = 1,
		frame_count = 1,
	}
end	
	
data:extend{
	{
		type = 'storage-tank',
		name = 'factory-1',
		icon = F..'/graphics/icon/factory-1.png',
		icon_size = 64,
		flags = {'player-creation'},
		minable = {mining_time = 1, result = 'factory-1', count = 1},
		max_health = 2000,
		collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
		selection_box = {{-3.8, -3.8}, {3.8, 3.8}},
		vehicle_impact_sound = { filename = '__base__/sound/car-stone-impact.ogg', volume = 1.0 },
		pictures = {
			picture = {
				layers = {
					{
						filename = F..'/graphics/factory/factory-1-shadow.png',
						width = 416,
						height = 320,
						shift = {1.5, 0},
						draw_as_shadow = true
					},
					{
						filename = F..'/graphics/factory/factory-1'..alt_graphics..'.png',
						width = 416,
						height = 320,
						shift = {1.5, 0},
					}
				}
			},
			fluid_background = blank(),
			window_background = blank(),
			flow_sprite = blank(),
			gas_flow = ablank(),
		},
		window_bounding_box = {{0,0},{0,0}},
		fluid_box = {
			base_area = 1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {},
		},
		flow_length_in_ticks = 1,
		circuit_wire_connection_points = circuit_connector_definitions['storage-tank'].points,
		circuit_connector_sprites = circuit_connector_definitions['storage-tank'].sprites,
		circuit_wire_max_distance = 0,
		map_color = {r = 0.8, g = 0.7, b = 0.55},
		is_military_target = true
	},
	{
		type = 'item-with-tags',
		name = 'factory-1',
		icon = F..'/graphics/icon/factory-1.png',
		icon_size = 64,
		subgroup = 'factorissimo2',
		order = 'a-a',
		place_result = 'factory-1',
		stack_size = 1
	},
	{
		type = 'item',
		name = 'factory-1-raw',
		icon = F..'/graphics/icon/factory-1.png',
		icon_size = 64,
		subgroup = 'factorissimo2',
		order = 'a-a',
		place_result = 'factory-1',
		stack_size = 1,
		flags = {'primary-place-result'}
	}
}

data:extend{
	{
		type = 'storage-tank',
		name = 'factory-2',
		icon = F..'/graphics/icon/factory-2.png',
		icon_size = 64,
		flags = {'player-creation'},
		minable = {mining_time = 1, result = 'factory-2', count = 1},
		max_health = 3500,
		collision_box = {{-5.8, -5.8}, {5.8, 5.8}},
		selection_box = {{-5.8, -5.8}, {5.8, 5.8}},
		vehicle_impact_sound = { filename = '__base__/sound/car-stone-impact.ogg', volume = 1.0 },
		pictures = {
			picture = {
				layers = {
					{
						filename = F..'/graphics/factory/factory-2-shadow.png',
						width = 544,
						height = 448,
						shift = {1.5, 0},
						draw_as_shadow = true
					},
					{
						filename = F..'/graphics/factory/factory-2'..alt_graphics..'.png',
						width = 544,
						height = 448,
						shift = {1.5, 0},
					}
				}
			},
			fluid_background = blank(),
			window_background = blank(),
			flow_sprite = blank(),
			gas_flow = ablank(),
		},
		window_bounding_box = {{0,0},{0,0}},
		fluid_box = {
			base_area = 1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {},
		},
		flow_length_in_ticks = 1,
		circuit_wire_connection_points = circuit_connector_definitions['storage-tank'].points,
		circuit_connector_sprites = circuit_connector_definitions['storage-tank'].sprites,
		circuit_wire_max_distance = 0,
		map_color = {r = 0.8, g = 0.7, b = 0.55},
		is_military_target = true
	},
	{
		type = 'item-with-tags',
		name = 'factory-2',
		icon = F..'/graphics/icon/factory-2.png',
		icon_size = 64,
		subgroup = 'factorissimo2',
		order = 'a-b',
		place_result = 'factory-2',
		stack_size = 1
	},
	{
		type = 'item',
		name = 'factory-2-raw',
		icon = F..'/graphics/icon/factory-2.png',
		icon_size = 64,
		subgroup = 'factorissimo2',
		order = 'a-b',
		place_result = 'factory-2',
		stack_size = 1,
		flags = {'primary-place-result'}
	}
}

data:extend{
	{
		type = 'storage-tank',
		name = 'factory-3',
		icon = F..'/graphics/icon/factory-3.png',
		icon_size = 64,
		flags = {'player-creation'},
		minable = {mining_time = 1, result = 'factory-3', count = 1},
		max_health = 5000,
		collision_box = {{-7.8, -7.8}, {7.8, 7.8}},
		selection_box = {{-7.8, -7.8}, {7.8, 7.8}},
		vehicle_impact_sound = { filename = '__base__/sound/car-stone-impact.ogg', volume = 1.0 },
		pictures = {
			picture = {
				layers = {
					{
						filename = F..'/graphics/factory/factory-3-shadow.png',
						width = 704,
						height = 608,
						shift = {2, -0.09375},
						draw_as_shadow = true
					},
					{
						filename = F..'/graphics/factory/factory-3'..alt_graphics..'.png',
						width = 704,
						height = 608,
						shift = {2, -0.09375},
					}
				}
			},
			fluid_background = blank(),
			window_background = blank(),
			flow_sprite = blank(),
			gas_flow = ablank(),
		},
		window_bounding_box = {{0,0},{0,0}},
		fluid_box = {
			base_area = 1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {},
		},
		flow_length_in_ticks = 1,
		circuit_wire_connection_points = circuit_connector_definitions['storage-tank'].points,
		circuit_connector_sprites = circuit_connector_definitions['storage-tank'].sprites,
		circuit_wire_max_distance = 0,
		map_color = {r = 0.8, g = 0.7, b = 0.55},
		is_military_target = true
	},
	{
		type = 'item-with-tags',
		name = 'factory-3',
		icon = F..'/graphics/icon/factory-3.png',
		icon_size = 64,
		subgroup = 'factorissimo2',
		order = 'a-c',
		place_result = 'factory-3',
		stack_size = 1
	},
	{
		type = 'item',
		name = 'factory-3-raw',
		icon = F..'/graphics/icon/factory-3.png',
		icon_size = 64,
		subgroup = 'factorissimo2',
		order = 'a-c',
		place_result = 'factory-3',
		stack_size = 1,
		flags = {'primary-place-result'}
	}
}
