-- Persistent state of the citadel (storage.citadel) and the cached map settings.
--
-- storage.citadel
--   schema, phase        "dormant" | "warned" | "siting" | "active" | "destroyed"
--   rng                  random generator state (script/util.lua)
--   surface              surface index (Nauvis)
--   base                 centre of the player base (spawn position), set when the citadel is placed
--   spawn_tick           earliest tick the citadel may appear (late start in a save past the threshold)
--   site                 search of the core chunk while siting
--   modules              chunk key -> module {key, x, y, type, built, ruined, keys = {unit_number -> entity},
--                        nkeys, hub, born}
--   order                chunk keys in build order; count = #order
--   alive                module type -> modules of that type that are built and not ruined
--   key_of               unit_number of a key building -> chunk key of its module
--   blocked              chunk key -> tick until which the chunk is not tried again
--   bbox                 {x1, y1, x2, y2} chunk bounds of the city
--   core_key, stunned_until, next_growth, accel_since, shields
--   upgrades             {armor, damage, rate, intel, shield_size, shield_rate}
--   focus, deaths        armour focus and killing blows per focus group since the last adaptation
--   foundries            array of {e = entity, m = chunk key, kind, next}; foundry_index unit_number -> i
--   units                {list = array of entities, index = unit_number -> i}
--   forming              {group, target} the squad that is gathering at the muster point
--   waves                array of attacking squads (script/squads.lua)
--   intel                {map = chunk key -> record, list = keys, queue, head, seen} (script/intel.lua)
--   danger               chunk key -> {v, t} losses of the droids there (decaying)
--   alarm                {position, tick} a citadel building or droid was destroyed by a player
--   salvage              recycled parts (a free droid at 1)
--   work                 build queue (script/builder.lua)
--   cull_next, cull_cursor, beat
local S = require("lib.shared")
local U = require("script.util")

local state = {}
state.SCHEMA = 1

function state.new()
  local surface = game.surfaces["nauvis"] or game.get_surface(1)
  local seed = surface and surface.map_gen_settings.seed or 1
  storage.citadel = {
    schema = state.SCHEMA,
    phase = "dormant",
    rng = U.seed(seed * 7 + 12345),
    surface = surface and surface.index or 1,
    modules = {},
    order = {},
    count = 0,
    alive = {},
    key_of = {},
    blocked = {},
    upgrades = {armor = 0, damage = 0, rate = 0, intel = 0, shield_size = 0, shield_rate = 0},
    focus = "balanced",
    deaths = {kinetic = 0, energy = 0, chemical = 0},
    foundries = {},
    foundry_index = {},
    units = {list = {}, index = {}},
    waves = {},
    next_wave = 1,
    intel = {map = {}, list = {}, queue = {}, head = 1, tail = 0, seen = {}},
    danger = {},
    salvage = 0,
    work = {},
    beat = 0,
    stats = {launched = 0, lost = 0, produced = 0, modules_lost = 0},
  }
  return storage.citadel
end

function state.get()
  return storage.citadel
end

---------------------------------------------------------------------------------------------------
-- Map settings, cached (read again on on_runtime_mod_setting_changed).
---------------------------------------------------------------------------------------------------
state.cfg = {}

function state.read_settings()
  local g = settings.global
  local s = S.setting
  local cfg = state.cfg
  cfg.enabled = g[s.enabled].value
  cfg.evolution = g[s.evolution].value
  cfg.warning = math.min(g[s.warning].value, cfg.evolution)
  cfg.base_radius = g[s.base_radius].value
  cfg.distance = g[s.distance].value
  cfg.growth_ticks = math.max(60, math.floor(g[s.growth].value * 3600))
  cfg.stun_ticks = math.max(60, math.floor(g[s.stun].value * 3600))
  cfg.accel_modules = g[s.accel_modules].value
  cfg.accel_per_hour = g[s.accel_percent].value / 100
  cfg.shield_modules = g[s.shield_modules].value
  cfg.unit_limit = g[s.unit_limit].value
  cfg.attack_groups = g[s.attack_groups].value
  cfg.squad_base = g[s.squad_base].value
  cfg.squad_max = math.max(g[s.squad_max].value, 1)
  cfg.clear_radius = g[s.clear_radius].value
  cfg.messages = g[s.messages].value
  cfg.cull_min = 3600     -- ticks between two clearing looks: cull_min + random(cull_jitter)
  cfg.cull_jitter = 3600
  -- overrides set through the remote interface (tests, admins), kept in the save
  local c = storage.citadel
  if c and c.overrides then
    for k, v in pairs(c.overrides) do cfg[k] = v end
  end
end

function state.surface(c)
  return game.get_surface(c.surface)
end

return state
