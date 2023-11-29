

local function TRAFOS_DISPLAYER_PICTURE(f) return {
	north = {
		layers = {
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
				x = 233,
				width = 233, height = 155,
				shift = {2.6, -0.45},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
					x = 466,
					width = 466, height = 310,
					shift = {2.6, -0.45},
					scale = 0.5,
				},
			},
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows.png",
				x = 233,
				width = 233, height = 155,
				shift = {2.6, -0.45},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows-hr.png",
					x = 466,
					width = 466, height = 310,
					shift = {2.6, -0.45},
					scale = 0.5,
				},
			},
		},
	},
	east = {
		layers = {
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
				width = 233, height = 155,
				shift = {1.5, -1.15},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
					width = 466, height = 310,
					shift = {1.5, -1.15},
					scale = 0.5,
				},
			},
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows.png",
				width = 233, height = 155,
				shift = {1.5, -1.15},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows-hr.png",
					width = 466, height = 310,
					shift = {1.5, -1.15},
					scale = 0.5,
				},
			},
		},
	},
	south = {
		layers = {
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
				x = 699,
				width = 233, height = 155,
				shift = {2.6, -0.45},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
					x = 1398,
					width = 466, height = 310,
					shift = {2.6, -0.45},
					scale = 0.5,
				},
			},
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows.png",
				x = 699,
				width = 233, height = 155,
				shift = {2.6, -0.45},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows-hr.png",
					x = 1398,
					width = 466, height = 310,
					shift = {2.6, -0.45},
					scale = 0.5,
				},
			},
		},
	},
	west = {
		layers = {
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
				x = 466,
				width = 233, height = 155,
				shift = {1.5, -1.15},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
					x = 932,
					width = 466, height = 310,
					shift = {1.5, -1.15},
					scale = 0.5,
				},
			},
			{
				filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows.png",
				x = 466,
				width = 233, height = 155,
				shift = {1.5, -1.15},
				hr_version = {
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-arrows-hr.png",
					x = 932,
					width = 466, height = 310,
					shift = {1.5, -1.15},
					scale = 0.5,
				},
			},
		},
	},
} end


