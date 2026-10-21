-- Defence tower: repair (from Repair Turret by Klonan, Paranoidal fork 9.0.6).
-- Every `interval` ticks a tower heals up to `beams` damaged friendly entities in a square of +-range tiles,
-- spending energy from its hidden electric-energy-interface and durability of the repair pack in its own slot.
-- Range, speed and beams come from the force's researched upgrade levels. The same square is the shield
-- zone of the tower (scripts/shield.lua); turrets the shield repairs (shielded()) are left to it.
--
-- Damage is NOT tracked through on_entity_damaged (its cost grows with every hit on the map):
--   * every repairable building whose centre lies in a tower square is kept once in a watch list;
--     a small portion of it is polled each tick (slow tier, a full pass in about scan_period ticks);
--   * the buildings of chunks where damage was seen recently (by the polls, the vehicle search or the
--     shield) are polled every hot_period ticks (hot tier);
--   * damaged vehicles/characters: one search per covered chunk (clipped to the tower squares in it),
--     every moving_period ticks while something moves there, less and less often while nothing does.
-- Reading tower squares (build, move, range research, shield switched off, rescans) is queued work
-- split into strips, at most work_steps strips per tick; a range change reads only the ring between
-- the old and the new square. Without towers the module does nothing per tick.
local C = require("shared")
local A = require("scripts.area")

local R = {}

local TURRET, ENERGY, BEAM = C.turret, C.energy, C.beam
local INTERVAL = C.interval
local ENERGY_PER_HP = C.energy_per_hp
local EEI_OFFSET = C.eei_offset
local SCAN_PERIOD, SCAN_MAX = C.scan_period, C.scan_max
local HOT_PERIOD, HOT_TTL, HOT_CHUNKS = C.hot_period, C.hot_ttl, C.hot_chunks
local MOVING_PERIOD, MOVING_MAX, MOVING_SWEEP = C.moving_period, C.moving_max, C.moving_sweep
local RESCAN_INTERVAL = C.rescan_interval
local STRIP, WORK_STEPS, PURGE_BATCH = C.strip, C.work_steps, C.purge_batch
local CHUNK = A.CHUNK
local BEAM_DURATION = 20
local DATA_VERSION = 4

local floor, abs, max, min, ceil = math.floor, math.abs, math.max, math.min, math.ceil
local chunk_key, key_of, ring = A.chunk_key, A.key, A.ring
local chest_inventory = defines.inventory.chest

local moving_type_list =
{
  "character", "car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon",
}
local moving_types = {}
for _, t in pairs(moving_type_list) do moving_types[t] = true end

local ignored_names = {["entity-ghost"] = true, ["tile-ghost"] = true, [ENERGY] = true}

local area_fill = {r = 0.04, g = 0.16, b = 0.04, a = 0.16}
local area_border = {r = 0.3, g = 0.9, b = 0.3, a = 0.9}

-- Links to the shield (set by control.lua): shielded(entity, name) is true for turrets the shield of
-- the towers repairs; range_changed(force_index, old, new) after the range of a force's towers changed.
local shielded = function() return false end
local range_changed = function() end

function R.set_shield(is_shielded, on_range_changed)
  shielded, range_changed = is_shielded, on_range_changed
end

-- Caches derived only from prototypes: identical on every peer, safe outside storage.
local repairable_cache = {}
local function is_repairable(entity)
  local name = entity.name
  local v = repairable_cache[name]
  if v == nil then
    v = not entity.prototype.has_flag("not-repairable")
    repairable_cache[name] = v
  end
  return v
end

local speed_cache = {}
local function pack_speed(stack)
  local name = stack.name
  local v = speed_cache[name]
  if v == nil then
    v = stack.prototype.speed or 0
    speed_cache[name] = v
  end
  return v
end

--[[ storage.rt
  v = DATA_VERSION
  turrets[uid] = T = {entity, eei, inventory, uid, surface, force, x, y, range, beam_pos, targets = {[uid] = entity}, active, warn}
  map[surface][chunk_x][chunk_y] = {[uid] = T}  -- towers whose square reaches the chunk
  buckets[uid % INTERVAL] = {[uid] = T}        -- active towers only
  forces[force_index] = number of towers
  stats[force_index] = {range, shot, beams, buffer}
  hover[player_index] = {fill, border}
  watch = {n, cursor, list = {uid}, pos = {[uid] = index}, ent = {[uid] = entity}, key = {[uid] = chunk key},
           members = {[chunk key] = {[uid] = true}}}  -- buildings in tower squares
  hot = {list = {chunk key}, pos = {[key] = index}, ttl = {[key] = tick}, due = {[key] = tick}, cursor}
  chunks = {list = {chunk key}, pos = {[key] = index}, info = {[key] = {s, cx, cy, next, period}}, cursor}
  queue = {head, tail, [i] = job}  -- area work, see step()
  rescan = uid of the tower last re-read
]]
local data

