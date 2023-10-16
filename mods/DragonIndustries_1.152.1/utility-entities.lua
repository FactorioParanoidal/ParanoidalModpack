function createBasicLight(name, params)

	return
	{
		type = "lamp",
		name = name,
		icon = "__core__/graphics/empty.png",
		icon_size = 1,
		flags = {"placeable-off-grid", "not-on-map"},
		max_health = 100,
		destructible = false,
		corpse = "small-remnants",
		--collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		--selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		selectable_in_game = false,
		collision_mask = {},
		order = "z",
		--vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
		  type = "void",
		  usage_priority = "lamp"
		},
		energy_usage_per_tick = "1W",
		darkness_for_all_lamps_on = 0.0001,
		darkness_for_all_lamps_off = 0,
		light = {intensity = params.brightness, size = params.size, color = params.color},
		light_when_colored = {intensity = params.brightness, size = params.size, color = params.color},
		glow_size = 6,
		glow_color_intensity = 0.135,
		picture_off =
		{
		  layers =
		  {
			{
			  filename = "__core__/graphics/empty.png",
			  priority = "high",
			  width = 1,
			  height = 1,
			  frame_count = 1,
			  axially_symmetrical = false,
			  direction_count = 1,
			},
		  }
		},
		picture_on =
		{
			  filename = "__core__/graphics/empty.png",
			  priority = "high",
			  width = 1,
			  height = 1,
			  frame_count = 1,
			  axially_symmetrical = false,
			  direction_count = 1,
		},
		signal_to_color_mapping =
		{
		},

		circuit_wire_connection_point = nil,--circuit_connector_definitions["lamp"].points,
		circuit_connector_sprites = circuit_connector_definitions["lamp"].sprites,
		circuit_wire_max_distance = 0--default_circuit_wire_max_distance
	}
  
end