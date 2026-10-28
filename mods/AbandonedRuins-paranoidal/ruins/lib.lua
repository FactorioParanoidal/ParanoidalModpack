-- Ruin builder for the "paranoidal" ruin set.
--
-- Ruin sets are rebuilt in on_load, so everything here must be deterministic:
-- math.random is never used. Layout randomness comes from a small PRNG seeded by
-- the ruin name; per-spawn randomness uses the core's number/entity expressions.
-- The result of build() is plain data (no functions): it goes through remote.call.

local lib = {}

lib.HALF = { small = 4, medium = 8, large = 16 }

-- Footprints (width, height) of entities used with put()/try_put(); default 1x1.
local SIZES = {
  ["wooden-chest"] = { 1, 1 }, ["iron-chest"] = { 1, 1 }, ["steel-chest"] = { 1, 1 },
  ["bob-brass-chest"] = { 1, 1 }, ["mini-steel-chest"] = { 1, 1 },
  ["bi-wooden-chest-large"] = { 2, 2 }, ["bi-wooden-chest-huge"] = { 3, 3 },
  ["burner-assembling-machine"] = { 3, 3 }, ["assembling-machine-1"] = { 3, 3 },
  ["stone-furnace"] = { 2, 2 }, ["angels-burner-ore-crusher"] = { 3, 3 }, ["angels-ore-crusher"] = { 3, 3 },
  ["bi-bio-farm"] = { 9, 9 }, ["bob-mining-drill-1"] = { 3, 3 }, ["burner-mining-drill"] = { 2, 2 },
  ["electric-mining-drill"] = { 3, 3 }, ["bob-area-mining-drill-1"] = { 3, 3 },
  ["steam-engine"] = { 3, 5 }, ["boiler"] = { 3, 2 }, ["bob-stone-mixing-furnace"] = { 2, 2 },
  ["angels-blast-furnace"] = { 5, 5 }, ["bi-cokery"] = { 3, 3 },
  ["angels-flare-stack"] = { 2, 2 }, ["angels-clarifier"] = { 5, 5 }, ["angels-washing-plant"] = { 5, 5 },
  ["angels-algae-farm"] = { 7, 7 }, ["angels-composter"] = { 3, 3 }, ["bob-electronics-machine-1"] = { 2, 2 },
  ["big-lab"] = { 15, 15 }, ["burner-lab"] = { 3, 3 }, ["lab"] = { 3, 3 },
  ["burner-turbine"] = { 4, 4 }, ["bob-burner-generator"] = { 3, 3 }, ["texugo-wind-turbine"] = { 3, 2 },
  ["recycler-1"] = { 2, 4 }, ["ic-refine-workshop"] = { 3, 3 }, ["ic-control-post"] = { 3, 3 },
  ["aai-big-ship-wreck-1"] = { 4, 3 }, ["aai-big-ship-wreck-2"] = { 3, 3 }, ["aai-big-ship-wreck-3"] = { 2, 2 },
  ["aai-medium-ship-wreck-1"] = { 1, 1 }, ["aai-medium-ship-wreck-2"] = { 1, 1 }, ["aai-small-ship-wreck"] = { 1, 1 },
  ["deadlock-copper-lamp"] = { 2, 2 }, ["deadlock-floor-lamp"] = { 2, 2 }, ["deadlock-large-lamp"] = { 2, 2 },
  ["gun-turret"] = { 2, 2 }, ["bob-gun-turret-2"] = { 2, 2 }, ["bi-dart-turret"] = { 1, 1 },
  ["small-worm-turret"] = { 2, 2 }, ["medium-worm-turret"] = { 2, 2 }, ["big-worm-turret"] = { 2, 2 },
  ["flamethrower-turret"] = { 2, 3 },
  ["angels-electrolyser"] = { 5, 5 }, ["angels-casting-machine"] = { 3, 3 }, ["angels-induction-furnace"] = { 5, 5 },
  ["chemical-plant"] = { 3, 3 }, ["angels-ore-sorting-facility"] = { 7, 7 }, ["bi-bio-greenhouse"] = { 3, 3 },
  ["angels-crop-farm"] = { 5, 5 }, ["angels-seed-extractor"] = { 3, 3 }, ["angels-bio-processor"] = { 5, 5 },
  ["angels-liquifier"] = { 3, 3 }, ["clowns-sluicer"] = { 3, 3 }, ["angels-hydro-plant"] = { 5, 5 },
  ["radar"] = { 3, 3 }, ["ore-radar"] = { 3, 3 }, ["storage-tank"] = { 3, 3 }, ["bob-small-storage-tank"] = { 1, 1 },
  ["angels-storage-tank-3"] = { 2, 2 }, ["big-rock"] = { 2, 2 }, ["huge-rock"] = { 3, 3 }, ["big-sand-rock"] = { 2, 2 },
  ["angels-crystal-rock"] = { 3, 3 }, ["bob-hardened-bile"] = { 2, 2 },
  ["crash-site-spaceship-wreck-big-1"] = { 3, 3 }, ["crash-site-spaceship-wreck-big-2"] = { 3, 3 },
  ["crash-site-spaceship-wreck-medium-1"] = { 2, 2 }, ["crash-site-spaceship-wreck-medium-2"] = { 2, 2 },
  ["crash-site-spaceship-wreck-medium-3"] = { 2, 2 },
  ["fe-c-accumulator"] = { 2, 2 }, ["angels-air-filter"] = { 5, 5 }, ["CW-air-filter-machine-1"] = { 3, 3 },
  ["angels-bio-arboretum-1"] = { 5, 5 }, ["bi-bio-reactor"] = { 3, 3 }, ["bi-bio-boiler"] = { 3, 2 },
  ["burner-generator"] = { 3, 2 }, ["car"] = { 2, 2 }, ["tank"] = { 2, 3 },
  ["oil-refinery"] = { 5, 5 }, ["pumpjack"] = { 3, 3 }, ["offshore-pump"] = { 1, 2 },
  ["straight-rail"] = { 2, 2 },
}