local function new_data()
  return
  {
    v = DATA_VERSION, turrets = {}, map = {}, buckets = {}, forces = {}, stats = {}, hover = {},
    watch = {n = 0, cursor = 1, list = {}, pos = {}, ent = {}, key = {}, members = {}},
    hot = {list = {}, pos = {}, ttl = {}, due = {}, cursor = 1},
    chunks = {list = {}, pos = {}, info = {}, cursor = 1},
    queue = {head = 1, tail = 0},
  }
end

-- Other mods can raise events (e.g. technology effects reset) in their on_configuration_changed
-- before ours has rebuilt storage. Until then events are ignored; rebuild() rescans the map anyway.
local function stale()
  return not (data and data.v == DATA_VERSION)
end

---------------------------------------------------------------------------
-- Research

local function researched(techs, prefix, levels)
  local n = 0
  for i = 1, #levels do
    local t = techs[prefix .. i]
    if t and t.researched then n = n + 1 end
  end
  return n
end

local function compute_stats(force)
  local techs = force.technologies
  local hps = C.heal_per_second * (1 + C.speed_bonus * researched(techs, C.speed_tech, C.speed_levels))
  local beams = 1 + researched(techs, C.beams_tech, C.beams_levels)
  local shot = hps * INTERVAL / 60
  return
  {
    range = C.range + researched(techs, C.range_tech, C.range_levels),
    shot = shot,
    beams = beams,
    -- one full volley must fit into the buffer
    buffer = max(C.min_buffer, shot * beams * ENERGY_PER_HP * 1.2),
  }
end

local default_stats

local function stats_of(force_index)
  local s = data.stats[force_index]
  if s then return s end
  local force = game.forces[force_index]
  if force then
    s = compute_stats(force)
    data.stats[force_index] = s
    return s
  end
  default_stats = default_stats or {range = C.range, shot = C.heal_per_second * INTERVAL / 60, beams = 1, buffer = C.min_buffer}
  return default_stats
end

-- Half side of the tower square of a force (repair and shield zone).
function R.range_of(force_index)
  if stale() then return C.range end
  return stats_of(force_index).range
end

---------------------------------------------------------------------------
-- Covered chunks: the map of towers by chunk and the list of chunks for the vehicle search.

local function chunk_bounds(T)
  local r = T.range
  return floor((T.x - r) / CHUNK), floor((T.x + r) / CHUNK),
         floor((T.y - r) / CHUNK), floor((T.y + r) / CHUNK)
end

local function chunk_add(s, cx, cy)
  local K = data.chunks
  local key = key_of(s, cx, cy)
  if K.pos[key] then return end
  local n = #K.list + 1
  K.list[n] = key
  K.pos[key] = n
  K.info[key] = {s = s, cx = cx, cy = cy, next = 0, period = MOVING_PERIOD}
end

local function chunk_remove(s, cx, cy)
  local K = data.chunks
  local key = key_of(s, cx, cy)
  local i = K.pos[key]
  if not i then return end
  local n = #K.list
  local last = K.list[n]
  K.list[i] = last
  K.pos[last] = i
  K.list[n] = nil
  K.pos[key] = nil
  K.info[key] = nil
end

local function map_add(T)
  local sm = data.map[T.surface]
  if not sm then sm = {}; data.map[T.surface] = sm end
  local x1, x2, y1, y2 = chunk_bounds(T)
  for cx = x1, x2 do
    local mx = sm[cx]
    if not mx then mx = {}; sm[cx] = mx end
    for cy = y1, y2 do
      local list = mx[cy]
      if not list then
        list = {}
        mx[cy] = list
        chunk_add(T.surface, cx, cy)
      end
      list[T.uid] = T
    end
  end
end

local function map_remove(T)
  local sm = data.map[T.surface]
  if not sm then return end
  local x1, x2, y1, y2 = chunk_bounds(T)
  for cx = x1, x2 do
    local mx = sm[cx]
    if mx then
      for cy = y1, y2 do
        local list = mx[cy]
        if list then
          list[T.uid] = nil
          if not next(list) then
            mx[cy] = nil
            chunk_remove(T.surface, cx, cy)
          end
        end
      end
      if not next(mx) then sm[cx] = nil end
    end
  end
  if not next(sm) then data.map[T.surface] = nil end
