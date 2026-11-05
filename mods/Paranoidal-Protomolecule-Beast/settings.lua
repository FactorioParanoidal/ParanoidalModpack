-- The arrival and creature settings keep the original mod's defaults; the outbreak's (lair, research, raids) are new.
local function bool(name, type, order, default)
  return {type = "bool-setting", name = "the-beast-" .. name, setting_type = type, order = order, default_value = default}
end

local function int(name, type, order, default, min, max)
  return {type = "int-setting", name = "the-beast-" .. name, setting_type = type, order = order, default_value = default, minimum_value = min, maximum_value = max}
end

local function double(name, type, order, default, min, max)
  return {type = "double-setting", name = "the-beast-" .. name, setting_type = type, order = order, default_value = default, minimum_value = min, maximum_value = max}
end

data:extend
{
  -- Startup: these are in the prototypes.
  double("health-multiplier", "startup", "a", 1, 0.1, 10),
  double("damage-multiplier", "startup", "b", 1, 0.1, 10),
  int("infection-health", "startup", "c", 100, 1, 100000),

  -- Map: arrival.
  bool("auto-arrival", "runtime-global", "a-a", true),
  int("first-arrival-minutes", "runtime-global", "a-b", 20, 0, 100000),
  {type = "string-setting", name = "the-beast-arrival-technology", setting_type = "runtime-global", order = "a-c", default_value = "", allow_blank = true, auto_trim = true},
  int("arrival-min-evolution", "runtime-global", "a-d", 80, 0, 100),
  int("arrival-max-evolution", "runtime-global", "a-d2", 90, 0, 100),
  bool("avoid-replicators", "runtime-global", "a-d3", true),
  int("retry-minutes", "runtime-global", "a-e", 5, 1, 100000),
  int("min-outpost-distance", "runtime-global", "a-g", 0, 0, 1000000),
  int("min-outpost-drills", "runtime-global", "a-h", 3, 1, 100),
  int("outpost-radius", "runtime-global", "a-i", 12, 1, 100),
  int("first-infected-drills", "runtime-global", "a-j", 3, 1, 100),

  -- Map: spreading.
  double("spread-speed", "runtime-global", "b-a", 1, 0.1, 10),
  bool("infect-walls", "runtime-global", "b-b", true),
  bool("infect-pipes", "runtime-global", "b-c", true),
  bool("infect-poles", "runtime-global", "b-d", true),
  bool("infect-turrets", "runtime-global", "b-e", true),
  bool("infect-roboports", "runtime-global", "b-f", true),
  bool("infect-trains", "runtime-global", "b-g", true),
  bool("infect-energy", "runtime-global", "b-h", true),
  bool("infect-artillery", "runtime-global", "b-i", true),
  bool("infect-vehicles", "runtime-global", "b-j", true),

  -- Map: creatures.
  bool("inserters-awaken", "runtime-global", "c-a", true),
  bool("compounds", "runtime-global", "c-b", true),
  bool("wall-climbing", "runtime-global", "c-c", true),

  -- Map: the outbreak.
  int("landing-minutes", "runtime-global", "d-a", 5, 1, 120),
  int("seed-minutes", "runtime-global", "d-a2", 60, 5, 1000),
  int("lair-min-distance", "runtime-global", "d-b", 150, 50, 2000),
  int("lair-max-distance", "runtime-global", "d-c", 300, 50, 2000),
  int("buildup-min-minutes", "runtime-global", "d-d", 30, 0, 1000),
  int("buildup-max-minutes", "runtime-global", "d-e", 60, 0, 1000),
  int("research-minutes", "runtime-global", "d-f", 30, 1, 1000),
  int("raid-interval-minutes", "runtime-global", "d-g", 10, 1, 1000),
  int("raid-duration-minutes", "runtime-global", "d-h", 3, 1, 60),
  int("raid-radius", "runtime-global", "d-i", 15, 5, 100),
  int("start-speed", "runtime-global", "d-j", 25, 5, 500),
  int("end-speed", "runtime-global", "d-k", 150, 5, 500),
  bool("capture-ruins", "runtime-global", "d-l", true),
  bool("lair-clones", "runtime-global", "d-m", true),
  int("raid-clones", "runtime-global", "d-n", 2, 0, 10),
  int("lair-max-buildings", "runtime-global", "d-o", 400, 0, 2000),
  bool("lair-artillery", "runtime-global", "d-p", true),
  bool("spore-artillery", "runtime-global", "d-q", true),
  bool("lair-rails", "runtime-global", "d-r", true),
  bool("lure-station", "runtime-global", "d-s", true),
  bool("rail-raids", "runtime-global", "d-t", true),
  bool("junction-warning", "runtime-global", "d-u", false),
  bool("power-leech", "runtime-global", "d-v", true),
  int("leech-max-mw", "runtime-global", "d-w", 50, 1, 100000)
}
