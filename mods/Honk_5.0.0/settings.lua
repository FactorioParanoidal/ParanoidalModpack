require("setting.soundgroup")

data:extend{
	{
    name = "honk-groups",
    type = "string-setting",
    setting_type = "startup",
    hidden = true,
    default_value = "none",
    order = "aaa"
  },
  {
    name = "honk-speakers",
    type = "bool-setting",
    setting_type = "startup",
    default_value = "true",
    order = "aba"
  },
  {
    name = "honk-default-sound",
    type = "string-setting",
    setting_type = "runtime-global",
    allowed_values = {"none"},
    order = "aaa",
  },
  {
    name = "honk-sound-locos-none",
    type = "string-setting",
    setting_type = "runtime-global",
    default_value = "",
    allow_blank = true,
    auto_trim = true,
    order = "acb"
  }
}

addHonkSoundGroup("diesel")

-- Add custom sounds
local steam_locos = {
-- YIR Industries Railways
  "y_loco_fs_steam_green",
  "yir_loco_sel_blue",
  "y_loco_steam_wt450",
  "y_loco_ses_std",
  "y_loco_ses_red",
-- YIR Railways Addons
  "yir_mre044",
  "yir_loco_steam_wt580of",
  "yir_kr_green",
-- Steam Locomotive
  "SteamTrains-locomotive",
}

local boat_locos = {
  "boat_engine"
}

local ship_locos = {
  "cargo_ship_engine"
}

addHonkSoundGroup("steam", steam_locos)
addHonkSoundGroup("boat", boat_locos)
addHonkSoundGroup("ship", ship_locos)
