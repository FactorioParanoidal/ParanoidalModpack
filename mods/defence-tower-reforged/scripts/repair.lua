-- Defence tower: repair (from Repair Turret by Klonan, Paranoidal fork 9.0.6).
-- Every `interval` ticks a tower heals up to `beams` damaged friendly entities in a square of +-range tiles,
-- spending energy from its hidden electric-energy-interface and durability of the repair pack in its own slot.
-- Range, speed and beams come from the force's researched upgrade levels. The same square is the shield
-- zone of the tower (scripts/shield.lua); turrets the shield repairs (shielded()) are left to it.
--
-- Damage is NOT tracked through on_entity_damaged (its cost grows with every hit on the map).
-- Instead every repairable building inside any tower area is kept once in a list, and a fixed small
-- portion of that list is polled each tick. Vehicles and characters are searched per tower area
-- every `moving_period` ticks. Without towers the module does nothing per tick.
local C = require("shared")

local R = {}

local TURRET, ENERGY, BEAM = C.turret, C.energy, C.beam
local INTERVAL = C.interval
local ENERGY_PER_HP = C.energy_per_hp
local EEI_OFFSET = C.eei_offset
local SCAN_PERIOD, SCAN_MIN, SCAN_MAX = C.scan_period, C.scan_min, C.scan_max
local MOVING_PERIOD = C.moving_period
local RESCAN_INTERVAL = C.rescan_interval
local CHUNK = 32
local BEAM_DURATION = 20
local DATA_VERSION = 3

local floor, abs, max, ceil = math.floor, math.abs, math.max, math.ceil
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
-- the towers repairs; range_changed(force_index) is called after the range of a force's towers changed.
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
  map[surface][chunk_x][chunk_y] = {[uid] = T}
  buckets[uid % INTERVAL] = {[uid] = T}        -- active towers only
  mbuckets[uid % MOVING_PERIOD] = {[uid] = T}  -- all towers, for the vehicle/character search
  forces[force_index] = number of towers
  stats[force_index] = {range, shot, beams, buffer}
  hover[player_index] = {fill, border}
  watch = {n, cursor, list = {uid}, pos = {[uid] = index}, ent = {[uid] = entity}}  -- buildings in tower areas
  rescan = uid of the tower last re-read
]]
local data