end

local function turrets_at(surface_index, x, y)
  local sm = data.map[surface_index]
  if not sm then return end
  local mx = sm[floor(x / CHUNK)]
  if not mx then return end
  return mx[floor(y / CHUNK)]
end

-- Towers whose square may reach the point: {[uid] = T} (T.x, T.y, T.range, T.force); nil if none.
function R.towers_at(surface_index, x, y)
  if stale() then return nil end
  return turrets_at(surface_index, x, y)
end

-- Is the point covered by a tower of the force (other than the entity itself)?
local function covered(uid, x, y, surface_index, force_index)
  local list = turrets_at(surface_index, x, y)
  if not list then return false end
  for tuid, T in pairs(list) do
    local r = T.range
    if T.force == force_index and tuid ~= uid and abs(x - T.x) <= r and abs(y - T.y) <= r then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------
-- Watch list (dense array + index, swap-remove) with the members of every chunk

local function watch_add(entity, uid, key)
  local W = data.watch
  if W.pos[uid] then return end
  local n = W.n + 1
  W.n = n
  W.list[n] = uid
  W.pos[uid] = n
  W.ent[uid] = entity
  W.key[uid] = key
  local m = W.members[key]
  if not m then m = {}; W.members[key] = m end
  m[uid] = true
end

local function watch_remove(uid)
  local W = data.watch
  local i = W.pos[uid]
  if not i then return end
  local n = W.n
  local last = W.list[n]
  W.list[i] = last
  W.pos[last] = i
  W.list[n] = nil
  W.pos[uid] = nil
  W.ent[uid] = nil
  local key = W.key[uid]
  W.key[uid] = nil
  local m = W.members[key]
  if m then
    m[uid] = nil
    if not next(m) then W.members[key] = nil end
  end
  W.n = n - 1
end

---------------------------------------------------------------------------
-- Hot chunks: damage seen there recently

local function mark_hot(key, tick)
  local H = data.hot
  if not H.pos[key] then
    local n = #H.list + 1
    H.list[n] = key
    H.pos[key] = n
    H.due[key] = tick + 1
  end
  H.ttl[key] = tick + HOT_TTL
end

local function hot_remove_at(i)
  local H = data.hot
  local n = #H.list
  local key, last = H.list[i], H.list[n]
  H.list[i] = last
  H.pos[last] = i
  H.list[n] = nil
  H.pos[key] = nil
  H.ttl[key] = nil
  H.due[key] = nil
end

-- The shield saw damage at a turret: the buildings around are polled often for a while.
function R.mark_hot(surface_index, x, y, tick)
  if stale() then return end
  local key = chunk_key(surface_index, x, y)
  if data.watch.members[key] then mark_hot(key, tick) end
end

---------------------------------------------------------------------------
-- Activity

local function activate(T)
  T.active = true
  local i = T.uid % INTERVAL
  local bucket = data.buckets[i]
  if not bucket then bucket = {}; data.buckets[i] = bucket end
  bucket[T.uid] = T
end

local function deactivate(T)
  T.active = false
  local i = T.uid % INTERVAL
  local bucket = data.buckets[i]
  if not bucket then return end
  bucket[T.uid] = nil
  if not next(bucket) then data.buckets[i] = nil end
end

local function set_warning(T, on)
  local warn = T.warn
  if on then
    if not (warn and warn.valid) then
      T.warn = rendering.draw_sprite
      {
        sprite = "item/repair-pack",
        target = {entity = T.entity, offset = {0, -0.6}},
        surface = T.entity.surface,
        x_scale = 0.6,
        y_scale = 0.6,
        render_layer = "entity-info-icon",
      }
    end
  elseif warn then
    if warn.valid then warn.destroy() end
    T.warn = nil
  end
end

-- Offer a damaged entity to every tower of its force that covers it.
local function offer(entity, uid, x, y, surface_index, force_index)
  local list = turrets_at(surface_index, x, y)
  if not list then return end
  for tuid, T in pairs(list) do
    local r = T.range
    if T.force == force_index and tuid ~= uid and abs(x - T.x) <= r and abs(y - T.y) <= r then
      T.targets[uid] = entity
      if not T.active then activate(T) end
    end
  end
end

