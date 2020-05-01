local neutral_flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "placeable-neutral"}
  
  data:extend({
  
	{
	type = "simple-entity",
	name = "square-0",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-0.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-1",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-1.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-2",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-2.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-3",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-3.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-4",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-4.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-5",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-5.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	 {
	type = "simple-entity",
	name = "square-6",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-6.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-7",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-7.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
	type = "simple-entity",
	name = "square-8",
	icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
	flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
	subgroup = "wrecks",
	order = "d[remnants]-d[ship-wreck]-b[medium]-a",
	max_health = 200,
	render_layer = "entity-info-icon",
	pictures =
	  {
		{
		filename = "__Turret-Shields__/graphics/square-8.png",
		width = 260,
		height= 40,
		scale=0.25,
		shift = {0,0.1},
		}
	  },
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "smoke-with-trigger",
		duration = 41,
		fade_in_duration = 0,
		fade_away_duration = 40,
		spread_duration = 0,
		start_scale = 1,
		end_scale = 1,
		show_when_smoke_off = true,
		cyclic = true, 
		affected_by_wind = false,
		movement_slow_down_factor = 0,
		color = { r = 1, g = 1, b = 1, a=1 },
		
		name = "square-9",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		animation =

			{
				filename = "__Turret-Shields__/graphics/square-9.png",
				width = 260,
				height= 40,
				scale=0.25,
				shift = {0,1.1},
			}

	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-0",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-0.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-1",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-1.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-2",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-2.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-3",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-3.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-4",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-4.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-5",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-5.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-6",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-6.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-7",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-7.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-8",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-8.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-9",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-9.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-10",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-10.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-11",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-11.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "simple-entity",
		name = "liquid-square-12",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		pictures =
		{
			{
				filename = "__Turret-Shields__/graphics/liquid-square-12.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,0.1},
			}
		},
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "smoke-with-trigger",
		duration = 41,
		fade_in_duration = 0,
		fade_away_duration = 40,
		spread_duration = 0,
		start_scale = 1,
		end_scale = 1,
		show_when_smoke_off = true,
		cyclic = true, 
		affected_by_wind = false,
		movement_slow_down_factor = 0,
		color = { r = 1, g = 1, b = 1, a=1 },
		
		name = "liquid-square-13",
		icon = "__Turret-Shields__/graphics/blank.png",	icon_size = 32,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		render_layer = "entity-info-icon",
		animation =
		
			{
				filename = "__Turret-Shields__/graphics/liquid-square-13.png",
				width = 388,
				height= 40,
				scale=0.25,
				shift = {0,1.1},
			}
		
	},-------------------------------------------------------------------------------------------------------------------------------
		
  })


