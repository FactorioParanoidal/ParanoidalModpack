


local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")

local tile_trigger_effects = require("__space-age__.prototypes.tile.tile-trigger-effects")
local tile_pollution = require("__space-age__/prototypes/tile/tile-pollution-values")
local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")

local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout



data:extend({
  {
    type = "noise-expression",
    name = "moshine_spot_size",
    expression = 8
  },
  {
    type = "noise-expression",
    name = "moshine_starting_mask",
    -- exclude random spots from the inner 300 tiles, 80 tile blur
    expression = "clamp((distance - 30) / 10, -1, 1)"
  },
  {
    type = "noise-expression",
    name = "moshine_molten_copper_geyser_spots",
    expression = "aquilo_spot_noise{seed = 567,\z
                                    count = 80,\z
                                    skip_offset = 0,\z
                                    region_size = 600 + 400 / control:molten_copper_geyser:frequency,\z
                                    density = 1,\z
                                    radius = moshine_spot_size * sqrt(control:molten_copper_geyser:size),\z
                                    favorability = 1}"
  },
  {
    type = "noise-expression",
    name = "moshine_starting_molten_copper_geyser",
    expression = "starting_spot_at_angle{angle = aquilo_angle, distance = 40, radius = moshine_spot_size * 0.8, x_distortion = 0, y_distortion = 0}"
  },
  {
    type = "noise-expression",
    name = "moshine_molten_copper_geyser_probability",
    expression = "(control:molten_copper_geyser:size > 0)\z
                  * (max(moshine_starting_molten_copper_geyser * 0.08,\z
                         min(moshine_starting_mask, moshine_molten_copper_geyser_spots) * 0.015))"
  },
  {
    type = "noise-expression",
    name = "moshine_molten_copper_geyser_richness",
    expression = "max(moshine_starting_molten_copper_geyser * 1800000,\z
                      moshine_molten_copper_geyser_spots * 1440000) * control:molten_copper_geyser:richness"
  },

  {
    type = "noise-expression",
    name = "moshine_steam_geyser_spots",
    expression = "aquilo_spot_noise{seed = 567,\z
                                    count = 60,\z
                                    skip_offset = 1,\z
                                    region_size = 600 + 400 / control:steam_geyser:frequency,\z
                                    density = 1,\z
                                    radius = moshine_spot_size * 1.2 * sqrt(control:steam_geyser:size),\z
                                    favorability = 1}"
  },
  {
    type = "noise-expression",
    name = "moshine_starting_steam_geyser",
    expression = "starting_spot_at_angle{angle = aquilo_angle + 120, distance = 80, radius = moshine_spot_size * 0.6, x_distortion = 0, y_distortion = 0}"
  },
  {
    type = "noise-expression",
    name = "moshine_steam_geyser_probability",
    expression = "(control:steam_geyser:size > 0)\z
                  * (max(moshine_starting_steam_geyser * 1.3,\z
                         min(moshine_starting_mask, moshine_steam_geyser_spots) * 0.22))"
  },
  {
    type = "noise-expression",
    name = "moshine_steam_geyser_richness",
    expression = "max(moshine_starting_steam_geyser * 480000,\z
                      moshine_steam_geyser_spots * 7200000) * control:steam_geyser:richness"
  },
--[[
  {
    type = "autoplace-control",
    name = "moshine_islands",
    order = "c-z-d",
    category = "terrain",
    can_be_disabled = false,
    hidden = true,
  },]]
}) 