function TRAFOS_UNIT_PICTURE(f) 
	local altoverlay = {
		north = {
			filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-altoverlay-hr.png",
			x = 466,
			width = 466, height = 310,
			shift = {2.6, -0.45},
			scale = 0.5,
		},
		east = {
			filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-altoverlay-hr.png",
			width = 466, height = 310,
			shift = {1.5, -1.15},
			scale = 0.5,
		},
		south = {
			filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-altoverlay-hr.png",
			x = 1398,
			width = 466, height = 310,
			shift = {2.6, -0.45},
			scale = 0.5,
		},
		west = {
			filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-altoverlay-hr.png",
			x = 932,
			width = 466, height = 310,
			shift = {1.5, -1.15},
			scale = 0.5,
		},
	}



	local template = {
		north = { 
			layers = {
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
					x = 233,
					width = 233, height = 155,
					shift = {2.6, -0.45},
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
						x = 466,
						width = 466, height = 310,
						shift = {2.6, -0.45},
						scale = 0.5,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows.png",
					x = 233,
					width = 233, height = 155,
					shift = {2.6, -0.45},
					draw_as_shadow = true,
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows-hr.png",
						x = 466,
						width = 466, height = 310,
						shift = {2.6, -0.45},
						scale = 0.5,
						draw_as_shadow = true,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask-hr.png",
					x = 466,
					width = 466, height = 310,
					shift = {2.6, -0.45},
					blend_mode = TRAFOS_TIER_BLEND_MODE,
					tint = TRAFOS_TINT[f],
					scale = 0.5,
				},
			},
		},
		east = {
			layers = {
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
					width = 233, height = 155,
					shift = {1.5, -1.15},
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
						width = 466, height = 310,
						shift = {1.5, -1.15},
						scale = 0.5,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows.png",
					width = 233, height = 155,
					shift = {1.5, -1.15},
					draw_as_shadow = true,
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows-hr.png",
						width = 466, height = 310,
						shift = {1.5, -1.15},
						scale = 0.5,
						draw_as_shadow = true,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask.png",
					width = 233, height = 155,
					shift = {1.5, -1.15},
					blend_mode = TRAFOS_TIER_BLEND_MODE,
					tint = TRAFOS_TINT[f],
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask-hr.png",
						width = 466, height = 310,
						shift = {1.5, -1.15},
						scale = 0.5,
						blend_mode = TRAFOS_TIER_BLEND_MODE,
						tint = TRAFOS_TINT[f],
					},
				},
			},
		},
		south = {
			layers = {
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
					x = 699,
					width = 233, height = 155,
					shift = {2.6, -0.45},
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
						x = 1398,
						width = 466, height = 310,
						shift = {2.6, -0.45},
						scale = 0.5,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows.png",
					x = 699,
					width = 233, height = 155,
					shift = {2.6, -0.45},
					draw_as_shadow = true,
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows-hr.png",
						x = 1398,
						width = 466, height = 310,
						shift = {2.6, -0.45},
						scale = 0.5,
						draw_as_shadow = true,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask.png",
					x = 699,
					width = 233, height = 155,
					shift = {2.6, -0.45},
					blend_mode = TRAFOS_TIER_BLEND_MODE,
					tint = TRAFOS_TINT[f],
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask-hr.png",
						x = 1398,
						width = 466, height = 310,
						shift = {2.6, -0.45},
						scale = 0.5,
						blend_mode = TRAFOS_TIER_BLEND_MODE,
						tint = TRAFOS_TINT[f],
					},
				},
			},
		},
		west = {
			layers = {
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites.png",
					x = 466,
					width = 233, height = 155,
					shift = {1.5, -1.15},
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-sprites-hr.png",
						x = 932,
						width = 466, height = 310,
						shift = {1.5, -1.15},
						scale = 0.5,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows.png",
					x = 466,
					width = 233, height = 155,
					shift = {1.5, -1.15},
					draw_as_shadow = true,
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-shadows-hr.png",
						x = 932,
						width = 466, height = 310,
						shift = {1.5, -1.15},
						scale = 0.5,
						draw_as_shadow = true,
					},
				},
				{
					filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask.png",
					x = 466,
					width = 233, height = 155,
					shift = {1.5, -1.15},
					blend_mode = TRAFOS_TIER_BLEND_MODE,
					tint = TRAFOS_TINT[f],
					hr_version = {
						filename = TRAFOS_GRAPHICS_BASE.."/entities/trafo-mask-hr.png",
						x = 932,
						width = 466, height = 310,
						shift = {1.5, -1.15},
						scale = 0.5,
						blend_mode = TRAFOS_TIER_BLEND_MODE,
						tint = TRAFOS_TINT[f],
					},
				},
			},
		},
	}

	if TRAFOS_ALTOVERLAY then
		table.insert(template.north.layers, altoverlay.north)
		table.insert(template.east.layers, altoverlay.east)
		table.insert(template.south.layers, altoverlay.south)
		table.insert(template.west.layers, altoverlay.west)
	end

	return template

end


