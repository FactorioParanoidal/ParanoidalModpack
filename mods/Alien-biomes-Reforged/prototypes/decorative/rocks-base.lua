local rock_coverage_multiplier = 3
local rock_max_prob_multiplier = 6
return {
{
  name = "huge-rock",
  type = "simple-entity",
  flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
  icon = "__base__/graphics/icons/huge-rock.png",
  icon_size = 64,
  subgroup = "grass",
  order = "b[decorative]-l[rock]-a[huge]",
  collision_box = {{-1.5, -1.1}, {1.5, 1.1}},
  selection_box = {{-1.7, -1.3}, {1.7, 1.3}},
  minable =
  {
    mining_particle = "stone-particle",
    mining_time = 1.5,
    results = {{type = "item", name = "stone", amount_min = 20, amount_max = 40}, {type = "item", name = "coal", amount_min = 0, amount_max = 20}},
    --count = 200
  },
  loot =
  {
    {item = "stone", probability = 1, count_min = 10, count_max = 20}
  },
  count_as_rock_for_filtered_deconstruction = true,
  mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
  --vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
  impact_category = "stone", --?
  render_layer = "object",
  max_health = 2000,
  resistances =
  {
    { type = "fire", percent = 100 },
    { type = "poison", percent = 100 }
  },
  autoplace = {
    order = "a[doodad]-a[rock]-a[huge]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.0875 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 1.5,
    },
    -- coverage = 0.00125 * rock_coverage_multiplier,
    -- max_probability = 0.0875 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-05.png",
      width = 201,
      height = 179,
      scale = 0.5,
      shift = {0.25, 0.0625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-06.png",
      width = 233,
      height = 171,
      scale = 0.5,
      shift = {0.429688, 0.046875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-07.png",
      width = 240,
      height = 192,
      scale = 0.5,
      shift = {0.398438, 0.03125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-08.png",
      width = 219,
      height = 175,
      scale = 0.5,
      shift = {0.148438, 0.132812}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-09.png",
      width = 240,
      height = 208,
      scale = 0.5,
      shift = {0.3125, 0.0625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-10.png",
      width = 243,
      height = 190,
      scale = 0.5,
      shift = {0.1875, 0.046875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-11.png",
      width = 249,
      height = 185,
      scale = 0.5,
      shift = {0.398438, 0.0546875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-12.png",
      width = 273,
      height = 163,
      scale = 0.5,
      shift = {0.34375, 0.0390625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-13.png",
      width = 275,
      height = 175,
      scale = 0.5,
      shift = {0.273438, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-14.png",
      width = 241,
      height = 215,
      scale = 0.5,
      shift = {0.195312, 0.0390625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-15.png",
      width = 318,
      height = 181,
      scale = 0.5,
      shift = {0.523438, 0.03125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-16.png",
      width = 217,
      height = 224,
      scale = 0.5,
      shift = {0.0546875, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-17.png",
      width = 332,
      height = 228,
      scale = 0.5,
      shift = {0.226562, 0.046875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-18.png",
      width = 290,
      height = 243,
      scale = 0.5,
      shift = {0.195312, 0.0390625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-19.png",
      width = 349,
      height = 225,
      scale = 0.5,
      shift = {0.609375, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/huge-rock/huge-rock-20.png",
      width = 287,
      height = 250,
      scale = 0.5,
      shift = {0.132812, 0.03125}
    }
  }
},
{
  name = "big-rock",
  type = "simple-entity",
  flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
  icon = "__base__/graphics/icons/big-rock.png",
  icon_size = 64,
  subgroup = "grass",
  order = "b[decorative]-l[rock]-b[big]",
  collision_box = {{-1.0, -0.9}, {1.0, 1.0}},
  selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
  minable =
  {
    mining_particle = "stone-particle",
    mining_time = 1,
    result = "stone",
    count = 20
  },
  loot =
  {
    {item = "stone", probability = 1, count_min = 10, count_max = 20}
  },
  count_as_rock_for_filtered_deconstruction = true,
  mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
  --vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
  impact_category = "stone", --?
  render_layer = "object",
  max_health = 500,
  resistances =
  {
    { type = "fire", percent = 100 },
    { type = "poison", percent = 100 }
  },
  autoplace = {
    order = "a[doodad]-a[rock]-b[big]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.16 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 1.4,
    },
    -- coverage = 0.002 * rock_coverage_multiplier,
    -- max_probability = 0.16 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-01.png",
      width = 188,
      height = 127,
      scale = 0.5,
      shift = {-0.046875, 0.171875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-02.png",
      width = 195,
      height = 135,
      scale = 0.5,
      shift = {0.445312, 0.125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-03.png",
      width = 205,
      height = 132,
      scale = 0.5,
      shift = {0.484375, 0.0546875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-04.png",
      width = 144,
      height = 142,
      scale = 0.5,
      shift = {0.210938, 0.0390625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-05.png",
      width = 130,
      height = 107,
      scale = 0.5,
      shift = {0.0234375, 0.226562}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-06.png",
      width = 165,
      height = 109,
      scale = 0.5,
      shift = {0.15625, 0.226562}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-07.png",
      width = 150,
      height = 133,
      scale = 0.5,
      shift = {0.257812, 0.148438}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-08.png",
      width = 156,
      height = 111,
      scale = 0.5,
      shift = {0.0859375, 0.179688}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-09.png",
      width = 187,
      height = 120,
      scale = 0.5,
      shift = {0.078125, 0.0859375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-10.png",
      width = 225,
      height = 128,
      scale = 0.5,
      shift = {-0.15625, 0.0703125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-11.png",
      width = 183,
      height = 144,
      scale = 0.5,
      shift = {0.195312, 0.257812}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-12.png",
      width = 158,
      height = 138,
      scale = 0.5,
      shift = {0.0390625, 0.15625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-13.png",
      width = 188,
      height = 150,
      scale = 0.5,
      shift = {0.226562, 0.21875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-14.png",
      width = 186,
      height = 160,
      scale = 0.5,
      shift = {0.132812, 0.0625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-15.png",
      width = 181,
      height = 174,
      scale = 0.5,
      shift = {0.304688, -0.09375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-16.png",
      width = 212,
      height = 150,
      scale = 0.5,
      shift = {0.335938, 0.117188}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-17.png",
      width = 155,
      height = 117,
      scale = 0.5,
      shift = {0.25, 0.0390625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-18.png",
      width = 141,
      height = 128,
      scale = 0.5,
      shift = {0.304688, 0.0390625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-19.png",
      width = 176,
      height = 114,
      scale = 0.5,
      shift = {0.390625, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/big-rock/big-rock-20.png",
      width = 120,
      height = 125,
      scale = 0.5,
      shift = {0.148438, 0.03125}
    },
  }
},
{
  name = "medium-rock",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-l[rock]-c[medium]",
  collision_box = {{-1.1, -1.1}, {1.1, 1.1}},
  --selection_box = {{-1.3, -1.3}, {1.3, 1.3}},
  render_layer = "decorative",
  autoplace = {
    order = "a[doodad]-a[rock]-c[medium]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.35 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 0.85,
    },
    -- coverage = 0.005 * rock_coverage_multiplier,
    -- max_probability = 0.35 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-01.png",
      priority = base_decorative_sprite_priority,
      width = 89,
      height = 63,
      scale = 0.5,
      shift = {0.078125, 0.109375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-02.png",
      priority = base_decorative_sprite_priority,
      width = 77,
      height = 66,
      scale = 0.5,
      shift = {0.015625, 0.132812}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-03.png",
      priority = base_decorative_sprite_priority,
      width = 92,
      height = 63,
      scale = 0.5,
      shift = {0.148438, 0.179688}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-04.png",
      priority = base_decorative_sprite_priority,
      width = 91,
      height = 59,
      scale = 0.5,
      shift = {-0.0078125, 0.1875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-05.png",
      priority = base_decorative_sprite_priority,
      width = 104,
      height = 72,
      scale = 0.5,
      shift = {0.203125, 0.179688}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-06.png",
      priority = base_decorative_sprite_priority,
      width = 83,
      height = 82,
      scale = 0.5,
      shift = {0.015625, 0.21875}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-07.png",
      priority = base_decorative_sprite_priority,
      width = 111,
      height = 65,
      scale = 0.5,
      shift = {0.0625, 0.3125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-08.png",
      priority = base_decorative_sprite_priority,
      width = 79,
      height = 81,
      scale = 0.5,
      shift = {0.109375, 0.148438}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-09.png",
      priority = base_decorative_sprite_priority,
      width = 98,
      height = 56,
      scale = 0.5,
      shift = {0.015625, 0.140625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-10.png",
      priority = base_decorative_sprite_priority,
      width = 91,
      height = 68,
      scale = 0.5,
      shift = {0, 0.132812}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-11.png",
      priority = base_decorative_sprite_priority,
      width = 105,
      height = 71,
      scale = 0.5,
      shift = {-0.0234375, 0.125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/medium-rock/medium-rock-12.png",
      priority = base_decorative_sprite_priority,
      width = 78,
      height = 80,
      scale = 0.5,
      shift = {0.078125, -0.015625}
    }
  }
},
{
  name = "small-rock",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-l[rock]-d[small]",
  collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
  render_layer = "decorative",
  autoplace = {
    order = "a[doodad]-a[rock]-d[small]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.7 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 0.7,
    },
    -- coverage = 0.01 * rock_coverage_multiplier,
    -- max_probability = 0.7 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-01.png",
      priority = base_decorative_sprite_priority,
      width = 51,
      height = 37,
      scale = 0.5,
      shift = {0.0546875, 0.117188}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-02.png",
      priority = base_decorative_sprite_priority,
      width = 52,
      height = 35,
      scale = 0.5,
      shift = {0.0390625, 0.078125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-03.png",
      priority = base_decorative_sprite_priority,
      width = 46,
      height = 42,
      scale = 0.5,
      shift = {-0.0078125, 0.148438}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-04.png",
      priority = base_decorative_sprite_priority,
      width = 53,
      height = 33,
      scale = 0.5,
      shift = {0.0234375, 0.15625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-05.png",
      priority = base_decorative_sprite_priority,
      width = 47,
      height = 46,
      scale = 0.5,
      shift = {0.0390625, 0.140625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-06.png",
      priority = base_decorative_sprite_priority,
      width = 62,
      height = 41,
      scale = 0.5,
      shift = {-0.03125, 0.09375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-07.png",
      priority = base_decorative_sprite_priority,
      width = 64,
      height = 36,
      scale = 0.5,
      shift = {-0.015625, 0.0703125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-08.png",
      priority = base_decorative_sprite_priority,
      width = 65,
      height = 31,
      scale = 0.5,
      shift = {-0.71875, -0.164062}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-09.png",
      priority = base_decorative_sprite_priority,
      width = 46,
      height = 34,
      scale = 0.5,
      shift = {-0.0859375, 0.101562}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-10.png",
      priority = base_decorative_sprite_priority,
      width = 48,
      height = 34,
      scale = 0.5,
      shift = {0.0078125, 0.125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-11.png",
      priority = base_decorative_sprite_priority,
      width = 51,
      height = 33,
      scale = 0.5,
      shift = {-0.0859375, 0.078125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-12.png",
      priority = base_decorative_sprite_priority,
      width = 47,
      height = 39,
      scale = 0.5,
      shift = {0.078125, 0.117188}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-13.png",
      priority = base_decorative_sprite_priority,
      width = 43,
      height = 33,
      scale = 0.5,
      shift = {0, 0.09375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-14.png",
      priority = base_decorative_sprite_priority,
      width = 43,
      height = 30,
      scale = 0.5,
      shift = {0.046875, 0.140625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-15.png",
      priority = base_decorative_sprite_priority,
      width = 41,
      height = 37,
      scale = 0.5,
      shift = {0, 0.140625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/small-rock/small-rock-16.png",
      priority = base_decorative_sprite_priority,
      width = 46,
      height = 33,
      scale = 0.5,
      shift = {0.0234375, 0.125}
    }
  }
},
{
  name = "tiny-rock",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-l[rock]-e[tiny]",
  collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
  render_layer = "decorative",
  autoplace = {
    order = "a[doodad]-a[rock]-e[tiny]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.77 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 0.7,
    },
    -- coverage = 0.011000000000000001 * rock_coverage_multiplier,
    -- max_probability = 0.77000000000000002 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-01.png",
      priority = base_decorative_sprite_priority,
      width = 29,
      height = 21,
      scale = 0.5,
      shift = {0.0390625, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-02.png",
      priority = base_decorative_sprite_priority,
      width = 30,
      height = 19,
      scale = 0.5,
      shift = {0.0078125, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-03.png",
      priority = base_decorative_sprite_priority,
      width = 29,
      height = 24,
      scale = 0.5,
      shift = {0.0234375, 0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-04.png",
      priority = base_decorative_sprite_priority,
      width = 32,
      height = 20,
      scale = 0.5,
      shift = {0.03125, 0.015625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-05.png",
      priority = base_decorative_sprite_priority,
      width = 29,
      height = 25,
      scale = 0.5,
      shift = {0, -0.0078125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-06.png",
      priority = base_decorative_sprite_priority,
      width = 36,
      height = 24,
      scale = 0.5,
      shift = {0, -0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-07.png",
      priority = base_decorative_sprite_priority,
      width = 78,
      height = 34,
      scale = 0.5,
      shift = {-0.34375, -0.132812}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-08.png",
      priority = base_decorative_sprite_priority,
      width = 35,
      height = 19,
      scale = 0.5,
      shift = {-0.03125, 0}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-09.png",
      priority = base_decorative_sprite_priority,
      width = 28,
      height = 20,
      scale = 0.5,
      shift = {0.0234375, 0.015625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-10.png",
      priority = base_decorative_sprite_priority,
      width = 29,
      height = 20,
      scale = 0.5,
      shift = {0.0078125, -0.0234375}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-11.png",
      priority = base_decorative_sprite_priority,
      width = 29,
      height = 20,
      scale = 0.5,
      shift = {0.046875, 0.0078125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-12.png",
      priority = base_decorative_sprite_priority,
      width = 29,
      height = 22,
      scale = 0.5,
      shift = {0.015625, 0}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-13.png",
      priority = base_decorative_sprite_priority,
      width = 27,
      height = 19,
      scale = 0.5,
      shift = {0.03125, 0.015625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-14.png",
      priority = base_decorative_sprite_priority,
      width = 27,
      height = 19,
      scale = 0.5,
      shift = {0.0078125, 0.0078125}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-15.png",
      priority = base_decorative_sprite_priority,
      width = 26,
      height = 22,
      scale = 0.5,
      shift = {0.0078125, 0.015625}
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/tiny-rock/tiny-rock-16.png",
      priority = base_decorative_sprite_priority,
      width = 27,
      height = 20,
      scale = 0.5,
      shift = {0.03125, 0.0078125}
    }
  }
},
{
  name = "sand-big-rock",
  type = "simple-entity",
  flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
  icon = "__base__/graphics/icons/big-rock.png",
  icon_size = 64,
  subgroup = "wrecks",
  order = "b[decorative]-l[rock]-b[big]",
  collision_box = {{-0.75, -0.75}, {0.75, 0.75}},
  selection_box = {{-1.0, -1.0}, {1.0, 0.75}},
  render_layer = "object",
  max_health = 500,
  autoplace = {
    order = "a[doodad]-a[rock]-b[big]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.175 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      sharpness = 0.7,
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile",
      quantile = 1.9,
    },
    -- coverage = 0.0025 * rock_coverage_multiplier,
    -- max_probability = 0.175 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  minable =
  {
    mining_particle = "stone-particle",
    mining_time = 1,
    results = {{type = "item", name = "stone", amount_min = 10, amount_max = 20}},
  },
  loot =
  {
    {item = "stone", probability = 1, count_min = 0, count_max = 10}
  },
  resistances =
  {
    { type = "fire", percent = 100 },
    { type = "poison", percent = 100 }
  },
  count_as_rock_for_filtered_deconstruction = true,
  mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
  --vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
  impact_category = "stone", --?
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-01.png",
      width = 209,
      height = 138,
      shift = {0.304688, -0.4},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-02.png",
      width = 165,
      height = 129,
      shift = {0.0, 0.0390625},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-03.png",
      width = 151,
      height = 139,
      shift = {0.151562, 0.0},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-04.png",
      width = 216,
      height = 110,
      shift = {0.390625, 0.0},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-05.png",
      width = 154,
      height = 147,
      shift = {0.328125, 0.0703125},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-06.png",
      width = 154,
      height = 132,
      shift = {0.16875, -0.1},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-07.png",
      width = 193,
      height = 130,
      shift = {0.3, -0.2},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-08.png",
      width = 136,
      height = 117,
      shift = {0.0, 0.0},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-09.png",
      width = 157,
      height = 115,
      shift = {0.1, 0.0},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-10.png",
      width = 198,
      height = 153,
      shift = {0.325, -0.1},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-11.png",
      width = 190,
      height = 115,
      shift = {0.453125, 0.0},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-12.png",
      width = 229,
      height = 126,
      shift = {0.539062, -0.015625},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-13.png",
      width = 151,
      height = 125,
      shift = {0.0703125, 0.179688},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-14.png",
      width = 137,
      height = 117,
      shift = {0.160938, 0.0},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-15.png",
      width = 201,
      height = 141,
      shift = {0.242188, -0.195312},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-big-rock-16.png",
      width = 209,
      height = 154,
      shift = {0.351562, -0.1},
      scale = 0.5,
    },
  },
},
{
  name = "sand-medium-rock",
  type = "optimized-decorative",
  subgroup = "wrecks",
  order = "d[remnants]-d[ship-wreck-grass]-b[small]",
  collision_box = {{-1.5, -0.5}, {1.5, 0.5}},
  render_layer = "floor",
  autoplace = {
    order = "a[doodad]-a[rock]-c[medium]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.28 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      sharpness = 0.7,
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 1.2,
    },
    -- coverage = 0.004 * rock_coverage_multiplier,
    -- max_probability = 0.27999999999999998 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-01.png",
      priority = base_decorative_sprite_priority,
      width = 134,
      height = 82,
      shift = {0.328125, 0.515625},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-02.png",
      priority = base_decorative_sprite_priority,
      width = 110,
      height = 79,
      shift = {0.15625, 0.570312},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-03.png",
      priority = base_decorative_sprite_priority,
      width = 90,
      height = 60,
      shift = {0.34375, 0.484375},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-04.png",
      priority = base_decorative_sprite_priority,
      width = 110,
      height = 89,
      shift = {0.296875, 0.476562},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-05.png",
      priority = base_decorative_sprite_priority,
      width = 106,
      height = 76,
      shift = {0.359375, 0.25},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-06.png",
      priority = base_decorative_sprite_priority,
      width = 100,
      height = 92,
      shift = {0.4375, 0.296875},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-07.png",
      priority = base_decorative_sprite_priority,
      width = 82,
      height = 83,
      shift = {0.59375, 0.398438},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-08.png",
      priority = base_decorative_sprite_priority,
      width = 123,
      height = 92,
      shift = {0.601562, 0.328125},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-09.png",
      priority = base_decorative_sprite_priority,
      width = 146,
      height = 76,
      shift = {0.5625, 0.3125},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-10.png",
      priority = base_decorative_sprite_priority,
      width = 112,
      height = 77,
      shift = {0.46875, 0.460938},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-11.png",
      priority = base_decorative_sprite_priority,
      width = 91,
      height = 61,
      shift = {0.445312, 0.507812},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-12.png",
      priority = base_decorative_sprite_priority,
      width = 105,
      height = 84,
      shift = {0.398438, 0.453125},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-13.png",
      priority = base_decorative_sprite_priority,
      width = 94,
      height = 73,
      shift = {0.375, 0.632812},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-14.png",
      priority = base_decorative_sprite_priority,
      width = 122,
      height = 89,
      shift = {0.359375, 0.570312},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-15.png",
      priority = base_decorative_sprite_priority,
      width = 98,
      height = 65,
      shift = {0.1875, 0.773438},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-medium-rock-16.png",
      priority = base_decorative_sprite_priority,
      width = 144,
      height = 76,
      shift = {0.109375, 0.71875},
      scale = 0.5,
    },
  }
},

{
  name = "sand-small-rock",
  type = "optimized-decorative",
  subgroup = "wrecks",
  order = "d[remnants]-d[ship-wreck-grass]-b[small]",
  collision_box = {{-1.5, -0.5}, {1.5, 0.5}},
  render_layer = "floor",
  autoplace = {
    order = "a[doodad]-a[rock]-d[small]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.77 * rock_max_prob_multiplier,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='rocks', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 1.0,
    },
    -- coverage = 0.011000000000000001 * rock_coverage_multiplier,
    -- max_probability = 0.77000000000000002 * rock_max_prob_multiplier,
    -- peaks = {
    --   {
    --     noise_layer = "rocks",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9,
    --   }
    -- },
    -- sharpness = 0.7
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-01.png",
      priority = base_decorative_sprite_priority,
      width = 56,
      height = 45,
      shift = {0.40625, 0.476562},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-02.png",
      priority = base_decorative_sprite_priority,
      width = 54,
      height = 45,
      shift = {0.296875, 0.476562},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-03.png",
      priority = base_decorative_sprite_priority,
      width = 44,
      height = 40,
      shift = {0.328125, 0.53125},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-04.png",
      priority = base_decorative_sprite_priority,
      width = 60,
      height = 43,
      shift = {0.265625, 0.601562},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-05.png",
      priority = base_decorative_sprite_priority,
      width = 52,
      height = 48,
      shift = {0.296875, 0.46875},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-06.png",
      priority = base_decorative_sprite_priority,
      width = 57,
      height = 39,
      shift = {0.554688, 0.523438},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-07.png",
      priority = base_decorative_sprite_priority,
      width = 73,
      height = 41,
      shift = {0.570312, 0.539062},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-08.png",
      priority = base_decorative_sprite_priority,
      width = 50,
      height = 46,
      shift = {0.640625, 0.390625},
      scale = 0.5,
     },
     {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-09.png",
      priority = base_decorative_sprite_priority,
      width = 52,
      height = 43,
      shift = {0.671875, 0.335938},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-10.png",
      priority = base_decorative_sprite_priority,
      width = 63,
      height = 39,
      shift = {0.632812, 0.398438},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-11.png",
      priority = base_decorative_sprite_priority,
      width = 57,
      height = 41,
      shift = {0.460938, 0.617188},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-12.png",
      priority = base_decorative_sprite_priority,
      width = 67,
      height = 51,
      shift = {0.460938, 0.570312},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-13.png",
      priority = base_decorative_sprite_priority,
      width = 70,
      height = 37,
      shift = {0.484375, 0.789062},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-14.png",
      priority = base_decorative_sprite_priority,
      width = 63,
      height = 48,
      shift = {0.179688, 0.90625},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-15.png",
      priority = base_decorative_sprite_priority,
      width = 56,
      height = 48,
      shift = {0.140625, 0.78125},
      scale = 0.5,
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-rock/sand-small-rock-16.png",
      priority = base_decorative_sprite_priority,
      width = 74,
      height = 46,
      shift = {-0.03125, 0.78125},
      scale = 0.5,
    },
  },
},
{
  name = "sand-decal",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-b[red-desert-decal]",
  collision_box = {{-6, -6}, {6, 6}},
  collision_mask = {
    layers = {
      doodad = true,
      water_tile = true,
    },
    not_colliding_with_itself = true
  },
  render_layer = "decals",
  tile_layer = default_decal_layer, -- despite the name, this is not sand exclusive decal; draw under stone path and concrete
  autoplace = {
    order = "a[doodad]-b[decal]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.05,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.1)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "0.2 * peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='sand-decal', octaves=octaves-4, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.05",
      quantile = 0.4,
    },
    -- max_probability = 0.05,
    -- peaks = {
    --   {
    --     influence = 0.2,
    --     noise_layer = "sand-decal",
    --     --noise_octaves_difference = -2,
    --     noise_octaves_difference = -4,
    --     noise_persistence = 0.9
    --   },
    --   {
    --     influence = 0.05,
    --   }
    -- },
    -- sharpness = 0.1
  },
  pictures =
  {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-01.png",
      width = 975,
      height = 664,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-02.png",
      width = 628,
      height = 477,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-03.png",
      width = 519,
      height = 331,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-04.png",
      width = 870,
      height = 781,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-05.png",
      width = 230,
      height = 161,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-06.png",
      width = 140,
      height = 110,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-07.png",
      width = 285,
      height = 243,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-08.png",
      width = 156,
      height = 85,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-09.png",
      width = 212,
      height = 152,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-10.png",
      width = 233,
      height = 197,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-11.png",
      width = 324,
      height = 413,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-12.png",
      width = 504,
      height = 488,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-13.png",
      width = 329,
      height = 305,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-14.png",
      width = 811,
      height = 724,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-15.png",
      width = 266,
      height = 262,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-16.png",
      width = 921,
      height = 712,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-17.png",
      width = 722,
      height = 395,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-18.png",
      width = 187,
      height = 289,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-19.png",
      width = 999,
      height = 374,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-20.png",
      width = 783,
      height = 399,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-21.png",
      width = 668,
      height = 406,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-22.png",
      width = 437,
      height = 318,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-23.png",
      width = 394,
      height = 246,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-24.png",
      width = 361,
      height = 291,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-25.png",
      width = 1290,
      height = 1281,
      slice_y = 4,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-26.png",
      width = 314,
      height = 174,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-27.png",
      width = 348,
      height = 264,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-28.png",
      width = 488,
      height = 357,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-29.png",
      width = 594,
      height = 634,
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/sand-decal/sand-decal-30.png",
      width = 195,
      height = 215,
      scale = 0.5
    },
  },
},
{
  name = "sand-dune-decal",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-b[red-desert-decal]",
  collision_box = {{-4, -4}, {4, 4}},
  collision_mask = {
    layers = {
      doodad = true,
      water_tile = true,
    },
    not_colliding_with_itself = true
  },
  render_layer = "decals",
  tile_layer = default_decal_layer,
  autoplace =
  {
    order = "a[doodad]-b[decal]",
    tile_restriction = { "sand-1" },
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.04,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.2)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='sand-dune-decal', octaves=octaves-3, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.5",
      quantile = -0,
    },
    -- sharpness = 0.2,
    -- max_probability = 0.04,
    -- peaks = {
    --   {
    --     influence = 0.5,
    --   },
    --   {
    --     influence = 1,
    --     noise_layer = "sand-dune-decal",
    --     noise_octaves_difference = -3,
    --     noise_persistence = 0.7,
    --   }
    -- },
  },
  pictures =
  {
    --dune
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-00.png",
      width = 212,
      height = 168,
      shift = util.by_pixel(-8, 0),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-01.png",
      width = 211,
      height = 148,
      shift = util.by_pixel(5.75, -3.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-02.png",
      width = 260,
      height = 184,
      shift = util.by_pixel(3, 1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-03.png",
      width = 129,
      height = 181,
      shift = util.by_pixel(0.75, 1.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-04.png",
      width = 196,
      height = 184,
      shift = util.by_pixel(-3.5, -1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-05.png",
      width = 215,
      height = 184,
      shift = util.by_pixel(-1.25, -1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-06.png",
      width = 218,
      height = 179,
      shift = util.by_pixel(6.5, 4.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-07.png",
      width = 250,
      height = 183,
      shift = util.by_pixel(17.5, 3.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-08.png",
      width = 260,
      height = 176,
      shift = util.by_pixel(5, 0.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-09.png",
      width = 260,
      height = 184,
      shift = util.by_pixel(-5.5, -1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-10.png",
      width = 233,
      height = 183,
      shift = util.by_pixel(-13.75, 1.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-11.png",
      width = 172,
      height = 184,
      shift = util.by_pixel(-9.5, 2),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-12.png",
      width = 260,
      height = 166,
      shift = util.by_pixel(2.5, -6.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-13.png",
      width = 259,
      height = 172,
      shift = util.by_pixel(4.75, -1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-14.png",
      width = 199,
      height = 184,
      shift = util.by_pixel(-2.25, -2),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-15.png",
      width = 214,
      height = 184,
      shift = util.by_pixel(8.5, -3),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-16.png",
      width = 162,
      height = 182,
      shift = util.by_pixel(-8, -4.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-17.png",
      width = 222,
      height = 153,
      shift = util.by_pixel(-3, -0.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-18.png",
      width = 247,
      height = 184,
      shift = util.by_pixel(4.25, -2.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-19.png",
      width = 211,
      height = 184,
      shift = util.by_pixel(-5.75, -3),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-20.png",
      width = 248,
      height = 183,
      shift = util.by_pixel(-1.5, 2.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-21.png",
      width = 176,
      height = 184,
      shift = util.by_pixel(6.5, 1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-22.png",
      width = 208,
      height = 185,
      shift = util.by_pixel(9, -1.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-23.png",
      width = 227,
      height = 184,
      shift = util.by_pixel(-3.75, -1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-24.png",
      width = 158,
      height = 186,
      shift = util.by_pixel(4.5, -1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-25.png",
      width = 260,
      height = 184,
      shift = util.by_pixel(1.5, -1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-26.png",
      width = 134,
      height = 184,
      shift = util.by_pixel(-0.5, -1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-27.png",
      width = 127,
      height = 165,
      shift = util.by_pixel(26.25, 1.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-28.png",
      width = 258,
      height = 158,
      shift = util.by_pixel(-2.5, -4.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/dune/|color|/sand-dune-decal/sand-dune-decal-29.png",
      width = 180,
      height = 184,
      shift = util.by_pixel(-3.5, -2),
      scale = 0.5
    },
  },
},
{
  name = "stone-decal",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-b[red-desert-decal]",
  collision_box = {{-4, -4}, {4, 4}},
  collision_mask = {
    layers = {
      doodad = true,
      water_tile = true,
    },
    not_colliding_with_itself = true
  },
  render_layer = "decals",
  tile_layer = default_decal_layer, -- under stone-path
  autoplace =
  {
    order = "a[doodad]-b[decal]",
    probability_expression = "max_probability * sharpness_filter",
    local_expressions = {
      max_probability = 0.01,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.3)",
      peaks_expr = "influence_modifier + peak1_expr",
      peak1_expr = "peak1_noise_expression",
      peak1_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='stone-decal', octaves=octaves-2, input_scale=1, output_scale=1}",
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = -0,
    },
    -- max_probability = 0.01,
    -- peaks = {
    --   {
    --     noise_layer = "stone-decal",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.9
    --   }
    -- },
    -- sharpness = 0.3
  },
  pictures =
  {
    --lightDecal
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-00.png",
      width = 400,
      height = 299,
      shift = util.by_pixel(4.5, -2.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-01.png",
      width = 419,
      height = 320,
      shift = util.by_pixel(-0.75, 2),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-02.png",
      width = 417,
      height = 287,
      shift = util.by_pixel(-1.25, 1.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-03.png",
      width = 421,
      height = 298,
      shift = util.by_pixel(-0.25, 5.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-04.png",
      width = 396,
      height = 302,
      shift = util.by_pixel(6, 4),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-05.png",
      width = 408,
      height = 295,
      shift = util.by_pixel(-2.5, 7.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-06.png",
      width = 417,
      height = 317,
      shift = util.by_pixel(-1.25, 3.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-07.png",
      width = 419,
      height = 312,
      shift = util.by_pixel(0.75, 2.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-08.png",
      width = 413,
      height = 317,
      shift = util.by_pixel(-2.25, 2.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-09.png",
      width = 403,
      height = 310,
      shift = util.by_pixel(0.25, 1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-10.png",
      width = 411,
      height = 307,
      shift = util.by_pixel(-0.75, 1.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-11.png",
      width = 421,
      height = 295,
      shift = util.by_pixel(-0.25, -0.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-12.png",
      width = 420,
      height = 280,
      shift = util.by_pixel(-0.5, -7),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-13.png",
      width = 403,
      height = 311,
      shift = util.by_pixel(0.75, 3.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-14.png",
      width = 418,
      height = 304,
      shift = util.by_pixel(0, 2),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-15.png",
      width = 398,
      height = 284,
      shift = util.by_pixel(-3.5, 6.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-16.png",
      width = 406,
      height = 313,
      shift = util.by_pixel(4, 0.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-17.png",
      width = 420,
      height = 294,
      shift = util.by_pixel(0.5, 4.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-18.png",
      width = 379,
      height = 289,
      shift = util.by_pixel(0.25, 5.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-19.png",
      width = 401,
      height = 311,
      shift = util.by_pixel(-5.25, 1.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-20.png",
      width = 418,
      height = 315,
      shift = util.by_pixel(0.5, 1.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-21.png",
      width = 418,
      height = 314,
      shift = util.by_pixel(1, 3),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-22.png",
      width = 421,
      height = 270,
      shift = util.by_pixel(-0.25, 1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-23.png",
      width = 403,
      height = 290,
      shift = util.by_pixel(2.25, -2.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-24.png",
      width = 418,
      height = 315,
      shift = util.by_pixel(-0.5, 2.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-25.png",
      width = 414,
      height = 310,
      shift = util.by_pixel(-2, 4),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-26.png",
      width = 403,
      height = 306,
      shift = util.by_pixel(-3.75, 5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-27.png",
      width = 416,
      height = 303,
      shift = util.by_pixel(1, 0.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-28.png",
      width = 422,
      height = 311,
      shift = util.by_pixel(0, 2.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/stone-decal/stone-decal-29.png",
      width = 406,
      height = 292,
      shift = util.by_pixel(-3.5, 2),
      scale = 0.5
    },
  },
},
}
