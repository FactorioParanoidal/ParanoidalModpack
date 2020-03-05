local neutral_flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "placeable-neutral"}
  
data:extend({
	{
		type = "electric-energy-interface",
		name = "ts-electric-interface-0",
		icon = "__Turret-Shields__/graphics/entity_icon.png",
		icon_size = 128,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		collision_mask={"floor-layer"},
		selection_box = {{-1, -1 }, {1, 1}},
		alert_icon_shift = {0,0.08},
		render_layer = "entity-info-icon",
		selectable_in_game=false,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			input_flow_limit = "1KW",
			buffer_capacity = "5MJ"
		},
		energy_production = "0kW",
		energy_usage = "0kW",
		enable_gui = false,
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "electric-energy-interface",
		name = "ts-electric-interface-5",
		icon = "__Turret-Shields__/graphics/entity_icon.png",
		icon_size = 128,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		collision_mask={"floor-layer"},
		selection_box = {{-1, -1 }, {1, 1}},
		alert_icon_shift = {0,0.08},
		render_layer = "entity-info-icon",
		selectable_in_game=false,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			input_flow_limit = math.floor(settings.startup["TS_energy_consumption_multiplier"].value*300).."KW",
			buffer_capacity = "5MJ"
		},
		energy_production = "0kW",
		energy_usage = "0kW",
		enable_gui = false,
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "electric-energy-interface",
		name = "ts-electric-interface-10",
		icon = "__Turret-Shields__/graphics/entity_icon.png",
		icon_size = 128,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		collision_mask={"floor-layer"},
		selection_box = {{-1, -1 }, {1, 1}},
		alert_icon_shift = {0,0.08},
		render_layer = "entity-info-icon",
		selectable_in_game=false,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			input_flow_limit = math.floor(settings.startup["TS_energy_consumption_multiplier"].value*600).."KW",
			buffer_capacity = "5MJ"
		},
		energy_production = "0kW",
		energy_usage = "0kW",
		enable_gui = false,
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "electric-energy-interface",
		name = "ts-electric-interface-15",
		icon = "__Turret-Shields__/graphics/entity_icon.png",
		icon_size = 128,
		flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
		subgroup = "wrecks",
		order = "d[remnants]-d[ship-wreck]-b[medium]-a",
		max_health = 200,
		collision_mask={"floor-layer"},
		selection_box = {{-1, -1 }, {1, 1}},
		alert_icon_shift = {0,0.08},
		render_layer = "entity-info-icon",
		selectable_in_game=false,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			input_flow_limit = math.floor(settings.startup["TS_energy_consumption_multiplier"].value*900).."KW",
			buffer_capacity = "5MJ"
		},
		energy_production = "0kW",
		energy_usage = "0kW",
		enable_gui = false,
	},-------------------------------------------------------------------------------------------------------------------------------
  })

for i=25,575,10 do
	data:extend({
		{
			type = "electric-energy-interface",
			name = "ts-electric-interface-"..i,
			icon = "__Turret-Shields__/graphics/entity_icon.png",
			icon_size = 128,
			flags = neutral_flags, --{"not-blueprintable", "placeable-neutral", "placeable-off-grid", "not-on-map"},
			subgroup = "wrecks",
			order = "d[remnants]-d[ship-wreck]-b[medium]-a",
			max_health = 200,
			collision_mask={"floor-layer"},
			selection_box = {{-1, -1 }, {1, 1}},
			alert_icon_shift = {0,0.08},
			render_layer = "entity-info-icon",
			selectable_in_game=false,
			energy_source =
			{
				type = "electric",
				usage_priority = "secondary-input",
				input_flow_limit = math.floor(settings.startup["TS_energy_consumption_multiplier"].value*i*60).."KW",
				buffer_capacity = "5MJ"
			},
			energy_production = "0kW",
			energy_usage = "0kW",
			enable_gui = false,
		},-------------------------------------------------------------------------------------------------------------------------------
	
	})
end
