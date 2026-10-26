-- What the citadel knows about the player base, and how its squads choose targets.
--
-- Knowledge: chunk records {x, y, soft, def, power, tick}. Radar modules explore the base like a
-- flood fill from its centre: one chunk per radar per look, only chunks with player buildings are
-- kept and spread to their neighbours, so the search follows the base and never scans empty land.
-- Squads add the chunks where they found targets. Without radars the citadel knows only that.
--
-- Danger: losses of the droids per chunk, decaying by half every DANGER_HALF ticks (computed when
-- read: no periodic pass).
--
-- Intelligence levels (computing centres, 0..6):
--   0  nearest known chunk; launches half-gathered squads; no retreat
--   1  discipline: waits for a full squad, retreats after heavy losses
--   2  target choice: buildings without towers first, keeps away from defended chunks
--   3  memory of losses: avoids chunks where droids died (target and route)
--   4  march without distraction: does not stop for what it meets on the way
--   5  pincers: a squad splits and attacks two places at once
--   6  strikes the power: poles, generators, accumulators first; damaged squads go to the repair docks
local U = require("script.util")
local forces = require("script.forces")

local I = {}

I.SOFT = {"electric-pole", "pipe", "pipe-to-ground", "pump", "offshore-pump", "transport-belt",
  "underground-belt", "splitter", "inserter", "assembling-machine", "furnace", "mining-drill", "lab",
  "boiler", "generator", "solar-panel", "accumulator", "reactor", "roboport", "radar", "storage-tank",
  "container", "logistic-container", "beacon", "rocket-silo", "burner-generator", "heat-pipe"}
