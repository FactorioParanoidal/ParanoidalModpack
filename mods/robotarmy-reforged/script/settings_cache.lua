-- Cached map settings. Rebuilt on init/load and when a setting changes; reading
-- settings.global costs a lookup per access, the cache is read in hot paths.
local shared = require("lib.shared")

local S = shared.setting
local cache = {}

local TARGETING = {
  ["nearest"] = 1,
  ["defend-assembler"] = 2,
  ["keep-radius-clear"] = 3,
}

function cache.refresh()
  local global = settings.global
  cache.qrf_distance = global[S.qrf_distance].value
  cache.qrf_vehicles = global[S.qrf_vehicles].value
  cache.qrf_walls = global[S.qrf_walls].value
  cache.qrf_alerts = global[S.qrf_alerts].value
  cache.targeting = TARGETING[global[S.targeting].value] or 1
  cache.squad_messages = global[S.squad_messages].value
  cache.teleport = global[S.teleport].value
  cache.debug = global[S.debug].value
  cache.repair_at_base = global[S.repair_at_base].value / 100 -- share of max health per second
  cache.loot_chest = settings.startup[S.loot_chest].value
end

cache.TARGET_NEAREST = 1
cache.TARGET_DEFEND_ASSEMBLER = 2
cache.TARGET_KEEP_RADIUS_CLEAR = 3

return cache
