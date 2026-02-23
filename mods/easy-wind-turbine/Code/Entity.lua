---@class LuaSettings
local SS = settings.startup
local SteamValue = SS["TurbineSteam"].value

data:extend({
	{
		type = "generator",
		name = "EasyWindTurbine1",
		icon = "__easy-wind-turbine__/graphics/Item/wind_turbine_item.png",
		icon_size = 32,
		flags = {"placeable-neutral","player-creation"},
		minable = {mining_time = 1, result = "EasyWindTurbine1"},
		max_health = 400,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		effectivity = 100.0,
		fluid_usage_per_tick = 0.0098,
		maximum_temperature = 100,
		resistances = {
			{type = "fire", percent = 20 },
			{type = "physical", percent = 20 },
			{type = "impact", percent = 30 }
		},
		fast_replaceable_group = "easy-wind-turbine",
		collision_box = {{-0.50, -0.50}, {0.50, 0.50}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fluid_box = {
			volume = SteamValue * 100,
			base_area = 1,
			height = 2,
			base_level = -1,
			pipe_connections = {},
			production_type = "input-output",
			filter = "steam",
			minimum_temperature = 0.0
		},
		energy_source = {
			type = "electric",
			usage_priority = "primary-output"
		},
		horizontal_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine1_horizontal.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			repeat_count = 10,
			shift = {2.48, -1.45}
		},
		vertical_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine1_vertical.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			repeat_count = 10,
			shift = {2.48, -1.45}
		},
        working_sound = {
            sound = {
                filename = "__base__/sound/train-wheels.ogg",
                volume = 0.4
            },
            match_speed_to_activity = true,
        },
        min_perceived_performance = 1.0,
        performance_to_sound_speedup = 0.2
    },
	{
		type = "generator",
		name = "EasyWindTurbine2",
		icon = "__easy-wind-turbine__/graphics/Item/wind_turbine_item.png",
		icon_size = 32,
		flags = {"placeable-neutral","player-creation"},
		minable = {mining_time = 1, result = "EasyWindTurbine2"},
		max_health = 400,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		effectivity = 100.0,
		fluid_usage_per_tick = 0.049,
		maximum_temperature = 100,
			resistances = {
			{type = "fire", percent = 20},
			{type = "physical", percent = 20},
			{type = "impact", percent = 30}
		},
		fast_replaceable_group = "easy-wind-turbine",
		collision_box = {{-0.50, -0.50}, {0.50, 0.50}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		fluid_box = {
			volume = SteamValue * 200,
			base_area = 1,
			height = 2,
			base_level = -1,
			pipe_connections = {},
			production_type = "input-output",
			filter = "steam",
			minimum_temperature = 0.0
		},
		energy_source = {
			type = "electric",
			usage_priority = "primary-output"
		},
		horizontal_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine2_horizontal.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
		vertical_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine2_vertical.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
        working_sound = {
            sound = {
                filename = "__base__/sound/train-wheels.ogg",
                volume = 0.4
            },
            match_speed_to_activity = true,
        },
        min_perceived_performance = 1.00,
        performance_to_sound_speedup = 0.2
    },
	{
		type = "generator",
		name = "EasyWindTurbine3",
		icon = "__easy-wind-turbine__/graphics/Item/wind_turbine_item.png",
		icon_size = 32,
		flags = {"placeable-neutral","player-creation"},
		minable = {mining_time = 1, result = "EasyWindTurbine3"},
		max_health = 400,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		effectivity = 100.0,
		fluid_usage_per_tick = 0.098,
		maximum_temperature = 100,
		resistances = {
			{type = "fire", percent = 20 },
			{type = "physical", percent = 20 },
			{type = "impact", percent = 30 }
		},
        fast_replaceable_group = "easy-wind-turbine",
        collision_box = {{-0.50, -0.50}, {0.50, 0.50}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fluid_box = {
            volume = SteamValue * 300,
            base_area = 1,
            height = 2,
            base_level = -1,
            pipe_connections = {},
            production_type = "input-output",
            filter = "steam",
            minimum_temperature = 0.0
		},
		energy_source = {
			type = "electric",
			usage_priority = "primary-output"
		},
		horizontal_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine3_horizontal.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
		vertical_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine3_vertical.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
        working_sound = {
            sound = {
                filename = "__base__/sound/train-wheels.ogg",
				volume = 0.4
            },
            match_speed_to_activity = true,
        },
        min_perceived_performance = 1.0,
        performance_to_sound_speedup = 0.2
    },
	{
		type = "generator",
		name = "EasyWindTurbine4",
		icon = "__easy-wind-turbine__/graphics/Item/wind_turbine_item.png",
		icon_size = 32,
		flags = {"placeable-neutral","player-creation"},
		minable = {mining_time = 1, result = "EasyWindTurbine4"},
		max_health = 400,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		effectivity = 100.0,
		fluid_usage_per_tick = 0.1471,
		maximum_temperature = 100,
		resistances = {
			{type = "fire", percent = 20 },
			{type = "physical", percent = 20 },
			{type = "impact", percent = 30 }
		},
        fast_replaceable_group = "easy-wind-turbine",
        collision_box = {{-0.50, -0.50}, {0.50, 0.50}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fluid_box = {
            volume = SteamValue * 400,
            base_area = 1,
            height = 2,
            base_level = -1,
            pipe_connections = {},
            production_type = "input-output",
            filter = "steam",
            minimum_temperature = 0.0
		},
		energy_source = {
			type = "electric",
			usage_priority = "primary-output"
		},
		horizontal_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine4_horizontal.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
		vertical_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine4_vertical.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
        working_sound = {
            sound = {
                filename = "__base__/sound/train-wheels.ogg",
				volume = 0.4
            },
            match_speed_to_activity = true,
        },
        min_perceived_performance = 1.0,
        performance_to_sound_speedup = 0.2
    },
	{
		type = "generator",
		name = "EasyWindTurbine5",
		icon = "__easy-wind-turbine__/graphics/Item/wind_turbine_item.png",
		icon_size = 32,
		flags = {"placeable-neutral","player-creation"},
		minable = {mining_time = 1, result = "EasyWindTurbine5"},
		max_health = 400,
		corpse = "big-remnants",
		dying_explosion = "medium-explosion",
		effectivity = 100.0,
		fluid_usage_per_tick = 0.1961,
		maximum_temperature = 100,
		resistances = {
			{type = "fire", percent = 20 },
			{type = "physical", percent = 20 },
			{type = "impact", percent = 30 }
		},
        fast_replaceable_group = "easy-wind-turbine",
        collision_box = {{-0.50, -0.50}, {0.50, 0.50}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        fluid_box = {
            volume = SteamValue * 500,
            base_area = 1,
            height = 2,
            base_level = -1,
            pipe_connections = {},
            production_type = "input-output",
            filter = "steam",
            minimum_temperature = 0.0
		},
		energy_source = {
			type = "electric",
			usage_priority = "primary-output"
		},
		horizontal_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine5_horizontal.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
		vertical_animation = {
			filename = "__easy-wind-turbine__/graphics/Entity/wind_turbine5_vertical.png",
			width = 300,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {2.48, -1.45}
		},
        working_sound = {
            sound = {
                filename = "__base__/sound/train-wheels.ogg",
				volume = 0.4
            },
            match_speed_to_activity = true,
        },
        min_perceived_performance = 1.0,
        performance_to_sound_speedup = 0.2
    },
})