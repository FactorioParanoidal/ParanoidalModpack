data.raw.item["beacon"].subgroup = "module-beacon"


data:extend(
{
  {
    type = "item",
    name = "beacon-2",
    icon = "__base__/graphics/icons/beacon.png",
    icon_size = 32,
    
    subgroup = "module-beacon",
    order = "a[beacon]-2",
    place_result = "beacon-2",
    stack_size = 10
  },

  {
    type = "item",
    name = "beacon-3",
    icon = "__base__/graphics/icons/beacon.png",
    icon_size = 32,
    
    subgroup = "module-beacon",
    order = "a[beacon]-3",
    place_result = "beacon-3",
    stack_size = 10
  },


  {
    type = "beacon",
    name = "beacon-2",
    icon = "__base__/graphics/icons/beacon.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "beacon-2"},
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    allowed_effects = {"consumption", "speed", "pollution"},
    base_picture =
    {
      filename = "__base__/graphics/entity/beacon/beacon-base.png",
      width = 116,
      height = 93,
      shift = { 0.34, 0.06}
    },
    animation =
    {
      filename = "__base__/graphics/entity/beacon/beacon-antenna.png",
      width = 54,
      height = 50,
      line_length = 8,
      frame_count = 32,
      shift = { -0.03, -1.72},
      animation_speed = 0.5
    },
    animation_shadow =
    {
      filename = "__base__/graphics/entity/beacon/beacon-antenna-shadow.png",
      width = 63,
      height = 49,
      line_length = 8,
      frame_count = 32,
      shift = { 3.12, 0.5},
      animation_speed = 0.5
    },
    radius_visualisation_picture =
    {
      filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
      width = 10,
      height = 10
    },
    supply_area_distance = 6,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "480kW",
    distribution_effectivity = 0.75,
    module_specification =
    {
      module_slots = 4,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    }
  },

  {
    type = "beacon",
    name = "beacon-3",
    icon = "__base__/graphics/icons/beacon.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "beacon-3"},
    max_health = 400,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    allowed_effects = {"consumption", "speed", "pollution"},
    base_picture =
    {
      filename = "__base__/graphics/entity/beacon/beacon-base.png",
      width = 116,
      height = 93,
      shift = { 0.34, 0.06}
    },
    animation =
    {
      filename = "__base__/graphics/entity/beacon/beacon-antenna.png",
      width = 54,
      height = 50,
      line_length = 8,
      frame_count = 32,
      shift = { -0.03, -1.72},
      animation_speed = 0.5
    },
    animation_shadow =
    {
      filename = "__base__/graphics/entity/beacon/beacon-antenna-shadow.png",
      width = 63,
      height = 49,
      line_length = 8,
      frame_count = 32,
      shift = { 3.12, 0.5},
      animation_speed = 0.5
    },
    radius_visualisation_picture =
    {
      filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
      width = 10,
      height = 10
    },
    supply_area_distance = 9,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "480kW",
    distribution_effectivity = 1,
    module_specification =
    {
      module_slots = 6,
      module_info_icon_shift = {0, 0.5},
      module_info_multi_row_initial_height_modifier = -0.3
    }
  },


  {
    type = "recipe",
    name = "beacon-2",
    enabled = "false",
    energy_required = 30,
    ingredients =
    {
      {"beacon", 1},
      {"electronic-circuit", 20},
      {"advanced-circuit", 20},
      {"processing-unit", 20},
      {"steel-plate", 10},
      {"copper-cable", 10},
    },
    result = "beacon-2"
  },

  {
    type = "recipe",
    name = "beacon-3",
    enabled = "false",
    energy_required = 45,
    ingredients =
    {
      {"beacon-2", 1},
      {"electronic-circuit", 20},
      {"advanced-circuit", 20},
      {"processing-unit", 20},
      {"steel-plate", 10},
      {"copper-plate", 10},
      {"copper-cable", 10},
    },
    result = "beacon-3"
  },


  {
    type = "technology",
    name = "effect-transmission-2",
    icon = "__base__/graphics/technology/effect-transmission.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "beacon-2"
      }
    },
    prerequisites =
    {
      "effect-transmission",
      "advanced-electronics-2"
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    order = "i-i-2"
  },

  {
    type = "technology",
    name = "effect-transmission-3",
    icon = "__base__/graphics/technology/effect-transmission.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "beacon-3"
      }
    },
    prerequisites =
    {
      "effect-transmission-2"
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    order = "i-i-3"
  },
}
)


