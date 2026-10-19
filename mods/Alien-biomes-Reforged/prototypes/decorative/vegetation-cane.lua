local pic = function(name, number, width, height)
  return {
    filename = "__Alien-biomes-Reforged__/graphics/decorative/"..name.."/"..name.."-"..number..".png",
    priority = base_decorative_sprite_priority,
    width = width,
    height = height,
    scale = 0.5
  }
end
local tile_restriction = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), {"snow"})) -- not ice
if table_size(tile_restriction) > 0 then
  data:extend({
    {
      name = "cane-single",
      localised_name = {"alien-biomes.cane-single"},
      type = "optimized-decorative",
      subgroup = "grass",
      order = "b[decorative]-b[asterisk-mini]-b[green]",
      collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
      render_layer = "decorative",
      autoplace = {
        probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
        local_expressions = {
          max_probability = 1,
          penalty = 0.25,
          sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
          peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
          peak1_expr = -0.2,
          peak2_expr = "0.4 * peak2_noise_expression * peak2_distance_expression",
          peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='grass1', octaves=octaves-2, input_scale=1, output_scale=1}",
          peak2_distance_expression = "(1 - (peak2_total_distance * (2 / 1)))",
          peak2_total_distance = "peak2_moisture_expr + peak2_temperature_expr",
          peak2_moisture_expr = "ab_mimic_peak_dimension(moisture,peak2_moisture_optimal,peak2_moisture_range,peak2_moisture_max_range)",
          peak2_moisture_optimal = 1,
          peak2_moisture_range = 0.4,
          peak2_moisture_max_range = 0.6,
          peak2_temperature_expr = "ab_mimic_peak_dimension(temperature,peak2_temperature_optimal,peak2_temperature_range,peak2_temperature_max_range)",
          peak2_temperature_optimal = -10,
          peak2_temperature_range = 10,
          peak2_temperature_max_range = 15,
          octaves = "8 - log2(var('control:trees:frequency'))",
          influence_modifier = "0.5 - quantile - 0.3",
          quantile = 1,
        },
        -- random_probability_penalty = 0.25,
        -- peaks = {
        --   { influence = -0.2 },
        --   {
        --     influence = 0.4,
        --     noise_layer = "grass1",
        --     noise_octaves_difference = -2,
        --     noise_persistence = 0.8,
        --     temperature_optimal = -10,
        --     temperature_range = 10,
        --     temperature_max_range = 15,
        --     water_optimal = 1,
        --     water_range = 0.4,
        --     water_max_range = 0.6,
        --   }
        -- },
        tile_restriction = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), {"snow"})) -- not ice
      },
      pictures =
      {
        pic("cane-single", "01", 56, 60),
        pic("cane-single", "02", 44, 43),
        pic("cane-single", "03", 48, 51),
        pic("cane-single", "04", 45, 37),
        pic("cane-single", "05", 81, 57),
        pic("cane-single", "06", 31, 94),
      }
    },
    {
      name = "cane-cluster",
      localised_name = {"alien-biomes.cane-cluster"},
      type = "optimized-decorative",
      subgroup = "grass",
      order = "b[decorative]-b[asterisk-mini]-b[green]",
      collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
      render_layer = "decorative",
      autoplace = {
        probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
        local_expressions = {
          max_probability = 1,
          penalty = 0.75,
          sharpness_filter = "ab_sharpness_function(peaks_expr, 0)",
          peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
          peak1_expr = -0.2,
          peak2_expr = "0.4 * peak2_noise_expression * peak2_distance_expression",
          peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='grass1', octaves=octaves-2, input_scale=1, output_scale=1}",
          peak2_distance_expression = "(1 - (peak2_total_distance * (2 / 1)))",
          peak2_total_distance = "peak2_moisture_expr + peak2_temperature_expr",
          peak2_moisture_expr = "ab_mimic_peak_dimension(moisture,peak2_moisture_optimal,peak2_moisture_range,peak2_moisture_max_range)",
          peak2_moisture_optimal = 1,
          peak2_moisture_range = 0.4,
          peak2_moisture_max_range = 0.6,
          peak2_temperature_expr = "ab_mimic_peak_dimension(temperature,peak2_temperature_optimal,peak2_temperature_range,peak2_temperature_max_range)",
          peak2_temperature_optimal = -10,
          peak2_temperature_range = 10,
          peak2_temperature_max_range = 15,
          octaves = "8 - log2(var('control:trees:frequency'))",
          influence_modifier = "0.5 - quantile - 0.3",
          quantile = 1,
        },
        -- random_probability_penalty = 0.75,
        -- peaks = {
        --   { influence = -0.2 },
        --   {
        --     influence = 0.4,
        --     noise_layer = "grass1",
        --     noise_octaves_difference = -2,
        --     noise_persistence = 0.7,
        --     temperature_optimal = -10,
        --     temperature_range = 10,
        --     temperature_max_range = 15,
        --     water_optimal = 1,
        --     water_range = 0.4,
        --     water_max_range = 0.6,
        --   }
        -- },
        tile_restriction = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), {"snow"})) -- not ice
      },
      pictures =
      {
        pic("cane-cluster", "01", 131, 146),
        pic("cane-cluster", "02", 154, 176),
        pic("cane-cluster", "03", 264, 156),
        pic("cane-cluster", "04", 119, 138),
        pic("cane-cluster", "05", 140, 230),
      }
    },
  })
  
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
  if nauvis_deco_settings then
    nauvis_deco_settings["cane-single"] = {}
    nauvis_deco_settings["cane-cluster"] = {}
  end
end
