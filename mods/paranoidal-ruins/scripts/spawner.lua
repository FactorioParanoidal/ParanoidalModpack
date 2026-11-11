-- Random ruins in new chunks: chance per chunk, queue, spawning, no early repeats, ruins force and
-- excluded surfaces. Rewrite of the core of "Abandoned Ruins - Updated" 1.5.7 (roland77, Keysivi,
-- Gangsir, Bilka; MIT) with the Paranoidal fixes it had, for the one ruin set of this mod.
local util = require("__core__/lualib/util")
local expressions = require("scripts.expressions")
local infected_ship = require("scripts.infected-ship")

local M = {}

M.SET_NAME = "paranoidal"
M.ENEMY_FORCE = "AbandonedRuins:enemy"
M.SIZES = { "small", "medium", "large" }
M.HALF = { small = 4, medium = 8, large = 16 }
local DISTANCE_FACTOR = { small = 1, medium = 2.5, large = 5 }
local NONE = "__none__"

-- Internal or hidden surfaces: a surface whose name contains one of these keys gets no ruins.
-- Other mods add their own through the remote "exclude_surface".
local DEFAULT_EXCLUDED = {
  ["beltlayer"] = true,
  ["pipelayer"] = true,
  ["Factory floor"] = true, -- factorissimo2
  ["factory-floor"] = true, -- factorissimo3
  ["NiceFill"] = true,
  ["aai-signals"] = true,
}

---Ruins per size of the current set, built by control.lua (not saved, the same on every load).
---@type table<string, table[]>
M.set = { small = {}, medium = {}, large = {} }

---Called after a ruin has spawned, with the data of the "ruin spawned" event (journal).
---@type fun(data: table)?
M.on_spawned = nil

M.force_changed_event = script.generate_event_name()
-- Data: surface, center, half_size, size, ruin_set, ruin_name.
M.ruin_spawned_event = script.generate_event_name()

-- Settings cache (map settings: identical for every player, refreshed when they change) ---------

local cfg = {}
local thresholds = {}

function M.read_settings()
  local g = settings.global
  cfg.enabled = g["current-ruin-set"].value ~= NONE
  cfg.hostile = g["ruins-enemy-not-cease-fire"].value
  cfg.avoid_repeats = g["ruins-avoid-repeats"].value
  cfg.min_distance = g["ruins-min-distance-from-spawn"].value
  cfg.distance_matters = g["ruins-ignore-distance"].value == false
  cfg.interval = g["ruins-spawn-tick-seconds"].value

  -- A chunk gets at most one ruin: cumulative thresholds of one roll, scaled down when the sum
  -- of the three chances exceeds 1.
  local chances, sum = {}, 0
  for _, size in ipairs(M.SIZES) do
    chances[size] = g["ruins-" .. size .. "-ruin-chance"].value
    sum = sum + chances[size]
  end
  local scale = sum > 1 and 1 / sum or 1
  local acc = 0
  for _, size in ipairs(M.SIZES) do
    acc = acc + chances[size] * scale
    thresholds[size] = acc
  end
end

-- Ruins force -------------------------------------------------------------------------------

---Biters are friends of the ruins force; cease-fire with every other force follows the setting.
function M.apply_diplomacy()
  local enemy = M.enemy_force()
  local cease_fire = not cfg.hostile
  for _, force in pairs(game.forces) do
    if force ~= enemy then
      if force.ai_controllable then
        force.set_friend(enemy, true)
        enemy.set_friend(force, true)
      end
      force.set_cease_fire(enemy, cease_fire)
      enemy.set_cease_fire(force, cease_fire)
    end
  end
end

---@return LuaForce
function M.enemy_force()
  local force = storage.enemy_force
  if force and force.valid then return force end
  force = game.forces[M.ENEMY_FORCE]
  storage.enemy_force = force or game.create_force(M.ENEMY_FORCE)
  if not force then M.apply_diplomacy() end
  return storage.enemy_force
end

-- Surfaces ----------------------------------------------------------------------------------

function M.init_storage()
  storage.excluded = storage.excluded or util.table.deepcopy(DEFAULT_EXCLUDED)
  storage.queue = storage.queue or {}
  storage.bags = storage.bags or {}
end