planet_map_gen.moshine = function()
  return
  {
    property_expression_names =
    {
      elevation = "fulgora_elevation",
      temperature = "vulcanus_temperature",
      moisture = "fulgora_moisture",
      aux = "fulgora_aux",
      cliffiness = "fulgora_cliffiness",
      cliff_elevation = "cliff_elevation_from_elevation",
      --["entity:molten-copper-geyser:probability"] = "moshine_molten_copper_geyser_probability",
      --["entity:molten-copper-geyser:richness"] = "moshine_molten_copper_geyser_richness",
      ["entity:steam-geyser:probability"] = "moshine_steam_geyser_probability",
      ["entity:steam-geyser:richness"] = "moshine_steam_geyser_richness",
      ["entity:multi-ore:probability"] = "moshine_multi_ore_probability",
      ["entity:multi-ore:richness"] = "moshine_multi_ore_richness",
    },
    cliff_settings =
    {
      name = "cliff-moshine",
      --control = "moshine_cliff",
      cliff_elevation_0 = 80,
      -- Ideally the first cliff would be at elevation 0 on the coastline, but that doesn't work,
      -- so instead the coastline is moved to elevation 80.
      -- Also there needs to be a large cliff drop at the coast to avoid the janky cliff smoothing
      -- but it also fails if a corner goes below zero, so we need an extra buffer of 40.
      -- So the first cliff is at 80, and terrain near the cliff shouln't go close to 0 (usually above 40).
      cliff_elevation_interval = 40,
      cliff_smoothing = 0, -- This is critical for correct cliff placement on the coast.
      richness = 1
    },
    autoplace_controls =
    {
      --["molten_copper_geyser"] = {richness = 1500000000},
      ["steam_geyser"] = {richness = 150},
      --["fulgoran_data_source"] = { frequency = 4, size = 0.1, richness = 150 },
      --["moshine_islands"] = {},
      --["moshine_cliff"] = {},
      ["multi_ore"] = {},-- frequency = 600000000, size = 10000000, richness = 150500000 },
    },
    autoplace_settings =
    {
      ["tile"] =
      {
        settings =
        {
          --nauvis tiles
          --["volcanic-soil-dark"] = {},
          --["volcanic-soil-light"] = {},
          --["volcanic-ash-soil"] = {},
          --end of nauvis tiles
          --["volcanic-ash-flats"] = {},
          --["volcanic-ash-light"] = {},
          --["volcanic-ash-dark"] = {},
          --["volcanic-cracks"] = {},
          --["volcanic-cracks-warm"] = {},
          --["volcanic-folds"] = {},
          --["volcanic-folds-flat"] = {},
          ["moshine-rock"] = {},
          ["moshine-hot-swamp"] = {},
          ["moshine-lava"] = {},

          ["moshine-dust"] = {},
          ["moshine-sand"] = {},
          ["moshine-dunes"] = {},
          --["fulgoran-walls"] = {},
          --["fulgoran-paving"] = {},
          --["fulgoran-conduit"] = {},
          --["fulgoran-machinery"] = {},

          --["volcanic-folds-warm"] = {},
          --["volcanic-pumice-stones"] = {},
          --["volcanic-cracks-hot"] = {},
          --["volcanic-jagged-ground"] = {},
          --["volcanic-smooth-stone"] = {},
          --["volcanic-smooth-stone-warm"] = {},
          --["volcanic-ash-cracks"] = {},
        }
      },
      ["decorative"] =
      {
        settings =
        {
          ["moshine-medium-fulgora-rock"] = {},
          ["moshine-small-fulgora-rock"] = {},
          ["moshine-tiny-fulgora-rock"] = {},
          
          ["moshine-barnacles-decal"] = {},
          ["moshine-rock-decal-large"] = {},
          ["moshine-snow-drift-decal"] = {},
          -- nauvis decoratives
          --["v-brown-carpet-grass"] = {},
          --["v-green-hairy-grass"] = {},
          --["v-brown-hairy-grass"] = {},
          --["v-red-pita"] = {},
          -- end of nauvis
          --["moshine-crack-decal-large"] = {},
          --["vulcanus-crack-decal-huge-warm"] = {},
          --["vulcanus-lava-fire"] = {},
          --["calcite-stain"] = {},
          --["calcite-stain-small"] = {},
          --["sulfur-stain"] = {},
          --["sulfur-stain-small"] = {},
          --["sulfuric-acid-puddle"] = {},
          --["sulfuric-acid-puddle-small"] = {},
          ["moshine-crater-small"] = {},
          ["moshine-crater-large"] = {},

          --["moshine-pumice-relief-decal"] = {},
          --["moshine-dune-decal"] = {},
          --["moshine-sand-decal"] = {},


          --["small-volcanic-rock"] = {},
          --["medium-volcanic-rock"] = {},
          --["tiny-volcanic-rock"] = {},
          --["tiny-rock-cluster"] = {},
          --["small-sulfur-rock"] = {},
          --["tiny-sulfur-rock"] = {},
          --["sulfur-rock-cluster"] = {},
          --["moshine-waves-decal"] = {},
          
        }
      },
      ["entity"] =
      {
        settings =
        {
          --["molten-iron-geyser"] = {},
          --["molten-copper-geyser"] = {},
          ["steam-geyser"] = {},
          ["fulgoran-data-source"] = {},
          --["neodymium-ore"] = {},
          ["multi-ore"] = {},
          --["calcite"] = {},


          ["moshine-huge-volcanic-rock"] = {},
          ["moshine-big-fulgora-rock"] = {}
          --["big-volcanic-rock"] = {},
          --["moshine-crater-cliff"] = {},

          --["vulcanus-chimney"] = {},
          --["vulcanus-chimney-faded"] = {},
          --["vulcanus-chimney-cold"] = {},
          --["vulcanus-chimney-short"] = {},
          --["vulcanus-chimney-truncated"] = {},
          --["ashland-lichen-tree"] = {},
          --["ashland-lichen-tree-flaming"] = {},
        }
      }
    }
  }
