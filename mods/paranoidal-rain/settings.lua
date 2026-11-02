-- Paranoidal Rain settings. All names start with "prain-"; the script reads only its own (see scripts/config.lua).
local order = 0
local function o()
  order = order + 1
  return string.format("a%03d", order)
end

local function bool(name, default, kind)
  return { type = "bool-setting", name = name, setting_type = kind or "runtime-global", default_value = default, order = o() }
end

local function double(name, default, min, max)
  return { type = "double-setting", name = name, setting_type = "runtime-global", default_value = default,
    minimum_value = min, maximum_value = max, order = o() }
end

local function int(name, default, min, max)
  return { type = "int-setting", name = name, setting_type = "runtime-global", default_value = default,
    minimum_value = min, maximum_value = max, order = o() }
end

data:extend({
  -- Weather
  bool("prain-enabled", true),
  { type = "string-setting", name = "prain-allowed-surfaces", setting_type = "runtime-global",
    default_value = "nauvis", allow_blank = true, order = o() },
  double("prain-wet-min-minutes", 2, 0.5, 600),
  double("prain-wet-max-minutes", 20, 0.5, 600),
  double("prain-wet-power", 2.482, 0.01, 10),
  double("prain-dry-mean-minutes", 60, 1, 6000),
  int("prain-first-dry-minutes", 30, 0, 600),
  bool("prain-storm-stages", true),
  double("prain-monsoon-chance", 0.08, 0, 1),

  -- Look and sound
  double("prain-intensity", 0.6, 0.1, 5),
  int("prain-max-drops-per-tick", 300, 20, 1500),
  double("prain-wind-strength", 1, 0, 3),
  bool("prain-splashes", true),
  bool("prain-post-rain", true),
  double("prain-rain-volume", 0.5, 0, 1),
  bool("prain-thunder-sound", true),
  double("prain-thunder-volume", 1, 0, 1),
  bool("prain-thunder-layering", true),
  bool("prain-lightning-flash", true),
  double("prain-min-thunder-chance", 0.0003, 0, 0.01),
  double("prain-max-thunder-chance", 0.008, 0, 0.01),

  -- Lightning strikes
  double("prain-lightning-strike-chance", 0.1, 0, 1),
  bool("prain-lightning-chain", true),
  int("prain-lightning-protection-minutes", 60, 0, 6000),

  -- Mechanics
  int("prain-solar-percent", 75, -1, 100),
  int("prain-pollution-cleanup-per-minute", 10, 0, 100000),
  int("prain-pollution-chunks-per-tick", 4, 1, 64),
  bool("prain-fire-quench", true),
  int("prain-fire-quench-seconds", 30, 5, 600),
  int("prain-enemy-fire-acid-damage", 0, 0, 100),
  int("prain-player-fire-damage", 50, 0, 100),
  double("prain-hazard-slowdown", 2.5, 1, 5),

  -- Per player
  bool("prain-show-rain", true, "runtime-per-user"),
})
