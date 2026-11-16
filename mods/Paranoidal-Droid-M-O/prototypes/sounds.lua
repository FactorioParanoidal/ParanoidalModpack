local shared = require("shared")
require("__core__.lualib.sound-util")

-- Every sound the script plays. His voice is synthesised for the mod (tools: mod-development/mods/Paranoidal-Droid-M-O,
-- synth_sounds.py): no film audio. Voices aggregate tightly, so a crowd of Д-ОКs doesn't turn into a choir.
local function files(name, count)
  return make_sound_variations{filename = shared.mod .. "/sound/" .. name, number_of_variations = count, volume = 1}
end

local function sound(name, path, count, volume, max_count, speed)
  local variations = files(path, count)
  for _, v in pairs(variations) do
    v.volume = volume
    if speed then
      v.min_speed, v.max_speed = speed[1], speed[2]
    end
  end
  return
  {
    type = "sound",
    name = name,
    category = "game-effect",
    variations = variations,
    audible_distance_modifier = 0.6,
    aggregation = {max_count = max_count or 1, remove = true, count_already_playing = true}
  }
end

local s = shared.sounds
data:extend
{
  -- Contacts meeting and parting, and the charge crackling across them: the base game's.
  {
    type = "sound",
    name = s.connect,
    variations = make_sound_variations{filename = "__base__/sound/power-switch-activate", number_of_variations = 3, volume = 0.8},
    aggregation = {max_count = 2, remove = true, count_already_playing = true}
  },
  {type = "sound", name = s.disconnect, filename = "__base__/sound/power-switch-deactivate.ogg", volume = 0.6},
  {
    type = "sound",
    name = s.charge,
    variations = make_sound_variations{filename = "__base__/sound/robot-charging", number_of_variations = 7, volume = 1.2},
    aggregation = {max_count = 2, remove = true, count_already_playing = true}
  },
  -- His scanner finding a contaminant; his gasp; the siren that rises from his head.
  sound(s.scan, "voice/scan", 2, 0.55),
  sound(s.gasp, "voice/gasp", 3, 0.7, 1, {0.95, 1.05}),
  sound(s.siren, "voice/siren", 1, 0.5),
  -- "Huh?" at something new; "Hm…" deciding to leave his line; angry chattering at stubborn dirt.
  sound(s.huh, "voice/huh", 3, 0.7, 1, {0.95, 1.05}),
  sound(s.hm, "voice/hm", 2, 0.6),
  sound(s.grumble, "voice/grumble", 4, 0.6, 1, {0.95, 1.08}),
  -- The primal scream of a cleaner who has been made dirty.
  sound(s.scream, "voice/scream", 2, 0.75),
  sound(s.all_clean, "voice/all-clean", 2, 0.55),
  -- "M-O." His name, which is all he says when he introduces himself.
  sound(s.name, "voice/name", 3, 0.75, 1, {0.97, 1.03}),
  sound(s.warble, "voice/warble", 4, 0.5, 1, {0.95, 1.05}),
  sound(s.whoa, "voice/whoa", 2, 0.7),
  sound(s.low_battery, "voice/low-battery", 1, 0.55),
  sound(s.yelp, "voice/yelp", 3, 0.7, 1, {0.95, 1.08}),
  sound(s.gotcha, "voice/gotcha", 2, 0.7),
  -- Machine noises: the bin sucking an item in, a part breaking off a wreck, the bin emptied into a chest.
  sound(s.pickup, "machine/pickup", 3, 0.6, 2),
  sound(s.clank, "machine/clank", 3, 0.6, 2, {0.9, 1.1}),
  sound(s.unload, "machine/unload", 2, 0.6, 2)
}
