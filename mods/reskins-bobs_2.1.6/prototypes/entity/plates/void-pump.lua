-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.entities) then return end

-- Flare stack
-- void-pump

--[[if data.raw.furnace["void-pump"] then
  local entity = data.raw.furnace["void-pump"]
  entity.animation = {
    north = {
      filename = "__bobplates__/graphics/entity/small-pump/small-pump-up.png",
      width = 46,
      height = 52,
      frame_count = 8,
      shift = {0.09375, 0.03125 + 0.0625},
      animation_speed = 0.5
    },
    east = {
      filename = "__bobplates__/graphics/entity/small-pump/small-pump-right.png",
      width = 51,
      height = 56,
      frame_count = 8,
      shift = {0.265625, -0.21875},
      animation_speed = 0.5
    },
    south = {
      filename = "__bobplates__/graphics/entity/small-pump/small-pump-down.png",
      width = 61,
      height = 58,
      frame_count = 8,
      shift = {0.421875, -0.125},
      animation_speed = 0.5
    },
    west = {
      filename = "__bobplates__/graphics/entity/small-pump/small-pump-left.png",
      width = 56,
      height = 44,
      frame_count = 8,
      shift = {0.3125, 0.0625},
      animation_speed = 0.5
    }
  }
end
]]