-- A watched entity found damaged: offered to the towers covering it and its chunk becomes hot.
-- A turret the shield handles now (its shield was switched on after it was watched) leaves the list.
-- Returns false if the entity left the watch list.
local function found_damaged(e, uid, tick)
  if shielded(e, e.name) then
    watch_remove(uid)
    return false
  end
  local p = e.position
  offer(e, uid, p.x, p.y, e.surface_index, e.force_index)
  mark_hot(data.watch.key[uid], tick)
  return true
end

---------------------------------------------------------------------------
-- Area work, queued and spread: one step reads one strip of a rectangle (or one batch of the purge).
--   {op = "add", uid, x1, y1, x2, y2, y}: watch the buildings of the tower square in the rectangle
--   {op = "prune", s, f, x1, y1, x2, y2, y}: unwatch the buildings no tower covers any more
--   {op = "purge", f, i}: drop the turrets of a force whose shield was switched on from the watch list

-- Steps done in the current tick. Only meaningful within one tick: reset at the first use in a new
-- tick, so it carries no state between ticks (safe outside storage).
local steps_tick, steps_used = -1, 0
local function spend(tick)
  if steps_tick ~= tick then steps_tick, steps_used = tick, 0 end
  if steps_used >= WORK_STEPS then return false end
  steps_used = steps_used + 1
  return true
end

local function read_strip(T, x1, y1, x2, y2)
  local found = T.entity.surface.find_entities_filtered{area = {{x1, y1}, {x2, y2}}, force = T.force}
  local targets = T.targets
  local tx, ty, r, s = T.x, T.y, T.range, T.surface
  for _, e in pairs(found) do
    local uid = e.unit_number
    if uid and uid ~= T.uid then
      local name = e.name
      if not ignored_names[name] and not moving_types[e.type] and not shielded(e, name) then
        local p = e.position
        if abs(p.x - tx) <= r and abs(p.y - ty) <= r then
          local ratio = e.get_health_ratio()
          if ratio and is_repairable(e) then
            watch_add(e, uid, chunk_key(s, p.x, p.y))
            if ratio > 0 and ratio < 1 then targets[uid] = e end
          end
        end
      end
    end
  end
end

local function prune_strip(job, surface, y2)
  local pos = data.watch.pos
  for _, e in pairs(surface.find_entities_filtered{area = {{job.x1, job.y}, {job.x2, y2}}, force = job.f}) do
    local uid = e.unit_number
    if uid and pos[uid] then
      local p = e.position
      if not covered(uid, p.x, p.y, job.s, job.f) then watch_remove(uid) end
    end
  end
end

-- One step of a job; true when the job is finished.
local function step(job)
  local op = job.op
  if op == "add" then
    local T = data.turrets[job.uid]
    if not (T and T.entity.valid) or job.y >= job.y2 then return true end
    local y2 = min(job.y + STRIP, job.y2)
    read_strip(T, job.x1, job.y, job.x2, y2)
    job.y = y2
    if next(T.targets) and not T.active then activate(T) end
    return y2 >= job.y2
  elseif op == "prune" then
    local surface = game.surfaces[job.s]
    if not surface or job.y >= job.y2 then return true end
    local y2 = min(job.y + STRIP, job.y2)
    prune_strip(job, surface, y2)
    job.y = y2
    return y2 >= job.y2
  else -- purge
    local W = data.watch
    local i, f = job.i, job.f
    for _ = 1, PURGE_BATCH do
      if i > W.n then return true end
      local uid = W.list[i]
      local e = W.ent[uid]
      if not e.valid or (e.force_index == f and shielded(e, e.name)) then
        watch_remove(uid) -- the last entry moved to i
      else
        i = i + 1
      end
    end
    job.i = i
    return i > W.n
  end
end

local function run_queue(tick)
  local q = data.queue
  while q.head <= q.tail and spend(tick) do
    local h = q.head
    if step(q[h]) then
      q[h] = nil
      q.head = h + 1
    end
  end
  if q.head > q.tail then q.head, q.tail = 1, 0 end
end

-- Work asked for by an event: done at once while this tick's budget lasts and nothing waits, the rest
-- is queued.
local function work(job)
  local q = data.queue
  if q.head > q.tail then
    local tick = game.tick
    while spend(tick) do
      if step(job) then return end
    end
  end
  local t = q.tail + 1
  q.tail = t
  q[t] = job
end

