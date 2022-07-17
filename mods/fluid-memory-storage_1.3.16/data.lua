local circuit_wire_connection_points = {
	green = {0, 0},
	red = {0, 0}
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
	filename = '__fluid-memory-storage__/graphics/entity/nothing.png',
	priority = 'extra-high',
	size = 1
}

data:extend{
	{
		type = 'item',
		name = 'fluid-memory-unit',
		icon = '__fluid-memory-storage__/graphics/icon/fluid-memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		stack_size = 50,
		place_result = 'fluid-memory-unit-container',
		order = 'b',
		subgroup = 'memory-unit'
	},
	{
		type = 'animation',
		name = 'fluid-memory-unit-animation',
		filename = '__fluid-memory-storage__/graphics/entity/fluid-background.png',
		priority = 'extra-high',
		size = {128, 128},
		shift = {0.25, -0.0625},
		frame_count = 16,
		line_length = 8,
		apply_runtime_tint = true,
		hr_version = {
			filename = '__fluid-memory-storage__/graphics/entity/hr-fluid-background.png',
			priority = 'extra-high',
			size = {256, 256},
			shift = {0.25, -0.0625},
			scale = 0.5,
			frame_count = 16,
			line_length = 8,
			apply_runtime_tint = true
		}
	},
	{
		type = 'electric-energy-interface',
		localised_name = {'entity-name.fluid-memory-unit'},
		localised_description = {'entity-description.fluid-memory-unit'},
		energy_source = {
			type = 'electric',
			usage_priority = 'secondary-input',
			buffer_capacity = '1J'
		},
		energy_usage = '1000W',
		collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
		icon = '__fluid-memory-storage__/graphics/icon/fluid-memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		collision_mask = {},
		selectable_in_game = false,
		remove_decoratives = 'false',
		name = 'fluid-memory-unit-powersource',
		flags = {'placeable-neutral', 'hidden', 'not-selectable-in-game', 'not-rotatable', 'not-flammable', 'placeable-off-grid'}
	},
	{
		name = 'fluid-memory-unit',
		type = 'storage-tank',
		icon = '__fluid-memory-storage__/graphics/icon/fluid-memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		fluid_box = {
			base_area = 1200,
			base_level = -1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{position = {0, 2}},
				{position = {0, -2}},
				{position = {2, 0}},
				{position = {-2, 0}}
			}
		},
		two_direction_only = true,
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		window_bounding_box = {{-1, -1}, {1, 1}},
		flags = {'placeable-neutral', 'hidden', 'not-selectable-in-game', 'not-rotatable', 'not-flammable'},
		pictures = {
			picture = nothing,
			fluid_background = nothing,
			window_background = nothing,
			flow_sprite = nothing,
			gas_flow = nothing
		},
		flow_length_in_ticks = 360,
		collision_mask = {},
		selectable_in_game = false,
		remove_decoratives = 'false'
	},
	{
		type = 'recipe',
		name = 'fluid-memory-unit',
		ingredients = {
			{'storage-tank', 2},
			mods['deep-storage-unit'] and {'memory-unit', 1} or {'productivity-module', 8},
			{'energy-shield-equipment', 4}
		},
		result = 'fluid-memory-unit',
		enabled = false
	},
	{
		type = 'technology',
		name = 'fluid-memory-storage',
		icon = '__fluid-memory-storage__/graphics/technology/fluid-memory-storage.png',
		icon_size = 128,
		effects = {{
			recipe = 'fluid-memory-unit',
			type = 'unlock-recipe'
		}},
		prerequisites = {
			mods['deep-storage-unit'] and 'memory-unit' or 'chemical-science-pack',
			'fluid-handling'
		},
		unit = {
			count = 200,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1}
			},
			time = 30
		}
	},
	{
		type = 'container',
		name = 'fluid-memory-unit-container',
		localised_name = {'entity-name.fluid-memory-unit'},
		localised_description = {'entity-description.fluid-memory-unit'},
		picture = {
			filename = '__fluid-memory-storage__/graphics/entity/fluid-memory-unit.png',
			priority = 'high',
			size = {128, 128},
			shift = {0.25, -0.0625},
			hr_version = {
				filename = '__fluid-memory-storage__/graphics/entity/hr-fluid-memory-unit.png',
				priority = 'high',
				size = {256, 256},
				shift = {0.25, -0.0625},
				scale = 0.5
			}
		},
		enable_inventory_bar = false,
		minable = {
			result = 'fluid-memory-unit',
			mining_time = 1
		},
		inventory_size = 1,
		scale_info_icon = true,
		max_health = 1500,
		corpse = 'medium-remnants',
		icon = '__fluid-memory-storage__/graphics/icon/fluid-memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		flags = {'player-creation', 'placeable-neutral', 'hide-alt-info', 'not-rotatable'},
		placeable_by = {item = 'fluid-memory-unit', count = 1}
	},
	{
		circuit_wire_connection_points = circuit_wire_connection_points,
		circuit_wire_max_distance = 9,
		collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		flags = {'player-creation', 'placeable-neutral', 'hidden', 'not-deconstructable', 'not-flammable', 'not-upgradable', 'not-rotatable', 'hide-alt-info', 'placeable-off-grid'},
		icon = '__fluid-memory-storage__/graphics/icon/fluid-memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		item_slot_count = 1,
		name = 'fluid-memory-unit-combinator',
		type = 'constant-combinator',
		collision_mask = {},
		remove_decoratives = 'false',
		sprites = nothing,
		activity_led_sprites = nothing,
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		selection_priority = 51,
		placeable_by = {item = 'fluid-memory-unit', count = 0}
	}
}

