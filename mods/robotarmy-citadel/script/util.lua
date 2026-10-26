-- Small helpers: chunk keys and areas, distances, the deterministic random generator of the citadel.
local U = {}

U.CHUNK = 32
local OFFSET = 1048576    -- 2^20: chunk coordinates are far inside +-2^20
local SPAN = 2097152      -- 2^21

--- Number key of a chunk (exact in a double: < 2^42).
function U.key(x, y)
  return (x + OFFSET) * SPAN + (y + OFFSET)
end

function U.unkey(k)
  local x = math.floor(k / SPAN)
  return x - OFFSET, (k - x * SPAN) - OFFSET
end

function U.chunk_of(pos)
  return math.floor((pos.x or pos[1]) / 32), math.floor((pos.y or pos[2]) / 32)
end

function U.area(cx, cy)
  return {{cx * 32, cy * 32}, {cx * 32 + 32, cy * 32 + 32}}
end

function U.center(cx, cy)
  return {x = cx * 32 + 16, y = cy * 32 + 16}
end

function U.dist2(a, b)
  local dx = (a.x or a[1]) - (b.x or b[1])
  local dy = (a.y or a[2]) - (b.y or b[2])
  return dx * dx + dy * dy
end

function U.dist(a, b)
  return math.sqrt(U.dist2(a, b))
end

function U.gps(pos, surface)
  return string.format("[gps=%d,%d,%s]", math.floor(pos.x or pos[1]), math.floor(pos.y or pos[2]), surface.name)
end

U.NEIGHBOURS4 = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
U.NEIGHBOURS8 = {{0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}}

---------------------------------------------------------------------------------------------------
-- Deterministic random numbers (Park-Miller, state kept in storage: the same on every peer and
-- after a save/load). 48271 * (2^31 - 1) < 2^53, so the product is exact in a double.
---------------------------------------------------------------------------------------------------
local M = 2147483647

function U.seed(value)
  local s = math.floor(math.abs(value or 1)) % (M - 1)
  return s + 1
end

--- Float in [0, 1).
function U.random(c)
  c.rng = (c.rng * 48271) % M
  return (c.rng - 1) / (M - 1)
end

--- Integer in [1, n].
function U.random_int(c, n)
  return math.min(n, math.floor(U.random(c) * n) + 1)
end

--- Weighted choice: list of {value, weight}; nil if every weight is 0.
function U.pick(c, list)
  local total = 0
  for _, e in pairs(list) do total = total + e[2] end
  if total <= 0 then return nil end
  local r = U.random(c) * total
  for _, e in ipairs(list) do
    r = r - e[2]
    if r < 0 then return e[1] end
  end
  return list[#list][1]
end

return U
