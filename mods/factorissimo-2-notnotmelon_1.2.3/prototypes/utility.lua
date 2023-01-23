local F = '__factorissimo-2-notnotmelon__'

-- Circuit connectors

data:extend{
	{
		type = 'item',
		name = 'factory-circuit-connector',
		icon = F..'/graphics/icon/factory-circuit-connector.png',
		icon_size = 64,
		flags = {},
		subgroup = 'factorissimo2',
		order = 'c-b',
		place_result = 'factory-circuit-connector',
		stack_size = 50,
	},
	{
		type = 'electric-pole',
		name = 'factory-circuit-connector',
		icon = F..'/graphics/icon/factory-circuit-connector.png',
		icon_size = 32,
		flags = {'placeable-neutral', 'player-creation'},
		minable = {hardness = 0.2, mining_time = 0.5, result = 'factory-circuit-connector'},
		max_health = 50,
		corpse = 'small-remnants',
		supply_area_distance = 0,
		draw_copper_wires = false,
		collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		item_slot_count = 15,
		pictures = {
			direction_count = 1,
			filename = F..'/graphics/utility/factory-combinators.png',
			width = 79,
			height = 63,
			frame_count = 1,
			shift = {0.140625, 0.140625},
		},
		connection_points = {{
			shadow = {
				red = {0.75, 0.5625},
				green = {0.21875, 0.5625}
			},
			wire = {
				red = {0.28125, 0.15625},
				green = {-0.21875, 0.15625}
			}
		}},
		maximum_wire_distance = 7.5
	}
}