-- The tower square (r_in < 0) or the ring between +-r_in and the current range.
local function queue_area(T, r_in)
  for _, rect in ipairs(ring(T.x, T.y, r_in, T.range)) do
    local a, b = rect[1], rect[2]
    work({op = "add", uid = T.uid, x1 = a[1], y1 = a[2], x2 = b[1], y2 = b[2], y = a[2]})
  end
end

local function queue_prune(s, f, x, y, r_in, r_out)
  for _, rect in ipairs(ring(x, y, r_in, r_out)) do
    local a, b = rect[1], rect[2]
    work({op = "prune", s = s, f = f, x1 = a[1], y1 = a[2], x2 = b[1], y2 = b[2], y = a[2]})
  end
end

---------------------------------------------------------------------------
-- Towers

local function create_energy(T)
  local entity = T.entity
  local eei = entity.surface.create_entity
  {
    name = ENERGY,
    position = {T.x, T.y + EEI_OFFSET},
    force = entity.force,
    create_build_effect_smoke = false,
  }
  if eei then
    eei.destructible = false
    eei.operable = false
    eei.electric_buffer_size = stats_of(T.force).buffer
  end
  T.eei = eei
  return eei
end

local function add_turret(entity)
  local uid = entity.unit_number
  local existing = data.turrets[uid]
  if existing then return existing end
  local position = entity.position
  local T =
  {
    entity = entity,
    uid = uid,
    surface = entity.surface_index,
    force = entity.force_index,
    x = position.x,
    y = position.y,
    beam_pos = {position.x, position.y - 2.5},
    inventory = entity.get_inventory(chest_inventory),
    targets = {},
    active = false,
  }
  T.range = stats_of(T.force).range
  data.turrets[uid] = T
  data.forces[T.force] = (data.forces[T.force] or 0) + 1
  create_energy(T)
  map_add(T)
  script.register_on_object_destroyed(entity)
  queue_area(T, -1)
  return T
end

local function remove_turret(uid)
  local T = data.turrets[uid]
  if not T then return end
  data.turrets[uid] = nil
  map_remove(T)
  if T.active then deactivate(T) end
  if T.eei and T.eei.valid then T.eei.destroy() end
  set_warning(T, false)
  local n = (data.forces[T.force] or 1) - 1
  data.forces[T.force] = n > 0 and n or nil
  queue_prune(T.surface, T.force, T.x, T.y, -1, T.range)
end

-- One volley: heal up to `beams` valid targets in range.
local function update(T)
  local entity = T.entity
  if not entity.valid then
    remove_turret(T.uid)
    return
  end

  local eei = T.eei
  if not (eei and eei.valid) then
    eei = create_energy(T)
    if not eei then return end
  end

  local S = stats_of(T.force)
  local shot, beams = S.shot, S.beams
  local targets = T.targets
  local x, y, r = T.x, T.y, T.range
  local stack = T.inventory[1]
  local energy = eei.energy
  local surface, force = entity.surface, entity.force
  local found, no_pack, fired = false, false, 0

  for k, e in pairs(targets) do
    local missing
    if e.valid then
      local health = e.health
      if health and health > 0 then
        local m = e.max_health - health
        if m > 0 then
          local p = e.position
          if abs(p.x - x) <= r and abs(p.y - y) <= r then missing = m end
        end
      end
    end

    if not missing then
      targets[k] = nil
    else
      found = true
      if not (stack.valid_for_read and stack.is_repair_tool) then no_pack = true break end
      local speed = pack_speed(stack)
      if speed <= 0 then no_pack = true break end
      local heal = missing < shot and missing or shot
      local cost = heal * ENERGY_PER_HP
      if energy < cost then break end
      energy = energy - cost
      -- One repair pack heals speed * durability HP, the same as repairing by hand.
      stack.drain_durability(heal / speed)
      e.health = e.health + heal
      if heal >= missing then targets[k] = nil end
      surface.create_entity
      {
        name = BEAM,
        position = T.beam_pos,
        source_position = T.beam_pos,
        target = e,
        duration = BEAM_DURATION,
        force = force,
      }
      fired = fired + 1
      if fired >= beams then break end
    end
  end

  if fired > 0 then eei.energy = energy end
  if not found then
    set_warning(T, false)
    deactivate(T)
    return
  end
  set_warning(T, no_pack)
end

local function relocate(T)
  local entity = T.entity
  local ox, oy = T.x, T.y
  map_remove(T)
  local position = entity.position
  T.x, T.y = position.x, position.y
  T.beam_pos = {position.x, position.y - 2.5}
  if T.eei and T.eei.valid then
    T.eei.teleport({T.x, T.y + EEI_OFFSET})
  else
    create_energy(T)
  end
  T.targets = {}
  map_add(T)
  queue_prune(T.surface, T.force, ox, oy, -1, T.range)
  queue_area(T, -1)