end

local planet_catalogue_vulcanus = require("__space-age__.prototypes.planet.procession-catalogue-vulcanus")
local effects = require("__core__.lualib.surface-render-parameter-effects")
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")


local texturemod = "__Moshine-assets__/graphics/space/"
local texturesa = "__space-age__/graphics/space/"


local planetbackdrop = {
  atmosphere_color = {
    41,
    48,
    189,
    7,
  },
  atmosphere_ray_light_color_1 = {
    84,
    44,
    0,
    255,
  },
  atmosphere_ray_light_color_2 = {
    125,
    94,
    26,
    255,
  },
  atmosphere_thickness = 0.255,
  cloud_flow_intensity = 5,
  cloud_flow_seconds = 53,
  cloud_normal_intensity = 5,
  cloud_panning_rate = 1,
  cloud_vertical_offset = 0,
  cloudiness = 0.097,
  emission_scalar = 4.638,
  emission_scales_with_shadow = false,
  global_cloud = {
    filename = texturesa .. "nauvis-cloud.png",
    width = 2048,
    height = 1024,
  },
  global_cloud_flow = {
    filename = texturesa .. "nauvis-cloud-flow.png",
    width = 2048,
    height = 1024,
  },
  global_cloud_normal = {
    filename = texturesa .. "vulcanus-cloud-normal.png",
    width = 2048,
    height = 1024,
  },
  light_color = {
    236,
    236,
    236,
    255,
  },
  light_direction = {
    -0.53259223,
    0.1460832,
    0.61090524,
  },
  light_intensity_contrast = 0.601,
  light_radius = 15,
  planet_axis = {
    3,
    13,
  },
  planet_axis_deviation_amplitude = {
    10,
    10,
  },
  planet_axis_deviation_seconds = {
    382.18884120171674,
    323.47639484978544,
  },
  planet_emission = {
    filename = texturemod .. "moshine-emission.png",
    width = 2048,
    height = 1024,
  },
  planet_normal = {
    filename = texturesa .. "nauvis-cloud-normal.png",
    width = 2048,
    height = 1024,
  },
  planet_surface = {
    filename = texturemod .. "moshine.png",
    width = 2048,
    height = 1024,
  },
  radius = 520,
  rotation_seconds = 900,
  specular_color = {
    255,
    124,
    0,
    255,
  },
  specular_intensity = 1,
  surface_normal_intensity = 0.521,
  surface_vertical_offset = 0.063,
}






