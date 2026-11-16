local shared = require("shared")
require("__core__.lualib.sound-util")

-- Every sound of hers is synthesised for the mod (tools: mod-development/mods/Paranoidal-NAN-E/synth_sounds.py):
-- no film audio, no recorded speech. Her voice is a babble with intonation: the 47-dialect voice chip is broken,
-- so the words come as text over her head.
-- make_sound_variations takes only the file name and the count (core lualib): volume and speed go on each variation.
local function sound(name, path, count, volume, speed)
  local variations = make_sound_variations{filename = shared.mod .. "/sound/" .. path, number_of_variations = count}
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
    audible_distance_modifier = 0.7,
    aggregation = {max_count = 1, remove = true, count_already_playing = true}
  }
end

local s = shared.sounds
data:extend
{
  sound(s.chatter, "voice/chatter", 8, 0.75, {0.95, 1.05}),
  sound(s.happy, "voice/happy", 3, 0.75),
  sound(s.worried, "voice/worried", 3, 0.75),
  sound(s.question, "voice/question", 3, 0.75),
  sound(s.stern, "voice/stern", 3, 0.8),
  sound(s.glitch, "voice/glitch", 3, 0.7),
  sound(s.sleepy, "voice/sleepy", 1, 0.7),
  sound(s.boot, "jingle/boot", 1, 0.7),
  sound(s.shutdown, "jingle/shutdown", 1, 0.7),
  sound(s.lullaby, "jingle/lullaby", 1, 0.6),
  sound(s.card, "jingle/card", 1, 0.7),
  sound(s.decrypted, "jingle/decrypted", 1, 0.7),
  sound(s.solved, "jingle/solved", 1, 0.7),
  sound(s.wrong, "jingle/wrong", 1, 0.7),
  sound(s.vacuum, "machine/vacuum", 1, 0.5, {0.9, 1.1}),
  sound(s.sneeze, "machine/sneeze", 1, 0.8),
  sound(s.spray, "machine/spray", 1, 0.35, {0.85, 1.15}),
  sound(s.zap, "machine/zap", 1, 0.8),
  sound(s.umbrella, "machine/umbrella", 1, 0.6)
}