local function new_data()
  return
  {
    v = DATA_VERSION, turrets = {}, map = {}, buckets = {}, mbuckets = {}, forces = {}, stats = {}, hover = {},
    watch = {n = 0, cursor = 1, list = {}, pos = {}, ent = {}},
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
-- Spatial map of towers by covered chunks

local function chunk_bounds(T)
  local r = T.range
  return floor((T.x - r) / CHUNK), floor((T.x + r) / CHUNK),
         floor((T.y - r) / CHUNK), floor((T.y + r) / CHUNK)
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
      if not list then list = {}; mx[cy] = list end
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
          if not next(list) then mx[cy] = nil end
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

-- Towers whose area may reach the point: {[uid] = T} (T.x, T.y, T.range, T.force); nil if none.
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
-- Watch list (dense array + index, swap-remove)

local function watch_add(entity, uid)
  local W = data.watch
  if W.pos[uid] then return end
  local n = W.n + 1
  W.n = n
  W.list[n] = uid
  W.pos[uid] = n
  W.ent[uid] = entity
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
  W.n = n - 1
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

---------------------------------------------------------------------------
-- Area reads (only on build/research/rescan, never per hit)

local function check_moving(T)
  local x, y, r = T.x, T.y, T.range
  local found = T.entity.surface.find_entities_filtered
  {
    area = {{x - r, y - r}, {x + r, y + r}},
    force = T.force,
    type = moving_type_list,
  }
  local targets = T.targets
  local any = false
  for _, e in pairs(found) do
    local ratio = e.get_health_ratio()
    if ratio and ratio > 0 and ratio < 1 and is_repairable(e) then
      targets[e.unit_number] = e
      any = true
    end
  end
  if any and not T.active then activate(T) end
end

-- Put every repairable building of the tower's area into the watch list; damaged ones become targets.
local function add_area(T)
  local x, y, r = T.x, T.y, T.range
  local found = T.entity.surface.find_entities_filtered
  {
    area = {{x - r, y - r}, {x + r, y + r}},
    force = T.force,
  }
  local targets = T.targets
  for _, e in pairs(found) do
    local uid = e.unit_number
    if uid and uid ~= T.uid then
      local name = e.name
      if not ignored_names[name] and not moving_types[e.type] and not shielded(e, name) then
        local ratio = e.get_health_ratio()
        if ratio and is_repairable(e) then
          watch_add(e, uid)
          if ratio > 0 and ratio < 1 then targets[uid] = e end
        end
      end
    end
  end
  check_moving(T)
  if next(targets) and not T.active then activate(T) end
end

-- Drop watched entities of an old area that no tower covers any more.
local function prune_area(surface_index, force_index, x, y, r)
  local surface = game.surfaces[surface_index]
  if not surface then return end -- entities are invalid then and leave the list on their own
  local pos = data.watch.pos
  for _, e in pairs(surface.find_entities_filtered{area = {{x - r, y - r}, {x + r, y + r}}, force = force_index}) do
    local uid = e.unit_number
    if uid and pos[uid] then
      local p = e.position
      if not covered(uid, p.x, p.y, surface_index, force_index) then watch_remove(uid) end
    end
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
  local mi = uid % MOVING_PERIOD
  local mb = data.mbuckets[mi]
  if not mb then mb = {}; data.mbuckets[mi] = mb end
  mb[uid] = T
  create_energy(T)
  map_add(T)
  script.register_on_object_destroyed(entity)
  add_area(T)
  return T
end

local function remove_turret(uid)
  local T = data.turrets[uid]
  if not T then return end
  data.turrets[uid] = nil
  map_remove(T)
  if T.active then deactivate(T) end
  local mi = uid % MOVING_PERIOD
  local mb = data.mbuckets[mi]
  if mb then
    mb[uid] = nil
    if not next(mb) then data.mbuckets[mi] = nil end
  end
  if T.eei and T.eei.valid then T.eei.destroy() end
  set_warning(T, false)
  local n = (data.forces[T.force] or 1) - 1
  data.forces[T.force] = n > 0 and n or nil
  prune_area(T.surface, T.force, T.x, T.y, T.range)
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
  prune_area(T.surface, T.force, ox, oy, T.range)
  add_area(T)
end

-- Research changed: apply range and buffer to every tower of the force.
local function refresh_force(force)
  local index = force.index
  local S = compute_stats(force)
  data.stats[index] = S
  if not data.forces[index] then return end
  local shrunk = {}
  local moved = false
  for _, T in pairs(data.turrets) do
    if T.force == index and T.entity.valid then
      if T.eei and T.eei.valid then T.eei.electric_buffer_size = S.buffer end
      local old = T.range
      if old ~= S.range then
        moved = true
        map_remove(T)
        T.range = S.range
        map_add(T)
        if S.range > old then
          add_area(T)
        else
          shrunk[#shrunk + 1] = {T, old}
        end
      end
    end
  end
  -- after all towers have their new range
  for _, v in pairs(shrunk) do
    local T = v[1]
    prune_area(T.surface, index, T.x, T.y, v[2])
  end
  if moved then range_changed(index) end
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
-- tower targets, or come back to them.
function R.shield_force_changed(force_index, on)
  if stale() then return end
  if on then
    local W = data.watch
    local leave = {}
    for uid, e in pairs(W.ent) do
      if e.valid and e.force_index == force_index and shielded(e, e.name) then leave[#leave + 1] = uid end
    end
    for i = 1, #leave do watch_remove(leave[i]) end
    for _, T in pairs(data.turrets) do
      if T.force == force_index then
        local targets = T.targets
        for uid, e in pairs(targets) do
          if e.valid and shielded(e, e.name) then targets[uid] = nil end
        end
      end
    end
  else
    for _, T in pairs(data.turrets) do
      if T.force == force_index and T.entity.valid then add_area(T) end
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
  watch_add(entity, uid)
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

-- Poll a portion of the watch list; damaged entities are offered to the towers covering them.
local function scan_watch()
  local W = data.watch
  local n = W.n
  local budget = ceil(n / SCAN_PERIOD)
  if budget < SCAN_MIN then budget = SCAN_MIN elseif budget > SCAN_MAX then budget = SCAN_MAX end
  if budget > n then budget = n end
  local list, ent = W.list, W.ent
  local i = W.cursor
  for _ = 1, budget do
    if i > n then i = 1 end
    local uid = list[i]
    local e = ent[uid]
    if e.valid then
      local ratio = e.get_health_ratio()
      if ratio and ratio < 1 and ratio > 0 then
        local p = e.position
        offer(e, uid, p.x, p.y, e.surface_index, e.force_index)
      end
      i = i + 1
    else
      watch_remove(uid) -- the last entry moves to i and is checked next
      n = n - 1
      if n == 0 then break end
    end
  end
  W.cursor = i
end

local function rescan_step()
  local turrets = data.turrets
  local cursor = data.rescan
  if cursor and not turrets[cursor] then cursor = nil end
  local uid, T = next(turrets, cursor)
  if not uid then uid, T = next(turrets) end
  data.rescan = uid
  if T and T.entity.valid then add_area(T) end
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
    watch_add(entity, uid)
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
  if data.watch.n > 0 then scan_watch() end
  local mb = data.mbuckets[tick % MOVING_PERIOD]
  if mb then
    for _, T in pairs(mb) do
      if T.entity.valid then check_moving(T) end
    end
  end
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
  data.map[event.surface_index] = nil
  for uid, T in pairs(data.turrets) do
    if T.surface == event.surface_index then remove_turret(uid) end
  end
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
