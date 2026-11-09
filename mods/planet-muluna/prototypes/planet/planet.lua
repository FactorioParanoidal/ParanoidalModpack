local rro = Muluna.rro
local planet_lib = require("__PlanetsLib__.lib.planet")
local nauvis = data.raw["planet"]["nauvis"]
local nauvis_gen = nauvis.map_gen_settings
local asteroid_util = require "__space-age__.prototypes.planet.asteroid-spawn-definitions"
local tau = 2*math.pi
local meld = require("meld")
local planet_catalogue_vulcanus = require("__space-age__.prototypes.planet.procession-catalogue-vulcanus")
Muluna:extend({
		{
			type = "surface-property",
			name = "is-muluna",
      hidden = true,
			default_value = 0,
      localised_name = {"surface-property-name.planet-str"},
			localised_unit_key = "surface-property-unit.planet-str",
			order = "z[is-muluna]z",
		},
	})
Muluna:extend{
  {
    type = "autoplace-control",
    --localised_name = {"entity-name.cliff-muluna"},
    name = "muluna_cliff",
    order = "c-z-a",
    category = "cliff"
  },
  {
    type = "noise-function", --Copy of Nauvis elevation 
    name = "elevation_muluna_function",
    expression = "wlc_elevation",
    parameters = {"added_cliff_elevation"},
    local_expressions =
    {
      elevation_magnitude = 20,
      wlc_amplitude = 2,
      wlc_elevation = "max(nauvis_main - water_level * wlc_amplitude, starting_island)",
      nauvis_main = "elevation_magnitude * (lerp(0.5 * added_cliff_elevation - 0.6,\z
                                                1.9 * added_cliff_elevation + 1.6,\z
                                                0.1 + 0.5 * nauvis_bridges)\z
                                           + 0.25 * nauvis_detail\z
                                           + 3 * muluna_macro * starting_macro_multiplier)",
      -- if most of the world is flooded make sure starting areas still have land
      starting_island = "nauvis_main + elevation_magnitude * (2.5 - distance * segmentation_multiplier / 200)",
      starting_macro_multiplier = "clamp(distance * nauvis_segmentation_multiplier / 2000, 0, 1)",
      starting_lake = "elevation_magnitude * (-3 + (starting_lake_distance + starting_lake_noise) / 8) / 8",
      starting_lake_distance = "distance_from_nearest_point{x = x, y = y, points = starting_lake_positions, maximum_distance = 1024}",
      starting_lake_noise = "quick_multioctave_noise_persistence{x = x_scaled,\z
                                                                 y = y_scaled,\z
                                                                 seed0 = map_seed,\z
                                                                 seed1 = 14,\z
                                                                 input_scale = 1/8,\z
                                                                 output_scale = 0.8,\z
                                                                 octaves = 4,\z
                                                                 octave_input_scale_multiplier = 0.5,\z
                                                                 persistence = 0.68}",
      x_scaled = "x/3",
      y_scaled = "y/3",

                                                                
    }
  },
  {
    type = "noise-expression",
    name = "elevation_muluna",
    --intended_property = "elevation", --removed as an option as it is the default
    expression = "elevation_muluna_function(muluna_hills_plateaus)"
  },
  {
    type = "noise-expression",
    name = "elevation_muluna_no_cliff",
    --intended_property = "elevation", --removed as an option as it is the default
    expression = "elevation_muluna_function(0)"
  },
  {
    type = "noise-expression",
    name = "muluna_plateaus", -- make the hills to plateaus
    expression = "0.5 + clamp((muluna_hills - nauvis_hills_cliff_level) * 10, -0.5, 0.5)"
  },
  {
    type = "noise-expression",
    name = "muluna_hills_plateaus", -- make the hills to plateaus
    expression = "0.4 * nauvis_hills + 0.6 * muluna_plateaus"
  },
  {
    type = "noise-expression",
    name = "muluna_hills", -- The medium-scale hills for plateaus that act as cliff forts in normal play, or 'islands' in high-water settings.
    expression = "abs(multioctave_noise{x = x,\z
                                        y = y,\z
                                        persistence = 4,\z
                                        seed0 = map_seed,\z
                                        seed1 = 900,\z
                                        octaves = 4,\z
                                        input_scale = nauvis_segmentation_multiplier / 3000 })"
  },
  {
    type = "noise-expression",
    name = "muluna_macro",
    expression = "multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.6,\z
                                    seed0 = map_seed,\z
                                    seed1 = 1000,\z
                                    octaves = 2,\z
                                    input_scale = nauvis_segmentation_multiplier / 1600/10}\z
                  * max(0, multioctave_noise{x = x,\z
                                    y = y,\z
                                    persistence = 0.6,\z
                                    seed0 = map_seed,\z
                                    seed1 = 1100,\z
                                    octaves = 1,\z
                                    input_scale = nauvis_segmentation_multiplier / 1600/10})",
  },
  {
    type = "noise-expression",
    name = "muluna_cliff_ringbreak",
    expression = "abs(muluna_hills - muluna_hills_offset)"
  },
  {
    type = "noise-expression",
    name = "muluna_hills_offset",
    -- A duplicate of nauvis_hills but with an offset to allow ring-breaking.
    -- By comparing the nauvis_hills and nauvis_hills_offset, there's a low difference band perpendicular to the offset direction.
    -- which can be used to break small ring features.
    expression = "0.5*abs(multioctave_noise{x = x + 12 * nauvis_hills_offset_normalized_x,\z
                                        y = y + 12 * nauvis_hills_offset_normalized_y,\z
                                        persistence = 0.5,\z
                                        seed0 = map_seed,\z
                                        seed1 = 900,\z
                                        octaves = 4,\z
                                        input_scale = nauvis_segmentation_multiplier / 90})"
  },
  {
    type = "noise-expression",
    name = "cliffiness_muluna",
    --intended_property = "cliffiness", --removed as an option as it is the default
    expression = "(main_cliffiness >= cliff_cutoff) * 10",
    -- values are so that main_cliffiness has a debug range from 0-2 being the range that is selected from by cliff_cutoff
    -- i.e. red+ cliffs are only shwon at high cliff richness, green+ are always shown
    local_expressions =
    {
      cliff_cutoff = "2 * cliff_gap_size ^ 1.5",
      cliff_gap_size = "0.2 - 0.2 * slider_to_linear(cliff_richness, -1, 1)",
      main_cliffiness = "min( base_cliffiness,\z
                              elevation_cliffiness,\z
                              starting_area_cliffiness,\z
                              8 * low_frequency_cliffiness)",
      -- compnents to min
      base_cliffiness = "(muluna_cliff_ringbreak - 0.01) * 60",
      forest_path_cliffiness = "(forest_path_billows - 0.03) * 12",
      bridge_path_cliffiness = "(nauvis_bridge_billows - 0.05) * 15", -- not required if elevation is there
      elevation_cliffiness = "(elevation_muluna_no_cliff - 4) / 2",
      starting_area_cliffiness = "-2 + distance * segmentation_multiplier / 120",
      -- when frequency is below 100% then it won't remove the final cliff band.
      -- Vertical frequency can't change below 1, so use the rest of the slider to reduce large-scale horizontal frequency
      low_frequency_cliffiness = "0.5\z
                                  + basis_noise{x = x,\z
                                                y = y,\z
                                                seed0 = map_seed,\z
                                                seed1 = 86883,\z
                                                input_scale = nauvis_segmentation_multiplier/500/0.5,\z
                                                output_scale = 0.51}\z
                                  + min(slider_to_linear(cliff_frequency, -1.7, 1.7),\z
                                        slider_to_linear(cliff_richness, -1, 1))",

      -- misc
      cliff_frequency = "40 / cliff_elevation_interval"
    }
  },
  {
    type = "noise-expression",
    name = "cliff_elevation_muluna",
    --intended_property = "cliff_elevation", --removed as an option as it is the default
    expression = "15 + 20 * (muluna_hills - muluna_hills_cliff_level)"
  },
  {
    type = "noise-expression",
    name = "muluna_hills_cliff_level", -- make the hills to plateaus
    expression = "clamp(0.70 + multioctave_noise{x = x,\z
                                          y = y,\z
                                          persistence = 2,\z
                                          octaves = 2,\z
                                          seed0 = map_seed,\z
                                          seed1 = 99584+354,\z
                                          input_scale = nauvis_segmentation_multiplier/500/3,\z
                                          output_scale = 0.6}, 0.15, 1.65)"
  },
}

