-- Legendary ruins: planning, multi-chunk building, sanctuary protection, discovery and the
-- life cycle (dormant -> solved / ruined / lost). All state lives in storage.legend.
local C = require("legendary.config")
local K = require("legendary.kit")
local P = require("legendary.plan")
local loot = require("legendary.loot")
local kinds = require("legendary.kinds")
local F = require("legendary.feats")

local S = {}

local LIVE = { building = true, dormant = true }        -- sanctuary rules apply
local TICKING = { dormant = true }                       -- kind logic runs while awake

function S.state()
  local L = storage.legend
  if not L then
    L = { next_id = 1, sites = {}, index = {}, spawned = {}, awake = {}, watch = {} }
    storage.legend = L
  end
  return L
end

local function chunk_key(cx, cy) return cx .. ":" .. cy end

-- Index: surface -> chunk -> site id, for the site area plus a margin of whole chunks.
local INDEX_MARGIN = 3

local function index_site(L, site, add)
  local per = L.index[site.surface]
  if not per then
    per = {}
    L.index[site.surface] = per
  end
  local x1 = math.floor((site.x - site.half) / 32) - INDEX_MARGIN
  local y1 = math.floor((site.y - site.half) / 32) - INDEX_MARGIN
  local x2 = math.floor((site.x + site.half - 1) / 32) + INDEX_MARGIN
  local y2 = math.floor((site.y + site.half - 1) / 32) + INDEX_MARGIN
  for cx = x1, x2 do
    for cy = y1, y2 do
      local k = chunk_key(cx, cy)
      if add then per[k] = site.id elseif per[k] == site.id then per[k] = nil end
    end
  end
end

---Site whose area (plus margin) contains the position, or nil.
function S.site_at(surface_index, pos, margin)
  local L = storage.legend
  local per = L and L.index[surface_index]
  if not per then return nil end
  local id = per[chunk_key(math.floor(pos.x / 32), math.floor(pos.y / 32))]
  local site = id and L.sites[id]
  if site and K.inside(site, pos, margin or 0) then return site end
  return nil
end

function S.protected(site)
  return site ~= nil and LIVE[site.state] == true
end

-- Planning -------------------------------------------------------------------------------

local function core_allows()
  if C.setting("current-ruin-set") ~= "paranoidal" then return false end
  local core = remote.interfaces["AbandonedRuins"]
  if core and core.is_spawning_ruins_enabled then
    return remote.call("AbandonedRuins", "is_spawning_ruins_enabled") ~= false
  end
  return true
end

