local F = '__factorissimo-2-notnotmelon__';

require('circuit-connector-sprites')

local function cwc0c()
	return {shadow = {red = {0,0}, green = {0,0}, copper = {0,0}}, wire = {red = {0,0}, green = {0,0}, copper = {0,0}}}
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

local function rblank()
	return {
		filename = F..'/graphics/nothing.png',
		priority = 'high',
		width = 1,
		height = 1,
		direction_count = 1,
	}
end

local function ps()
	return {
		filename = F..'/graphics/component/pipe-connection-south.png',
		priority = 'extra-high',
		width = 44,
		height = 32,
		hr_version = {
			filename = F..'/graphics/component/hr-pipe-connection-south.png',
			priority = 'extra-high',
			width = 88,
			height = 64,
			scale = 0.5
		}
	}
end

local function blankpipepictures()
	return {
		straight_vertical_single = blank(),
		straight_vertical = blank(),
		straight_vertical_window = blank(),
		straight_horizontal_window = blank(),
		straight_horizontal = blank(),
		corner_up_right = blank(),
		corner_up_left = blank(),
		corner_down_right = blank(),
		corner_down_left = blank(),
		t_up = blank(),
		t_down = blank(),
		t_right = blank(),
		t_left = blank(),
		cross = blank(),
		ending_up = blank(),
		ending_down = blank(),
		ending_right = blank(),
		ending_left = blank(),
		horizontal_window_background = blank(),
		vertical_window_background = blank(),
		fluid_background = blank(),
		low_temperature_flow = blank(),
		middle_temperature_flow = blank(),
		high_temperature_flow = blank(),
		gas_flow = ablank(),
	}
end

local function southpipepictures()
	return {
		straight_vertical_single = blank(),
		straight_vertical = ps(),
		straight_vertical_window = ps(),
		straight_horizontal_window = blank(),
		straight_horizontal = blank(),
		corner_up_right = blank(),
		corner_up_left = blank(),
		corner_down_right = ps(),
		corner_down_left = ps(),
		t_up = blank(),
		t_down = ps(),
		t_right = ps(),
		t_left = ps(),
		cross = ps(),
		ending_up = blank(),
		ending_down = ps(),
		ending_right = blank(),
		ending_left = blank(),
		horizontal_window_background = blank(),
		vertical_window_background = blank(),
		fluid_background = blank(),
		low_temperature_flow = blank(),
		middle_temperature_flow = blank(),
		high_temperature_flow = blank(),
		gas_flow = ablank(),
	}
end

local function blankheatpipepictures()
	return {
		single = blank(),
		straight_vertical = blank(),
		straight_horizontal = blank(),
		corner_right_down = blank(),
		corner_left_down = blank(),
		corner_right_up = blank(),
		corner_left_up = blank(),
		t_up = blank(),
		t_down = blank(),
		t_right = blank(),
		t_left = blank(),
        ending_up = blank(),
		ending_down = blank(),
		ending_right = blank(),
		ending_left = blank(),
        cross = blank() 
	}
end

-- Factory power I/O

local function create_energy_interfaces(size, icon)
	local j = size/2-0.3
	data:extend{{
		type = 'electric-energy-interface',
		name = 'factory-power-input-' .. size,
		icon = icon,
		icon_size = 32,
		flags = {'not-on-map'},
		minable = nil,
		max_health = 1,
		selectable_in_game = false,
		energy_source = {
			type = 'electric',
			usage_priority = 'tertiary',
			input_flow_limit = '0W',
			output_flow_limit = '0W',
			buffer_capacity = '0J',
			render_no_power_icon = false,
		},
		energy_usage = '0MW',
		energy_production = '0MW',
		selection_box = {{-j,-j},{j,j}},
		collision_box = {{-j,-j},{j,j}},
		collision_mask = {},
		localised_name = '',
	}}
end

create_energy_interfaces(8, F..'/graphics/icon/factory-1.png')
create_energy_interfaces(12, F..'/graphics/icon/factory-2.png')
create_energy_interfaces(16, F..'/graphics/icon/factory-3.png')
create_energy_interfaces(32, F..'/graphics/icon/factory-4.png')

-- Connection indicators

data:extend{{
	type = 'item',
	name = 'factory-connection-indicator-settings',
	icon_size = 32,
	icon = F..'/graphics/indicator/blueprint-settings.png',
	stack_size = 1,
	flags = {'hidden', 'not-stackable', 'only-in-cursor'}
}}

