-- The whole table for constants, please load this file and use the constant
-- names instead of their direct values in your mods.
---@type table<string, string>
local constants = {
  -- Allow spawning on all planets (or only default SA planets?)
  ENABLE_SPAWN_RUINS_ALL_PLANETS_KEY = "ruins-enable-spawn-ruins-all-planets",

  -- Enable (recommended for small factories, always enabled when debug-log is enabled) "expensive" sanity-checks
  ENABLE_EXPENSIVE_SANITY_CHECKS_KEY = "ruins-expensive-sanity-checks",

  -- Configuration key for current ruin set
  CURRENT_RUIN_SET_KEY = "current-ruin-set",

  -- Configuration key for enabling debug log
  ENABLE_DEBUG_LOG_KEY = "ruins-enable-debug-log",

  -- Configuration key for enabling debugging utilities
  ENABLE_DEBUG_UTILS_KEY = "ruins-enable-debug-utils",

  -- Configuration key for enabling debugging on_nth_tick events
  ENABLE_DEBUG_ON_TICK_KEY = "ruins-enable-debug-on-tick",

  -- Key for enemy buildings should start shooting at the player
  -- (true) or cease fire (false)
  ENABLE_ENEMY_NOT_CEASE_FIRE_KEY = "ruins-enemy-not-cease-fire",

  -- Key for seconds between two spawn ticks
  SPAWN_TICK_SECONDS_KEY = "ruins-spawn-tick-seconds",

  -- Key for minimum distance to spawning point (where the player
  -- spawns) untils ruins start spawning
  MIN_DISTANCE_FROM_SPAWN_KEY = "ruins-min-distance-from-spawn",

  -- Key part for allowed planets (to spawn ruins)
  ALLOWED_PLANET_KEY_PART = "ruins-allowed-planet-",

  -- Debug surface name
  DEBUG_SURFACE_NAME = "debug-ruins",

  -- None (no ruin-set selected)
  NONE = "__none__"
}

return constants
