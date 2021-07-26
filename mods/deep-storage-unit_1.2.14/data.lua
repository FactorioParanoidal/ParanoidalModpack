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
		icon = '__deep-storage-unit__/graphics/icon/memory-element.png',
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
		icon = '__deep-storage-unit__/graphics/icon/empty-memory-element.png',
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
		icon = '__deep-storage-unit__/graphics/icon/memory-communicator.png',
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
		icon = '__deep-storage-unit__/graphics/technology/empty-memory-element.png',
		icon_size = 128,
		effects = {{
			recipe = 'empty-memory-element',
			type = 'unlock-recipe'
		}},
		prerequisites = {
			'memory-unit',
			'energy-shield-mk2-equipment'
		},
		unit = {
			count = 500,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
			},
			time = 30
		}
	},
	{
		type = 'item',
		name = 'memory-unit',
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		stack_size = 10,
		place_result = 'memory-unit',
		order = 'a',
		subgroup = 'memory-unit'
	},
	{
		type = 'container',
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		name = 'memory-unit',
		inventory_size = 120,
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
		enable_inventory_bar = false
	},
	{
		type = 'recipe',
		name = 'memory-unit',
		ingredients = {
			{'advanced-circuit', 45},
			{'energy-shield-equipment', 4},
			{'steel-plate', 45},
			{'productivity-module', 16}
		},
		result = 'memory-unit',
		enabled = false
	},
	{
		type = 'technology',
		name = 'memory-unit',
		icon = '__deep-storage-unit__/graphics/technology/memory-unit.png',
		icon_size = 128,
		effects = {
			{
				recipe = 'memory-unit',
				type = 'unlock-recipe'
			},
			{
				recipe = 'memory-communicator',
				type = 'unlock-recipe'
			}
		},
		prerequisites = {
			'energy-shield-equipment',
			'productivity-module',
			'logistics-2'
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
		flags = {'player-creation', 'placeable-neutral', 'hidden', 'not-deconstructable', 'not-flammable', 'not-upgradable', 'not-rotatable', 'hide-alt-info', 'placeable-off-grid'},
		icon = '__deep-storage-unit__/graphics/icon/memory-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		item_slot_count = 1,
		name = 'memory-unit-combinator',
		type = 'constant-combinator',
		collision_mask = {},
		remove_decoratives = 'false',
		sprites = {filename = '__deep-storage-unit__/graphics/nothing.png', size = 1},
		activity_led_sprites = {filename = '__deep-storage-unit__/graphics/nothing.png', size = 1},
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
		selection_priority = 51,
		placeable_by = {item = 'memory-unit', count = 0}
	}
}

if mods['Krastorio2'] and settings.startup['remove-krastorio-warehouses'].value == true then
	local warehouses = {
		['kr-big-container'] = 'container',
		['kr-big-active-provider-container'] = 'logistic-container',
		['kr-big-passive-provider-container'] = 'logistic-container',
		['kr-big-buffer-container'] = 'logistic-container',
		['kr-big-storage-container'] = 'logistic-container',
		['kr-big-requester-container'] = 'logistic-container',
	}
	
	for _, tech in ipairs{'kr-containers', 'kr-logistic-containers-1', 'kr-logistic-containers-2'} do
		tech = data.raw.technology[tech]
		local new_effects = {}
		for _, effect in ipairs(tech.effects) do
			if effect.type ~= 'unlock-recipe' or not warehouses[effect.recipe] then
				new_effects[#new_effects + 1] = effect
			end
		end
		tech.effects = new_effects
	end
	
	for recipe, _ in pairs(warehouses) do
		data.raw.recipe[recipe].hidden = true
	end
end

for _, module in pairs(data.raw.module) do
	if module.effect.productivity and module.effect.productivity.bonus and module.effect.productivity.bonus > 0 and module.limitation then
		module.limitation[#module.limitation + 1] = 'empty-memory-element'
	end
end