local function create_indicator(ctype, suffix, image)
	data:extend{{
		type = 'storage-tank',
		name = 'factory-connection-indicator-' .. ctype .. '-' .. suffix,
		localised_name = {'entity-name.factory-connection-indicator-' .. ctype},
		flags = {'not-on-map', 'player-creation', 'not-deconstructable'},
		placeable_by = {item = 'factory-connection-indicator-settings', count = 1},
		max_health = 500,
		selection_box = {{-0.4,-0.4},{0.4,0.4}},
		collision_box = {{-0.4,-0.4},{0.4,0.4}},
		collision_mask = {'not-colliding-with-itself'},
		fluid_box = {
			base_area = 1,
			pipe_connections = {},
		},
		two_direction_only = false,
		window_bounding_box = {{0,0},{0,0}},
		pictures = {
			picture = {
				sheet = {
					filename = F..'/graphics/indicator/' .. image .. '.png',
					priority = 'extra-high',
					frames = 4,
					width = 32,
					height = 32
				},
			},
			fluid_background = blank(),
			window_background = blank(),
			flow_sprite = blank(),
			gas_flow = ablank(),
		},
		flow_length_in_ticks = 100,
		circuit_wire_connection_points = table.deepcopy(circuit_connector_definitions['storage-tank'].points),
		circuit_connector_sprites = table.deepcopy(circuit_connector_definitions['storage-tank'].sprites),
		circuit_wire_max_distance = 0,
		se_allow_in_space = true
	}}
end

create_indicator('belt', 'd0', 'green-dir')

create_indicator('chest', 'd0', 'brown-dir') -- 0 is catchall for "There isn't an entity for this exact value"
create_indicator('chest', 'd10', 'brown-dir')
create_indicator('chest', 'd20', 'brown-dir')
create_indicator('chest', 'd60', 'brown-dir')
create_indicator('chest', 'd180', 'brown-dir')
create_indicator('chest', 'd600', 'brown-dir')

create_indicator('chest', 'b0', 'brown-dot')
create_indicator('chest', 'b10', 'brown-dot')
create_indicator('chest', 'b20', 'brown-dot')
create_indicator('chest', 'b60', 'brown-dot')
create_indicator('chest', 'b180', 'brown-dot')
create_indicator('chest', 'b600', 'brown-dot')

create_indicator('fluid', 'd0', 'blue-dir')
create_indicator('fluid', 'd5', 'blue-dir')
create_indicator('fluid', 'd10', 'blue-dir')
create_indicator('fluid', 'd30', 'blue-dir')
create_indicator('fluid', 'd120', 'blue-dir')

create_indicator('heat', 'b0', 'yellow-dot')
create_indicator('heat', 'b5', 'yellow-dot')
create_indicator('heat', 'b10', 'yellow-dot')
create_indicator('heat', 'b30', 'yellow-dot')
create_indicator('heat', 'b120', 'yellow-dot')

create_indicator('circuit', 'b0', 'red-dot')

-- Other auxiliary entities

data:extend{{
	type = 'simple-entity-with-force',
	name = 'factory-blueprint-anchor',
	flags = {'player-creation', 'hidden', 'placeable-off-grid'},
	collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	picture = blank(),
	placeable_by = {item = 'simple-entity-with-force', count = 1}
}}

local j = 0.99
data:extend{
	{
		type = 'electric-pole',
		name = 'factory-power-pole',
		minable = nil,
		max_health = 1,
		selection_box = {{-j,-j}, {j,j}},
		collision_box = {{-j,-j}, {j,j}},
		collision_mask = {},
		flags = {'not-on-map', 'hidden'},
		maximum_wire_distance = 1,
		supply_area_distance = 64,
		pictures = table.deepcopy(data.raw['electric-pole']['substation'].pictures),
		drawing_box = table.deepcopy(data.raw['electric-pole']['substation'].drawing_box),
		radius_visualisation_picture = blank(),
		connection_points = {cwc0c(), cwc0c(), cwc0c(), cwc0c()},
	},
	{
		type = 'electric-pole',
		name = 'factory-overflow-pole',
		minable = nil,
		max_health = 1,
		selection_box = {{-j,-j}, {j,j}},
		collision_box = {{-j,-j}, {j,j}},
		collision_mask = {},
		flags = {'not-on-map', 'hidden'},
		maximum_wire_distance = 1,
		supply_area_distance = 64,
		pictures = rblank(),
		radius_visualisation_picture = blank(),
		connection_points = {cwc0c()},
		localised_name = '',
		selectable_in_game = false,
        draw_copper_wires = false,
		draw_circuit_wires = false
	},
	{
		type = 'electric-pole',
		name = 'factory-power-connection',
		pictures = table.deepcopy(data.raw['electric-pole']['small-electric-pole'].pictures),
		supply_area_distance = 0,
		connection_points = {cwc0c(), cwc0c(), cwc0c(), cwc0c()},
		draw_copper_wires = false,
		maximum_wire_distance = 1,
		collision_box = table.deepcopy(data.raw['electric-pole']['small-electric-pole'].collision_box),
		selection_box = table.deepcopy(data.raw['electric-pole']['small-electric-pole'].selection_box),
		collision_mask = {},
		flags = {'not-on-map', 'hidden'},
		max_health = 1,
		radius_visualisation_picture = blank(),
		localised_name = '',
	},
}