end

-- Research changed: apply range and buffer to every tower of the force. A range change reads only the
-- ring between the old and the new square.
local function refresh_force(force)
  local index = force.index
  local S = compute_stats(force)
  data.stats[index] = S
  if not data.forces[index] then return end
  local old
  for _, T in pairs(data.turrets) do
    if T.force == index and T.entity.valid then
      if T.eei and T.eei.valid then T.eei.electric_buffer_size = S.buffer end
      local r = T.range
      if r ~= S.range then
        old = r
        map_remove(T)
        T.range = S.range
        map_add(T)
        if S.range > r then
          queue_area(T, r)
        else
          queue_prune(T.surface, index, T.x, T.y, S.range, r)
        end
      end
    end
  end
  if old then range_changed(index, old, S.range) end
end

local function clear_hover(player_index)
  local h = data.hover[player_index]
  if not h then return end
  for _, o in pairs(h) do
    if o.valid then o.destroy() end
  end
  data.hover[player_index] = nil
end

-- Full rebuild from the entities on the map: init, configuration change, force merge.
function R.rebuild()
  local old = storage.rt
  if old then
    for _, T in pairs(old.turrets or {}) do
      if T.warn and T.warn.valid then T.warn.destroy() end
    end
    for _, h in pairs(old.hover or {}) do
      for _, o in pairs(h) do
        if o.valid then o.destroy() end
      end
    end
  end
  data = new_data()
  storage.rt = data
  for _, force in pairs(game.forces) do
    data.stats[force.index] = compute_stats(force)
  end
  for _, surface in pairs(game.surfaces) do
    for _, eei in pairs(surface.find_entities_filtered{name = ENERGY}) do
      eei.destroy()
    end
  end
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = TURRET}) do
      add_turret(entity)
    end
  end
end

function R.on_load()
  data = storage.rt
end

---------------------------------------------------------------------------
-- Links from the shield

-- The shield of a force was switched on (research) or off: turrets leave the watch list and the
-- tower targets (in batches), or are read again from the tower squares (queued).
function R.shield_force_changed(force_index, on)
  if stale() then return end
  if on then
    for _, T in pairs(data.turrets) do
      if T.force == force_index then
        local targets = T.targets
        for uid, e in pairs(targets) do
          if e.valid and shielded(e, e.name) then targets[uid] = nil end
        end
      end
    end
    work({op = "purge", f = force_index, i = 1})
  else
    for _, T in pairs(data.turrets) do
      if T.force == force_index and T.entity.valid then queue_area(T, -1) end
    end
  end
end

-- A turret switched out of the shield (toggle): repaired by beams again if a tower covers it.
function R.turret_unshielded(entity)
  if stale() or not entity.valid then return end
  local name = entity.name
  if shielded(entity, name) or ignored_names[name] or not is_repairable(entity) then return end
  local uid = entity.unit_number
  local p = entity.position
  local surface_index, force_index = entity.surface_index, entity.force_index
  if not covered(uid, p.x, p.y, surface_index, force_index) then return end
  watch_add(entity, uid, chunk_key(surface_index, p.x, p.y))
  local ratio = entity.get_health_ratio()
  if ratio and ratio > 0 and ratio < 1 then offer(entity, uid, p.x, p.y, surface_index, force_index) end
end

-- A turret given back to the shield (toggle): no longer watched or targeted by beams.
function R.turret_shielded(entity)
  if stale() or not entity.valid or not shielded(entity, entity.name) then return end
  local uid = entity.unit_number
  watch_remove(uid)
  local p = entity.position
  local list = turrets_at(entity.surface_index, p.x, p.y)
  if list then
    for _, T in pairs(list) do T.targets[uid] = nil end
  end
end

-- Number of towers of a force (all forces if nil).
function R.count(force_index)
  if stale() then return 0 end
  if force_index then return data.forces[force_index] or 0 end
  local n = 0
  for _ in pairs(data.turrets) do n = n + 1 end
  return n
end

---------------------------------------------------------------------------
-- Per tick

