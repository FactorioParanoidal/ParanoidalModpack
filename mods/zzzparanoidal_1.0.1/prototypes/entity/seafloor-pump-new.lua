local crafting_categories1 = {"pump-water"}
	local fixed_recipe = "angel-viscous-mud"
	local flags1 = {"hidden", "placeable-neutral", "player-creation", "filter-directions"}
	local fluid_boxes =
	{
		{
			base_area = 1,
			base_level = 1,
			pipe_covers = pipecoverspictures(),
			production_type = "output",
			pipe_connections =
			{
				{
					position = {0, 1},
					type = "output"
				}
			}
		},
		off_when_no_fluid_recipe = false
	}

data:extend({
  {
    type = "item",
    name = "seafloor-pump-2",
    icons = angelsmods.functions.add_number_icon_layer({
      {
        icon = "__zzzparanoidal__/graphics/icon/seafloor-pump-mk2-ico.png",
        icon_size = 32,
      },
    }, 2, angelsmods.refining.number_tint),
    icon_size = 32,
    subgroup = "washing-building",
    order = "a",
    place_result = "seafloor-pump-2",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "seafloor-pump-2",
    subgroup = "other",
    icons = angelsmods.functions.add_number_icon_layer({
      {
        icon = "__zzzparanoidal__/graphics/icon/seafloor-pump-mk2-ico.png",
        icon_size = 32,
      },
    }, 2, angelsmods.refining.number_tint),
    icon_size = 32,
    minable = { mining_time = 1, result = "seafloor-pump-2" },
    fast_replaceable_group = "seafloor-pump",
    -- next_upgrade = "seafloor-pump-3",

    max_health = 600,
    crafting_speed = 1,
    results = {{type = "fluid", name = "water-viscous-mud", amount = 600}},
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
    },
    energy_usage = "550kW",
    corpse = "small-remnants",
    flags = flags1,
    crafting_categories = crafting_categories1,
    fixed_recipe = fixed_recipe,
    fluid_boxes = fluid_boxes,
    resistances = {
      {
        type = "fire",
        percent = 70,
      },
    },
    collision_box = { { -1.4, -2.45 }, { 1.4, 0.3 } },
    selection_box = { { -1.6, -2.49 }, { 1.6, 0.49 } },
    tile_width = 3,
    tile_height = 3,
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    animation = {
      north = {
        filename = "__zzzparanoidal__/graphics/entity/seafloor-pump-mk2.png",
        priority = "high",
        shift = { 0, -1 },
        width = 160,
        height = 160,
      },
      east = {
        filename = "__zzzparanoidal__/graphics/entity/seafloor-pump-mk2.png",
        priority = "high",
        shift = { 1, 0 },
        x = 160,
        width = 160,
        height = 160,
      },
      south = {
        filename = "__zzzparanoidal__/graphics/entity/seafloor-pump-mk2.png",
        priority = "high",
        shift = { 0, 1 },
        x = 320,
        width = 160,
        height = 160,
      },
      west = {
        filename = "__zzzparanoidal__/graphics/entity/seafloor-pump-mk2.png",
        priority = "high",
        shift = { -1, 0 },
        x = 480,
        width = 160,
        height = 160,
      },
    },
    placeable_position_visualization = {
      filename = "__core__/graphics/cursor-boxes-32x32.png",
      priority = "extra-high-no-scale",
      width = 64,
      height = 64,
      scale = 0.5,
      x = 3 * 64,
    },
    circuit_wire_connection_points = circuit_connector_definitions["offshore-pump"].points,
    circuit_connector_sprites = circuit_connector_definitions["offshore-pump"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    collision_mask = { "object-layer", "train-layer" }, -- collide just with object-layer and train-layer which don't collide with water, this allows us to build on 1 tile wide ground
    center_collision_mask = { "water-tile", "object-layer", "player-layer" }, -- to test that tile directly under the pump is ground
    fluid_box_tile_collision_test = { "ground-tile" },
    adjacent_tile_collision_test = { "water-tile" },
    adjacent_tile_collision_mask = { "ground-tile" }, -- to prevent building on edge of map :(
    adjacent_tile_collision_box = { { -2, -3 }, { 2, -2 } },
  },
})