data:extend{{
	type = 'item',
	name = 'factory-overlay-controller-settings',
	icon_size = data.raw.item['constant-combinator'].icon_size,
	icon = data.raw.item['constant-combinator'].icon,
	icon_mipmaps = data.raw.item['constant-combinator'].icon_mipmaps,
	stack_size = 1,
	flags = {'hidden', 'not-stackable', 'only-in-cursor'},
	place_result = 'factory-overlay-controller'
}}

local overlay_controller = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
overlay_controller.name = 'factory-overlay-controller'
overlay_controller.circuit_wire_max_distance = 0
overlay_controller.collision_mask = {}
data:extend{overlay_controller}

local function create_dummy_connector(dir, dx, dy, pictures)
	data:extend{{
		type = 'pipe',
		name = 'factory-fluid-dummy-connector-' .. dir,
		flags = {'not-on-map', 'hide-alt-info'},
		minable = nil,
		max_health = 500,
		selection_box = {{-0.4,-0.4},{0.4,0.4}},
		selectable_in_game = false,
		collision_box = {{-0.4,-0.4},{0.4,0.4}},
		collision_mask = {},
		fluid_box = {
			base_area = 1, -- Heresy
			pipe_connections = {
				{position = {dx, dy}, type = 'output'},
			},
		},
		horizontal_window_bounding_box = {{0,0},{0,0}},
		vertical_window_bounding_box = {{0,0},{0,0}},
		pictures = pictures,
		vehicle_impact_sound = {filename = '__base__/sound/car-metal-impact.ogg', volume = 0.65},
		localised_name = {'entity-name.pipe'}
	}}
end

-- Connectors are named by the direction they are facing,
-- so that their names can be generated using cpos.direction_in or cpos.direction_out
create_dummy_connector(defines.direction.south, 0, 1, southpipepictures())
create_dummy_connector(defines.direction.north, 0, -1, blankpipepictures())
create_dummy_connector(defines.direction.east, 1, 0, blankpipepictures())
create_dummy_connector(defines.direction.west, -1, 0, blankpipepictures())

data:extend{
    {
        type = 'radar',
        name = 'factory-hidden-radar',
        selectable_in_game = false,
        flags = {'not-on-map', 'hide-alt-info', 'hidden'},
        collision_mask = {},
        energy_per_nearby_scan = '0W',
        energy_per_sector = '1W',
        energy_source = {type = 'void'},
        energy_usage = '1W',
        max_distance_of_sector_revealed = 0,
        max_distance_of_nearby_sector_revealed = 3,
        pictures = rblank(),
        localised_name = '',
        max_health = 1
    },
    {
        type = 'heat-pipe',
        name = 'factory-heat-dummy-connector',
        selectable_in_game = false,
        flags = {'not-on-map', 'hide-alt-info', 'hidden'},
        collision_mask = {},
        collision_box = table.deepcopy(data.raw['heat-pipe']['heat-pipe'].collision_box),
        pictures = rblank(),
        localised_name = {'entity-name.heat-pipe'},
        max_health = 1,
        heat_glow_sprites = blankheatpipepictures(),
        connection_sprites = blankheatpipepictures(),
        heat_buffer = {
            max_temperature = 0,
            specific_heat = '1W',
            max_transfer = '1W',
            default_temperature = 0,
            min_working_temperature = 0,
            min_temperature_gradient = 0,
            connections = table.deepcopy(data.raw['heat-pipe']['heat-pipe'].heat_buffer.connections)
        }
    }
}