-- Slow tier: a portion of the whole watch list, a full pass in about SCAN_PERIOD ticks.
local function scan_slow(tick)
  local W = data.watch
  local budget = ceil(W.n / SCAN_PERIOD)
  if budget > SCAN_MAX then budget = SCAN_MAX end
  local list, ent = W.list, W.ent
  local i = W.cursor
  for _ = 1, budget do
    local n = W.n
    if n == 0 then break end
    if i > n then i = 1 end
    local uid = list[i]
    local e = ent[uid]
    if e.valid then
      local ratio = e.get_health_ratio()
      if not (ratio and ratio < 1 and ratio > 0) or found_damaged(e, uid, tick) then
        i = i + 1
      end
    else
      watch_remove(uid) -- the last entry moved to i and is checked next
    end
  end
  W.cursor = i
end

-- Hot tier: the members of every hot chunk at most every HOT_PERIOD ticks, at most HOT_CHUNKS chunks
-- per tick; the list is walked so that every entry is looked at about every HOT_PERIOD ticks.
local function scan_hot(tick)
  local H = data.hot
  local visits = ceil(#H.list / HOT_PERIOD)
  local polls = 0
  local W = data.watch
  local i = H.cursor
  for _ = 1, visits do
    local count = #H.list
    if count == 0 or polls >= HOT_CHUNKS then break end
    if i > count then i = 1 end
    local key = H.list[i]
    if tick > H.ttl[key] then
      hot_remove_at(i) -- the last entry moved to i
    elseif tick < H.due[key] then
      i = i + 1
    else
      polls = polls + 1
      H.due[key] = tick + HOT_PERIOD
      local m = W.members[key]
      if m then
        local gone, damaged
        for uid in pairs(m) do
          local e = W.ent[uid]
          if e.valid then
            local ratio = e.get_health_ratio()
            if ratio and ratio < 1 and ratio > 0 then
              damaged = damaged or {}
              damaged[#damaged + 1] = uid
            end
          else
            gone = gone or {}
            gone[#gone + 1] = uid
          end
        end
        if gone then
          for k = 1, #gone do watch_remove(gone[k]) end
        end
        if damaged then
          for k = 1, #damaged do
            local uid = damaged[k]
            local e = W.ent[uid]
            if e then found_damaged(e, uid, tick) end
          end
        end
      end
      i = i + 1
    end
  end
  H.cursor = i
end

-- One search for vehicles/characters of the tower forces in a covered chunk, clipped to the union of
-- the tower squares in it. Returns true if anything that moves was found (damaged or not).
local function search_moving(c, tick)
  local sm = data.map[c.s]
  local mx = sm and sm[c.cx]
  local list = mx and mx[c.cy]
  if not list then return false end
  local x1, y1, x2, y2
  local forces, seen = {}, {}
  for _, T in pairs(list) do
    local r = T.range
    if not x1 then
      x1, y1, x2, y2 = T.x - r, T.y - r, T.x + r, T.y + r
    else
      x1, y1 = min(x1, T.x - r), min(y1, T.y - r)
      x2, y2 = max(x2, T.x + r), max(y2, T.y + r)
    end
    if not seen[T.force] then
      seen[T.force] = true
      forces[#forces + 1] = T.force
    end
  end
  local cx0, cy0 = c.cx * CHUNK, c.cy * CHUNK
  x1, y1 = max(x1, cx0), max(y1, cy0)
  x2, y2 = min(x2, cx0 + CHUNK), min(y2, cy0 + CHUNK)
  if x1 >= x2 or y1 >= y2 then return false end
  local surface = game.surfaces[c.s]
  if not surface then return false end
  local found = surface.find_entities_filtered{area = {{x1, y1}, {x2, y2}}, force = forces, type = moving_type_list}
  for _, e in pairs(found) do
    local ratio = e.get_health_ratio()
    if ratio and ratio > 0 and ratio < 1 and is_repairable(e) then
      local p = e.position
      offer(e, e.unit_number, p.x, p.y, c.s, e.force_index)
      local key = chunk_key(c.s, p.x, p.y)
      if data.watch.members[key] then mark_hot(key, tick) end
    end
  end
  return found[1] ~= nil
end

-- Every chunk entry is looked at about every MOVING_SWEEP ticks and searched when it is due.
local function sweep_moving(tick)
  local K = data.chunks
  local count = #K.list
  local budget = ceil(count / MOVING_SWEEP)
  local i = K.cursor
  for _ = 1, budget do
    if i > count then i = 1 end
    local c = K.info[K.list[i]]
    if tick >= c.next then
      if search_moving(c, tick) then
        c.period = MOVING_PERIOD
      else
        c.period = min(MOVING_MAX, c.period * 2)
      end
      c.next = tick + c.period
    end
    i = i + 1
  end
  K.cursor = i
end

local function rescan_step()
  local turrets = data.turrets
  local cursor = data.rescan
  if cursor and not turrets[cursor] then cursor = nil end
  local uid, T = next(turrets, cursor)
  if not uid then uid, T = next(turrets) end
  data.rescan = uid
  if T and T.entity.valid then queue_area(T, -1) end
end

---------------------------------------------------------------------------
-- Events (registered by control.lua)

function R.on_built(event)
  if stale() then return end
  local entity = event.entity or event.destination
  if not (entity and entity.valid) then return end
  local name = entity.name
  if name == TURRET then add_turret(entity) end
  local force_index = entity.force_index
  if not data.forces[force_index] then return end
  local p = entity.position
  local surface_index = entity.surface_index
  if not turrets_at(surface_index, p.x, p.y) then return end
  local uid = entity.unit_number
  if not uid or ignored_names[name] or moving_types[entity.type] or shielded(entity, name) then return end
  local ratio = entity.get_health_ratio()
  if not ratio or not is_repairable(entity) then return end
  if covered(uid, p.x, p.y, surface_index, force_index) then
    watch_add(entity, uid, chunk_key(surface_index, p.x, p.y))
    if ratio > 0 and ratio < 1 then offer(entity, uid, p.x, p.y, surface_index, force_index) end
  end
end

function R.on_cloned(event)
  if stale() then return end
  local entity = event.destination
  if not (entity and entity.valid) then return end
  if entity.name == ENERGY then
    entity.destroy() -- the tower clone gets its own
  elseif entity.name == TURRET then
    add_turret(entity)
  end
end

function R.on_object_destroyed(event)
  if stale() then return end
  if event.type == defines.target_type.entity then
    remove_turret(event.useful_id)
  end
end

function R.on_tick(event)
  if stale() then return end
  local tick = event.tick
  local q = data.queue
  if q.head <= q.tail then run_queue(tick) end
  if data.watch.n > 0 then scan_slow(tick) end
  if data.hot.list[1] then scan_hot(tick) end
  if data.chunks.list[1] then sweep_moving(tick) end
  if tick % RESCAN_INTERVAL == 0 and next(data.turrets) then rescan_step() end
  local bucket = data.buckets[tick % INTERVAL]
  if not bucket then return end
  for _, T in pairs(bucket) do
    update(T)
  end
end

function R.on_research(event)
  if stale() then return end
  local research = event.research
  if research and research.valid and research.name:find("^repair%-turret%-") then
    refresh_force(research.force)
  end
end

function R.on_force_event(event)
  if stale() then return end
  local force = event.force
  if force and force.valid then refresh_force(force) end
end

function R.on_selected_entity_changed(event)
  if stale() then return end
  local index = event.player_index
  clear_hover(index)
  local player = game.get_player(index)
  local selected = player and player.selected
  if not (selected and selected.name == TURRET) then return end
  local r = stats_of(selected.force_index).range
  local p = selected.position
  local surface = selected.surface
  local left_top, right_bottom = {p.x - r, p.y - r}, {p.x + r, p.y + r}
  data.hover[index] =
  {
    rendering.draw_rectangle
    {
      color = area_fill, filled = true, left_top = left_top, right_bottom = right_bottom,
      surface = surface, players = {index}, draw_on_ground = true,
    },
    rendering.draw_rectangle
    {
      color = area_border, width = 2, filled = false, left_top = left_top, right_bottom = right_bottom,
      surface = surface, players = {index}, draw_on_ground = true,
    },
  }
end

function R.on_player_removed(event)
  if stale() then return end
  clear_hover(event.player_index)
end

function R.on_surface_deleted(event)
  if stale() then return end
  local s = event.surface_index
  for uid, T in pairs(data.turrets) do
    if T.surface == s then remove_turret(uid) end
  end
  data.map[s] = nil
end

-- A tower moved by a script (Even Pickier Dollies, script_raised_teleported).
function R.on_moved(entity)
  if stale() then return end
  if not (entity and entity.valid and entity.name == TURRET) then return end
  local T = data.turrets[entity.unit_number]
  if T then relocate(T) end
end

-- Event id of Picker Dollies style moves, if such a mod is present.
function R.dolly_event_id()
  local dollies = remote.interfaces["PickerDollies"]
  if dollies and dollies["dolly_moved_entity_id"] then
    return remote.call("PickerDollies", "dolly_moved_entity_id")
  end
  return nil
end

return R
