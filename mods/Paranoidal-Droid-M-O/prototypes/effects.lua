local shared = require("shared")
require("__core__.lualib.sound-util")

-- Floor dust: vanilla's grey dust puff, a little browner and bigger.
local dust_smoke = table.deepcopy(data.raw["trivial-smoke"]["small-dust-particle-smoke"])
dust_smoke.name = shared.dust_smoke
dust_smoke.animation.tint = {r = 0.4, g = 0.37, b = 0.32, a = 0.5}
dust_smoke.start_scale = 0.15
dust_smoke.end_scale = 0.6
dust_smoke.duration = 80
dust_smoke.fade_away_duration = 50

local empty_animation = {{filename = "__core__/graphics/empty.png", size = 1, frame_count = 1}}

data:extend
{
  dust_smoke,
  {
    -- Made by the script as the last of a contaminant goes: a puff of dust and a rattle of grit.
    type = "explosion",
    name = shared.dust,
    flags = {"not-on-map"},
    hidden = true,
    animations = empty_animation,
    sound =
    {
      variations = make_sound_variations{filename = "__base__/sound/walking/pebble/stones", number_of_variations = 9, volume = 1.0},
      aggregation = {max_count = 2, remove = true, count_already_playing = true}
    },
    created_effect =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-trivial-smoke",
            smoke_name = shared.dust_smoke,
            repeat_count = 8,
            offset_deviation = {{-0.4, -0.4}, {0.4, 0.4}},
            starting_frame_deviation = 5,
            speed_from_center = 0.008,
            speed_from_center_deviation = 0.006
          }
        }
      }
    }
  },
  {
    -- His last sound, played with the inserter's explosion when he is destroyed.
    type = "explosion",
    name = shared.death_cry,
    flags = {"not-on-map"},
    hidden = true,
    animations = empty_animation,
    sound =
    {
      variations = make_sound_variations{filename = shared.mod .. "/sound/voice/death", number_of_variations = 1, volume = 0.8},
      aggregation = {max_count = 1, remove = true, count_already_playing = true}
    }
  }
}
