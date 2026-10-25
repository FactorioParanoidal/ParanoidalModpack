-- Tuning constants of the squad AI (ticks, tiles). Mod settings: script/settings_cache.lua;
-- squad thresholds and garrison sizes (set in the GUI): lib/shared.lua.
return {
  BUCKETS = 60,                       -- each squad is updated once per this many ticks
  SPAWNER_PERIOD = 60,                -- each droid assembler / guard station is checked once per this many ticks
  MAX_SPAWNS_PER_CHECK = 5,           -- droids deployed by one spawner per check
  MAX_PENDING = 20,                   -- finished deploy crafts waiting for room (the machine pauses meanwhile)
  CIRCUIT_PERIOD = 60,                -- droid counters
  GUI_PERIOD = 30,                    -- open army windows and selection marks


  SQUAD_CHECK_RANGE = 20,             -- a new droid joins the nearest squad within this range
  AT_ASSEMBLER_RANGE = 20,            -- a squad this close to an assembler is "at" the assembler
  MERGE_RANGE = 20,                   -- retreated squads this close to each other merge
  NEARBY_DROIDS_HALF_SIZE = 16,       -- spawn limit area around assemblers / stations: 32x32 tiles
  ASSEMBLER_SPAWN_LIMIT_FACTOR = 1.5, -- an assembler stops spawning above hunt size * this nearby
  SPAWN_OFFSET = 5,                   -- assembler spawn point offset towards its output side
  GUARD_HOME_RADIUS = 15,             -- guards farther than this from their station are sent back

  SANITY_CHECK_PERIOD = 600,          -- orders are refreshed after this long ...
  SANITY_CHECK_DISTANCE_DIVISOR = 5000, -- ... plus one more period per this many tiles of path
  MIN_ORDER_INTERVAL = 120,           -- a squad is not given a new order more often than this
  IDLE_HUNT_BACKOFF_MAX = 1800,       -- longest wait between searches while no enemy is found (30 s)

  UNITGROUP_FAILURE_DISTANCE = 40,    -- members farther than this from the group are stray
  UG_FAILURE_RECENCY_TICKS = 300,     -- two group failures within this escalate the response
  SAFE_READD_TICKS = 300,             -- a member that left the group twice within this is kicked out
  PLAYER_VIEW_RADIUS = 60,            -- stray members are only teleported when no player is this close
  TELEPORT_SEARCH_RADIUS = 20,

  KEEP_RADIUS_CLEAR = 500,            -- "keep radius clear" targeting: radius around assemblers
  HYBRID_BACKTRACK_FACTOR = 2,
  ASSEMBLER_THREAT_REFRESH = 1800,

  QRF_TARGET_RADIUS = 5,
  QRF_TARGET_REACHED = 10,
  QRF_HOME_REACHED = 15,
  QRF_MIN_DURATION = 120,             -- a QRF attack is not considered finished before this
  QRF_ALERT_COOLDOWN = 600,

  ARTIFACT_GRAB_RADIUS = 30,
}
