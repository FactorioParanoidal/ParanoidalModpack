data:extend(
{
--- weight 10 is normal. The higher the number, the higher the probabilities to sound.

-------------------------------------------------------------------------------------AQUILO
--[[
  {
    type = "ambient-sound",
    name = "frozeta-4-hero",
    track_type = "hero-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-4-hero.ogg", --Replaced if Factorio version >= 2.0.59
  },
--]]
  require("__space-age__/sound/ambient/aquilo/aquilo-1/aquilo-1"),
  {
    type = "ambient-sound",
    name = "frozeta-2",
    track_type = "main-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-2.ogg",
    weight = 10
  },
  {
    type = "ambient-sound",
    name = "frozeta-3",
    track_type = "main-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-3.ogg",
    weight = 10
  },
  --[[
  {
    type = "ambient-sound",
    name = "frozeta-4",
    track_type = "main-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-4.ogg",
    weight = 10
  },
  --]]
  require("__space-age__/sound/ambient/aquilo/aquilo-5/aquilo-5"),
  {
    type = "ambient-sound",
    name = "frozeta-6",
    track_type = "main-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-6.ogg",
    weight = 10
  },
  require("__space-age__/sound/ambient/aquilo/aquilo-7/aquilo-7"),
  {
    type = "ambient-sound",
    name = "frozeta-8",
    track_type = "main-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-8.ogg",
    weight = 10
  },
  {
    type = "ambient-sound",
    name = "frozeta-9",
    track_type = "main-track",
    planets = {"frozeta"},
    sound = "__space-age__/sound/ambient/aquilo/aquilo-9.ogg",
    weight = 10
  },
  require("__space-age__/sound/ambient/aquilo/aquilo-10/aquilo-10"),
  require("__space-age__/sound/ambient/aquilo/interlude-1/interlude-1"),
  require("__space-age__/sound/ambient/aquilo/interlude-2/interlude-2"),
  require("__space-age__/sound/ambient/aquilo/interlude-3/interlude-3"),
  require("__space-age__/sound/ambient/aquilo/interlude-4/interlude-4"),

-------------------------------------------------------------------------------------SPACE

})
--[[
local hero_sound = data.raw["ambient-sound"]["frozeta-4-hero"]

if helpers.compare_versions(helpers.game_version,"2.0.59") > -1 then
  hero_sound.sound = "__space-age__/sound/ambient/aquilo/aquilo-3-hero.ogg"
end
--]]