local map_gen = {
    property_expression_names =
    { -- Warning: anything set here overrides any selections made in the map setup screen so the options do nothing.
      cliff_elevation = "cliff_elevation_muluna",
      cliffiness = "cliffiness_muluna",
      --elevation = "elevation_island"
      elevation = "elevation_muluna"
    },
    cliff_settings = 
    {
        name = "cliff-muluna",
        control = "muluna_cliff",
        cliff_smoothing = 0.2,
        cliff_elevation_0 = -0,
        cliff_elevation_interval = 1,
        richness = 1
      },
    autoplace_controls = 
    {
        --["stone"] = {},
        ["lunar_rocks"] = {},
        ["muluna_cliff"] = {},
        ["oxide-asteroid-chunk"] = {},
        ["metallic-asteroid-chunk"] = {},
        ["carbonic-asteroid-chunk"] = {},
        ["anorthite-chunk"] = {},
        --["helium"] = {},
        --["uranium-ore"] = {},
      },
    autoplace_settings = {
        ["tile"] =
      {
        settings =
        {
            ["muluna-dirt-1"] = {},
            ["muluna-dirt-2"] = {},
            ["muluna-dirt-3"] = {},
            ["muluna-dirt-4"] = {},
            ["muluna-dirt-5"] = {},
            ["muluna-dirt-6"] = {},
            ["muluna-dirt-7"] = {},
            ["muluna-dirt-8"] = {},
            ["muluna-dirt-9"] = {},
        }
      },
      ["decorative"] =
      {
        settings =
        {
          ["lunar-medium-rock"] = data.raw["optimized-decorative"]["lunar-medium-rock"] ~= nil and {} or nil,
          ["lunar-small-rock"] = data.raw["optimized-decorative"]["lunar-small-rock"] ~= nil and {} or nil,
          ["lunar-tiny-rock"] = data.raw["optimized-decorative"]["lunar-tiny-rock"] ~= nil and {} or nil,
          --["medium-sand-rock"] = {},
          --["small-sand-rock"] = {}
        }
      },
        ["entity"] =
      {
        settings =
        {
          --["stone"] = {},
          ["lunar-rock"] = data.raw["simple-entity"]["lunar-rock"] ~= nil and {} or nil,
          ["lunar-huge-rock"] = data.raw["simple-entity"]["lunar-huge-rock"] ~= nil and {} or nil,
          --["big-sand-rock"] = {},
          --["huge-rock"] = {},
          --["big-rock"] = {},
          ["oxide-asteroid-chunk"] = {},
          ["metallic-asteroid-chunk"] = {},
          ["carbonic-asteroid-chunk"] = {},
          ["anorthite-chunk"] = {},
          --["helium"] = {},
          --["uranium-ore"] = {},
        }
      }
    }


}
if mods["cupric-asteroids"] then
  map_gen.autoplace_controls["cupric-asteroid-chunk"] = {}
  map_gen.autoplace_settings["entity"].settings["cupric-asteroid-chunk"] = {}
