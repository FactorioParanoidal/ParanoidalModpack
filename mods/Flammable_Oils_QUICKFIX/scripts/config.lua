-- Tunables of the Paranoidal fork. Energies are in MJ, times in ticks.
local C = {}

-- Ignition chance of a dying entity by damage type (upstream).
C.CHANCES = { fire = 0.95, explosion = 0.75, acid = 0.5, electric = 0.5, laser = 0.5 }
-- Damage types that set tanks on fire and ammo stores cooking off.
C.HEAT_DAMAGE = { fire = true, explosion = true }

C.MIN_ENERGY = 10                 -- smallest fluid charge that explodes (upstream)

-- Volatile gases: their energy counts this many times for every hazard, and an entity holding them
-- explodes on any death (any damage type, no chance roll, no MIN_ENERGY) if filled above the fraction.
C.VOLATILE = {
  ["angels-gas-hydrogen"] = 4,
  ["bob-hydrogen"] = 4,
  ["angels-gas-deuterium"] = 4,
  ["bob-deuterium"] = 4,
}
C.VOLATILE_MIN_FRACTION = 0.025   -- emptier fluid boxes do not explode (Beta 8 threshold)
C.MAX_EXPLOSIONS_PER_TICK = 20
C.MAX_TASKS_PER_TICK = 80

-- Spectacle tiers by stored energy.
C.SMALL_ENERGY = 500
C.MEDIUM_ENERGY = 5000
C.HUGE_ENERGY = 25000
C.SMOG_ACHIEVEMENT = 20000        -- pollution of one blast

-- Fuse: fire crawling through connected pipes.
C.FUSE_DELAY = 20                 -- per pipe
C.FUSE_MIN_ENERGY = 1             -- emptier pipes stop the fire
C.FUSE_ACHIEVEMENT = 100          -- pipes in one chain
C.FUSE_STOP_TYPES = { pump = true, ["offshore-pump"] = true, valve = true }

-- Storage tank overheating.
C.TANK_MIN_CAPACITY = 1000
C.TANK_MIN_ENERGY = 100
C.TANK_UPDATE = 30
C.TANK_SAVED_FRACTION = 0.25      -- drained below this share of the initial charge = saved
C.CATASTROPHE_ENERGY = 1000       -- a tank this full always ends in a catastrophe
C.LONG_FIRES_MIN = 40
C.LONG_FIRES_MAX = 200

-- Ammunition cook-off.
C.COOK_START_INTERVAL = 120
C.COOK_MIN_INTERVAL = 6
C.COOK_ACCEL = 0.82
C.COOK_ACHIEVEMENT = 50           -- pops of one store
C.CONTAINER_INVENTORIES = {
  ["container"] = { "chest" },
  ["logistic-container"] = { "chest" },
  ["cargo-wagon"] = { "cargo_wagon" },
  ["car"] = { "car_trunk", "car_ammo" },
  ["spider-vehicle"] = { "spider_trunk", "spider_ammo" },
  ["ammo-turret"] = { "turret_ammo" },
  ["artillery-turret"] = { "artillery_turret_ammo" },
  ["artillery-wagon"] = { "artillery_wagon_ammo" },
}
-- Stores that react to fire damage directly (turrets are attacked all the time: proximity only).
C.DAMAGE_EVENT_TYPES = {
  "storage-tank", "container", "logistic-container", "cargo-wagon", "car", "spider-vehicle", "artillery-wagon",
}

-- Chemical accidents: charge of a 3x3 machine with a flammable recipe.
C.ACCIDENT_ENERGY = 200
C.ACCIDENT_AMOUNT = 200
C.TOXIC_POLLUTION = 500

C.HAZARD_MARGIN = 4               -- tanks/ammo within explosion radius + margin react
C.CHECK_COOLDOWN = 120            -- per-entity cooldown for damage-event checks
C.ALERT_COOLDOWN = 600            -- per chunk and alert kind

-- Ruin traps (AbandonedRuins-paranoidal).
C.TRAP_PREFIX = "pd-flo-trap-"
C.TRAP_INTERVAL = 60
C.TRAP_MARGIN = 6
C.TRAP_DELAY = 180

C.NO_HEALTH_TYPES = {
  "resource", "fire", "corpse", "character-corpse", "rail-remnants", "item-entity", "explosion",
  "smoke-with-trigger", "projectile", "artillery-projectile", "sticker", "stream", "beam",
  "entity-ghost", "tile-ghost", "item-request-proxy", "deconstructible-tile-proxy", "highlight-box",
  "particle-source", "speech-bubble", "arrow", "cliff",
}

return C