for i = 1, 5 do
	data:extend({
		{
			type = "simple-entity-with-force",
			name = "trafo-"..i.."-displayer",
			icons = {
				{ icon = TRAFOS_GRAPHICS_BASE.."/icons/trafo.png" },
				{ icon = TRAFOS_GRAPHICS_BASE.."/icons/tier-"..i..".png" },
			},
			icon_size = 32,
			flags = {"placeable-player", "player-creation"},
			minable = {mining_time = 1, result = "trafo-"..i},
			max_health = 300,
			resistances = {{
					type = "fire",
					percent = 70,
			}},
			random_variation_on_create = false,
			collision_mask = { "item-layer", "object-layer", "player-layer", "water-tile"},
			collision_box = {{-0.7, -1.7}, {0.7, 1.7}},
			selection_box = {{-0.9, -1.9}, {0.9, 1.9}},
			drawing_box = {{-1.0, -3.0}, {1.0, 2.0}},
			picture = TRAFOS_DISPLAYER_PICTURE(i),
		},
		{
			type = "simple-entity-with-force",
			name = "trafo-"..i.."-unit",
			icons = {
				{ icon = TRAFOS_GRAPHICS_BASE.."/icons/trafo.png" },
				{ icon = TRAFOS_GRAPHICS_BASE.."/icons/tier-"..i..".png" },
			},
			icon_size = 32,
			flags = {"placeable-player", "player-creation", "not-rotatable"},
			minable = {mining_time = 1, result = "trafo-"..i},
			corpse = "big-remnants",
			dying_explosion = "medium-explosion",
			placeable_by = { item = "trafo-"..i, count = 1},
			max_health = 300,
			resistances = {{
					type = "fire",
					percent = 70,
			}},
			random_variation_on_create = false,
			collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
			collision_box = {{-0.7, -1.7}, {0.7, 1.7}},
			selection_box = {{-0.9, -1.9}, {0.9, 1.9}},
			drawing_box = {{-1.0, -3.0}, {1.0, 2.0}},
			picture = TRAFOS_UNIT_PICTURE(i),
		},
		{
			type = "fluid",
			name = "trafo-water-"..i,
			default_temperature = 15,
			max_temperature = 100,
			heat_capacity = 20* 10^(i - 1).."J",
			base_color = {r=0, g=0.34, b=0.6},
			flow_color = {r=0.7, g=0.7, b=0.7},
			icon = TRAFOS_GRAPHICS_BASE.."/icons/flash.png",
			icon_size = 32,
			order = "a[fluid]-a[water]",
			pressure_to_speed_ratio = 0.4,
			flow_to_energy_ratio = 0.59,
			auto_barrel = false,
			hidden = true,
		},
		{
			type = "fluid",
			name = "trafo-steam-"..i,
			default_temperature = 15,
			max_temperature = 500,
			heat_capacity = 20 * 10^(i - 1).."J",
			icon = TRAFOS_GRAPHICS_BASE.."/icons/flash.png",
			icon_size = 32,
			base_color = {r=0.5, g=0.5, b=0.5},
			flow_color = {r=1.0, g=1.0, b=1.0},
			order = "a[fluid]-b[steam]",
			pressure_to_speed_ratio = 0.4,
			flow_to_energy_ratio = 0.59,
			gas_temperature = 15,
			auto_barrel = false,
			hidden = true,
		},
		{
			type = "infinity-pipe",
			name = "trafo-pump-n-"..i,
			icons = {{
				icon = "__base__/graphics/icons/pipe.png",
				tint = {r = 0.5, g = 0.5, b = 1},
			}},
			icon_size = 32,
			gui_mode = "none",
			flags = { "hide-alt-info", unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			collision_mask = {"ghost-layer"},
			collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
			selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
			horizontal_window_bounding_box = {{0, 0}, {0, 0}},
			vertical_window_bounding_box = {{0, 0}, {0, 0}},
			selectable_in_game = false,
			pictures = TRAFOS_PIPE_PICTURES,
			fluid_box = {
				base_area = 1,
				production_type = "output",
				filter = "trafo-water-"..i,
				pipe_connections = {{ position = {0, -1} }},
			},
		},
		{
			type = "infinity-pipe",
			name = "trafo-pump-e-"..i,
			icons = {{
				icon = "__base__/graphics/icons/pipe.png",
				tint = {r = 0.5, g = 0.5, b = 1},
			}},
			icon_size = 32,
			gui_mode = "none",
			flags = { "hide-alt-info", unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			collision_mask = {"ghost-layer"},
			collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
			selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
			horizontal_window_bounding_box = {{0, 0}, {0, 0}},
			vertical_window_bounding_box = {{0, 0}, {0, 0}},
			selectable_in_game = false,
			pictures = TRAFOS_PIPE_PICTURES,
			fluid_box = {
				base_area = 1,
				production_type = "output",
				filter = "trafo-water-"..i,
				pipe_connections = {{ position = {1, 0} }},
			},
		},
		{
			type = "infinity-pipe",
			name = "trafo-pump-s-"..i,
			icons = {{
				icon = "__base__/graphics/icons/pipe.png",
				tint = {r = 0.5, g = 0.5, b = 1},
			}},
			icon_size = 32,
			gui_mode = "none",
			flags = { "hide-alt-info", unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			collision_mask = {"ghost-layer"},
			collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
			selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
			horizontal_window_bounding_box = {{0, 0}, {0, 0}},
			vertical_window_bounding_box = {{0, 0}, {0, 0}},
			selectable_in_game = false,
			pictures = TRAFOS_PIPE_PICTURES,
			fluid_box = {
				base_area = 1,
				production_type = "output",
				filter = "trafo-water-"..i,
				pipe_connections = {{ position = {0, 1} }},
			},
		},
		{
			type = "infinity-pipe",
			name = "trafo-pump-w-"..i,
			icons = {{
				icon = "__base__/graphics/icons/pipe.png",
				tint = {r = 0.5, g = 0.5, b = 1},
			}},
			icon_size = 32,
			gui_mode = "none",
			flags = { "hide-alt-info", unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			collision_mask = {"ghost-layer"},
			collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
			selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
			horizontal_window_bounding_box = {{0, 0}, {0, 0}},
			vertical_window_bounding_box = {{0, 0}, {0, 0}},
			selectable_in_game = false,
			pictures = TRAFOS_PIPE_PICTURES,
			fluid_box = {
				base_area = 1,
				production_type = "output",
				filter = "trafo-water-"..i,
				pipe_connections = {{ position = {-1, 0} }},
			},
		},
		{
			type = "boiler",
			name = "trafo-source-"..i,
			icon = TRAFOS_GRAPHICS_BASE.."/icons/trafo.png",
			icon_size = 32,
			order = "z",
			flags = { "hide-alt-info", unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			selectable_in_game = false,
			collision_mask = {"ghost-layer"},
			mode = "output-to-separate-pipe",
			collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
			selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
			target_temperature = 100,
			fluid_box = {
				production_type = "input",
				base_area = 1,
				base_level = -1,
				height = 2,
				pipe_connections = {
					{ type="input", position = {0.5,  1.5} },
				},
				secondary_draw_orders = {north = -1},
			},
			output_fluid_box = {
				base_area = 0.1,
				height = 1,
				base_level = 0,

				pipe_connections = {{ type = "output", position = {-0.5, 1.5} }},
				production_type = "output",
				filter = "trafo-steam-"..i,
			},
			energy_consumption = 1*10^(i-1).."MW",
			energy_source = {
				type = "electric",
				input_priority = "secondary",
				usage_priority = "secondary-input",
				emissions = 0,
			},
			structure = { north = TRAFOS_INVISIBLE, east = TRAFOS_INVISIBLE, south = TRAFOS_INVISIBLE, west = TRAFOS_INVISIBLE },
			fire = {},
			fire_glow = {},
			burning_cooldown = 0.1,
		},
		{
			type = "generator",
			name = "trafo-target-"..i.."-sw", --powered from south or west
			icon = TRAFOS_GRAPHICS_BASE.."/icons/trafo.png",
			icon_size = 32,
			order = "z",
			flags = { TRAFOS_ALTOVERLAY, unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			selectable_in_game = false,
			effectivity = TRAFOS_EFFICIENCY,
			fluid_usage_per_tick = 10,
			maximum_temperature = 100,
			burns_fluid = false,
			collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
			selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
			fluid_box = {
				base_area = 0.1,
				height = 1,
				base_level = -1,
				pipe_connections = {{ type = "input", position = {0.5, 1.5} }},
				production_type = "input",
				filter = "trafo-steam-"..i,
				minimum_temperature = 100.0,
			},
			energy_source =	{
				type = "electric",
				usage_priority = "secondary-output"
			},
			horizontal_animation = TRAFOS_INVISIBLE,
			vertical_animation = TRAFOS_INVISIBLE,

			working_sound =	{
				match_speed_to_activity = true,
				sound = {
					filename = TRAFOS_SOUND_BASE.."/MainsBrum50Hz.ogg",
					volume = settings.startup["trafos-volume"].value,
				},
			},
			min_perceived_performance = 0.25,
			performance_to_sound_speedup = 0.5,
		},
		{
			type = "generator",
			name = "trafo-target-"..i.."-ne", --powered from north or east
			icon = TRAFOS_GRAPHICS_BASE.."/icons/trafo.png",
			icon_size = 32,
			order = "z",
			flags = { TRAFOS_ALTOVERLAY, unpack(TRAFOS_INTERNAL_ENTITY_FLAGS) },
			selectable_in_game = false,
			effectivity = TRAFOS_EFFICIENCY,
			fluid_usage_per_tick = 10,
			maximum_temperature = 100,
			burns_fluid = false,
			collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
			selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
			fluid_box = {
				base_area = 0.1,
				height = 1,
				base_level = -1,
				pipe_connections = {
					{ type = "input", position = {-0.5, -1.5} },
				},
				production_type = "input",
				filter = "trafo-steam-"..i,
				minimum_temperature = 100.0
			},
			energy_source =	{
				type = "electric",
				usage_priority = "secondary-output"
			},
			horizontal_animation = TRAFOS_INVISIBLE,
			vertical_animation = TRAFOS_INVISIBLE,

			working_sound =	{
				match_speed_to_activity = true,
				sound = { 
					filename = TRAFOS_SOUND_BASE.."/MainsBrum50Hz.ogg",
					volume = settings.startup["trafos-volume"].value,
				},
			},
			min_perceived_performance = 0.25,
			performance_to_sound_speedup = 0.5,
		}
	})
end