end
if mods["alien-biomes"] then
  map_gen.autoplace_settings["decorative"] = nil
  map_gen.autoplace_settings["entity"].settings["big-sand-rock"] = nil
  map_gen.autoplace_settings["entity"].settings["huge-rock"] = nil
  map_gen.autoplace_settings["entity"].settings["big-rock"] = nil
end





local parent_planet = "nauvis"


-- if mods["any-planet-start"] then
--   parent_planet = settings.startup["aps-planet"].value
--   --assert(1==2,tostring(parent_planet))
--   local start_planet = settings.startup["aps-planet"].value
--   if parent_planet == "none" or parent_planet =="muluna" then
--     parent_planet = "nauvis"
--   end
--   end

local orbit_radius = 1.5
local o_parent_planet = data.raw["planet"][parent_planet]

local muluna= 
{
    type = "planet",
    name = "muluna",
    
    --draw_orbit = false,
    solar_power_in_space = nauvis.solar_power_in_space,
    auto_save_on_first_trip = true,
    gravity_pull = 10,
    order = nauvis.order .. "a",
    
    icons = {
      {
        icon = "__muluna-graphics__/graphics/moon-icon-mipped.png",
        icon_size = 64,
        
      }
    },
    icon = "__muluna-graphics__/graphics/moon-icon-mipped.png",
    icon_size = 64,
    
    --orientation = nauvis.orientation-0.02,
    --distance = nauvis.distance*1.0,
    
    
    label_orientation = 0.55,
    starmap_icon = "__muluna-graphics__/graphics/moon-icon.png",
    starmap_icon_size = 1482,
    subgroup = "planetslib-satellites", -- Paranoidal fork: PlanetsLib subgroup under its own name
    magnitude = o_parent_planet.magnitude*3/5,
    --pollutant_type = "radiation",
    persistent_ambient_sounds=data.raw["space-platform-hub"]["space-platform-hub"].persistent_ambient_sounds,
    localised_description={"planetslib-templates.moon-description",{"space-location-description.muluna"},"[planet="..parent_planet.."]"},
    surface_properties = {
        ["solar-power"] = 200,
        ["pressure"] = 3,
        ["magnetic-field"] = 0.01,
        ["day-night-cycle"] = nauvis.surface_properties["day-night-cycle"],
        ["is-muluna"] = 1,
    },
    map_gen_settings = map_gen,
    parked_platforms_orientation=0.70,
    orbit = {
      orientation = 0.75, 
      distance = orbit_radius*o_parent_planet.magnitude/(nauvis.magnitude),
      --draw_orbit = true,
      parent = {
        type = "planet",
        name = parent_planet,
        },
        --sprite = PlanetsLib.get_orbit_sprite(orbit_radius*o_parent_planet.magnitude/(nauvis.magnitude))
    },
    platform_surface_render_parameters = {
      platform_backdrop = require("planet-appearance-21")
    },
    surface_render_parameters = {
      shadow_opacity = 0.9,
      space_dust_foreground = data.raw["planet"]["nauvis"].platform_surface_render_parameters.space_dust_foreground,
      -- clouds = Muluna.rro.util_merge{nauvis.surface_render_parameters.clouds,
      --                     opacity_at_day = 0.9,
      --                     opacity_at_night = 0.9,
      --                     density_at_day = 0.9,
      --                     density_at_night = 0.9,

      --                     },
      -- clouds = {
      --   shape_noise_texture =
      --   {
      --     filename = "__muluna-graphics__/graphics/clouds-noise-new.png",
      --     size = 2048
      --   },
      --   detail_noise_texture =
      --   {
      --     filename = "__muluna-graphics__/graphics/clouds-detail-noise-3.png",
      --     size = 2048
      --   },
      --   opacity = 0.9,
      --   opacity_at_night = 0.9,
      --   density = 0.9,
      --   density_at_night = 0.9,
      --   warp_sample_1 = { scale = 0.8 / 16 },
      --   warp_sample_2 = { scale = 0.8 / 16 },
      --   warped_shape_sample = { scale = 1 },
      --   additional_density_sample = { scale = 1, wind_speed_factor = 1.77 },
      --   detail_sample_1 = { scale = 1, wind_speed_factor = 0.2 / 1.709 },
      --   detail_sample_2 = { scale = 1, wind_speed_factor = 0.2 / 1.709 },
  
      --   scale = 1,
      --   movement_speed_multiplier = 0.1,
      --   shape_warp_strength = 0.06,
      --   shape_warp_weight = 0.4,
      --   detail_sample_morph_duration = 0,
      -- }
      

      
    },
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

    --Player effects, based on Varaxia's work on Celestial weather
    ticks_between_player_effects = 1,
    --player_effects = require("player_effects").player_effects

    
}