local function choose_kind(L)
  local repeats = C.setting("pd-legendary-repeat") == true
  local candidates, total = {}, 0
  for _, kind in ipairs(kinds.list) do
    if (L.spawned[kind.name] or 0) == 0 then
      candidates[#candidates + 1] = kind
      total = total + (kind.weight or 1)
    end
  end
  if #candidates == 0 and repeats then
    -- every type has appeared: a new cycle
    L.spawned = {}
    return choose_kind(L)
  end
  if #candidates == 0 then return nil end
  local roll = math.random() * total
  for _, kind in ipairs(candidates) do
    roll = roll - (kind.weight or 1)
    if roll <= 0 then return kind end
  end
  return candidates[#candidates]
end

local function far_enough(L, surface, x, y, half)
  local spacing = C.spacing()
  for _, other in pairs(L.sites) do
    if other.surface == surface.index and other.state ~= "lost" then
      local d = math.sqrt((other.x - x) ^ 2 + (other.y - y) ^ 2)
      if d < spacing + half + other.half then return false end
    end
  end
  local spawn = game.forces.player.get_spawn_position(surface)
  local nearest = math.sqrt((x - spawn.x) ^ 2 + (y - spawn.y) ^ 2) - half * 1.42
  return nearest >= C.min_distance(surface)
end

---Plans a site of `kind` around the chunk; returns the site or nil.
function S.plan(surface, chunk, kind, forced)
  local L = S.state()
  local n = math.floor(kind.size / 32)
  local tlx, tly = chunk.x - math.floor(n / 2), chunk.y - math.floor(n / 2)
  local half = n * 16
  local x, y = tlx * 32 + half, tly * 32 + half
  if not forced and not far_enough(L, surface, x, y, half) then return nil end
  local id = L.next_id
  L.next_id = id + 1
  local site = {
    id = id, kind = kind.name, surface = surface.index, x = x, y = y, half = half,
    chunks = { tlx, tly, tlx + n - 1, tly + n - 1 },
    state = "waiting", seed = math.random(1, 2147483646), planned = game.tick,
    data = {}, found = {}, tags = {}, forced = forced or nil,
  }
  L.sites[id] = site
  L.spawned[kind.name] = (L.spawned[kind.name] or 0) + 1
  index_site(L, site, true)
  surface.request_to_generate_chunks({ x = x, y = y }, math.ceil(n / 2) + 1)
  log(string.format("[legendary] planned %s #%d at %d,%d (%dx%d)", kind.name, id, x, y, kind.size, kind.size))
  return site
end

function S.on_chunk_generated(event)
  if not C.enabled() then return end
  local surface = event.surface
  if not (surface and surface.valid and C.SURFACES[surface.name]) then return end
  local chance = C.setting("pd-legendary-chance") or 0
  if chance <= 0 or math.random() >= chance then return end
  if not core_allows() then return end
  local center = { x = event.position.x * 32 + 16, y = event.position.y * 32 + 16 }
  local spawn = game.forces.player.get_spawn_position(surface)
  if K.dist(center, spawn) < C.min_distance(surface) then return end
  local L = S.state()
  local kind = choose_kind(L)
  if not kind then return end
  S.plan(surface, event.position, kind, false)
end

-- Building -------------------------------------------------------------------------------

local function all_generated(surface, site)
  local c = site.chunks
  for cx = c[1], c[3] do
    for cy = c[2], c[4] do
      if not surface.is_chunk_generated({ x = cx, y = cy }) then return false end
    end
  end
  return true
end

local function footprint(name)
  local proto = prototypes.entity[name]
  if not proto then return 1, 1 end
  return math.max(1, proto.tile_width), math.max(1, proto.tile_height)
end

local function player_force(force)
  return force.name == "player" or #force.players > 0
end

-- Journal entries (small/medium/large ruins) that were inside the cleared area.
local function drop_journal(site)
  local pending = storage.pending
  if not pending then return end
  for k, bucket in pairs(pending) do
    for i = #bucket, 1, -1 do
      local ruin = bucket[i]
      if ruin.surface == site.surface and K.inside(site, ruin, 0) then table.remove(bucket, i) end
    end
    if #bucket == 0 then pending[k] = nil end
  end
end

-- Buildings of players (not characters, ghosts or corpses) inside the area of a planned site.
local KEEP_TYPES = { character = true, ["character-corpse"] = true, resource = true }
local function player_buildings(surface, site)
  for _, e in pairs(surface.find_entities_filtered({ area = K.area(site, 0) })) do
    if e.valid and not KEEP_TYPES[e.type] and e.type ~= "entity-ghost" and e.type ~= "tile-ghost"
      and player_force(e.force) then
      return true
    end
  end
  return false
end

local function start_build(site)
  local kind = kinds.by_name[site.kind]
  -- A natural site never covers somebody's outpost: it is given up and may appear elsewhere.
  local surface = K.surface(site)
  if not site.forced and surface and player_buildings(surface, site) then
    log(string.format("[legendary] %s #%d given up: player buildings in the area", site.kind, site.id))
    S.lose(site)
    return
  end
  local plan = P.new(site.half, site.seed, footprint)
  kind.layout(plan, site, K)
  site.build = { phase = "clear", row = -site.half, tiles = plan.tiles, ti = 1, entities = plan.entities, ei = 1 }
  site.state = "building"
end

local function build_step(site)
  local surface = K.surface(site)
  if not surface then
    site.state = "lost"
    return
  end
  local b = site.build
  if b.phase == "clear" then
    local y1 = site.y + b.row
    local y2 = math.min(y1 + C.CLEAR_ROWS, site.y + site.half)
    local area = { { site.x - site.half, y1 }, { site.x + site.half, y2 } }
    for _, e in pairs(surface.find_entities_filtered({ area = area })) do
      if e.valid and not KEEP_TYPES[e.type] and not player_force(e.force) then
        e.destroy({ do_cliff_correction = e.type == "cliff", raise_destroy = true })
      end
    end
    b.row = b.row + C.CLEAR_ROWS
    if b.row >= site.half then
      drop_journal(site)
      b.phase = "tiles"
    end
  elseif b.phase == "tiles" then
    local batch, last = {}, math.min(#b.tiles, b.ti + C.TILE_BUDGET - 1)
    for i = b.ti, last do
      local t = b.tiles[i]
      if prototypes.tile[t[1]] then
        batch[#batch + 1] = { name = t[1], position = { site.x + t[2], site.y + t[3] } }
      end
    end
    if #batch > 0 then surface.set_tiles(batch, true, true, true, false) end
    b.ti = last + 1
    if b.ti > #b.tiles then b.phase = "entities" end
  elseif b.phase == "entities" then
    local last = math.min(#b.entities, b.ei + C.ENTITY_BUDGET - 1)
    for i = b.ei, last do K.create(site, surface, b.entities[i]) end
    b.ei = last + 1
    if b.ei > #b.entities then b.phase = "finish" end
  elseif b.phase == "finish" then
    site.build = nil
    site.state = "dormant"
    local kind = kinds.by_name[site.kind]
    for _, vault in ipairs(K.list(site, "vault")) do
      vault.operable = false
      vault.minable_flag = false
      vault.destructible = false
    end
    if kind.built then kind.built(site, K) end
    log(string.format("[legendary] built %s #%d", site.kind, site.id))
  end
end

local function check_waiting(L)
  for _, site in pairs(L.sites) do
    if site.state == "waiting" then
      local surface = K.surface(site)
      if not surface then
        site.state = "lost"
      elseif all_generated(surface, site) then
        if not site.ready then
          site.ready = game.tick + C.SETTLE_TICKS
        elseif game.tick >= site.ready then
          start_build(site)
        end
      elseif game.tick - site.planned > 36000 then
        -- the map generator did not get there in 10 minutes: ask again
        site.planned = game.tick
        surface.request_to_generate_chunks({ x = site.x, y = site.y }, math.ceil(site.half / 32) + 1)
      end
    end
  end
end

-- Discovery and awake --------------------------------------------------------------------

function S.caption(site)
  return { "pd-legendary-name." .. site.kind }
end

-- Map tag on the site center. Charting is not instant, so a tag that cannot be placed yet waits
-- in site.tag_wait and is retried by the scan.
local function tag_for(site, force, icon)
  local surface = K.surface(site)
  if not surface then return end
  local old = site.tags[force.index]
  if old and old.valid then old.destroy() end
  site.tags[force.index] = nil
  local tag = nil
  if force.is_chunk_charted(surface, { x = math.floor(site.x / 32), y = math.floor(site.y / 32) }) then
    tag = force.add_chart_tag(surface, {
      position = { site.x, site.y }, icon = { type = "virtual", name = icon },
    })
  end
  site.tag_wait = site.tag_wait or {}
  if tag then
    site.tags[force.index] = tag
    site.tag_wait[force.index] = nil
  else
    force.chart(surface, K.area(site, 32))
    site.tag_wait[force.index] = icon
  end
end

local function retry_tags(L)
  for _, site in pairs(L.sites) do
    if site.tag_wait and next(site.tag_wait) then
      for force_index, icon in pairs(site.tag_wait) do
        local force = game.forces[force_index]
        if force then tag_for(site, force, icon) else site.tag_wait[force_index] = nil end
      end
    end
  end
end

local function discover(site, player)
  local force = player.force
  if site.found[force.index] then return end
  site.found[force.index] = game.tick
  local kind = kinds.by_name[site.kind]
  game.print({ "pd-legendary.discovered", player.name, S.caption(site), { "pd-legendary-tier." .. kind.tier } },
    { color = { 1, 0.75, 0.2 } })
  force.print({ "pd-legendary-lore." .. site.kind })
  force.print({ "pd-legendary-hint." .. site.kind }, { color = { 0.6, 0.9, 1 } })
  if C.ferocity().truce then force.print({ "pd-legendary.truce-note" }) end
  K.sound(site, "utility/new_objective", { x = site.x, y = site.y })
  tag_for(site, force, site.state == "dormant" and "signal-lock" or "signal-unlock")
  -- journal: one entry per legendary type
  storage.found = storage.found or {}
  storage.found[force.index] = storage.found[force.index] or {}
  local key = "legendary/" .. site.kind
  storage.found[force.index][key] = (storage.found[force.index][key] or 0) + 1
  F.found(site, player)
end

local function scan(L)
  for _, player in pairs(game.connected_players) do
    local char = player.character
    if char and char.valid and L.index[player.surface_index] then
      local pos = char.position
      local cx, cy = math.floor(pos.x / 32), math.floor(pos.y / 32)
      local per = L.index[player.surface_index]
      local seen = {}
      for dx = -1, 1 do
        for dy = -1, 1 do
          local id = per[chunk_key(cx + dx, cy + dy)]
          if id and not seen[id] then
            seen[id] = true
            local site = L.sites[id]
            if site and (site.state == "dormant" or site.state == "solved") then
              if TICKING[site.state] and K.inside(site, pos, C.AWAKE_MARGIN) then
                L.awake[id] = game.tick + C.AWAKE_TICKS
              end
              if K.inside(site, pos, C.DISCOVERY_MARGIN) then discover(site, player) end
            end
          end
        end
      end
    end
  end
end

-- Flying vehicles (aircraft, spidertrons) pass over walls: the sanctuary throws them out.
local wall_layers
local function flying(vehicle)
  if vehicle.type == "spider-vehicle" then return true end
  if not wall_layers then
    local wall = prototypes.entity["stone-wall"]
    wall_layers = wall and wall.collision_mask.layers or { object = true }
  end
  for layer in pairs(vehicle.prototype.collision_mask.layers) do
    if wall_layers[layer] then return false end
  end
  return true
end

local function push_out(site, p)
  local vehicle = p.vehicle
  if not (vehicle and vehicle.valid and p.inside and flying(vehicle)) then return end
  local rx, ry = p.rx, p.ry
  local margin = site.half + 12
  local target
  if math.abs(rx) > math.abs(ry) then
    target = { x = site.x + (rx >= 0 and margin or -margin), y = vehicle.position.y }
  else
    target = { x = vehicle.position.x, y = site.y + (ry >= 0 and margin or -margin) }
  end
  vehicle.teleport(target)
  p.player.print({ "pd-legendary.updraft" }, { color = { 1, 0.5, 0.3 } })
  F.player(p.player, "updraft")
end

local function tick_site(L, site)
  local kind = kinds.by_name[site.kind]
  local ctx = { tick = game.tick, players = K.players(site), surface = K.surface(site) }
  if not ctx.surface then return end
  for _, p in ipairs(ctx.players) do push_out(site, p) end
  if kind.tick then kind.tick(site, ctx, K) end
end

-- Outcome --------------------------------------------------------------------------------

function S.solve(site, player)
  if site.state ~= "dormant" then return end
  local kind = kinds.by_name[site.kind]
  site.state = "solved"
  site.solved = game.tick
  F.solved(site, player)
  storage.legend.awake[site.id] = nil
  for _, vault in ipairs(K.list(site, "vault")) do
    loot.fill(site, kind, vault)
    vault.operable = true
  end
  K.clear_renders(site)
  if kind.solved then kind.solved(site, K) end
  for _, unit in ipairs(K.list(site, "guardian")) do unit.die() end
  local who = player and player.name or { "pd-legendary.someone" }
  game.print({ "pd-legendary.solved", who, S.caption(site) }, { color = { 0.4, 1, 0.4 } })
  K.sound(site, "utility/research_completed", { x = site.x, y = site.y })
  for force_index in pairs(site.found) do
    local force = game.forces[force_index]
    if force then tag_for(site, force, "signal-unlock") end
  end
end

function S.ruin(site, reason)
  if site.state ~= "dormant" then return end
  local kind = kinds.by_name[site.kind]
  site.state = "ruined"
  storage.legend.awake[site.id] = nil
  F.ruined(site)
  for _, vault in ipairs(K.list(site, "vault")) do vault.destroy() end
  K.clear_renders(site)
  if kind.ruined then kind.ruined(site, K) end
  game.print({ "pd-legendary.ruined", S.caption(site), reason or { "pd-legendary.reason-default" } },
    { color = { 1, 0.4, 0.3 } })
  for force_index in pairs(site.found) do
    local force = game.forces[force_index]
    if force then tag_for(site, force, "signal-skull") end
  end
end

function S.lose(site)
  local L = S.state()
  -- a site that never stood may appear again elsewhere
  if (site.state == "waiting" or site.state == "building") and (L.spawned[site.kind] or 0) > 0 then
    L.spawned[site.kind] = L.spawned[site.kind] - 1
  end
  site.state = "lost"
  site.build = nil
  L.awake[site.id] = nil
  K.clear_renders(site)
  for _, tag in pairs(site.tags or {}) do
    if tag.valid then tag.destroy() end
  end
  index_site(L, site, false)
end

-- Event handlers -------------------------------------------------------------------------

function S.on_tick(event)
  local L = storage.legend
  if not L then return end
  local tick = event.tick
  for _, site in pairs(L.sites) do
    if site.state == "building" then build_step(site) end
  end
  K.process_relevers(L, tick)
  if tick % C.WAIT_INTERVAL == 0 then check_waiting(L) end
  if tick % C.SCAN_INTERVAL == 0 then
    scan(L)
    retry_tags(L)
  end
  if tick % C.TICK_INTERVAL == 0 then
    for id, until_tick in pairs(L.awake) do
      local site = L.sites[id]
      if not (site and TICKING[site.state]) then
        L.awake[id] = nil
      elseif tick > until_tick then
        L.awake[id] = nil
        local kind = kinds.by_name[site.kind]
        if kind.sleep then kind.sleep(site, K) end
      else
        tick_site(L, site)
      end
    end
  end
end

-- Building inside a sanctuary is undone. Ghosts are removed so robots never come.
local function allowed(site, entity)
  local kind = kinds.by_name[site.kind]
  if not kind.allow_build then return false end
  local name, type = entity.name, entity.type
  if type == "entity-ghost" then
    name, type = entity.ghost_name, entity.ghost_type
  end
  return kind.allow_build(name, type) == true
end

function S.on_built(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local site = S.site_at(entity.surface_index, entity.position, 0)
  if not S.protected(site) or allowed(site, entity) then return end
  local player = event.player_index and game.get_player(event.player_index)
  if entity.type == "entity-ghost" or entity.type == "tile-ghost" then
    entity.destroy()
  elseif player and player.valid then
    if not player.mine_entity(entity, true) and entity.valid then entity.destroy() end
  else
    entity.order_deconstruction(entity.force)
  end
  if player and player.valid then
    player.create_local_flying_text({ text = { "pd-legendary.no-build" }, position = event.entity.valid and entity.position or player.position, color = { 1, 0.4, 0.3 } })
    F.player(player, "refused-build")
  end
end

function S.on_built_tile(event)
  local surface = game.get_surface(event.surface_index)
  if not surface or not storage.legend or not storage.legend.index[event.surface_index] then return end
  local revert = {}
  for _, t in pairs(event.tiles) do
    local pos = { x = t.position.x + 0.5, y = t.position.y + 0.5 }
    local site = S.site_at(event.surface_index, pos, 0)
    if S.protected(site) then
      revert[#revert + 1] = { name = t.old_tile.name, position = t.position }
    elseif site and site.state ~= "lost" then
      -- after the victory players may pave the site; their own tiles can be taken up again
      site.player_tiles = site.player_tiles or {}
      site.player_tiles[t.position.x .. "," .. t.position.y] = true
    end
  end
  if #revert == 0 then return end
  surface.set_tiles(revert, true, true, true, false)
  local player = event.player_index and game.get_player(event.player_index)
  if player and event.item then
    player.insert({ name = event.item.name, count = #revert, quality = event.quality and event.quality.name or nil })
    player.create_local_flying_text({ text = { "pd-legendary.no-build" }, position = player.position, color = { 1, 0.4, 0.3 } })
  elseif event.robot and event.robot.valid and event.item then
    surface.spill_item_stack({ position = event.robot.position, stack = { name = event.item.name, count = #revert } })
  end
end

-- The floor of a legendary ruin is part of it: its tiles cannot be taken up (a labyrinth alone is
-- 16 000 concrete). Tiles laid by players after the victory can be taken up again.
local function tile_products(tile)
  local out = {}
  local props = tile and tile.mineable_properties
  for _, p in pairs(props and props.products or {}) do
    if p.type == "item" and p.name then
      out[#out + 1] = { name = p.name, count = p.amount or p.amount_max or 1 }
    end
  end
  return out
end

function S.on_mined_tile(event)
  local L = storage.legend
  if not (L and L.index[event.surface_index]) then return end
  local surface = game.get_surface(event.surface_index)
  if not surface then return end
  local revert, taken = {}, {}
  for _, t in pairs(event.tiles) do
    local pos = { x = t.position.x + 0.5, y = t.position.y + 0.5 }
    local site = S.site_at(event.surface_index, pos, 0)
    if site and site.state ~= "lost" and site.state ~= "waiting" then
      local key = t.position.x .. "," .. t.position.y
      if site.player_tiles and site.player_tiles[key] then
        site.player_tiles[key] = nil
      else
        revert[#revert + 1] = { name = t.old_tile.name, position = t.position }
        for _, p in ipairs(tile_products(t.old_tile)) do taken[p.name] = (taken[p.name] or 0) + p.count end
      end
    end
  end
  if #revert == 0 then return end
  surface.set_tiles(revert, true, false, true, false)
  local player = event.player_index and game.get_player(event.player_index)
  local inventory
  if player and player.valid then
    inventory = player.get_main_inventory()
    player.create_local_flying_text({ text = { "pd-legendary.no-mine-tiles" }, position = player.position, color = { 1, 0.4, 0.3 } })
    F.player(player, "floor")
  elseif event.robot and event.robot.valid then
    inventory = event.robot.get_inventory(defines.inventory.robot_cargo)
  end
  if inventory then
    for name, count in pairs(taken) do
      if prototypes.item[name] then inventory.remove({ name = name, count = count }) end
    end
  end
end

-- Levers are mined by hand; robots never get them.
function S.on_marked_for_deconstruction(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == "pd-legend-lever" then
    entity.cancel_deconstruction(entity.force)
  end
end

function S.on_mined(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.name == "pd-legend-lever") then return end
  local site = S.site_at(entity.surface_index, entity.position, 0)
  if not (site and site.state == "dormant") then return end
  local kind = kinds.by_name[site.kind]
  local key
  for k, e in pairs(site.ents or {}) do
    if e.valid and e == entity then key = k break end
  end
  local player = event.player_index and game.get_player(event.player_index)
  if key and kind.lever then kind.lever(site, key, player, entity, K) end
end

---Register an entity of a site: kind.destroyed(site, tag, unit_number) runs when it is gone.
function S.watch(site, entity, tag)
  local L = S.state()
  if not (entity and entity.valid) then return end
  local reg = script.register_on_object_destroyed(entity)
  L.watch[reg] = { site = site.id, tag = tag }
end

function S.on_object_destroyed(event)
  local L = storage.legend
  local w = L and L.watch[event.registration_number]
  if not w then return end
  L.watch[event.registration_number] = nil
  local site = L.sites[w.site]
  if not (site and site.state == "dormant") then return end
  local kind = kinds.by_name[site.kind]
  if kind.destroyed then kind.destroyed(site, w.tag, event.useful_id, K) end
end

function S.on_player_changed_position(event)
  local L = storage.legend
  if not L then return end
  local player = game.get_player(event.player_index)
  if not (player and player.character and L.index[player.surface_index]) then return end
  local pos = player.character.position
  local site = S.site_at(player.surface_index, pos, 2)
  if not (site and site.state == "dormant") then return end
  local kind = kinds.by_name[site.kind]
  if kind.step then
    kind.step(site, {
      player = player, char = player.character, pos = pos, rx = pos.x - site.x, ry = pos.y - site.y,
      inside = K.inside(site, pos, 0), vehicle = player.vehicle,
    }, K)
  end
end

function S.on_chunk_deleted(event)
  local L = storage.legend
  if not L then return end
  for _, site in pairs(L.sites) do
    if site.surface == event.surface_index and site.state ~= "lost" then
      for _, pos in pairs(event.positions) do
        local c = site.chunks
        if pos.x >= c[1] and pos.x <= c[3] and pos.y >= c[2] and pos.y <= c[4] then
          S.lose(site)
          break
        end
      end
    end
  end
end

function S.on_surface_removed(surface_index)
  local L = storage.legend
  if not L then return end
  for id, site in pairs(L.sites) do
    if site.surface == surface_index then
      L.sites[id] = nil
      L.awake[id] = nil
    end
  end
  L.index[surface_index] = nil
end

-- Forces ---------------------------------------------------------------------------------

function S.setup_force()
  local legend = game.forces[C.FORCE] or game.create_force(C.FORCE)
  local truce = C.ferocity().truce
  for _, force in pairs(game.forces) do
    if force ~= legend then
      if force.ai_controllable or force.name == C.RUINS_FORCE or force.name == "neutral" then
        force.set_friend(legend, true)
        legend.set_friend(force, true)
      else
        force.set_friend(legend, false)
        legend.set_friend(force, false)
        force.set_cease_fire(legend, truce)
        legend.set_cease_fire(force, truce)
      end
    end
  end
  return legend
end

-- Statistics and debugging ---------------------------------------------------------------

function S.found_count(found_force)
  local n = 0
  for key in pairs(found_force or {}) do
    if key:sub(1, 10) == "legendary/" then n = n + 1 end
  end
  return n
end

---Places a legendary site of `name` around the chunk at `position` (for admins and tests).
function S.force_spawn(surface, position, name)
  local kind = kinds.by_name[name]
  if not kind then return nil end
  return S.plan(surface, { x = math.floor(position.x / 32), y = math.floor(position.y / 32) }, kind, true)
end

return S