---@param surface LuaSurface
---@return boolean
function M.surface_allowed(surface)
  if not (surface and surface.valid) or surface.generate_with_lab_tiles then return false end
  local name = surface.name
  for key in pairs(storage.excluded or DEFAULT_EXCLUDED) do
    if name:find(key, 1, true) then return false end
  end
  return true
end

---@param name string
function M.exclude_surface(name)
  if type(name) ~= "string" or name == "" then error("exclude_surface: surface name expected") end
  local surface = game.surfaces[name]
  if surface and surface.planet then
    error("Surface '" .. name .. "' is a planet surface: exclude_surface is for internal or hidden surfaces only")
  end
  M.init_storage()
  storage.excluded[name] = true
end

---@param name string
function M.reinclude_surface(name)
  if type(name) ~= "string" or name == "" then error("reinclude_surface: surface name expected") end
  if storage.excluded then storage.excluded[name] = nil end
end

-- Spawning ----------------------------------------------------------------------------------

local function area_of(half, center)
  return { { center.x - half, center.y - half }, { center.x + half, center.y + half } }
end

local function insert_fluids(entity, fluids, vars)
  for name, amount_expression in pairs(fluids) do
    local amount = expressions.number(amount_expression, vars)
    if amount > 0 and prototypes.fluid[name] and entity.valid then
      entity.insert_fluid({ name = name, amount = amount })
    end
  end
end

local function insert_items(entity, items, vars)
  local plain = {}
  for name, count_expression in pairs(items) do
    if not prototypes.item[name] then
      log("[paranoidal-ruins] item '" .. name .. "' does not exist - skipped")
    elseif type(count_expression) == "table" and count_expression.count ~= nil then
      -- {count = <number-expression>, quality = "<quality>"}; an unknown quality gives normal
      local count = expressions.number(count_expression.count, vars)
      local quality = count_expression.quality
      if quality ~= nil and not prototypes.quality[quality] then quality = nil end
      if count > 0 and entity.valid then entity.insert({ name = name, count = count, quality = quality }) end
    else
      local count = expressions.number(count_expression, vars)
      if count > 0 then plain[name] = count end
    end
  end
  if next(plain) then util.insert_safe(entity, plain) end
end

local function spawn_entity(expression, offset, center, surface, opts, vars)
  local name = expressions.entity(expression, vars)
  -- Explicit template fallback only; keep the original when its prototype is available.
  if not prototypes.entity[name] and type(opts.fallback) == "string" and prototypes.entity[opts.fallback] then
    name = opts.fallback
  end
  if not prototypes.entity[name] then
    log("[paranoidal-ruins] entity '" .. name .. "' does not exist - skipped")
    return
  end
  local recipe = opts.recipe
  if type(recipe) ~= "string" or not prototypes.recipe[recipe] then recipe = nil end
  local quality = opts.quality
  if type(quality) ~= "string" or not prototypes.quality[quality] then quality = nil end

  local entity = surface.create_entity({
    name = name,
    position = { center.x + offset.x, center.y + offset.y },
    direction = defines.direction[opts.dir] or defines.direction.north,
    -- hostile ruin buildings belong to the ruins force; the cease-fire setting controls it
    force = (opts.force or "neutral") == "neutral" and "neutral" or M.enemy_force(),
    raise_built = true,
    create_build_effect_smoke = false,
    recipe = recipe,
    quality = quality,
  })
  if not (entity and entity.valid) then return end

  if entity.name == infected_ship.NAME then infected_ship.sync_evolution(surface) end

  if opts.dmg then
    local amount = expressions.number(opts.dmg.dmg, vars)
    if amount > 0 then entity.damage(amount, opts.dmg.force or "neutral", opts.dmg.type or "physical") end
  end
  if type(opts.dead) == "number" and opts.dead > 0 and entity.valid and math.random() <= opts.dead then entity.die() end
  if not entity.valid then return end
  if opts.fluids then insert_fluids(entity, opts.fluids, vars) end
  if opts.items and entity.valid then insert_items(entity, opts.items, vars) end
end

