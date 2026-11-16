local shared = require("shared")
local s = shared.settings

data:extend
{
  -- Her look: the agent's own nanny, or Informatron's original box on tracks.
  {type = "string-setting", name = s.look, setting_type = "startup", default_value = "own",
   allowed_values = {"own", "informatron"}, order = "a"},
  -- How often she talks by herself. Memories, the case and alarms come anyway (the window keeps them all).
  {type = "string-setting", name = s.chatter, setting_type = "runtime-per-user", default_value = "rare",
   allowed_values = {"often", "rare", "silent"}, order = "b"},
  {type = "int-setting", name = s.distance, setting_type = "runtime-per-user", default_value = 4,
   minimum_value = 2, maximum_value = 12, order = "c"},
  {type = "bool-setting", name = s.errands, setting_type = "runtime-per-user", default_value = true, order = "d"},
  {type = "bool-setting", name = s.spoilers, setting_type = "runtime-per-user", default_value = true, order = "e"},
  {type = "bool-setting", name = s.voice, setting_type = "runtime-per-user", default_value = true, order = "f"},
  {type = "bool-setting", name = s.chat, setting_type = "runtime-per-user", default_value = false, order = "g"},
  {type = "bool-setting", name = s.button, setting_type = "runtime-per-user", default_value = true, order = "h"},
  -- The map's: how long she reads one memory card.
  {type = "int-setting", name = s.decode, setting_type = "runtime-global", default_value = 60, minimum_value = 1,
   maximum_value = 600, order = "i"}
}
