-- Virtual signals of the droid counter.
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"

local SIGNALS = {
  {shared.alive_signal, "signal_droid_counter.png"},
  {"signal-droid-rifle-count", "signal_droid_rifle_count.png"},
  {"signal-droid-smg-count", "signal_droid_smg_count.png"},
  {"signal-droid-rocket-count", "signal_droid_rocket_count.png"},
  {"signal-droid-flame-count", "signal_droid_flame_count.png"},
  {"signal-droid-terminator-count", "signal_droid_terminator_count.png"},
}

local prototypes = {}
for i, s in pairs(SIGNALS) do
  prototypes[i] = {
    type = "virtual-signal",
    name = s[1],
    icon = ICONS .. s[2],
    icon_size = 64,
    subgroup = "virtual-signal-number",
    order = string.format("r[droid]-[%02d]", i),
  }
end

data:extend(prototypes)
