-- Pure Lua checks (no game): run from the mod root with Lua 5.1/5.2: lua tests/layout_test.lua
-- Plans stay inside the walls, do not overlap, keep the roads and the plaza free, every module type
-- has a plan with its key buildings; walls of a lone module; chunk keys; the module choice.
package.path = "./?.lua;" .. package.path
local S = require("lib.shared")
local L = require("script.layout")
local U = require("script.util")
local M = require("script.modules")

local fails = 0
local function check(ok, msg)
  if not ok then
    fails = fails + 1
    print("FAIL " .. msg)
  end
end

-- plans
local PLAZA_OK = {[S.entity.pylon] = true, [S.entity.lamp] = true, [S.entity.shield_tower] = true}
for name, t in pairs(M.types) do
  check(L.plans[name] ~= nil, "no plan for " .. name)
  local entries = L.entries(name)
  entries[#entries + 1] = L.TOWER
  local used = {}
  local has_key = {}
  for _, e in ipairs(entries) do
    local size = S.size[e[1]]
    check(size ~= nil, name .. ": no size for " .. tostring(e[1]))
    size = size or {1, 1}
    for x = e[2], e[2] + size[1] - 1 do
      for y = e[3], e[3] + size[2] - 1 do
        check(x >= 1 and x <= 30 and y >= 1 and y <= 30, string.format("%s: %s outside at %d,%d", name, e[1], x, y))
        local k = x * 32 + y
        check(not used[k], string.format("%s: %s overlaps %s at %d,%d", name, e[1], tostring(used[k]), x, y))
        used[k] = e[1]
        if L.is_road(x, y) then
          check(PLAZA_OK[e[1]], string.format("%s: %s on the road/plaza at %d,%d", name, e[1], x, y))
        end
      end
    end
    has_key[e[1]] = true
  end
  for _, key in pairs(t.keys) do check(has_key[key], name .. ": key " .. key .. " not in the plan") end
  -- the foundry exit (below the 5x5 foundry at 4,4 the droids appear at y + 4 from its centre)
  if t.foundry and name ~= "core" then
    check(not used[6 * 32 + 10], name .. ": foundry exit blocked")
  end
  -- muster point free
  check(not used[math.floor(L.MUSTER.x) * 32 + math.floor(L.MUSTER.y)], name .. ": muster point blocked")
end

-- walls of a lone module: 124 border tiles, 16 of them gates
local lone = L.walls(function() return false end)
local walls, gates = 0, 0
for _, v in pairs(lone) do
  if v == "wall" then walls = walls + 1 else gates = gates + 1 end
end
check(walls + gates == 124 and gates == 16, string.format("lone walls %d gates %d", walls, gates))
-- inner corner: neighbours north and east, not north-east
local inner = L.walls(function(dx, dy) return (dx == 0 and dy == -1) or (dx == 1 and dy == 0) end)
check(inner[31 * 32 + 0] == "wall", "inner corner wall missing")
check(inner[16 * 32 + 0] == nil, "wall on the shared north edge")

-- chunk keys
for _, p in pairs({{0, 0}, {-1, -1}, {12345, -54321}, {-62500, 62500}}) do
  local x, y = U.unkey(U.key(p[1], p[2]))
  check(x == p[1] and y == p[2], string.format("key %d,%d -> %d,%d", p[1], p[2], x, y))
end

-- module choice over 120 modules: caps hold, every category appears
local c = {rng = U.seed(42), count = 1, alive = {core = 1}, shields = false}
local seen = {}
for n = 2, 120 do
  c.count = n
  if n >= 25 then c.shields = true end
  local t = M.choose(c, true)
  check(M.types[t] ~= nil and t ~= "core", "bad choice " .. tostring(t))
  c.alive[t] = (c.alive[t] or 0) + 1
  seen[M.types[t].cat] = (seen[M.types[t].cat] or 0) + 1
end
for name, t in pairs(M.types) do
  local cap = type(t.cap) == "function" and t.cap(c) or t.cap
  if cap then check((c.alive[name] or 0) <= cap, name .. " over its cap: " .. tostring(c.alive[name])) end
end
for _, cat in pairs({"production", "power", "defense", "support", "recon", "upgrade", "shield"}) do
  check((seen[cat] or 0) > 0, "category never chosen: " .. cat)
end
local demand, supply = M.power(c)
local summary = {}
for cat, n in pairs(seen) do summary[#summary + 1] = cat .. "=" .. n end
table.sort(summary)
print(string.format("120 modules: %s; power demand %.0f MW, supply %.0f MW", table.concat(summary, " "), demand, supply))

print(fails == 0 and "ALL PASS" or ("FAILS " .. fails))
os.exit(fails == 0 and 0 or 1)
