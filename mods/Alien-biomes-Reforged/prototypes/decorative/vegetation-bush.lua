local util = require("data-util")
local flower_bush_base = {
  name = "flower-bush",
  type = "optimized-decorative",
  autoplace = {
    order = "a[doodad]-e[garballo]",
    probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
    local_expressions = {
      max_probability = 1,
      penalty = 0.75,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.8)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
      peak1_expr = -1.4,
      peak2_expr = "peak2_noise_expression",
      peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='garballo', octaves=octaves, input_scale=1, output_scale=1}",
      peak3_expr = "peak3_distance_expression",
      peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 3)))",
      peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr + peak3_aux_expr",
      peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
      peak3_moisture_optimal = 1,
      peak3_moisture_range = 0.3,
      peak3_moisture_max_range = 0.35,
      peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
      peak3_temperature_optimal = 15,
      peak3_temperature_range = 15,
      peak3_temperature_max_range = 20,
      peak3_aux_expr = "ab_mimic_peak_dimension(aux,peak3_aux_optimal,peak3_aux_range,peak3_aux_max_range)",
      peak3_aux_optimal = 0,
      peak3_aux_range = 0.25,
      peak3_aux_max_range = 0.2,
      octaves = "10 - log2(var('control:trees:frequency'))",
      influence_modifier = "0.5 - quantile + 0.4",
      quantile = 1,
    },
    -- max_probability = 1,
    -- peaks = {
    --   { influence = -1.4 },
    --   {
    --     noise_layer = "garballo",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.8,
    --   },
    --   {
    --     temperature_optimal = 15,
    --     temperature_range = 15,
    --     temperature_max_range = 20,
    --     water_optimal = 1,
    --     water_range = 0.3,
    --     water_max_range = 0.35,
    --     aux_optimal = 0,
    --     aux_range = 0.25,
    --     aux_max_range = 0.2,
    --   }
    -- },
    -- random_probability_penalty = 0.75,
    -- sharpness = 0.8
  },
  subgroup = "grass",
  collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
  order = "b[decorative]-g[fluff]-b[dry]-a[brown]",
  pictures = {
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-00.png",
      height = 44,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.1015625,
        -0.0625
      },
      width = 67
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-01.png",
      height = 58,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.09375,
        -0.03125
      },
      width = 76
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-02.png",
      height = 44,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0546875,
        -0.046875
      },
      width = 75
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-03.png",
      height = 54,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0703125,
        -0.046875
      },
      width = 65
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-04.png",
      height = 55,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.125,
        -0.1015625
      },
      width = 88
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-05.png",
      height = 49,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0703125,
        -0.0234375
      },
      width = 63
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-06.png",
      height = 50,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.109375,
        -0.078125
      },
      width = 74
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-07.png",
      height = 53,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        -0.0546875,
        -0.1171875
      },
      width = 89
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-08.png",
      height = 58,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.046875,
        -0.046875
      },
      width = 70
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-09.png",
      height = 53,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0390625,
        -0.0078125
      },
      width = 83
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-10.png",
      height = 61,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.078125,
        -0.0703125
      },
      width = 76
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-11.png",
      height = 50,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0546875,
        -0.0625
      },
      width = 71
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-12.png",
      height = 57,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.1171875,
        -0.0078125
      },
      width = 79
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-13.png",
      height = 50,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.015625,
        -0.046875
      },
      width = 60
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-14.png",
      height = 38,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0234375,
        -0.078125
      },
      width = 65
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-15.png",
      height = 51,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0390625,
        -0.0390625
      },
      width = 65
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-17.png",
      height = 38,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0546875,
        -0.03125
      },
      width = 49
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/flower-bush/flower-bush-green-pink/flower-bush-18.png",
      height = 35,
      line_length = 1,
      priority = "extra-high",
      scale = 0.5,
      shift = {
        0.0390625,
        -0.0390625
      },
      width = 53
    },
  },
}
local variants = {
  {
    name = "blue-pink",
    temperature = 0.15,
    aux = 1,
    noise_layer = "garballo"
  },
  { name = "green-pink",
    temperature = 0.15,
    aux = 0,
    noise_layer = "pita"
  },
  { name = "green-yellow",
    temperature = 0.85,
    aux = 0,
    noise_layer = "grass3"
  },
  { name = "red-blue",
    temperature = 0.85,
    aux = 1,
    noise_layer = "fluff"
  },
}
  
-- Get the nauvis planet decorative specification
local nauvis = data.raw.planet.nauvis
local nauvis_deco_settings
if    nauvis
  and nauvis.map_gen_settings
  and nauvis.map_gen_settings.autoplace_settings
  and nauvis.map_gen_settings.autoplace_settings.decorative
then
  nauvis_deco_settings = nauvis.map_gen_settings.autoplace_settings.decorative.settings
end

for _, variant in pairs(variants) do
  local bush = table.deepcopy(flower_bush_base)
  bush.name = bush.name .. "-" .. variant.name
  bush.localised_name = {"alien-biomes.ab-bush"}
  --bush.autoplace.peaks[#bush.autoplace.peaks].temperature_optimal = variant.temperature * 100
  bush.autoplace.local_expressions.peak3_temperature_optimal = variant.temperature * 100
  --bush.autoplace.peaks[#bush.autoplace.peaks].aux_optimal = variant.aux
  bush.autoplace.local_expressions.peak3_aux_optimal = variant.aux
  --bush.autoplace.peaks[2].noise_layer = variant.noise_layer
  bush.autoplace.local_expressions.peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='"..variant.noise_layer.."', octaves=octaves-2, input_scale=1, output_scale=1}"
  util.replace_filenames_recursive(bush.pictures, "green-pink", variant.name)
  bush.autoplace.tile_restriction = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), {"dirt", "grass"}))
  if table_size(bush.autoplace.tile_restriction) > 0 then
    data:extend({bush})
    if nauvis_deco_settings then
      nauvis_deco_settings[bush.name] = {}
    end
  end
end
