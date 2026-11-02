data.raw["mining-drill"]["pumpjack"].fast_replaceable_group = "pumpjack"
data.raw.item["pumpjack"].order = "b[fluids]-b[pumpjack-1]"
data.raw.item["pumpjack"].weight = 50000

if settings.startup["bobmods-mining-pumpjacks"].value == true then
  data.raw["mining-drill"]["pumpjack"].next_upgrade = "bob-pumpjack-1"

  data:extend({
    {
      type = "item",
      name = "bob-pumpjack-1",
      icon = "__base__/graphics/icons/pumpjack.png",
      icon_size = 64,
      subgroup = "extraction-machine",
      order = "b[fluids]-b[pumpjack-2]",
      place_result = "bob-pumpjack-1",
      stack_size = 20,
      drop_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-move.ogg",
        volume = 0.6,
      },
      inventory_move_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-move.ogg",
        volume = 0.6,
      },
      pick_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-pickup.ogg",
        volume = 0.6,
      },
      weight = 50000,
    },
    {
      type = "item",
      name = "bob-pumpjack-2",
      icon = "__base__/graphics/icons/pumpjack.png",
      icon_size = 64,
      subgroup = "extraction-machine",
      order = "b[fluids]-b[pumpjack-3]",
      place_result = "bob-pumpjack-2",
      stack_size = 20,
      drop_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-move.ogg",
        volume = 0.6,
      },
      inventory_move_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-move.ogg",
        volume = 0.6,
      },
      pick_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-pickup.ogg",
        volume = 0.6,
      },
      weight = 50000,
    },
    {
      type = "item",
      name = "bob-pumpjack-3",
      icon = "__base__/graphics/icons/pumpjack.png",
      icon_size = 64,
      subgroup = "extraction-machine",
      order = "b[fluids]-b[pumpjack-4]",
      place_result = "bob-pumpjack-3",
      stack_size = 20,
      drop_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-move.ogg",
        volume = 0.6,
      },
      inventory_move_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-move.ogg",
        volume = 0.6,
      },
      pick_sound = {
        filename = "__base__/sound/item/pumpjack-inventory-pickup.ogg",
        volume = 0.6,
      },
      weight = 50000,
    },
  })

  data:extend({
    {
      type = "recipe",
      name = "bob-pumpjack-1",
      energy_required = 5,
      ingredients = {
        { type = "item", name = "pumpjack", amount = 1 },
        { type = "item", name = "steel-plate", amount = 20 },
        { type = "item", name = "iron-gear-wheel", amount = 10 },
        { type = "item", name = "advanced-circuit", amount = 5 },
        { type = "item", name = "pipe", amount = 10 },
      },
      results = { { type = "item", name = "bob-pumpjack-1", amount = 1 } },
      enabled = false,
    },
    {
      type = "recipe",
      name = "bob-pumpjack-2",
      energy_required = 5,
      ingredients = {
        { type = "item", name = "bob-pumpjack-1", amount = 1 },
        { type = "item", name = "steel-plate", amount = 20 },
        { type = "item", name = "iron-gear-wheel", amount = 10 },
        { type = "item", name = "processing-unit", amount = 5 },
        { type = "item", name = "pipe", amount = 10 },
      },
      results = { { type = "item", name = "bob-pumpjack-2", amount = 1 } },
      enabled = false,
    },
    {
      type = "recipe",
      name = "bob-pumpjack-3",
      energy_required = 5,
      ingredients = {
        { type = "item", name = "bob-pumpjack-2", amount = 1 },
        { type = "item", name = "steel-plate", amount = 20 },
        { type = "item", name = "iron-gear-wheel", amount = 10 },
        { type = "item", name = "processing-unit", amount = 5 },
        { type = "item", name = "pipe", amount = 10 },
      },
      results = { { type = "item", name = "bob-pumpjack-3", amount = 1 } },
      enabled = false,
    },
  })

  data:extend({
    {
      type = "mining-drill",
      name = "bob-pumpjack-1",
      icon = "__base__/graphics/icons/pumpjack.png",
      icon_size = 64,
      flags = { "placeable-neutral", "player-creation" },
      minable = { mining_time = 1, result = "bob-pumpjack-1" },
      resource_categories = { "basic-fluid" },
      max_health = 150,
      corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
      selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
      drawing_box_vertical_extension = 1,
      energy_source = {
        type = "electric",
        emissions_per_minute = { pollution = 10 },
        usage_priority = "secondary-input",
      },
      output_fluid_box = {
        volume = 1000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
          {
            flow_direction = "output",
            positions = { { 1, -1 }, { 1, -1 }, { -1, 1 }, { -1, 1 } },
            direction = defines.direction.north,
          },
        },
      },
      energy_usage = "171kW",
      mining_speed = 2,
      resource_searching_radius = 0.49,
      vector_to_place_result = { 0, 0 },
      module_slots = 3,
      icons_positioning = {
        {
          inventory_index = defines.inventory.mining_drill_modules,
          shift = { 0, 0.5 },
          multi_row_initial_height_modifier = -0.3,
        },
      },
      fast_replaceable_group = "pumpjack",
      radius_visualisation_picture = {
        filename = "__base__/graphics/entity/pumpjack/pumpjack-radius-visualization.png",
        width = 12,
        height = 12,
      },
      monitor_visualization_tint = { r = 78, g = 173, b = 255 },
      -- Factorio 2.1: graphics, output positions and flipping are taken from the vanilla pumpjack below.
      working_sound = {
        sound = { filename = "__base__/sound/pumpjack.ogg" },
      },
      circuit_connector = circuit_connector_definitions["pumpjack"],
      circuit_wire_max_distance = 10,
      next_upgrade = "bob-pumpjack-2",
    },
    {
      type = "mining-drill",
      name = "bob-pumpjack-2",
      icon = "__base__/graphics/icons/pumpjack.png",
      icon_size = 64,
      flags = { "placeable-neutral", "player-creation" },
      minable = { mining_time = 1, result = "bob-pumpjack-2" },
      resource_categories = { "basic-fluid" },
      max_health = 200,
      corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
      selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
      drawing_box_vertical_extension = 1,
      energy_source = {
        type = "electric",
        emissions_per_minute = { pollution = 10 },
        usage_priority = "secondary-input",
      },
      output_fluid_box = {
        volume = 1000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
          {
            flow_direction = "output",
            positions = { { 1, -1 }, { 1, -1 }, { -1, 1 }, { -1, 1 } },
            direction = defines.direction.north,
          },
        },
      },
      energy_usage = "243kW",
      mining_speed = 3,
      resource_searching_radius = 0.49,
      vector_to_place_result = { 0, 0 },
      module_slots = 4,
      icons_positioning = {
        {
          inventory_index = defines.inventory.mining_drill_modules,
          shift = { 0, 0.5 },
          multi_row_initial_height_modifier = -0.3,
        },
      },
      fast_replaceable_group = "pumpjack",
      radius_visualisation_picture = {
        filename = "__base__/graphics/entity/pumpjack/pumpjack-radius-visualization.png",
        width = 12,
        height = 12,
      },
      monitor_visualization_tint = { r = 78, g = 173, b = 255 },
      -- Factorio 2.1: graphics, output positions and flipping are taken from the vanilla pumpjack below.
      working_sound = {
        sound = { filename = "__base__/sound/pumpjack.ogg" },
      },
      circuit_connector = circuit_connector_definitions["pumpjack"],
      circuit_wire_max_distance = 12.5,
      next_upgrade = "bob-pumpjack-3",
    },
    {
      type = "mining-drill",
      name = "bob-pumpjack-3",
      icon = "__base__/graphics/icons/pumpjack.png",
      icon_size = 64,
      flags = { "placeable-neutral", "player-creation" },
      minable = { mining_time = 1, result = "bob-pumpjack-3" },
      resource_categories = { "basic-fluid" },
      max_health = 250,
      corpse = "big-remnants",
      dying_explosion = "medium-explosion",
      collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
      selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
      drawing_box_vertical_extension = 1,
      energy_source = {
        type = "electric",
        emissions_per_minute = { pollution = 10 },
        usage_priority = "secondary-input",
      },
      output_fluid_box = {
        volume = 1000,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
          {
            flow_direction = "output",
            positions = { { 1, -1 }, { 1, -1 }, { -1, 1 }, { -1, 1 } },
            direction = defines.direction.north,
          },
        },
      },
      energy_usage = "360kW",
      mining_speed = 5,
      resource_searching_radius = 0.49,
      vector_to_place_result = { 0, 0 },
      module_slots = 5,
      icons_positioning = {
        {
          inventory_index = defines.inventory.mining_drill_modules,
          shift = { 0, 0.5 },
          multi_row_initial_height_modifier = -0.3,
          max_icons_per_row = 3,
        },
      },
      fast_replaceable_group = "pumpjack",
      radius_visualisation_picture = {
        filename = "__base__/graphics/entity/pumpjack/pumpjack-radius-visualization.png",
        width = 12,
        height = 12,
      },
      monitor_visualization_tint = { r = 78, g = 173, b = 255 },
      -- Factorio 2.1: graphics, output positions and flipping are taken from the vanilla pumpjack below.
      working_sound = {
        sound = { filename = "__base__/sound/pumpjack.ogg" },
      },
      circuit_connector = circuit_connector_definitions["pumpjack"],
      circuit_wire_max_distance = 15,
    },
  })

  -- Factorio 2.1: the vanilla pumpjack was redrawn (other frame sizes; its base moved from base_picture to
  -- graphics_set.working_visualisations), its output moved per direction and it can be flipped; 2.0 saves get
  -- east/west pumpjacks flipped (migrate_horizontal_mirroring), which keeps their 2.0 output. The Bob pumpjacks
  -- take the same graphics, output positions, flipping and migration as the 2.1 vanilla pumpjack.
  do
    local vanilla = data.raw["mining-drill"]["pumpjack"]
    for _, name in pairs({ "bob-pumpjack-1", "bob-pumpjack-2", "bob-pumpjack-3" }) do
      local drill = data.raw["mining-drill"][name]
      drill.graphics_set = util.table.deepcopy(vanilla.graphics_set)
      drill.graphics_set_flipped = util.table.deepcopy(vanilla.graphics_set_flipped)
      drill.use_mirroring = vanilla.use_mirroring
      drill.migrate_horizontal_mirroring = vanilla.migrate_horizontal_mirroring
      for index, connection in pairs(vanilla.output_fluid_box.pipe_connections) do
        local own = drill.output_fluid_box.pipe_connections[index]
        own.positions, own.position, own.direction = util.table.deepcopy(connection.positions), connection.position, connection.direction
      end
    end
  end

  if feature_flags["freezing"] then
    data.raw["mining-drill"]["bob-pumpjack-1"].heating_energy = "50kW"
    data.raw["mining-drill"]["bob-pumpjack-2"].heating_energy = "50kW"
    data.raw["mining-drill"]["bob-pumpjack-3"].heating_energy = "50kW"
    if mods["space-age"] then
      local function frozenpatch()
        local result = util.table.deepcopy(data.raw["mining-drill"].pumpjack.graphics_set.frozen_patch)
        return result
      end
      data.raw["mining-drill"]["bob-pumpjack-1"].graphics_set.reset_animation_when_frozen = true
      data.raw["mining-drill"]["bob-pumpjack-2"].graphics_set.reset_animation_when_frozen = true
      data.raw["mining-drill"]["bob-pumpjack-3"].graphics_set.reset_animation_when_frozen = true
      data.raw["mining-drill"]["bob-pumpjack-1"].graphics_set.frozen_patch = frozenpatch()
      data.raw["mining-drill"]["bob-pumpjack-2"].graphics_set.frozen_patch = frozenpatch()
      data.raw["mining-drill"]["bob-pumpjack-3"].graphics_set.frozen_patch = frozenpatch()
    end
  end

  data:extend({
    {
      type = "technology",
      name = "bob-pumpjacks-2",
      icon = "__base__/graphics/technology/oil-gathering.png",
      icon_size = 256,
      prerequisites = {
        "oil-processing",
        "advanced-circuit",
        "chemical-science-pack",
      },
      unit = {
        count = 150,
        time = 30,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack", 1 },
          { "chemical-science-pack", 1 },
        },
      },
      effects = {
        {
          type = "unlock-recipe",
          recipe = "bob-pumpjack-1",
        },
      },
    },
    {
      type = "technology",
      name = "bob-pumpjacks-3",
      icon = "__base__/graphics/technology/oil-gathering.png",
      icon_size = 256,
      prerequisites = {
        "bob-pumpjacks-2",
        "production-science-pack",
        "processing-unit",
      },
      unit = {
        count = 200,
        time = 30,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack", 1 },
          { "chemical-science-pack", 1 },
          { "production-science-pack", 1 },
        },
      },
      effects = {
        {
          type = "unlock-recipe",
          recipe = "bob-pumpjack-2",
        },
      },
    },
    {
      type = "technology",
      name = "bob-pumpjacks-4",
      icon = "__base__/graphics/technology/oil-gathering.png",
      icon_size = 256,
      prerequisites = {
        "bob-pumpjacks-3",
        "processing-unit",
        "utility-science-pack",
      },
      unit = {
        count = 250,
        time = 30,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack", 1 },
          { "chemical-science-pack", 1 },
          { "production-science-pack", 1 },
          { "utility-science-pack", 1 },
        },
      },
      effects = {
        {
          type = "unlock-recipe",
          recipe = "bob-pumpjack-3",
        },
      },
    },
  })
end