if not mods['deep-storage-unit'] then
	data:extend{
		{
			type = 'item-subgroup',
			name = 'memory-unit',
			group = 'logistics',
			order = 'g-a'
		},
		{
			type = 'item-with-tags',
			name = 'memory-element',
			icon = '__fluid-memory-storage__/graphics/icon/memory-element.png',
			icon_size = 64,
			icon_mipmaps = 4,
			stack_size = 1,
			flags = {'not-stackable'},
			order = 'h',
			subgroup = 'memory-unit'
		},
		{
			type = 'item',
			name = 'empty-memory-element',
			icon = '__fluid-memory-storage__/graphics/icon/empty-memory-element.png',
			icon_size = 64,
			icon_mipmaps = 4,
			stack_size = 1,
			flags = {'not-stackable'},
			order = 'i',
			subgroup = 'memory-unit'
		},
		{
			type = 'item',
			name = 'memory-communicator',
			icon = '__fluid-memory-storage__/graphics/icon/memory-communicator.png',
			icon_size = 64,
			icon_mipmaps = 4,
			stack_size = 1,
			flags = {'not-stackable'},
			order = 'j',
			subgroup = 'memory-unit'
		},
		{
			type = 'recipe',
			name = 'empty-memory-element',
			ingredients = {
				{'energy-shield-mk2-equipment', 1},
				{'plastic-bar', 1}
			},
			energy_required = 20,
			result = 'empty-memory-element',
			enabled = false
		},
		{
			type = 'recipe',
			name = 'memory-communicator',
			ingredients = {
				{'energy-shield-equipment', 1},
				{'programmable-speaker', 2}
			},
			energy_required = 20,
			result = 'memory-communicator',
			enabled = false
		},
		{
			type = 'technology',
			name = 'empty-memory-element',
			icon = '__fluid-memory-storage__/graphics/technology/empty-memory-element.png',
			icon_size = 128,
			effects = {{
				recipe = 'empty-memory-element',
				type = 'unlock-recipe'
			}},
			prerequisites = {
				'fluid-memory-storage',
				'energy-shield-mk2-equipment'
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
		}
	}
	
	table.insert(data.raw.technology['fluid-memory-storage'].effects, {
		recipe = 'memory-communicator',
		type = 'unlock-recipe'
	})
	
	for _, module in pairs(data.raw.module) do
		if module.effect.productivity and module.effect.productivity.bonus and module.effect.productivity.bonus > 0 and module.limitation then
			module.limitation[#module.limitation + 1] = 'empty-memory-element'
		end
	end
end