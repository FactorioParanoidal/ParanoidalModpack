-- Layout builder of a legendary ruin. Coordinates are tiles relative to the site center:
-- the site covers [-half, half) on both axes. A plan is plain data (stored in storage while the
-- site is being built), so it never holds functions or LuaObjects.
local P = {}

-- Deterministic PRNG (Park-Miller), seeded per site. Layouts never use math.random.
function P.rng(seed)
  local M = 2147483647
  local state = (math.floor(seed) % (M - 1)) + 1
  local rng = {}
  ---Float in [0, 1) or integer in [a, b].
  function rng.next(a, b)
    state = (state * 16807) % M
    local f = (state - 1) / (M - 1)
    if a == nil then return f end
    return a + math.floor(f * (b - a + 1))
  end
  function rng.pick(list) return list[rng.next(1, #list)] end
  function rng.chance(p) return rng.next() < p end
  function rng.shuffle(list)
    for i = #list, 2, -1 do
      local j = rng.next(1, i)
      list[i], list[j] = list[j], list[i]
    end
    return list
  end
  return rng
end

local Plan = {}
Plan.__index = Plan

---@param half integer half size in tiles
---@param seed integer
---@param footprint fun(name: string): integer, integer entity tile size (width, height)
function P.new(half, seed, footprint)
  return setmetatable({
    half = half, seed = seed, rng = P.rng(seed), footprint = footprint,
    tiles = {}, tile_index = {}, entities = {}, occ = {}, walls = {},
  }, Plan)
end

local function key(x, y) return x .. "," .. y end

function Plan:inside(x, y)
  return x >= -self.half and y >= -self.half and x < self.half and y < self.half
end

---Set one tile (the last write wins).
function Plan:tile(name, x, y)
  if not self:inside(x, y) then return self end
  local k = key(x, y)
  local i = self.tile_index[k]
  if i then
    self.tiles[i][1] = name
  else
    self.tiles[#self.tiles + 1] = { name, x, y }
    self.tile_index[k] = #self.tiles
  end
  return self
end

---Fill an inclusive tile rectangle; `name` may be a function(x, y) returning a name or nil.
function Plan:fill(name, x1, y1, x2, y2)
  for x = math.max(x1, -self.half), math.min(x2, self.half - 1) do
    for y = math.max(y1, -self.half), math.min(y2, self.half - 1) do
      local n = name
      if type(name) == "function" then n = name(x, y) end
      if n then self:tile(n, x, y) end
    end
  end
  return self
end

---Fill a disc of radius r around (cx, cy).
function Plan:disc(name, cx, cy, r, density)
  for x = math.floor(cx - r), math.ceil(cx + r) do
    for y = math.floor(cy - r), math.ceil(cy + r) do
      local d = math.sqrt((x + 0.5 - cx) ^ 2 + (y + 0.5 - cy) ^ 2)
      if d <= r and (not density or self.rng.next() < density) then self:tile(name, x, y) end
    end
  end
  return self
end

function Plan:size(name, opts)
  local w, h
  if opts and opts.w then
    w, h = opts.w, opts.h or opts.w
  else
    w, h = self.footprint(name)
  end
  if opts and (opts.dir == "east" or opts.dir == "west") then w, h = h, w end
  return w, h
end

function Plan:free(x, y, w, h)
  if x < -self.half or y < -self.half or x + w > self.half or y + h > self.half then return false end
  for i = x, x + w - 1 do
    for j = y, y + h - 1 do
      if self.occ[key(i, j)] then return false end
    end
  end
  return true
end

function Plan:mark(x, y, w, h)
  for i = x, x + w - 1 do
    for j = y, y + h - 1 do self.occ[key(i, j)] = true end
  end
end

function Plan:occupied(x, y) return self.occ[key(x, y)] == true end

---Reserve tiles (inclusive rectangle) so that later placements skip them.
function Plan:reserve(x1, y1, x2, y2)
  for x = x1, x2 do for y = y1, y2 do self.occ[key(x, y)] = true end end
  return self
end

---Place an entity by its top-left tile. Returns the entry or nil when the place is taken.
---opts: force ("legend"|"neutral"|"enemy"), dir, quality, items, fluids, key, list, recipe,
---invincible, locked (not minable), sealed (not operable), fixed (not rotatable), amount, w, h,
---health (0..1), loose (no occupancy check), text, tag.
function Plan:put(name, x, y, opts)
  opts = opts or {}
  local w, h = self:size(name, opts)
  if not opts.loose then
    if not self:free(x, y, w, h) then return nil end
    self:mark(x, y, w, h)
  end
  local entry = { name = name, x = x + w / 2, y = y + h / 2 }
  for k, v in pairs(opts) do
    if k ~= "w" and k ~= "h" and k ~= "loose" then entry[k] = v end
  end
  self.entities[#self.entities + 1] = entry
  return entry
end

---Place at an exact position (units, trees, decorations); no occupancy check.
function Plan:at(name, px, py, opts)
  local entry = { name = name, x = px, y = py }
  for k, v in pairs(opts or {}) do entry[k] = v end
  self.entities[#self.entities + 1] = entry
  self.occ[key(math.floor(px), math.floor(py))] = true
  return entry
end

---Border of an inclusive rectangle with 1x1 entities (walls). opts.doors: list of {x, y} left open.
function Plan:ring(name, x1, y1, x2, y2, opts)
  opts = opts or {}
  local doors = {}
  for _, d in ipairs(opts.doors or {}) do doors[key(d[1], d[2])] = true end
  local entity_opts = {}
  for k, v in pairs(opts) do if k ~= "doors" then entity_opts[k] = v end end
  local function wall(x, y)
    if not doors[key(x, y)] then self:put(name, x, y, entity_opts) end
  end
  for x = x1, x2 do wall(x, y1) wall(x, y2) end
  for y = y1 + 1, y2 - 1 do wall(x1, y) wall(x2, y) end
  return self
end

---Line of 1x1 entities from (x1, y1) to (x2, y2), horizontal or vertical.
function Plan:line(name, x1, y1, x2, y2, opts)
  local dx = x2 > x1 and 1 or (x2 < x1 and -1 or 0)
  local dy = y2 > y1 and 1 or (y2 < y1 and -1 or 0)
  local x, y = x1, y1
  while true do
    self:put(name, x, y, opts)
    if x == x2 and y == y2 then break end
    x, y = x + dx, y + dy
  end
  return self
end

-- Untouchable structure of a legendary ruin: guardian force, cannot be damaged or mined.
P.STRUCTURE = { force = "legend", invincible = true, locked = true }
P.WALL = "pd-legend-wall"   -- stone wall look, full-tile collision: no squeezing through (minime)

---Indestructible wall tile; walls also block the line of sight of the site's traps.
function Plan:wall(x, y, name, list)
  local opts = P.STRUCTURE
  if list then opts = { force = "legend", invincible = true, locked = true, list = list } end
  local e = self:put(name or P.WALL, x, y, opts)
  if e then self.walls[key(x, y)] = true end
  return e
end

function Plan:wall_line(x1, y1, x2, y2, name, list)
  local dx = x2 > x1 and 1 or (x2 < x1 and -1 or 0)
  local dy = y2 > y1 and 1 or (y2 < y1 and -1 or 0)
  local x, y = x1, y1
  while true do
    self:wall(x, y, name, list)
    if x == x2 and y == y2 then break end
    x, y = x + dx, y + dy
  end
end

---Wall border of an inclusive rectangle; doors: list of {x, y} tiles left open.
function Plan:wall_ring(x1, y1, x2, y2, doors, name)
  local open = {}
  for _, d in ipairs(doors or {}) do open[key(d[1], d[2])] = true end
  local function w(x, y) if not open[key(x, y)] then self:wall(x, y, name) end end
  for x = x1, x2 do w(x, y1) w(x, y2) end
  for y = y1 + 1, y2 - 1 do w(x1, y) w(x2, y) end
end

---Places at (x, y) or at the nearest free tile within `radius`; nil (and a log line) when there is none.
function Plan:put_near(name, x, y, opts, radius)
  for r = 0, radius or 3 do
    for dx = -r, r do
      for dy = -r, r do
        if math.max(math.abs(dx), math.abs(dy)) == r then
          local e = self:put(name, x + dx, y + dy, opts)
          if e then return e end
        end
      end
    end
  end
  log("[legendary] layout: no room for " .. name .. " near " .. x .. "," .. y)
  return nil
end

---Sealed reward chest (filled and opened when the ruin is beaten).
function Plan:vault(x, y)
  return self:put_near("crash-site-chest-2", x, y, { force = "neutral", list = "vault", invincible = true, locked = true, sealed = true })
end

---Lever: mined by hand to trigger something (the kind's lever handler gets `key`).
function Plan:lever(key_name, x, y, label)
  return self:put_near("pd-legend-lever", x, y, { force = "neutral", key = key_name, invincible = true, label = label })
end

---Tablet: a lever that cannot be mined (text is drawn by the kind).
function Plan:tablet(key_name, x, y)
  return self:put("pd-legend-lever", x, y, { force = "neutral", key = key_name, invincible = true, locked = true })
end

---Random placements in an inclusive area.
function Plan:scatter(names, count, opts, area)
  area = area or { -self.half, -self.half, self.half - 1, self.half - 1 }
  local placed, tries = 0, 0
  while placed < count and tries < count * 30 do
    tries = tries + 1
    local name = type(names) == "table" and self.rng.pick(names) or names
    local w, h = self:size(name, opts)
    local x = self.rng.next(area[1], area[3] - w + 1)
    local y = self.rng.next(area[2], area[4] - h + 1)
    if self:put(name, x, y, opts) then placed = placed + 1 end
  end
  return placed
end

---Off-grid decorations (trees, corpses, scorch marks) in an inclusive area, skipping taken tiles.
function Plan:sprinkle(names, count, opts, area)
  area = area or { -self.half, -self.half, self.half - 1, self.half - 1 }
  for _ = 1, count do
    local name = type(names) == "table" and self.rng.pick(names) or names
    local px = area[1] + self.rng.next() * (area[3] - area[1] + 1)
    local py = area[2] + self.rng.next() * (area[4] - area[2] + 1)
    if not self:occupied(math.floor(px), math.floor(py)) then self:at(name, px, py, opts) end
  end
end

return P
