-- Settings snapshot (storage.cfg) and constants. Only "prain-" settings are read.
local R = require("scripts.registry")

local M = {}
R.cfg = M

M.PREFIX = "prain-"
M.TICKS_PER_MINUTE = 3600
M.RAMP_TICKS = 600            -- rain fades in over the last 600 ticks of a dry spell and out over the last of a wet one
M.DROPS_PER_TILE = 0.003      -- drops per visible tile per tick at intensity 1 and stage factor 1 (Dynamic Rain koeff)
M.THUNDER_LEAD_TICKS = 10000  -- thunder may start this long before the rain

local function get(name)
  return settings.global[M.PREFIX .. name].value
end

local function parse_list(value)
  local list = {}
  for token in string.gmatch(value or "", "([^,]+)") do
    local name = token:match("^%s*(.-)%s*$")
    if name and name ~= "" then list[name] = true end
  end
  return list
end

function M.load()
  local c = storage.cfg or {}
  storage.cfg = c
  c.enabled = get("enabled")
  c.allowed = parse_list(get("allowed-surfaces"))
  local wet_min, wet_max = get("wet-min-minutes"), get("wet-max-minutes")
  if wet_max < wet_min then wet_min, wet_max = wet_max, wet_min end
  c.wet_min, c.wet_max = wet_min, wet_max
  c.wet_power = get("wet-power")
  c.dry_mean = get("dry-mean-minutes")
  c.first_dry = get("first-dry-minutes")
  c.storm_stages = get("storm-stages")
  c.seasons = get("seasons")
  c.monsoon_chance = get("monsoon-chance")

  c.intensity = get("intensity")
  c.max_drops = get("max-drops-per-tick")
  c.wind_strength = get("wind-strength")
  c.splashes = get("splashes")
  c.post_rain = get("post-rain")
  c.rain_volume = get("rain-volume")
  c.thunder_sound = get("thunder-sound")
  c.thunder_volume = get("thunder-volume")
  c.thunder_layering = get("thunder-layering")
  c.lightning_flash = get("lightning-flash")
  c.min_thunder = get("min-thunder-chance")
  c.max_thunder = get("max-thunder-chance")

  c.strike_chance = get("lightning-strike-chance")
  c.chain = get("lightning-chain")
  c.protection_ticks = get("lightning-protection-minutes") * M.TICKS_PER_MINUTE

  c.solar_percent = get("solar-percent")
  c.pollution_cleanup = get("pollution-cleanup-per-minute")
  c.pollution_chunks = get("pollution-chunks-per-tick")
  c.fire_quench = get("fire-quench")
  c.fire_quench_ticks = get("fire-quench-seconds") * 60
  c.enemy_damage = get("enemy-fire-acid-damage") / 100
  c.player_fire_damage = get("player-fire-damage") / 100
  c.hazard_slowdown = get("hazard-slowdown")
  c.enemy_day = get("enemy-day-percent") / 100
  c.enemy_night = get("enemy-night-percent") / 100
  c.enemy_attacks = get("enemy-more-attacks")
  return c
end

function M.get()
  return storage.cfg or M.load()
end

return M
