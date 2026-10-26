-- Life of the citadel: waiting for the evolution, the search for its place, growth by one module
-- per interval, ruined modules, loss of the core (a pause, then a new core in the farthest
-- foundry module), the shield stage, the acceleration stage and the final defeat.
local S = require("lib.shared")
local U = require("script.util")
local M = require("script.modules")
local B = require("script.builder")
local P = require("script.production")
local Q = require("script.squads")
local I = require("script.intel")
local UP = require("script.upgrades")
local SUP = require("script.support")
local bus = require("script.bus")
local state = require("script.state")
local forces = require("script.forces")
local E = S.entity

local C = {}

local LATE_START = 36000          -- a save already past the threshold: the citadel comes 10 min later
local SITE_WAIT = 120             -- heartbeats to wait for the generation of a candidate chunk
local BLOCK_TICKS = 108000        -- a chunk that cannot be built on is not tried again for 30 min
local WATER_MAX = 256             -- water tiles a chunk may have (they are paved over)
local GROWTH_RETRY = 600
local MAX_BUILD_FAILS = 3

function C.evolution(c)
  local enemy = game.forces.enemy
  local surface = state.surface(c)
  if not (enemy and surface) then return 0 end
  return enemy.get_evolution_factor(surface)
end

---------------------------------------------------------------------------------------------------
-- Start.
---------------------------------------------------------------------------------------------------
function C.init()
  local c = state.new()
  forces.ensure()
  state.read_settings()
  local cfg = state.cfg
  if cfg.enabled and C.evolution(c) >= cfg.evolution then
    c.phase = "warned"
    c.spawn_tick = game.tick + LATE_START
    c.late_message = true
  end
  return c
end

local function check_evolution(c, cfg)
  if c.late_message then
    c.late_message = nil
    forces.print(cfg, {"replicator-message.late-start", math.ceil((c.spawn_tick - game.tick) / 3600)})
  end
  local evo = C.evolution(c)
  if c.phase == "dormant" and evo >= cfg.warning then
    c.phase = "warned"
    forces.print(cfg, {"replicator-message.warning"})
  end
  if evo >= cfg.evolution and (not c.spawn_tick or game.tick >= c.spawn_tick) then
    c.phase = "siting"
    c.site = {attempt = 0}
  end
end