local function spawn_tiles(ruin_tiles, center, surface)
  local tiles = {}
  for _, spec in pairs(ruin_tiles) do
    if prototypes.tile[spec[1]] then
      tiles[#tiles + 1] = { name = spec[1], position = { center.x + spec[2].x, center.y + spec[2].y } }
    else
      log("[paranoidal-ruins] tile '" .. spec[1] .. "' does not exist - skipped")
    end
  end
  surface.set_tiles(tiles, true, true, true, true)
end

---@return boolean whether the area is free of water and impassable tiles (and was cleared)
local function clear_area(half, center, surface)
  local area = area_of(half, center)
  if surface.count_tiles_filtered({ area = area, limit = 1, collision_mask = { item = true, object = true, water_tile = true } }) == 1 then
    return false
  end
  local tree_chance = half / 14
  for _, entity in pairs(surface.find_entities_filtered({ area = area, type = "resource", invert = true })) do
    -- an earlier destroy (cliff correction) may have removed it already
    if entity.valid and (entity.type ~= "tree" or math.random() < tree_chance) then
      entity.destroy({ do_cliff_correction = true, raise_destroy = true })
    end
  end
  return true
end

---Clears the area and builds the ruin. Returns false when the area holds water or impassable tiles.
---@return boolean
local function build(ruin, half, center, surface)
  if not clear_area(half, center, surface) then return false end
  local vars = (ruin.variables and next(ruin.variables)) and expressions.variables(ruin.variables) or {}
  for _, info in pairs(ruin.entities or {}) do
    spawn_entity(info[1], info[2], center, surface, info[3] or {}, vars)
  end
  if ruin.tiles and next(ruin.tiles) then spawn_tiles(ruin.tiles, center, surface) end
  for _, corpse in pairs(surface.find_entities_filtered({ area = area_of(half, center), type = { "corpse", "rail-remnants" } })) do
    corpse.corpse_expires = false
  end
  return true
end

local function ruin_name(ruin)
  return (type(ruin.name) == "string" and ruin.name ~= "") and ruin.name or "unknown"
end

local function spawned(ruin, size, center, surface)
  local data = {
    surface = surface,
    center = { x = center.x, y = center.y },
    half_size = M.HALF[size],
    size = size,
    ruin_set = M.SET_NAME,
    ruin_name = ruin_name(ruin),
  }
  if M.on_spawned then M.on_spawned(data) end
  script.raise_event(M.ruin_spawned_event, data)
end

-- Opt-in only: all legacy templates keep their previous distance behavior.
local function safe_here(ruin, surface, center)
  local distance = ruin.safe_distance
  if type(distance) ~= "number" then return true end
  local function near(pos)
    return (center.x - pos.x)^2 + (center.y - pos.y)^2 < distance^2
  end
  if near({x = 0, y = 0}) then return false end
  for _, force in pairs(game.forces) do
    if not force.ai_controllable and force.name ~= "neutral" and near(force.get_spawn_position(surface)) then
      return false
    end
  end
  return true
end

local function allowed_here(ruin, surface, center)
  if not safe_here(ruin, surface, center) then return false end
  if ruin.spawn_on_surfaces ~= nil and not ruin.spawn_on_surfaces[surface.name] then return false end
  if ruin.no_spawning ~= nil and ruin.no_spawning[surface.name] then return false end
  if cfg.distance_matters and type(ruin.min_distance) == "number" then
    if math.sqrt(center.x * center.x + center.y * center.y) < ruin.min_distance then return false end
  end
  return true
end

local function weight(ruin)
  return (type(ruin.weight) == "number" and ruin.weight > 0) and ruin.weight or 1
end

local function pick_weighted(candidates)
  local total = 0
  for _, ruin in ipairs(candidates) do total = total + weight(ruin) end
  local roll = math.random() * total
  for _, ruin in ipairs(candidates) do
    roll = roll - weight(ruin)
    if roll <= 0 then return ruin end
  end
  return candidates[#candidates]
end

local function appearance(ruin)
  if type(ruin.spawn_chance) == "number" and math.random() >= ruin.spawn_chance then return nil end
  return ruin
end

---Weighted choice; with "avoid repeats" only among the ruins of the size not used in this cycle.
local function choose(size, surface, center)
  local allowed = {}
  for _, ruin in ipairs(M.set[size] or {}) do
    if allowed_here(ruin, surface, center) then allowed[#allowed + 1] = ruin end
  end
  if #allowed == 0 then return nil end
  if not cfg.avoid_repeats then return appearance(pick_weighted(allowed)) end

  local bag = storage.bags[size]
  if not bag then
    bag = { used = {}, cycle = 1 }
    storage.bags[size] = bag
  end
  local fresh = {}
  for _, ruin in ipairs(allowed) do
    if not bag.used[ruin_name(ruin)] then fresh[#fresh + 1] = ruin end
  end
  if #fresh == 0 then
    -- everything allowed here was already used: a new cycle
    bag.used = {}
    bag.cycle = bag.cycle + 1
    fresh = allowed
  end
  local ruin = pick_weighted(fresh)
  bag.used[ruin_name(ruin)] = true
  return appearance(ruin)
end

-- Queue: ruins of new chunks are built at the next multiple of the spawn interval (the BnL debris
-- trail of zzzparanoidal-start-bnl relies on this timing). The handler is registered only while
-- the queue holds ruins.

local on_spawn_tick

local function sync_tick()
  script.on_nth_tick(cfg.interval, (storage.queue and storage.queue[1]) and on_spawn_tick or nil)
end
M.sync_tick = sync_tick

on_spawn_tick = function()
  local queue = storage.queue
  storage.queue = {}
  if cfg.enabled then
    for _, item in ipairs(queue) do
      local surface = item.surface
      if surface.valid then
        local ruin = choose(item.size, surface, item.center)
        if ruin and build(ruin, M.HALF[item.size], item.center, surface) then
          spawned(ruin, item.size, item.center, surface)
        end
      end
    end
  end
  sync_tick()
end

---A new spawn interval: move the handler.
function M.set_interval(old_interval)
  if old_interval ~= cfg.interval then script.on_nth_tick(old_interval, nil) end
  sync_tick()
end

function M.interval() return cfg.interval end

local function queue_ruin(size, center, surface)
  local d = cfg.min_distance
  if cfg.distance_matters then d = d * DISTANCE_FACTOR[size] end
  if math.abs(center.x) < d and math.abs(center.y) < d then return end
  -- random variance so ruins are not always chunk aligned; even offsets keep a ruin on the 2x2
  -- rail grid, so its rails stay connected
  local variance = 12 - M.HALF[size] * 0.75
  if variance > 0 then
    local steps = math.floor(variance / 2)
    center.x = center.x + 2 * math.random(-steps, steps)
    center.y = center.y + 2 * math.random(-steps, steps)
  end
  local queue = storage.queue
  queue[#queue + 1] = { size = size, center = center, surface = surface }
  if #queue == 1 then sync_tick() end
end

---@param event EventData.on_chunk_generated
---@param deleted_before fun(): boolean was this chunk deleted with Delete-Chunk-Tool-reforged?
function M.on_chunk_generated(event, deleted_before)
  if not cfg.enabled then return end
  local roll = math.random()
  for _, size in ipairs(M.SIZES) do
    if roll < thresholds[size] then
      -- a deleted chunk generated again gets no new ruin (no loot from deleting chunks)
      if M.surface_allowed(event.surface) and not deleted_before() then
        queue_ruin(size, { x = event.position.x * 32 + 16, y = event.position.y * 32 + 16 }, event.surface)
      end
      return
    end
  end
end

---Builds the given ruin of the set at once (old mines for RSO Reforged). Respects the ruin set
---setting, excluded surfaces and the ruin's own surface list; raises the "ruin spawned" event.
---@return boolean
function M.spawn_now(ruin, size, center, surface)
  if not (cfg.enabled and M.HALF[size] and M.surface_allowed(surface)) then return false end
  if not safe_here(ruin, surface, center) then return false end
  if ruin.spawn_on_surfaces ~= nil and not ruin.spawn_on_surfaces[surface.name] then return false end
  if not build(ruin, M.HALF[size], center, surface) then return false end
  spawned(ruin, size, center, surface)
  return true
end

-- Claim tool --------------------------------------------------------------------------------

---@param event EventData.on_player_selected_area|EventData.on_player_alt_selected_area
function M.on_selected_area(event)
  if event.item ~= "ruins-claim-tool" then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local neutral, claimant = game.forces.neutral, player.force
  for _, entity in pairs(event.entities) do
    if entity.valid and entity.force == neutral then
      entity.force = claimant
      if entity.valid then script.raise_event(M.force_changed_event, { entity = entity, force = neutral }) end
    end
  end
  if event.name == defines.events.on_player_alt_selected_area then
    for _, remnant in pairs(event.surface.find_entities_filtered({ area = event.area, type = { "corpse", "rail-remnants" } })) do
      remnant.destroy({ raise_destroy = true })
    end
  end
end

return M