data:extend({

  --[[{
    type = "autoplace-control",
    name = "moshine_cliff",
    order = "d-z-c",
    category = "cliff",
    hidden = true,
  },]]
  {
    type = "surface-property",
    name = "temperature-celcius",
    default_value = 15,
    hidden_in_factoriopedia = true,
    hidden = true,
  },
  --[[
  {
    type = "surface-property",
    name = "moshine-exclusive",
    default_value = 0,
    hidden_in_factoriopedia = true,
    hidden = true,
  },]]

--    ██████  ██       █████  ███    ██ ███████ ████████ 
--    ██   ██ ██      ██   ██ ████   ██ ██         ██    
--    ██████  ██      ███████ ██ ██  ██ █████      ██    
--    ██      ██      ██   ██ ██  ██ ██ ██         ██    
--    ██      ███████ ██   ██ ██   ████ ███████    ██    

  {
    type = "planet",
    name = "moshine",
    icon = "__Moshine__/graphics/icons/moshine.png",
    starmap_icon = "__Moshine__/graphics/icons/starmap-planet-moshine.png",
    starmap_icon_size = 512,
    gravity_pull = 10,
    distance = 6,
    orientation = 0.05,
    magnitude = 0.9,
    order = "e[moshine]",
    subgroup = "planets",
    map_gen_settings = planet_map_gen.moshine(),
    pollutant_type = nil,
    solar_power_in_space = 60000,
    platform_procession_set =
    {
      arrival = {"planet-to-platform-b"},
      departure = {"platform-to-planet-a"}
    },
    planet_procession_set =
    {
      arrival = {"platform-to-planet-b"},
      departure = {"planet-to-platform-a"}
    },
    procession_graphic_catalogue = planet_catalogue_vulcanus,
    surface_properties =
    {
      ["day-night-cycle"] = 15 * minute,
      ["magnetic-field"] = 70,
      ["solar-power"] = 4000,
      pressure = 701,
      gravity = 7.01,
      ["temperature-celcius"] = 98,
      --solar_flares = 55,
    },
    asteroid_spawn_influence = 1,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus, 0.9),
    persistent_ambient_sounds =
    {
      base_ambience = {filename = "__space-age__/sound/wind/base-wind-vulcanus.ogg", volume = 0.8},
      wind = {filename = "__space-age__/sound/wind/wind-vulcanus.ogg", volume = 0.8},
      crossfade =
      {
        order = {"wind", "base_ambience"},
        curve_type = "cosine",
        from = {control = 0.35, volume_percentage = 10.0},
        to = {control = 2, volume_percentage = 100.0}
      },
      semi_persistent =
      {
        {
          sound = {variations = sound_variations("__space-age__/sound/world/semi-persistent/distant-rumble", 3, 1.6)},
          delay_mean_seconds = 10,
          delay_variance_seconds = 5
        },
        {
          sound = {variations = sound_variations("__space-age__/sound/world/semi-persistent/distant-flames", 5, 1.0)},
          delay_mean_seconds = 15,
          delay_variance_seconds = 7.0
        }
      }
    },
    surface_render_parameters =
    {
      clouds =
      {
        shape_noise_texture =
        {
          filename = "__core__/graphics/clouds-noise.png",
          size = 2048
        },
        detail_noise_texture =
        {
          filename = "__core__/graphics/clouds-detail-noise.png",
          size = 2048
        },

        warp_sample_1 = { scale = 0.8 / 16 },
        warp_sample_2 = { scale = 3.75 * 0.8 / 32, wind_speed_factor = 0 },
        warped_shape_sample = { scale = 2 * 0.18 / 32 },
        additional_density_sample = { scale = 1.5 * 0.18 / 32, wind_speed_factor = 1.77 },
        detail_sample_1 = { scale = 1.709 / 32, wind_speed_factor = 0.2 / 1.709 },
        detail_sample_2 = { scale = 2.179 / 32, wind_speed_factor = 0.33 / 2.179 },

        scale = 1,
        movement_speed_multiplier = 0.75,
        opacity = 0.15,
        opacity_at_night = 0.25,
        density_at_night = 1,
        detail_factor = 1.5,
        detail_factor_at_night = 2,
        shape_warp_strength = 0.06,
        shape_warp_weight = 0.4,
        detail_sample_morph_duration = 0,
      },
      fog = {
        shape_noise_texture =
        {
          filename = "__core__/graphics/clouds-noise.png",
          size = 2048
        },
        detail_noise_texture =
        {
          filename = "__core__/graphics/clouds-detail-noise.png",
          size = 2048
        },
        color1 = {1, 1, 0.8},
        color2 = {1, 1, 1},
        tick_factor = 0.000005,
      },
      -- clouds = effects.default_clouds_effect_properties(),

      -- Should be based on the default day/night times, ie
      -- sun starts to set at 0.25
      -- sun fully set at 0.45
      -- sun starts to rise at 0.55
      -- sun fully risen at 0.75
      day_night_cycle_color_lookup =
      {
        {0.0,  "__Moshine-assets__/graphics/terrain/moshine-1-day.png"},
        {0.35, "__Moshine-assets__/graphics/terrain/moshine-4-partialday.png"},
        {0.40, "__Moshine-assets__/graphics/terrain/moshine-3-dusk.png"},
        {0.45, "__Moshine-assets__/graphics/terrain/moshine-2-night.png"},
        {0.55, "__Moshine-assets__/graphics/terrain/moshine-2-night.png"},
        {0.75, "__Moshine-assets__/graphics/terrain/moshine-4-partialday.png"},
        {0.98, "__Moshine-assets__/graphics/terrain/moshine-1-day.png"},
      },

      terrain_tint_effect =
      {
        noise_texture =
        {
          filename = "__Moshine-assets__/graphics/terrain/moshine-tint-noise.png",
          size = 4096
        },

        offset = { 0.2, 0, 0.4, 0.8 },
        intensity = { 0.6, 0.6, 0.3, 0.3 },
        scale_u = { 3, 1, 1, 1 },
        scale_v = { 1, 1, 1, 1 },

        global_intensity = 0.4,
        global_scale = 0.1,
        zoom_factor = 3,
        zoom_intensity = 0.6
      },
    },
    platform_surface_render_parameters =
    {
      clouds = nil,
      fog = nil,
      day_night_cycle_color_lookup = 
      {
        {0.0,  "__Moshine__/graphics/moshine_space_lut.png"},
      },
      terrain_tint_effect = nil,
      shadow_opacity = 0.7,
      platform_backdrop = planetbackdrop,
      --[[{
        emission_scales_with_shadow = false,
        radius = 520,
        rotation_seconds = 15 * 60, --15m
        cloudiness = 0,
        surface_vertical_offset = 0.12,
        cloud_vertical_offset = nil,
        specular_intensity = 3000,
        specular_color = {1, 1, 0.95, 1},
        atmosphere_color = {0.1, 0.1, 0.7, 0.009},
        cloud_flow_intensity = nil,
        cloud_panning_rate = nil,
        planet_axis = {3.0, 13.0},
        planet_axis_deviation_amplitude = {10.0, 10.0},
        planet_axis_deviation_seconds = {890.5*2/4.66, 753.7*2/4.66},
        position = {-680, 601},
        parallax_strength = {0.98, 0.98},
        light_direction = {-0.42, 0.23, 0.67},
        light_intensity_contrast = 0.6,
        light_color = {1, 0.99, 0.95, 1},
        light_radius = 6,
        planet_surface =
        {
          filename = "__Moshine-assets__/graphics/space/moshine.png",
          width = 2048,
          height = 1024
        },
        planet_normal =
        {
          filename = "__space-age__/graphics/space/nauvis-cloud-normal.png",
          width = 2048,
          height = 1024
        },
        surface_normal_intensity = 0.4,
        planet_emission =
        {
          filename = "__Moshine-assets__/graphics/space/moshine-emission.png",
          width = 2048,
          height = 1024
        },
        global_cloud = nil,
        global_cloud_normal = nil,
        global_cloud_flow = nil,
      },]]
    },
  },
  {
    type = "space-connection",
    name = "nauvis-moshine",
    subgroup = "planet-connections",
    from = "nauvis",
    to = "moshine",
    order = "a",
    length = 17000,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus)
  },
  {
    type = "space-connection",
    name = "vulcanus-moshine",
    subgroup = "planet-connections",
    from = "vulcanus",
    to = "moshine",
    order = "a",
    length = 3000,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus)
  },
})