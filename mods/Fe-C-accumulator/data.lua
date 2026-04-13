data:extend({

	--- tech

	{
		type = "technology",
		name = "fe-c-accumulator",
		icon_size = 128,
		icon = "__Fe-C-accumulator__/graphics/fe-c-tech.png",
		effects = {
			{
				type = "unlock-recipe",
				recipe = "fe-c-accumulator",
			},
		},
		-- prerequisites will be added in data-updates if bob-electricity exists
		unit = {
			count = 10,
			ingredients = {
				{ "automation-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-e-a",
	},

	--- acumulator entity

	{
		type = "accumulator",
		name = "fe-c-accumulator",
		icon = "__Fe-C-accumulator__/graphics/accumulator.png",
		icon_size = 128,
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "fe-c-accumulator" },
		max_health = 100,
		corpse = "accumulator-remnants",
		collision_box = { { -0.9, -0.9 }, { 0.9, 0.9 } },
		selection_box = { { -1, -1 }, { 1, 1 } },
		--damaged_trigger_effect = hit_effects.rock(),
		drawing_box = { { -1, -1.5 }, { 1, 1 } },
		energy_source = {
			type = "electric",
			buffer_capacity = "1.25MJ",
			usage_priority = "tertiary",
			input_flow_limit = "50kW",
			output_flow_limit = "50kW",
		},
		chargable_graphics = {
			picture = {
				filename = "__Fe-C-accumulator__/graphics/accumulator.png",
				priority = "high",
				width = 130,
				height = 189,
				shift = util.by_pixel(0, -11),
				scale = 0.5,
			},
		},
		charge_cooldown = 3,
		discharge_cooldown = 6,
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound = {
			sound = {
				filename = "__base__/sound/accumulator-working.ogg",
				volume = 1,
			},
			idle_sound = {
				filename = "__base__/sound/accumulator-idle.ogg",
				volume = 0.4,
			},
			max_sounds_per_type = 5,
		},

		circuit_wire_connection_point = circuit_connector_definitions["accumulator"].points,
		circuit_connector_sprites = circuit_connector_definitions["accumulator"].sprites,
		circuit_wire_max_distance = default_circuit_wire_max_distance,

		default_output_signal = { type = "virtual", name = "signal-A" },
	},

	--- accumulator item

	{
		type = "item",
		name = "fe-c-accumulator",
		icon = "__Fe-C-accumulator__/graphics/accumulator_icon.png",
		icon_size = 128,
		-- flags = {"goes-to-quickbar"},
		subgroup = "energy",
		order = "e[accumulator]-a[bccumulator]",
		place_result = "fe-c-accumulator",
		stack_size = 50,
	},

	---- acumulator recipe

	{
		type = "recipe",
		name = "fe-c-accumulator",
		energy_required = 5,
		enabled = false,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 45 },
			{ type = "item", name = "copper-plate", amount = 5 },
			{ type = "item", name = "coal", amount = 75 },
		},
		results = { { type = "item", name = "fe-c-accumulator", amount = 1 } },
	},
})