I.DEFENSE = {"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret"}
I.POWER = {"electric-pole", "generator", "boiler", "solar-panel", "accumulator", "reactor", "burner-generator"}
I.TARGETS = {}
for _, t in pairs(I.SOFT) do I.TARGETS[#I.TARGETS + 1] = t end
for _, t in pairs(I.DEFENSE) do I.TARGETS[#I.TARGETS + 1] = t end
local IS_DEFENSE, IS_POWER = {}, {}
for _, t in pairs(I.DEFENSE) do IS_DEFENSE[t] = true end
for _, t in pairs(I.POWER) do IS_POWER[t] = true end

local DANGER_HALF = 108000
local MAX_RECORDS = 6000
local SAMPLE = 40
local LOCAL_RADIUS = 40

---------------------------------------------------------------------------------------------------
-- Danger.
---------------------------------------------------------------------------------------------------
function I.danger(c, k)
  local d = c.danger[k]
  if not d then return 0 end
  return d.v * 0.5 ^ ((game.tick - d.t) / DANGER_HALF)
end

function I.add_danger(c, position, amount)
  local x, y = U.chunk_of(position)
  local k = U.key(x, y)
  local v = I.danger(c, k) + amount
  if v < 0.05 then c.danger[k] = nil else c.danger[k] = {v = v, t = game.tick} end
end

--- Drops faded danger records and expired chunk blocks (on every growth step).
function I.prune(c)
  for k in pairs(c.danger) do
    if I.danger(c, k) < 0.05 then c.danger[k] = nil end
  end
  local now = game.tick
  for k, t in pairs(c.blocked) do
    if t <= now then c.blocked[k] = nil end
  end
end

---------------------------------------------------------------------------------------------------
-- Knowledge.
---------------------------------------------------------------------------------------------------
local function remember(c, x, y, soft, def, power)
  local intel = c.intel
  local k = U.key(x, y)
  local r = intel.map[k]
  if not r then
    if #intel.list >= MAX_RECORDS then return end
    intel.list[#intel.list + 1] = k
    r = {x = x, y = y, i = #intel.list}
    intel.map[k] = r
  end
  r.soft, r.def, r.power, r.tick = soft, def, power, game.tick
end

local function forget(c, k)
  local intel = c.intel
  local r = intel.map[k]
  if not r then return end
  intel.map[k] = nil
  local list = intel.list
  local last = #list
  if r.i ~= last then
    local moved = list[last]
    list[r.i] = moved
    intel.map[moved].i = r.i
  end
  list[last] = nil
end

function I.count(c)
  return #c.intel.list
end

--- One radar look: the next chunk of the flood fill from the base centre. Chunks with player
--- buildings spread the fill to their neighbours; empty chunks spread it only within `radius`
--- chunks of the centre (the spawn area may be empty, the base around it is not).
function I.scan(c, surface, radius)
  local intel = c.intel
  if not c.base then return end
  if intel.head > (intel.tail or 0) then
    -- a new pass: start again from the centre (records are refreshed, not dropped)
    local bx, by = U.chunk_of(c.base)
    intel.queue, intel.head, intel.tail, intel.seen = {U.key(bx, by)}, 1, 1, {[U.key(bx, by)] = true}
  end
  local k = intel.queue[intel.head]
  intel.queue[intel.head] = nil
  intel.head = intel.head + 1
  local x, y = U.unkey(k)
  local area = U.area(x, y)
  local pf = forces.player_names()
  local soft = surface.count_entities_filtered({area = area, force = pf, type = I.SOFT, limit = 60})
  local def = surface.count_entities_filtered({area = area, force = pf, type = I.DEFENSE, limit = 30})
  if soft + def > 0 then
    local power = surface.count_entities_filtered({area = area, force = pf, type = I.POWER, limit = 30})
    remember(c, x, y, soft, def, power)
  else
    forget(c, k)
    local bx, by = U.chunk_of(c.base)
    local dx, dy = x - bx, y - by
    if dx * dx + dy * dy > (radius or 0) * (radius or 0) then return end
  end
  for _, d in pairs(U.NEIGHBOURS8) do
    local nk = U.key(x + d[1], y + d[2])
    if not intel.seen[nk] then
      intel.seen[nk] = true
      intel.tail = intel.tail + 1
      intel.queue[intel.tail] = nk
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Targets.
---------------------------------------------------------------------------------------------------
local function far_from(r, exclude)
  for _, p in pairs(exclude or {}) do
    local dx, dy = r.x * 32 + 16 - p.x, r.y * 32 + 16 - p.y
    if dx * dx + dy * dy < 128 * 128 then return false end
  end
  return true
end

--- Position to attack (a known chunk) for a squad starting at `from`; the base centre if nothing is
--- known. `exclude`: positions the chosen target must keep away from (pincers).
function I.choose_target(c, level, from, exclude)
  local list = c.intel.list
  local best, best_score
  local n = #list
  local tries = math.min(n, SAMPLE)
  for _ = 1, tries do
    local k = list[U.random_int(c, n)]
    local r = c.intel.map[k]
    if r and far_from(r, exclude) then
      local p = {x = r.x * 32 + 16, y = r.y * 32 + 16}
      local score = -U.dist(from, p) / 64
      if level >= 2 then score = score + 2 * math.min(r.soft, 30) / 10 - 6 * r.def end
      if level >= 3 then score = score - 5 * I.danger(c, k) end
      if level >= 6 then score = score + 4 * math.min(r.power, 10) / 5 end
      if not best_score or score > best_score then best, best_score = p, score end
    end
  end
  return best or (c.base and {x = c.base.x, y = c.base.y})
end

--- Target near a squad: the entity position to attack, or nil. Records the chunk as known.
function I.local_target(c, surface, position, level)
  local found = surface.find_entities_filtered({position = position, radius = LOCAL_RADIUS,
    force = forces.player_names(), type = I.TARGETS, limit = 40})
  if #found == 0 then return nil end
  local best, best_score
  local soft, def, power = 0, 0, 0
  for _, e in pairs(found) do
    local t = e.type
    local d = U.dist(position, e.position)
    local score = -d
    if IS_DEFENSE[t] then
      def = def + 1
      if level >= 2 then score = score - 40 end
    else
      soft = soft + 1
    end
    if IS_POWER[t] then
      power = power + 1
      if level >= 6 then score = score + 30 end
    end
    if not best_score or score > best_score then best, best_score = e.position, score end
  end
  local x, y = U.chunk_of(position)
  remember(c, x, y, soft, def, power)
  return best
end

--- Waypoints from `from` to `to` (segments of about SEGMENT tiles). From level 3 the route bends
--- around the dangerous middle when one side of it is safer.
local SEGMENT = 192
function I.route(c, from, to, level)
  local points = {}
  local dx, dy = to.x - from.x, to.y - from.y
  local length = math.sqrt(dx * dx + dy * dy)
  local mid = {x = from.x + dx / 2, y = from.y + dy / 2}
  if level >= 3 and length > 2 * SEGMENT then
    local nx, ny = -dy / length, dx / length
    local function risk(p)
      local cx, cy = U.chunk_of(p)
      local v = 0
      for ox = -1, 1 do
        for oy = -1, 1 do v = v + I.danger(c, U.key(cx + ox, cy + oy)) end
      end
      return v
    end
    local here = risk(mid)
    if here > 1 then
      local off = math.min(length / 3, 320)
      local left = {x = mid.x + nx * off, y = mid.y + ny * off}
      local right = {x = mid.x - nx * off, y = mid.y - ny * off}
      local rl, rr = risk(left), risk(right)
      if math.min(rl, rr) < here then mid = rl <= rr and left or right end
    end
  end
  local function segment(a, b)
    local sx, sy = b.x - a.x, b.y - a.y
    local d = math.sqrt(sx * sx + sy * sy)
    local steps = math.max(1, math.ceil(d / SEGMENT))
    for i = 1, steps do
      points[#points + 1] = {x = a.x + sx * i / steps, y = a.y + sy * i / steps}
    end
  end
  segment(from, mid)
  segment(mid, to)
  return points
end

return I
