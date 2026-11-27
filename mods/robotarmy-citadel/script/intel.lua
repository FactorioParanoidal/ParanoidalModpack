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
--   0  nearest known chunk; launches at 60% rounded up; no retreat for casualties alone
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
local RAID_RADIUS = 128
local CONFIRM_AFTER = 216000 -- one hour; powered radar can refresh disconnected records
local MAINTAIN_PER_BEAT = 4
local VERIFY_PER_TARGET = 4
local ROUTE_COOLDOWN = 3600 -- retry preference only; a sole real target is never suppressed
local MAX_FAILED_ROUTES = 16

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
local function remember(c, x, y, soft, def, power, partial)
  local intel = c.intel
  local k = U.key(x, y)
  local r = intel.map[k]
  if not r then
    if #intel.list >= MAX_RECORDS then return end
    intel.list[#intel.list + 1] = k
    r = {x = x, y = y, i = #intel.list}
    intel.map[k] = r
  elseif partial and not r.partial then
    -- Keep a survey (or an old snapshot of unknown origin) and its original expiry.
    -- The latest bounded sighting can add evidence, but cannot survey the unseen tiles.
    r.sighting = {soft = soft, def = def, power = power, tick = game.tick}
    return
  end
  r.soft, r.def, r.power, r.tick = soft, def, power, game.tick
  r.partial, r.sighting = partial, nil
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

-- The area filter can include a building whose collision box overlaps a chunk border.
-- Count or confirm it only in the chunk containing its position.
local function check_chunk(surface, x, y, presence_only)
  local soft, def, power = 0, 0, 0
  for _, e in ipairs(surface.find_entities_filtered({area = U.area(x, y), force = forces.player_names(),
    type = I.TARGETS})) do
    local ex, ey = U.chunk_of(e.position)
    if ex == x and ey == y then
      if presence_only then return true end
      if IS_DEFENSE[e.type] then def = def + 1 else soft = soft + 1 end
      if IS_POWER[e.type] then power = power + 1 end
    end
  end
  if presence_only then return false end
  return math.min(60, soft), math.min(30, def), math.min(30, power)
end

function I.maintain(c, surface, powered)
  local intel = c.intel
  local i = intel.maintain_at or 1
  for _ = 1, math.min(MAINTAIN_PER_BEAT, #intel.list) do
    if i > #intel.list then i = 1 end
    local k = intel.list[i]
    if not k then break end
    local r = intel.map[k]
    if game.tick - (r.tick or 0) >= CONFIRM_AFTER then
      local soft, def, power = 0, 0, 0
      if powered then soft, def, power = check_chunk(surface, r.x, r.y) end
      if soft + def > 0 then
        remember(c, r.x, r.y, soft, def, power)
        i = i + 1
      elseif not powered and r.sighting and game.tick - r.sighting.tick < CONFIRM_AFTER then
        -- The old survey expired, not the more recent sighting. Do not renew either clock.
        local s = r.sighting
        r.soft, r.def, r.power, r.tick = s.soft, s.def, s.power, s.tick
        r.partial, r.sighting = true, nil
        i = i + 1
      else
        forget(c, k) -- next iteration checks the entry swapped into i
      end
    else
      i = i + 1
    end
  end
  intel.maintain_at = i
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
  local soft, def, power = check_chunk(surface, x, y)
  if soft + def > 0 then
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
local function chunk_key(p)
  return U.key(U.chunk_of(p))
end

function I.failed_route(c, target)
  local failed = c.failed_routes or {}
  c.failed_routes = failed
  local k = chunk_key(target)
  failed[k] = game.tick + ROUTE_COOLDOWN
  local n, oldest = 0, nil
  for key, until_tick in pairs(failed) do
    if until_tick <= game.tick then
      failed[key] = nil
    else
      n = n + 1
      if key ~= k and (not oldest or until_tick < failed[oldest]
        or (until_tick == failed[oldest] and key < oldest)) then oldest = key end
    end
  end
  if n > MAX_FAILED_ROUTES then failed[oldest] = nil end
end

local function delayed(c, key)
  return c and c.failed_routes and (c.failed_routes[key] or 0) > game.tick or false
end

local function far_from(r, exclude)
  for _, p in pairs(exclude or {}) do
    local dx, dy = r.x * 32 + 16 - p.x, r.y * 32 + 16 - p.y
    if dx * dx + dy * dy < 128 * 128 then return false end
  end
  return true
end

--- Position to attack (a known chunk) for a squad starting at `from`; the base centre if nothing is
--- known. `exclude`: positions the chosen target must keep away from (pincers).
function I.choose_target(c, level, from, exclude, surface, nearby_fallback)
  local list = c.intel.list
  local candidates, picks = {}, {}
  local n = #list
  for i = 1, math.min(n, SAMPLE) do
    -- Sample without replacement, storing only the at most SAMPLE swapped positions.
    local last = n - i + 1
    local j = U.random_int(c, last)
    local k = list[picks[j] or j]
    picks[j] = picks[last] or last
    local r = c.intel.map[k]
    if r and far_from(r, exclude) then
      local p = {x = r.x * 32 + 16, y = r.y * 32 + 16}
      local score = -U.dist(from, p) / 64
      if level >= 2 then
        local soft, defense, power = r.soft, r.def, r.power
        local s = r.sighting
        if s then -- lower bounds from two observations, not additive building counts
          soft, defense, power = math.max(soft, s.soft), math.max(defense, s.def), math.max(power, s.power)
        end
        score = score + 2 * math.min(soft, 30) / 10 - 6 * defense
        if level >= 3 then score = score - 5 * I.danger(c, k) end
        if level >= 6 then score = score + 4 * math.min(power, 10) / 5 end
      end
      candidates[#candidates + 1] = {k = k, p = p, score = score, order = #candidates + 1, delayed = delayed(c, k)}
    end
  end
  table.sort(candidates, function(a, b)
    if a.score == b.score then return a.order < b.order end
    return a.score > b.score
  end)
  -- Confirm the usual best choice first. A cooldown may replace a real target only with
  -- another verified one, never with the spawn point because four alternative records went stale.
  local fallback, left = nearby_fallback, VERIFY_PER_TARGET
  for _, candidate in ipairs(candidates) do
    if not (fallback and candidate.delayed) then
      local r = c.intel.map[candidate.k]
      if check_chunk(surface, r.x, r.y, true) then
        if not candidate.delayed then return candidate.p end
        fallback = candidate.p
      else
        forget(c, candidate.k)
      end
      left = left - 1
      if left == 0 then break end
    end
  end
  return fallback or (c.base and {x = c.base.x, y = c.base.y})
end

local function nearby_target(surface, position, level, radius, c, record)
  local found = surface.find_entities_filtered({position = position, radius = radius,
    force = forces.player_names(), type = I.TARGETS, limit = 40})
  if #found == 0 then return nil end
  local best, best_score, best_delayed
  local seen, records = record and {}, record and {}
  for _, e in ipairs(found) do
    local t, pos = e.type, e.position
    local score = -U.dist(position, pos)
    if level >= 2 and IS_DEFENSE[t] then score = score - 40 end
    if level >= 6 and IS_POWER[t] then score = score + 30 end
    local defer = c and c.failed_routes and delayed(c, chunk_key(pos)) or false
    if not best or (best_delayed and not defer) or (defer == best_delayed and score > best_score) then
      best, best_score, best_delayed = pos, score, defer
    end
    if seen then
      local x, y = U.chunk_of(pos)
      local k = U.key(x, y)
      if not seen[k] then
        seen[k] = {x = x, y = y, soft = 0, def = 0, power = 0}
        records[#records + 1] = seen[k]
      end
      local r = seen[k]
      if IS_DEFENSE[t] then r.def = r.def + 1 else r.soft = r.soft + 1 end
      if IS_POWER[t] then r.power = r.power + 1 end
    end
  end
  if records then
    for _, r in ipairs(records) do remember(c, r.x, r.y, r.soft, r.def, r.power, true) end
  end
  return best, best_delayed
end

--- Targets near the city need not be connected to the radar's scan from the player spawn.
function I.raid_target(surface, origin, level, c)
  return nearby_target(surface, origin, level, RAID_RADIUS, c)
end

--- Target near a marching squad: the entity position to attack, or nil. Records the chunk as known.
function I.local_target(c, surface, position, level)
  return nearby_target(surface, position, level, LOCAL_RADIUS, c, true)
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