---------------------------------------------------------------------------------------------------
-- Modules.
---------------------------------------------------------------------------------------------------
local function add_module(c, cx, cy, module_type)
  local k = U.key(cx, cy)
  local m = {key = k, x = cx, y = cy, type = module_type, built = false, ruined = false, keys = {}, nkeys = 0,
    born = game.tick}
  c.modules[k] = m
  c.order[#c.order + 1] = k
  c.count = #c.order
  local b = c.bbox
  if not b then
    c.bbox = {cx, cy, cx, cy}
  else
    b[1], b[2], b[3], b[4] = math.min(b[1], cx), math.min(b[2], cy), math.max(b[3], cx), math.max(b[4], cy)
  end
  return m
end

local function usable(m)
  return m and m.built and not m.ruined
end

local function core_down(c)
  return not usable(c.core_key and c.modules[c.core_key])
end

--- Reveals the core chunk to every player force and marks it on their maps. Charting takes a few
--- ticks, so the tags are retried on the heartbeat until they stick (at most TAG_TRIES looks).
local TAG_TRIES = 30
local function chart_tags(c, surface, position)
  c.tag_tries = c.tag_tries or 0
  if c.tag_tries == 0 then
    local area = {{position.x - 48, position.y - 48}, {position.x + 48, position.y + 48}}
    for _, force in pairs(forces.players()) do force.chart(surface, area) end
  end
  c.tag_tries = c.tag_tries + 1
  c.tagged = c.tagged or {}
  local missing = false
  for _, force in pairs(forces.players()) do
    if not c.tagged[force.index] then
      if force.add_chart_tag(surface, {position = position, icon = {type = "virtual", name = "signal-skull"}}) then
        c.tagged[force.index] = true
      else
        missing = true
      end
    end
  end
  c.tag_pending = missing and c.tag_tries < TAG_TRIES or nil
end

local function remove_tags(c, surface)
  if not c.tag_position then return end
  local p = c.tag_position
  local area = {{p.x - 2, p.y - 2}, {p.x + 2, p.y + 2}}
  for _, force in pairs(forces.players()) do
    for _, tag in pairs(force.find_chart_tags(surface, area)) do
      if tag.icon and tag.icon.name == "signal-skull" then tag.destroy() end
    end
  end
end

--- The decryption of replicator cores, for every player force once the citadel has appeared.
function C.unlock_recipes(c)
  if not c or not (c.phase == "active" or c.phase == "destroyed") then return end
  for _, force in pairs(forces.players()) do
    local r = force.recipes[S.decrypt_recipe]
    if r and not r.enabled then r.enabled = true end
  end
end

local function wire_hub(c, m)
  local hub = m.hub
  if not (hub and hub.valid) then return end
  local own = hub.get_wire_connector(defines.wire_connector_id.pole_copper, true)
  for _, d in pairs(U.NEIGHBOURS4) do
    local o = c.modules[U.key(m.x + d[1], m.y + d[2])]
    if o and o.hub and o.hub.valid then
      own.connect_to(o.hub.get_wire_connector(defines.wire_connector_id.pole_copper, true), false,
        defines.wire_origin.script)
    end
  end
end

local FOUNDRY_OF = {[E.core] = "core"}
for _, f in pairs(S.foundries) do FOUNDRY_OF[E["foundry_" .. f]] = f end

local function register_foundries(c, m)
  for _, e in pairs(m.keys) do
    local f = e.valid and FOUNDRY_OF[e.name]
    if f then P.add_foundry(c, e, m.key, f) end
  end
end

--- The hive is down: no growth for the pause (script/citadel.lua end_stun picks the new hive).
local function core_lost(c, cfg)
  c.stunned_until = game.tick + cfg.stun_ticks
  forces.print(cfg, {"replicator-message.core-destroyed", math.ceil(cfg.stun_ticks / 3600)})
end

local function on_module_built(c, k)
  local m = c.modules[k]
  local cfg = state.cfg
  local surface = state.surface(c)
  local is_core = k == c.core_key
  m.built = true
  if is_core then c.relocating = nil end
  if m.nkeys <= 0 then
    -- nothing of its plan stands there (could not be placed, or destroyed while being built)
    m.ruined = true
    m.failed = (m.failed or 0) + 1
    if is_core then
      if not c.core_ever and m.failed < MAX_BUILD_FAILS then
        B.build_module(c, k, true) -- the first hive: clear the place again and retry
      else
        core_lost(c, cfg)
      end
    end
    return
  end
  if is_core then c.core_ever = true end
  m.ruined = false
  m.failed = nil
  c.alive[m.type] = (c.alive[m.type] or 0) + 1
  register_foundries(c, m)
  wire_hub(c, m)
  UP.apply(c)
  surface.request_to_generate_chunks(U.center(m.x, m.y), 2)
  if not c.shields and c.count >= cfg.shield_modules and UP.shields_available() then
    c.shields = true
    forces.print(cfg, {"replicator-message.shields"})
    UP.apply(c)
    local keys = {}
    for i, key in ipairs(c.order) do keys[i] = key end
    B.queue(c, {t = "towers", keys = keys})
  end
  if not c.accel_since and c.count >= cfg.accel_modules then
    c.accel_since = game.tick
    forces.print(cfg, {"replicator-message.acceleration", math.floor(cfg.accel_per_hour * 100 + 0.5)})
  end
end
bus.on("module_built", on_module_built)
bus.on("module_restored", function(c, k)
  local m = c.modules[k]
  register_foundries(c, m)
  wire_hub(c, m)
  m.restore_fails = not (m.hub and m.hub.valid) and (m.restore_fails or 0) + 1 or nil
end)
bus.on("droid_made", function(c, e) Q.assign(c, e) end)

---------------------------------------------------------------------------------------------------
-- Place of the citadel.
---------------------------------------------------------------------------------------------------
local function site_ok(surface, cx, cy)
  local area = U.area(cx, cy)
  if surface.count_tiles_filtered({area = area, collision_mask = "water_tile", limit = WATER_MAX + 1}) > WATER_MAX then
    return false
  end
  local around = {{cx * 32 - 32, cy * 32 - 32}, {cx * 32 + 64, cy * 32 + 64}}
  return surface.count_entities_filtered({area = around, force = forces.player_names(), limit = 1}) == 0
end

local function spawn(c, cfg, surface, cx, cy)
  c.phase = "active"
  c.site = nil
  local m = add_module(c, cx, cy, "core")
  c.core_key = m.key
  B.build_module(c, m.key, true)
  c.next_growth = game.tick + cfg.growth_ticks
  c.cull_next = game.tick + math.floor(cfg.cull_min / 2)
  local center = U.center(cx, cy)
  surface.request_to_generate_chunks(center, 6)
  -- the corridor to the player base: the squads cannot find paths through chunks never generated
  if c.base then
    local dx, dy = c.base.x - center.x, c.base.y - center.y
    local steps = math.ceil(math.sqrt(dx * dx + dy * dy) / 64)
    for i = 1, steps do
      surface.request_to_generate_chunks({center.x + dx * i / steps, center.y + dy * i / steps}, 1)
    end
  end
  c.tag_position = center
  chart_tags(c, surface, center)
  forces.print(cfg, {"replicator-message.appeared", U.gps(center, surface)})
  C.unlock_recipes(c)
end

local function site_step(c, cfg, surface)
  local s = c.site
  if not s.cx then
    local force = game.forces.player or forces.players()[1]
    local base = force.get_spawn_position(surface)
    c.base = {x = base.x, y = base.y}
    local angle = U.random(c) * 2 * math.pi
    local chunks = cfg.base_radius + cfg.distance + 5 * math.floor(s.attempt / 8)
    local x, y = base.x + math.cos(angle) * chunks * 32, base.y + math.sin(angle) * chunks * 32
    s.cx, s.cy = U.chunk_of({x, y})
    s.wait = 0
    surface.request_to_generate_chunks({x, y}, 2)
    return
  end
  if not surface.is_chunk_generated({s.cx, s.cy}) then
    s.wait = s.wait + 1
    if s.wait > SITE_WAIT then
      s.attempt, s.cx = s.attempt + 1, nil
    end
    return
  end
  if site_ok(surface, s.cx, s.cy) then
    spawn(c, cfg, surface, s.cx, s.cy)
  else
    s.attempt, s.cx = s.attempt + 1, nil
  end
end

---------------------------------------------------------------------------------------------------
-- Growth.
---------------------------------------------------------------------------------------------------
--- "ok", "wait" (being generated) or false.
local function chunk_ok(surface, x, y)
  if not surface.is_chunk_generated({x, y}) then
    surface.request_to_generate_chunks(U.center(x, y), 1)
    return "wait"
  end
  local area = U.area(x, y)
  if surface.count_tiles_filtered({area = area, collision_mask = "water_tile", limit = WATER_MAX + 1}) > WATER_MAX then
    return false
  end
  if surface.count_entities_filtered({area = area, force = forces.player_names(), limit = 1}) > 0 then return false end
  return "ok"
end

local function pick_chunk(c, surface)
  local now = game.tick
  local seen, list = {}, {}
  local core = c.modules[c.core_key] or c.modules[c.order[1]]
  local toward
  local relays = c.alive.relay or 0
  if relays > 0 and c.base and core then
    local dx, dy = c.base.x - (core.x * 32 + 16), c.base.y - (core.y * 32 + 16)
    local d = math.sqrt(dx * dx + dy * dy)
    if d > 0 then toward = {dx / d, dy / d} end
  end
  for _, k in ipairs(c.order) do
    local m = c.modules[k]
    for _, d in ipairs(U.NEIGHBOURS4) do
      local x, y = m.x + d[1], m.y + d[2]
      local nk = U.key(x, y)
      if not c.modules[nk] and not seen[nk] and (c.blocked[nk] or 0) <= now then
        seen[nk] = true
        local near = 0
        for _, e in ipairs(U.NEIGHBOURS4) do
          if c.modules[U.key(x + e[1], y + e[2])] then near = near + 1 end
        end
        local score = 2 * near + 1.5 * U.random(c)
        if toward and core then
          local ox, oy = x - core.x, y - core.y
          local od = math.sqrt(ox * ox + oy * oy)
          if od > 0 then score = score + 0.6 * relays * (ox * toward[1] + oy * toward[2]) / od end
        end
        list[#list + 1] = {nk, x, y, score}
      end
    end
  end
  table.sort(list, function(a, b) if a[4] ~= b[4] then return a[4] > b[4] end return a[1] < b[1] end)
  for i = 1, math.min(8, #list) do
    local e = list[i]
    local ok = chunk_ok(surface, e[2], e[3])
    if ok == "ok" then return e[2], e[3] end
    if ok == false then c.blocked[e[1]] = now + BLOCK_TICKS end
  end
  return nil
end

local function rebuild(c, m)
  B.build_module(c, m.key, false)
end

local function grow(c, cfg, surface)
  c.next_growth = game.tick + cfg.growth_ticks
  UP.adapt(c)
  I.prune(c)
  -- first a ruined module, then a standing one that lost its hub pylon (no power), then a new one
  for _, k in ipairs(c.order) do
    local m = c.modules[k]
    if m.ruined and m.type ~= "core" and (m.failed or 0) < MAX_BUILD_FAILS then
      rebuild(c, m)
      return
    end
  end
  for _, k in ipairs(c.order) do
    local m = c.modules[k]
    if m.built and not m.ruined and not (m.hub and m.hub.valid) and (m.restore_fails or 0) < MAX_BUILD_FAILS then
      B.restore_module(c, k)
      return
    end
  end
  local x, y = pick_chunk(c, surface)
  if not x then
    c.next_growth = game.tick + GROWTH_RETRY
    return
  end
  local m = add_module(c, x, y, M.choose(c, UP.shields_available()))
  B.build_module(c, m.key, true)
end

---------------------------------------------------------------------------------------------------
-- Losses.
---------------------------------------------------------------------------------------------------
local function defeat(c, cfg)
  if c.phase == "destroyed" then return end
  c.phase = "destroyed"
  local surface = state.surface(c)
  forces.print(cfg, {"replicator-message.destroyed"}, {r = 0.4, g = 1, b = 0.4})
  Q.disband_all(c)
  local keys = {}
  for i, k in ipairs(c.order) do keys[i] = k end
  B.queue(c, {t = "cascade", keys = keys})
  for _, r in pairs(c.units.list) do
    if r.e.valid then r.e.destroy() end
  end
  c.units = {list = {}, index = {}}
  c.foundries, c.foundry_index = {}, {}
  if surface then remove_tags(c, surface) end
end
C.defeat = defeat

local function key_lost(c, m, unit_number)
  local cfg = state.cfg
  m.keys[unit_number] = nil
  c.key_of[unit_number] = nil
  P.remove_foundry(c, unit_number)
  m.nkeys = math.max(0, m.nkeys - 1)
  if m.built and m.nkeys == 0 and not m.ruined then
    m.ruined = true
    c.alive[m.type] = math.max(0, (c.alive[m.type] or 1) - 1)
    c.stats.modules_lost = c.stats.modules_lost + 1
    UP.apply(c)
    if m.type == "core" then core_lost(c, cfg) end
  end
  -- defeat: the hive is down and no foundry stands (not while the first hive or a new one is built)
  if c.core_ever and not c.relocating and core_down(c) and P.foundry_count(c) == 0 then defeat(c, cfg) end
end

--- After the pause: the farthest foundry module from the base becomes the new core.
local function end_stun(c, cfg)
  c.stunned_until = nil
  if P.foundry_count(c) == 0 then
    defeat(c, cfg)
    return
  end
  local best, best_d
  for _, k in ipairs(c.order) do
    local m = c.modules[k]
    if usable(m) and M.types[m.type].cat == "production" then
      local d = c.base and U.dist2(U.center(m.x, m.y), c.base) or 0
      if not best_d or d > best_d then best, best_d = m, d end
    end
  end
  if not best then
    defeat(c, cfg)
    return
  end
  local old = c.core_key and c.modules[c.core_key]
  if old and old ~= best then
    old.type = "foundry-light" -- the old core is rebuilt later as a foundry
    old.failed = nil
  end
  for un in pairs(best.keys) do
    P.remove_foundry(c, un)
    c.key_of[un] = nil
  end
  c.alive[best.type] = math.max(0, (c.alive[best.type] or 1) - 1)
  best.type = "core"
  best.built = false
  best.ruined = false
  c.relocating = best.key
  B.queue(c, {t = "demolish", k = best.key})
  B.build_module(c, best.key, false)
  c.core_key = best.key
  c.next_growth = game.tick + cfg.growth_ticks
  UP.apply(c)
  local surface = state.surface(c)
  forces.print(cfg, {"replicator-message.new-core", U.gps(U.center(best.x, best.y), surface)})
end

--- A key building whose entity is gone without a death event (another script): a few modules per look.
local function validate_keys(c)
  local n = #c.order
  if n == 0 then return end
  for _ = 1, math.min(n, 4) do
    local i = (c.validate_cursor or 0) % n + 1
    c.validate_cursor = i
    local m = c.modules[c.order[i]]
    if m and m.built then
      for un, e in pairs(m.keys) do
        if not e.valid then
          key_lost(c, m, un)
          if c.phase ~= "active" then return end
        end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Events.
---------------------------------------------------------------------------------------------------
local credit -- robotarmy-reforged kill credit available (looked up once)

local function in_city(c, position)
  local b = c.bbox
  if not b then return false end
  local x, y = U.chunk_of(position)
  return x >= b[1] - 1 and x <= b[3] + 1 and y >= b[2] - 1 and y <= b[4] + 1
end

function C.on_entity_died(event)
  local c = state.get()
  if not c or c.phase ~= "active" then return end
  local e = event.entity
  if not (e and e.valid) or e.force.name ~= S.force then return end
  local killer = event.force
  local by_player = killer and forces.is_player(killer)
  if e.type == "unit" then
    P.remove_unit(c, e.unit_number)
    P.on_lost(c)
    c.stats.lost = c.stats.lost + 1
    UP.on_death(c, event.damage_type and event.damage_type.name)
    if by_player then I.add_danger(c, e.position, 1) end
    local cause = event.cause
    if cause and cause.valid and cause.type == "unit" and cause.force ~= e.force then
      if credit == nil then
        credit = remote.interfaces["robotarmy-reforged"] ~= nil and remote.interfaces["robotarmy-reforged"].credit_kill ~= nil
      end
      if credit then remote.call("robotarmy-reforged", "credit_kill", cause) end
    end
  else
    local k = c.key_of[e.unit_number]
    if k and c.modules[k] then key_lost(c, c.modules[k], e.unit_number) end
  end
  if by_player and c.phase == "active" and in_city(c, e.position) then
    c.alarm = {position = e.position, tick = game.tick}
  end
end

--- Heartbeat, every 60 ticks.
function C.heartbeat()
  local c = state.get()
  if not c then return end
  local cfg = state.cfg
  c.beat = c.beat + 1
  local phase = c.phase
  if phase == "destroyed" or not cfg.enabled then return end
  -- once a minute: forces made by other mods may have become AI controlled after their creation
  if c.beat % 60 == 30 then forces.ensure() end
  if phase == "dormant" or phase == "warned" then
    if c.beat % 60 == 0 or (c.spawn_tick and game.tick >= c.spawn_tick) or c.late_message then
      check_evolution(c, cfg)
    end
    return
  end
  local surface = state.surface(c)
  if not surface then return end
  if phase == "siting" then
    site_step(c, cfg, surface)
    return
  end

  P.step(c, cfg, surface)
  if c.phase ~= "active" then return end
  Q.step(c, cfg, surface)
  for _ = 1, math.min(4, c.alive.radar or 0) do I.scan(c, surface, cfg.base_radius) end
  if c.beat % 5 == 0 then
    P.sweep_units(c, 25, function(e) Q.absorb(c, e) end)
    SUP.repair(c, surface)
    validate_keys(c)
    if c.phase ~= "active" then return end
  end
  if c.beat % 60 == 0 then SUP.jam(c, surface) end
  if c.tag_pending and c.beat % 5 == 0 then chart_tags(c, surface, c.tag_position) end
  if game.tick >= (c.cull_next or 0) then
    SUP.cull(c, cfg, surface)
    c.cull_next = game.tick + cfg.cull_min + U.random_int(c, math.max(1, cfg.cull_jitter))
  end
  if c.stunned_until then
    if game.tick >= c.stunned_until then end_stun(c, cfg) end
  elseif game.tick >= (c.next_growth or 0) and not B.busy(c) then
    grow(c, cfg, surface)
  end
end

---------------------------------------------------------------------------------------------------
-- Commands for tests and admins (remote interface).
---------------------------------------------------------------------------------------------------
--- Places the citadel now (at the given chunk, or by the normal search).
function C.force_spawn(x, y)
  local c = state.get()
  local cfg = state.cfg
  if c.phase == "active" or c.phase == "destroyed" then return false end
  local surface = state.surface(c)
  if x and y then
    local force = game.forces.player or forces.players()[1]
    local base = force.get_spawn_position(surface)
    c.base = {x = base.x, y = base.y}
    local cx, cy = U.chunk_of({x, y})
    surface.request_to_generate_chunks({x, y}, 2)
    surface.force_generate_chunk_requests()
    spawn(c, cfg, surface, cx, cy)
  else
    c.phase = "siting"
    c.site = {attempt = 0}
  end
  return true
end

--- Grows the citadel by n modules now (optionally of one type).
function C.force_grow(n, module_type)
  local c = state.get()
  if c.phase ~= "active" then return 0 end
  local surface = state.surface(c)
  surface.force_generate_chunk_requests()
  local done = 0
  for _ = 1, n or 1 do
    local x, y = pick_chunk(c, surface)
    if not x then
      surface.force_generate_chunk_requests()
      x, y = pick_chunk(c, surface)
    end
    if not x then break end
    local t = (module_type and M.types[module_type]) and module_type or M.choose(c, UP.shields_available())
    local m = add_module(c, x, y, t)
    B.build_module(c, m.key, true)
    done = done + 1
  end
  return done
end

function C.status()
  local c = state.get()
  if not c then return nil end
  local types = {}
  for k, v in pairs(c.alive) do types[k] = v end
  local ruined = 0
  for _, m in pairs(c.modules) do if m.ruined then ruined = ruined + 1 end end
  return {
    phase = c.phase, modules = c.count, ruined = ruined, alive = types, core = c.core_key and not core_down(c),
    stunned_until = c.stunned_until, next_growth = c.next_growth, shields = c.shields or false,
    accelerating = c.accel_since ~= nil, upgrades = c.upgrades, focus = c.focus, droids = P.unit_count(c),
    foundries = P.foundry_count(c), squads = #c.waves, forming = c.forming and c.forming.count or 0,
    known_chunks = I.count(c), building = B.busy(c), stats = c.stats,
    bbox = c.bbox, base = c.base, center = c.tag_position,
    core_position = c.core_key and (function() local x, y = U.unkey(c.core_key) return U.center(x, y) end)(),
  }
end

--- Every module: position, type, state, key buildings and the last placement (inspection).
function C.modules()
  local c = state.get()
  local out = {}
  if not c then return out end
  for i, k in ipairs(c.order) do
    local m = c.modules[k]
    out[i] = {x = m.x, y = m.y, type = m.type, built = m.built, ruined = m.ruined, keys = m.nkeys,
      hub = m.hub ~= nil and m.hub.valid, tower = m.tower ~= nil and m.tower.valid,
      planned = m.planned, placed = m.placed, missed = m.missed, core = k == c.core_key}
  end
  return out
end

--- Attacking squads and the gathering one (inspection).
function C.squads()
  local c = state.get()
  local out = {}
  if not c then return out end
  for i, w in ipairs(c.waves) do
    local g = w.group
    out[i] = {id = w.id, phase = w.phase, size0 = w.size0, steps = w.steps, target = w.target,
      size = g and g.valid and #g.members or 0, position = g and g.valid and g.position or nil}
  end
  local f = c.forming
  out.forming = f and f.group and f.group.valid and {count = #f.group.members, target = f.target,
    defending = f.defending ~= nil, position = f.group.position} or nil
  return out
end

--- Overrides of the map settings (tests, admins): keys of state.cfg, e.g. growth_ticks, stun_ticks,
--- base_radius, distance, squad_base, cull_min. nil clears them. Kept in the save.
function C.configure(overrides)
  local c = state.get()
  if not c then return false end
  if overrides == nil then
    c.overrides = nil
  else
    c.overrides = c.overrides or {}
    for k, v in pairs(overrides) do
      if state.cfg[k] == nil or type(state.cfg[k]) ~= type(v) then error("unknown or wrong setting " .. tostring(k)) end
      c.overrides[k] = v
    end
  end
  state.read_settings()
  return true
end

C.add_module = add_module

return C
