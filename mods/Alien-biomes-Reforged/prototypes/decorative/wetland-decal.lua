
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
  nauvis_deco_settings["wetland-decal"] = {}
end

data:extend({
  -- {
  --   type = "noise-layer",
  --   name = "wetland-decal"
  -- },
  {
    name = "wetland-decal",
    localised_name = {"alien-biomes.ab-wetland"},
    type = "optimized-decorative",
    subgroup = "grass",
    order = "b[decorative]-b[puddle-decal]",
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
    autoplace = {
      order = "a[doodad]-b[decal]",
      tile_restriction = alien_biomes.list_tiles(alien_biomes.require_tag(alien_biomes.all_tiles(), {"dirt", "grass"})),
      probability_expression = "max_probability * sharpness_filter",
      local_expressions = {
        max_probability = 0.1,
        sharpness_filter = "ab_sharpness_function(peaks_expr, 0.1)",
        peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
        peak1_expr = -1.2,
        peak2_expr = "0.1 * peak2_noise_expression",
        peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.8, seed0=map_seed, seed1='wetland-decal', octaves=octaves-2, input_scale=1, output_scale=1}",
        peak3_expr = "peak3_distance_expression",
        peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 1)))",
        peak3_total_distance = "peak3_moisture_expr",
        peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
        peak3_moisture_optimal = 1,
        peak3_moisture_range = 0.2,
        peak3_moisture_max_range = 0.4,
        octaves = "8 - log2(var('control:moisture:frequency'))",
        influence_modifier = "0.5 - quantile + 0.2",
        quantile = 0.4,
      },
      -- max_probability = 0.1,
      -- peaks = {
      --   {
      --     influence = -1.2
      --   },
      --   {
      --     influence = 0.1,
      --     noise_layer = "wetland-decal",
      --     noise_octaves_difference = -2,
      --     noise_persistence = 0.8,
      --   },
      --   {
      --     influence = 1,
      --     water_optimal = 1,
      --     water_range = 0.2,
      --     water_max_range = 0.4,
      --   }
      -- },
      -- sharpness = 0.1,
    },
    pictures =
    {
      --decalDark
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-00.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-01.png",
        width = 613,
        height = 438,
        shift = util.by_pixel(-0.25, 0),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-02.png",
        width = 612,
        height = 438,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-03.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-04.png",
        width = 612,
        height = 438,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-05.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-06.png",
        width = 613,
        height = 434,
        shift = util.by_pixel(-0.25, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-07.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 1.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-08.png",
        width = 612,
        height = 436,
        shift = util.by_pixel(0, 0.5),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-09.png",
        width = 612,
        height = 437,
        shift = util.by_pixel(0, 0.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-10.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-11.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-12.png",
        width = 612,
        height = 439,
        shift = util.by_pixel(0, 0.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-13.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 1.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-14.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-15.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 0.75),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-16.png",
        width = 612,
        height = 437,
        shift = util.by_pixel(0, 0.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-17.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 0.75),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-18.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-19.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 0.75),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-20.png",
        width = 612,
        height = 438,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-21.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-22.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 1.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-23.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-24.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-25.png",
        width = 612,
        height = 434,
        shift = util.by_pixel(0, 1),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-26.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 0.75),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-27.png",
        width = 612,
        height = 435,
        shift = util.by_pixel(0, 1.25),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-28.png",
        width = 612,
        height = 436,
        shift = util.by_pixel(0, 0.5),
        scale = 0.5
      },
      {
        filename = "__Alien-biomes-Reforged__/graphics/decorative/wetland/wetland-decal-29.png",
        width = 612,
        height = 436,
        shift = util.by_pixel(0, 0.5),
        scale = 0.5
      },
    },
  }})
