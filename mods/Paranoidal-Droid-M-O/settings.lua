local shared = require("shared")

data:extend
{
  {
    -- "own": the M-O model made for this mod; "overlay": M-O's head on the original Sweepbot chassis, recoloured.
    type = "string-setting",
    name = shared.settings.graphics,
    setting_type = "startup",
    default_value = "own",
    allowed_values = {"own", "overlay"},
    order = "a"
  },
  {
    -- Characters and vehicles coming off the ground leave muddy prints on the paving, for Д-ОК to clean.
    type = "bool-setting",
    name = shared.settings.tracks,
    setting_type = "runtime-global",
    default_value = true,
    order = "b"
  },
  {
    -- Д-ОК drives up to a dirty engineer on the paving and scrubs him clean.
    type = "bool-setting",
    name = shared.settings.chase,
    setting_type = "runtime-global",
    default_value = true,
    order = "c"
  },
  {
    type = "bool-setting",
    name = shared.settings.texts,
    setting_type = "runtime-per-user",
    default_value = true,
    order = "d"
  },
  {
    type = "bool-setting",
    name = shared.settings.voice,
    setting_type = "runtime-per-user",
    default_value = true,
    order = "e"
  }
}
