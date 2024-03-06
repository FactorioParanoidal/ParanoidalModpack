require 'gui-styles'

local circuit_wire_connection_points = {
	green = {0.25, -0.15},
	red = {-0.15, 0.1}
}

circuit_wire_connection_points = {
	shadow = circuit_wire_connection_points,
	wire = circuit_wire_connection_points
}

circuit_wire_connection_points = {
	circuit_wire_connection_points,
	circuit_wire_connection_points,
	circuit_wire_connection_points,
	circuit_wire_connection_points
}

local nothing = {
	filename = '__deep-storage-unit__/graphics/entity/nothing.png',
	priority = 'extra-high',
	size = 1
}

data:extend{
	{
		type = 'item',
		name = 'memory-unit',
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		stack_size = 10,
		place_result = 'memory-unit',
		order = 'c[memory-units]-a[memory-unit]',
		subgroup = 'storage',
		flags = {'primary-place-result'}
	},
	{
		type = 'item-with-tags',
		name = 'memory-unit-with-tags',
		icons = {
			{
				icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
				icon_size = 64,
				scale = 0.5
			},
			{
				icon = '__deep-storage-unit__/graphics/icon/packing-tape-50.png',
				icon_size = 64,
				icon_mipmaps = 4
			}
		},
		stack_size = 1,
		place_result = 'memory-unit',
		order = 'c[memory-units]-a[memory-unit-with-tags]',
		subgroup = 'storage',
		localised_name = {'item-name.memory-unit-with-tags'},
		localised_description = {'entity-description.memory-unit'},
		flags = {'not-stackable', 'hidden'}
	},
	{
		type = 'container',
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		name = 'memory-unit',
		inventory_size = 300,
		picture = {
			filename = '__deep-storage-unit__/graphics/entity/memory-unit.png',
			height = 256,
			priority = 'high',
			width = 256,
			shift = {0.59375, 0},
			hr_version = {
				filename = '__deep-storage-unit__/graphics/entity/hr-memory-unit.png',
				height = 512,
				priority = 'high',
				width = 512,
				scale = 0.5,
				shift = {0.59375, 0}
			}
		},
		max_health = 3000,
		minable = {mining_time = 1, result = 'memory-unit'},
		corpse = 'big-remnants',
		close_sound = {
			filename = '__base__/sound/metallic-chest-close.ogg',
			volume = 0.9
		},
		open_sound = {
			filename = '__base__/sound/metallic-chest-open.ogg',
			volume = 0.6
		},
		selection_box = {{-3, -3}, {3, 3}},
		collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
		flags = {'placeable-neutral', 'player-creation', 'not-rotatable'},
		enable_inventory_bar = false,
		se_allow_in_space = true,
		not_inventory_moveable = true,
		inventory_type = 'with_filters_and_bar'
	},
	{
		type = 'recipe',
		name = 'memory-unit',
		ingredients = {
			{'steel-chest', 4},
			{'energy-shield-equipment', 4},
			{'effectivity-module', 16}
		},
		result = 'memory-unit',
		enabled = false
	},
	{
		type = 'technology',
		name = 'memory-unit',
		icon = '__deep-storage-unit__/graphics/technology/memory-unit.png',
		icon_size = 128,
		effects = {{
			recipe = 'memory-unit',
			type = 'unlock-recipe'
		}},
		prerequisites = {
			'energy-shield-equipment',
			'effectivity-module',
			'chemical-science-pack'
		},
		unit = {
			count = 200,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
			},
			time = 30
		}
	},
	{
		type = 'electric-energy-interface',
		localised_name = {'entity-name.memory-unit'},
		localised_description = {'entity-description.memory-unit'},
		energy_source = {
			type = 'electric',
			usage_priority = 'secondary-input',
			buffer_capacity = '1J'
		},
		energy_usage = '1000W',
		collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		collision_mask = {},
		selectable_in_game = false,
		remove_decoratives = 'false',
		name = 'memory-unit-powersource',
		flags = {'placeable-neutral', 'hidden', 'not-selectable-in-game', 'not-rotatable', 'not-flammable', 'placeable-off-grid'}
	},
	{
		circuit_wire_connection_points = circuit_wire_connection_points,
		circuit_wire_max_distance = 9,
		collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		flags = {'placeable-neutral', 'hidden', 'not-deconstructable', 'not-flammable', 'not-upgradable', 'not-rotatable', 'hide-alt-info', 'placeable-off-grid'},
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		item_slot_count = 1,
		name = 'memory-unit-combinator',
		type = 'constant-combinator',
		collision_mask = {},
		remove_decoratives = 'false',
		sprites = nothing,
		activity_led_sprites = nothing,
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		selection_priority = 51,
		placeable_by = {item = 'memory-unit', count = 0}
	},
	{
		type = 'item-with-inventory', -- this is a hack to show the player's inventory gui.
		name = 'blank-gui-item',
		inventory_size = 1,
		item_filters = {'blank-gui-item'},
		stack_size = 1,
		icon = '__core__/graphics/empty.png',
		icon_size = 1,
		localised_name = '',
		flags = {'hidden', 'not-stackable'}
	},
	{
		type = 'sprite',
		name = 'bulk-insert',
		filename = '__deep-storage-unit__/graphics/icon/insert.png',
		size = {100, 100},
		flags = {'gui-icon'}
	},
	{
		type = 'sprite',
		name = 'bulk-extract',
		filename = '__deep-storage-unit__/graphics/icon/extract.png',
		size = {100, 100},
		flags = {'gui-icon'}
	}
}