muluna.distance = nil
muluna.orientation = nil


local bot_power = 0.2

muluna.surface_properties["gravity"] =  2 --muluna.surface_properties["pressure"]/100*bot_power

muluna.surface_properties["robot-energy-usage"] = bot_power

if settings.startup["PlanetsLib-enable-temperature"].value == true then
  muluna.surface_properties["temperature"] = 264
end

if settings.startup["PlanetsLib-enable-oxygen"].value == true then
  muluna.surface_properties["oxygen"] = 0
end

if settings.startup["PlanetsLib-enable-carbon-dioxide"].value == true then
  muluna.surface_properties["carbon-dioxide"] = 0
end

if settings.startup["muluna-easy-electric-roboports-on-muluna"].value == true then
  muluna.surface_properties["pressure"] = 10
end


if mods["any-planet-start"] then
  local nauvis = data.raw["planet"]["nauvis"]
  
  parent_planet = settings.startup["aps-planet"].value
  --assert(1==2,tostring(parent_planet))
  local start_planet = settings.startup["aps-planet"].value
  if parent_planet == "none" or parent_planet =="muluna" then
      parent_planet = "nauvis"
  end
end

local muluna_connection = {
  type = "space-connection",
  name = "nauvis-muluna",
  from = parent_planet,
  to = "muluna",
  subgroup = data.raw["space-connection"]["nauvis-vulcanus"].subgroup,
  length = 1000,
  --asteroid_spawn_definitions = asteroid_spawn_definitions_connection
}





if settings.startup["override-space-connection"].value == true then
  

end


PlanetsLib:extend({muluna})

Muluna:extend{muluna_connection}
