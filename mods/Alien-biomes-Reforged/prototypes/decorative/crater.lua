local crater_tile_restriction = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), {"dirt", "sand", "heat-1"}))
local function autoplace_crater (max_probability, random_probability_penalty, quantile)
  return {
    order = "a[doodad]-b[decal]",
    probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
    local_expressions = {
      max_probability = max_probability,
      penalty = random_probability_penalty,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.6)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
      peak1_expr = -0.3,
      peak2_expr = "0.5 * peak2_distance_expression * peak2_noise_expression",
      peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='crater', octaves=octaves-2, input_scale=1, output_scale=1}",
      peak2_distance_expression = "(1 - (peak2_total_distance * (2 / 1)))",
      peak2_total_distance = "peak2_moisture_expr",
      peak2_moisture_expr = "ab_mimic_peak_dimension(moisture,peak2_moisture_optimal,peak2_moisture_range,peak2_moisture_max_range)",
      peak2_moisture_optimal = 0,
      peak2_moisture_range = 0.2,
      peak2_moisture_max_range = 0.3,
      octaves = "8 - log2(var('control:rocks:frequency'))",
      influence_modifier = "0.5 - quantile + 0.3",
      quantile = quantile,
    },
    tile_restriction = crater_tile_restriction
  }

  -- return {
  --   max_probability = max_probability,
  --   random_probability_penalty = random_probability_penalty,
  --   sharpness = 0.7,
  --   order = "a[doodad]-b[decal]",
  --   peaks = {
  --     { influence = -0.3},
  --     {
  --       influence = 0.5,
  --       noise_layer = "crater",
  --       noise_octaves_difference = -2,
  --       noise_persistence = 0.9,
  --       water_optimal = 0,
  --       water_range = 0.2,
  --       water_max_range = 0.3,
  --     }
  --   },
  --   tile_restriction = crater_tile_restriction
  -- }
end
local function crater_picture (name, width, height)
  return {
    filename = "__Alien-biomes-Reforged__/graphics/decorative/crater/crater-"..name..".png",
    width = width,
    height = height,
    scale = 0.5
  }
end
local function make_crater(name, box, max_probability, random_probability_penalty, quantile, pictures)
  return {
    name = name,
    localised_name = {"alien-biomes.ab-crater"},
    type = "optimized-decorative",
    subgroup = "grass",
    order = "b[decorative]-b[crater-decal]",
    collision_box = {{-box, -box*0.75}, {box, box*0.75}},
    collision_mask = {
      layers = {
        doodad = true,
        water_tile = true,
      },
      not_colliding_with_itself = true,
    },
    render_layer = "decals",
    tile_layer = default_decal_layer,
    autoplace = autoplace_crater(max_probability, random_probability_penalty, quantile),
    pictures = pictures
  }
end
data:extend({
  -- {
  --     type = "noise-layer",
  --     name = "crater"
  -- },
  make_crater("crater3-huge", 8, 0.01, 0.95, -3.5, {
    crater_picture("huge-01", 1249, 877),
  }),
  make_crater("crater1-large-rare", 4, 0.07, 0.95, 0.298, {
    crater_picture("large-01", 679, 513),
  }),
  make_crater("crater1-large", 4, 0.07, 0.7, 0.30, {
    crater_picture("large-02", 327, 284),
    crater_picture("large-03", 481, 393),
    crater_picture("large-04", 406, 382),
    crater_picture("large-05", 363, 301),
  }),
  make_crater("crater2-medium", 3, 0.09, 0.5, 0.15, {
    crater_picture("medium-01", 283, 231),
    crater_picture("medium-02", 213, 182),
    crater_picture("medium-03", 243, 189),
    crater_picture("medium-04", 237, 173),
    crater_picture("medium-05", 195, 182),
    crater_picture("medium-06", 146, 125),
    crater_picture("medium-07", 180, 127),
  }),
  make_crater("crater4-small", 2, 0.06, 0.8, 0.05, {
    crater_picture("small-01", 122, 108),
  }),
})

-- Update the nauvis planet definition
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
  nauvis_deco_settings["crater3-huge"] = {}
  nauvis_deco_settings["crater1-large-rare"] = {}
  nauvis_deco_settings["crater1-large"] = {}
  nauvis_deco_settings["crater2-medium"] = {}
  nauvis_deco_settings["crater4-small"] = {}
end