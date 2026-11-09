if not mods["space-age"] then return end
local procession_graphic_catalogue_types = require("__base__/prototypes/planet/procession-graphic-catalogue-types")
local sounds = require("__space-age__.prototypes.entity.sounds")

local function hub_pod_shadow_offset()
  return {2, 2.5}
end
local function bay_pod_shadow_offset()
  return {1, 1.3}
end

-- Copied from __space-age__/prototypes/entity/cargo-hatch.lua, From Factorio 2.1.17
local function placeholder_shared_bay_hatch_animation()
  return
  {
    layers =
    {
      util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/shared-bay-hatch",
        {
          priority = "high",
          frame_count = 21,
          animation_speed = 0.5,
          scale = 0.5,
          shift = util.by_pixel(11, 16),
          run_mode = "forward-then-backward"
        }),
      util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/shared-bay-hatch-shadow",
        {
          priority = "high",
          frame_count = 21,
          scale = 0.5,
          shift = util.by_pixel(11, 16),
          run_mode = "forward-then-backward",
          draw_as_shadow = true,
        }),
        util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/shared-bay-hatch-emission",
        {
          priority = "high",
          frame_count = 3,
          scale = 0.5,
          shift = util.by_pixel(11, 16),
          run_mode = "forward-then-backward",
          draw_as_glow = true,
          blend_mode = "additive",
          frame_sequence = {1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3}
        }),
    }
  }
end

-- Copied from __space-age__/prototypes/entity/cargo-hatch.lua, From Factorio 2.1.17
function shared_bay_hatch(hatch_offset, hatch_illumination_index)
  return
  {
    hatch_graphics = placeholder_shared_bay_hatch_animation(),
    offset = hatch_offset,
    slice_height = 0.5,
    sky_slice_height = -0.5,
    travel_height = 3,
    pod_shadow_offset = hub_pod_shadow_offset();
    illumination_graphic_index = hatch_illumination_index,
    cargo_unit_entity_to_spawn = "cargo-pod",
    receiving_cargo_units = PlanetsLib.constants.space_platform_hub_receiving_cargo_units,
    opening_sound = sounds.cargo_bay_hatch_opening_sound,
    closing_sound = sounds.cargo_bay_hatch_closing_sound,
  }
end


-- Overrides global functions from vanilla Factorio, enabling PlanetsLib to add additional supported receiving cargo units to the vanilla space platform hub.
-- Copied from __space-age__/prototypes/entity/cargo-hatch.lua, From Factorio 2.1.11
function platform_upper_hatch(hatch_offset, slice_offset, travel_offset, sky_slice_offset, hatch_illumination_index)
  return
  {
    hatch_graphics = nil,
    offset = hatch_offset,
    slice_height = slice_offset or 1,
    sky_slice_height = sky_slice_offset or -1,
    travel_height = travel_offset or 1,
    pod_shadow_offset = bay_pod_shadow_offset();
    illumination_graphic_index = hatch_illumination_index,
    cargo_unit_entity_to_spawn = nil,
    receiving_cargo_units = PlanetsLib.constants.space_platform_hub_receiving_cargo_units
  }
end

function platform_lower_hatch(hatch_offset, slice_offset, travel_offset, sky_slice_offset, hatch_illumination_index)
  return
  {
    hatch_graphics = nil,
    offset = hatch_offset,
    slice_height = slice_offset or 1,
    sky_slice_height = sky_slice_offset or -1,
    travel_height = travel_offset or 1,
    pod_shadow_offset = bay_pod_shadow_offset();
    illumination_graphic_index = hatch_illumination_index,
    cargo_unit_entity_to_spawn = "cargo-pod",
    receiving_cargo_units = {}
  }
end

-- Original code copied from Factorio 2.1.11
-- function platform_upper_hatch(hatch_offset, slice_offset, travel_offset, sky_slice_offset, hatch_illumination_index)
--   return
--   {
--     hatch_graphics = nil,
--     offset = hatch_offset,
--     slice_height = slice_offset or 1,
--     sky_slice_height = sky_slice_offset or -1,
--     travel_height = travel_offset or 1,
--     pod_shadow_offset = bay_pod_shadow_offset();
--     illumination_graphic_index = hatch_illumination_index,
--     cargo_unit_entity_to_spawn = nil,
--     receiving_cargo_units = {"cargo-pod"}
--   }
-- end

-- function platform_lower_hatch(hatch_offset, slice_offset, travel_offset, sky_slice_offset, hatch_illumination_index)
--   return
--   {
--     hatch_graphics = nil,
--     offset = hatch_offset,
--     slice_height = slice_offset or 1,
--     sky_slice_height = sky_slice_offset or -1,
--     travel_height = travel_offset or 1,
--     pod_shadow_offset = bay_pod_shadow_offset();
--     illumination_graphic_index = hatch_illumination_index,
--     cargo_unit_entity_to_spawn = "cargo-pod",
--     receiving_cargo_units = {}
--   }
-- end

data.raw["space-platform-hub"]["space-platform-hub"].cargo_station_parameters.hatch_definitions = {
        platform_upper_hatch({0.5, -3.5} , 2.25, 3, -0.5, procession_graphic_catalogue_types.hatch_emission_in_1),
        platform_upper_hatch({2, -3.5}   , 2.25, 3, -0.5, procession_graphic_catalogue_types.hatch_emission_in_2),
        platform_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.hatch_emission_in_3),
        platform_lower_hatch({-1.75, 0}  , 2   , 3, 0   , procession_graphic_catalogue_types.hatch_emission_out_1),
        platform_lower_hatch({-0.5, 0.5} , 1.5 , 3, 0   , procession_graphic_catalogue_types.hatch_emission_out_2),
        platform_lower_hatch({-2, 1}     , 1   , 3, 0   , procession_graphic_catalogue_types.hatch_emission_out_3),
      }

data.raw["cargo-bay"]["cargo-bay"].hatch_definitions =
    {
      shared_bay_hatch({-0.32, -1.5}, procession_graphic_catalogue_types.hatch_emission_bay)
    }