-- Parameterised helpers for the core's expressions --------------------------------------

---Random integer in [min, max] (rolled per spawn by the core).
function lib.R(min, max) return { type = "random", min = min, max = max } end

---Item count with quality: {count = number-expression, quality = "<quality>"}.
---Unknown qualities fall back to normal in the core.
function lib.Q(count, quality) return { count = count, quality = quality } end

---Random entity name from the list (rolled per spawn).
function lib.ANY(list) return { type = "random-from-list", list = list } end

---Random damage option.
function lib.DMG(min, max) return { dmg = lib.R(min, max) } end

lib.TREE = { type = "random-of-entity-type", entity_type = "tree" }
lib.DEAD_TREES = { "dead-tree-desert", "dead-grey-trunk", "dead-dry-hairy-tree", "dry-tree", "dry-hairy-tree" }
lib.STUMPS = { "tree-01-stump", "tree-02-stump", "tree-03-stump", "tree-04-stump", "tree-05-stump" }
lib.ROCKS = { "big-rock", "big-sand-rock" }
lib.SCORCH = { "small-scorchmark", "medium-scorchmark" }

-- Deterministic PRNG -------------------------------------------------------------------

local M = 2147483647

---@param seed string
local function new_rng(seed)
  local h = 7
  for i = 1, #seed do h = (h * 31 + seed:byte(i)) % M end
  if h == 0 then h = 1 end
  local state = h
  local rng = {}
  ---Float in [0, 1) or integer in [a, b].
  function rng.next(a, b)
    state = (state * 16807) % M
    local f = (state - 1) / (M - 1)
    if a == nil then return f end
    return a + math.floor(f * (b - a + 1))
  end
  function rng.pick(list) return list[rng.next(1, #list)] end
  return rng
end

-- Builder ------------------------------------------------------------------------------

local Builder = {}
Builder.__index = Builder

local BUILDER_ONLY = { w = true, h = true, free = true }

---@param name string Unique ruin name inside its size, prefixed "pd-"
---@param size string "small"|"medium"|"large"
function lib.ruin(name, size)
  local half = assert(lib.HALF[size], "unknown size " .. tostring(size))
  return setmetatable({
    name = name, size = size, half = half,
    entities = {}, tiles = {}, occ = {}, tile_set = {},
    rng = new_rng(name), meta = {},
  }, Builder)
end

local function footprint(name, opts)
  local w, h = 1, 1
  if opts and opts.w then
    w, h = opts.w, opts.h or opts.w
  elseif type(name) == "string" and SIZES[name] then
    w, h = SIZES[name][1], SIZES[name][2]
  elseif type(name) == "table" and name.type == "random-from-list" and SIZES[name.list[1]] then
    w, h = SIZES[name.list[1]][1], SIZES[name.list[1]][2]
  end
  if opts and (opts.dir == "east" or opts.dir == "west") then w, h = h, w end
  return w, h
end

local function core_opts(opts)
  if not opts then return nil end
  local out, any = {}, false
  for k, v in pairs(opts) do
    if not BUILDER_ONLY[k] then out[k] = v any = true end
  end
  return any and out or nil
end

function Builder:is_free(tx, ty, w, h)
  local half = self.half
  if tx < -half or ty < -half or tx + w > half or ty + h > half then return false end
  for x = tx, tx + w - 1 do
    for y = ty, ty + h - 1 do
      if self.occ[x .. "," .. y] then return false end
    end
  end
  return true
end

function Builder:mark(tx, ty, w, h)
  for x = tx, tx + w - 1 do
    for y = ty, ty + h - 1 do self.occ[x .. "," .. y] = true end
  end
end

---Place an entity by its top-left tile (tx, ty). Errors when it overlaps or leaves the ruin.
function Builder:put(name, tx, ty, opts)
  local w, h = footprint(name, opts)
  assert(self:is_free(tx, ty, w, h), string.format("%s: %s at %d,%d (%dx%d) overlaps or is out of bounds", self.name, tostring(type(name) == "table" and name.list and name.list[1] or name), tx, ty, w, h))
  self:mark(tx, ty, w, h)
  self.entities[#self.entities + 1] = { name, { x = tx + w / 2, y = ty + h / 2 }, core_opts(opts) }
  return self
end

---Like put(), but silently skips occupied places. Returns true when placed.
function Builder:try_put(name, tx, ty, opts)
  local w, h = footprint(name, opts)
  if not self:is_free(tx, ty, w, h) then return false end
  self:put(name, tx, ty, opts)
  return true
end

---Off-grid decoration (trees, corpses, scorch marks) at an exact position, no footprint check
---except that the tile below becomes occupied for later grid placements.
function Builder:deco(name, x, y, opts)
  local half = self.half
  x = math.max(-half + 0.5, math.min(half - 0.5, x))
  y = math.max(-half + 0.5, math.min(half - 0.5, y))
  self.occ[math.floor(x) .. "," .. math.floor(y)] = true
  self.entities[#self.entities + 1] = { name, { x = x, y = y }, core_opts(opts) }
  return self
end

---Random placements inside an area (tile coordinates, inclusive-exclusive like put()).
---names: string, expression or list of names (one is picked per placement at build time).
function Builder:scatter(names, count, opts, area)
  local half = self.half
  area = area or { -half, -half, half, half }
  local placed, tries = 0, 0
  while placed < count and tries < count * 25 do
    tries = tries + 1
    local name = names
    if type(names) == "table" and names.type == nil then name = self.rng.pick(names) end
    local w, h = footprint(name, opts)
    local tx = self.rng.next(area[1], area[3] - w)
    local ty = self.rng.next(area[2], area[4] - h)
    if self:try_put(name, tx, ty, opts) then placed = placed + 1 end
  end
  return self
end

---Off-grid scatter for trees and corpses.
function Builder:scatter_deco(names, count, opts, area)
  local half = self.half
  area = area or { -half, -half, half, half }
  for _ = 1, count do
    local name = names
    if type(names) == "table" and names.type == nil then name = self.rng.pick(names) end
    local x = area[1] + self.rng.next() * (area[3] - area[1])
    local y = area[2] + self.rng.next() * (area[4] - area[2])
    if not self.occ[math.floor(x) .. "," .. math.floor(y)] then self:deco(name, x, y, opts) end
  end
  return self
end

---Walls/fences on the border of a tile rectangle [x1, x2] x [y1, y2] (inclusive).
---opts.gap: chance to leave a hole; opts.door: list of {x, y} tiles left open; other keys go to the core.
function Builder:ring(name, x1, y1, x2, y2, opts)
  opts = opts or {}
  local gap = opts.gap or 0
  local doors = {}
  for _, d in ipairs(opts.door or {}) do doors[d[1] .. "," .. d[2]] = true end
  local entity_opts = {}
  for k, v in pairs(opts) do if k ~= "gap" and k ~= "door" then entity_opts[k] = v end end
  local function wall(x, y)
    if doors[x .. "," .. y] then return end
    if gap > 0 and self.rng.next() < gap then return end
    self:try_put(name, x, y, entity_opts)
  end
  for x = x1, x2 do wall(x, y1) wall(x, y2) end
  for y = y1 + 1, y2 - 1 do wall(x1, y) wall(x2, y) end
  return self
end

---Fill a tile rectangle [x1, x2] x [y1, y2] (inclusive) with a tile, optional density 0..1.
function Builder:tiles_rect(tile, x1, y1, x2, y2, density)
  density = density or 1
  local half = self.half
  for x = math.max(x1, -half), math.min(x2, half - 1) do
    for y = math.max(y1, -half), math.min(y2, half - 1) do
      if density >= 1 or self.rng.next() < density then
        local key = x .. "," .. y
        if not self.tile_set[key] then
          self.tile_set[key] = true
          self.tiles[#self.tiles + 1] = { tile, { x = x, y = y } }
        end
      end
    end
  end
  return self
end

---Roughly round blob of tiles around (cx, cy) with radius r.
function Builder:tiles_blob(tile, cx, cy, r, density)
  density = density or 1
  local half = self.half
  for x = math.floor(cx - r), math.ceil(cx + r) do
    for y = math.floor(cy - r), math.ceil(cy + r) do
      local d = math.sqrt((x + 0.5 - cx) ^ 2 + (y + 0.5 - cy) ^ 2)
      local edge = d > r - 1 and 0.55 or 1
      if d <= r and x >= -half and x < half and y >= -half and y < half and self.rng.next() < density * edge then
        local key = x .. "," .. y
        if not self.tile_set[key] then
          self.tile_set[key] = true
          self.tiles[#self.tiles + 1] = { tile, { x = x, y = y } }
        end
      end
    end
  end
  return self
end

---Mark tiles as occupied so later scatter() does not put entities there (e.g. water).
function Builder:reserve(x1, y1, x2, y2)
  for x = x1, x2 do for y = y1, y2 do self.occ[x .. "," .. y] = true end end
  return self
end

---Relative spawn weight (default 1). Lower = rarer.
function Builder:weight(w) self.meta.weight = w return self end

---Minimum distance from the map origin (tiles). Use for dangerous or valuable ruins.
function Builder:far(distance) self.meta.min_distance = distance return self end

---Tag for discovery map markers: "danger" or "rare".
function Builder:tag(tag) self.meta.pd_tag = tag return self end

function Builder:build()
  local ruin = { name = self.name, entities = self.entities }
  if #self.tiles > 0 then ruin.tiles = self.tiles end
  for k, v in pairs(self.meta) do ruin[k] = v end
  return ruin
end

-- Chainable modifiers for an already built ruin: def(...):weight(0.5):far(800):tag("danger")
local Meta = {}
Meta.__index = Meta
function Meta:weight(w) self.ruin.weight = w return self end
function Meta:far(distance) self.ruin.min_distance = distance return self end
function Meta:tag(tag) self.ruin.pd_tag = tag return self end

---Collects ruins of one size. Returns def(name, fn) and the list.
---@param size string
function lib.collector(size)
  local list = {}
  local function def(name, fn)
    local b = lib.ruin(name, size)
    fn(b)
    local ruin = b:build()
    list[#list + 1] = ruin
    return setmetatable({ ruin = ruin }, Meta)
  end
  return def, list
end

return lib
