-- TODO: finish painting decals
local data_util = require("data-util")
-- data:extend({
-- {
--   type = "noise-layer",
--   name = "puddle-decal"
-- }
-- })
local lava_decal_base = {
  name = "lava-decal",
  type = "optimized-decorative",
  subgroup = "grass",
  order = "b[decorative]-b[lava-decal]",
  collision_box = {{-8, -8}, {8, 8}},
  collision_mask = {
    layers = {
      doodad = true,
      water_tile = true,
    },
    not_colliding_with_itself = true,
  },
  render_layer = "decals",
  tile_layer = default_decal_layer,
  autoplace = {
    order = "a[doodad]-b[decal]",
    probability_expression = "(max_probability * sharpness_filter)",
    local_expressions = {
      max_probability = 0.01,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.7)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
      peak1_expr = -1,
      peak2_expr = "0.1 * peak2_noise_expression",
      peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.95, seed0=map_seed, seed1='puddle-decal', octaves=octaves-2, input_scale=1, output_scale=1}",
      peak3_expr = "peak3_distance_expression",
      peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 1)))",
      peak3_total_distance = "peak3_temperature_expr",
      peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
      peak3_temperature_optimal = 150,
      peak3_temperature_range = 50,
      peak3_temperature_max_range = 60,
      octaves = "8 - log2(var('control:hot:frequency'))",
      influence_modifier = "0.5 - quantile",
      quantile = 0.12,
    },
    -- max_probability = 0.01,
    -- peaks = {
    --   {
    --      influence = -1
    --   },
    --   {
    --     influence = 0.1,
    --     noise_layer = "puddle-decal",
    --     noise_octaves_difference = -2,
    --     noise_persistence = 0.95,
    --   },
    --   {
    --     influence = 1,
    --     temperature_optimal = 150,
    --     temperature_range = 50,
    --     temperature_max_range = 60,
    --   }
    -- },
    -- sharpness = 0.7,
  },
  pictures =
  {
    --[[
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-00.png",
      width = 351,
      height = 267,
      shift = util.by_pixel(4.25, -1.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-01.png",
      width = 305,
      height = 262,
      shift = util.by_pixel(2.25, -3),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-02.png",
      width = 327,
      height = 270,
      shift = util.by_pixel(-8.25, -0.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-03.png",
      width = 258,
      height = 268,
      shift = util.by_pixel(10, -1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-04.png",
      width = 231,
      height = 201,
      shift = util.by_pixel(8.75, 3.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-05.png",
      width = 295,
      height = 234,
      shift = util.by_pixel(12.25, 6.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-06.png",
      width = 271,
      height = 172,
      shift = util.by_pixel(-5.75, 0.5),
      scale = 0.5
    },]]--
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-07.png",
      width = 282,
      height = 266,
      shift = util.by_pixel(-1.5, -1.5),
      scale = 0.5
    },
    --[[{
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-08.png",
      width = 377,
      height = 231,
      shift = util.by_pixel(-0.25, -7.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-09.png",
      width = 376,
      height = 202,
      shift = util.by_pixel(0, 6),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-10.png",
      width = 372,
      height = 234,
      shift = util.by_pixel(-1, 3.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-11.png",
      width = 344,
      height = 224,
      shift = util.by_pixel(-1.5, 1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-12.png",
      width = 290,
      height = 189,
      shift = util.by_pixel(-8, 4.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-13.png",
      width = 326,
      height = 228,
      shift = util.by_pixel(-3, -2),
      scale = 0.5
    },]]--
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-14.png",
      width = 312,
      height = 225,
      shift = util.by_pixel(-13.5, 4.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-15.png",
      width = 359,
      height = 186,
      shift = util.by_pixel(-4.25, 4.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-16.png",
      width = 287,
      height = 266,
      shift = util.by_pixel(10.75, -1.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-17.png",
      width = 377,
      height = 267,
      shift = util.by_pixel(0.25, -1.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-18.png",
      width = 375,
      height = 269,
      shift = util.by_pixel(0.25, -1.25),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-19.png",
      width = 346,
      height = 270,
      shift = util.by_pixel(-0.5, -1),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-20.png",
      width = 261,
      height = 198,
      shift = util.by_pixel(-3.25, 0.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-21.png",
      width = 270,
      height = 205,
      shift = util.by_pixel(2.5, -8.75),
      scale = 0.5
    },
    --[[{
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-22.png",
      width = 266,
      height = 212,
      shift = util.by_pixel(-11.5, 5.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-23.png",
      width = 292,
      height = 164,
      shift = util.by_pixel(13.5, -10.5),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-24.png",
      width = 377,
      height = 232,
      shift = util.by_pixel(-0.25, 2.5),
      scale = 0.5
    },]]--
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-25.png",
      width = 376,
      height = 204,
      shift = util.by_pixel(0, -3),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-26.png",
      width = 376,
      height = 214,
      shift = util.by_pixel(0, -13),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-27.png",
      width = 378,
      height = 209,
      shift = util.by_pixel(0, -4.75),
      scale = 0.5
    },
    {
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-28.png",
      width = 378,
      height = 198,
      shift = util.by_pixel(0, 5),
      scale = 0.5
    },
    --[[{
      filename = "__Alien-biomes-Reforged__/graphics/decorative/lava/|color|/lava-decal-29.png",
      width = 352,
      height = 218,
      shift = util.by_pixel(6, 0),
      scale = 0.5
    },]]--
  },
}
local variants = { }
if settings.startup["alien-biomes-include-volcanic-orange"].value ~= "Disabled" then
  table.insert(variants, "orange")
end
if settings.startup["alien-biomes-include-volcanic-green"].value ~= "Disabled"  then
  table.insert(variants, "green")
end
if settings.startup["alien-biomes-include-volcanic-blue"].value ~= "Disabled"  then
  table.insert(variants, "blue")
end
if settings.startup["alien-biomes-include-volcanic-purple"].value ~= "Disabled"  then
  table.insert(variants, "purple")
end

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
local heats = {"heat-2", "heat-3", "heat-4"}
for _, variant in pairs(variants) do
  local lava = table.deepcopy(lava_decal_base)
  lava.name = lava.name .. "-" .. variant
  lava.localised_name = {"alien-biomes.ab-lava", {"alien-biomes."..variant}}
  lava.autoplace.tile_restriction = {}
  for _, heat in pairs(heats) do
    table.insert(lava.autoplace.tile_restriction, "volcanic-" .. variant .. "-" .. heat)
  end
  local lava_matrices = require("prototypes/tint-matrices").lava
  for i, pic in pairs(lava.pictures) do
    local idx = pic.filename and pic.filename:match("lava%-decal%-(%d+)%.png$")
    local m = idx and lava_matrices[idx]
    if m and m.tints[variant] then
      local base = {filename = m.base, width = pic.width, height = pic.height, shift = pic.shift, scale = pic.scale}
      local glow = table.deepcopy(base)
      glow.filename = m.glow
      glow.blend_mode = "additive"
      glow.tint = m.tints[variant]
      lava.pictures[i] = {layers = {base, glow}}
    else
      data_util.replace_filenames_recursive(pic, "|color|", variant)
    end
  end
  data:extend({lava})
  if nauvis_deco_settings then
    nauvis_deco_settings[lava.name] = {}
  end
end
