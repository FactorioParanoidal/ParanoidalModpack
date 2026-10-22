-- Unit test of the geology logic outside the game (Lua 5.1/5.2):
--   lua tools/test_geology.lua MOD_DIR
-- Loads scripts/reforged-geology.lua with mocked remote/settings and checks the soil -> resource
-- table of the remote interface, then checks the climate boxes and the noise expressions of
-- prototypes/reforged/geology.lua (what RSO-reforged uses) on sample climate points.
local mod_dir = arg[1]
package.path = mod_dir .. "/?.lua;" .. package.path
local failures = 0
local function check(cond, msg)
  if not cond then failures = failures + 1; print("FAIL " .. msg) else print("ok   " .. msg) end
end

-- mocks
local iface
remote = {add_interface = function(name, f) iface = {name = name, f = f} end}
local geology_on = true
settings = {startup = setmetatable({}, {__index = function(_, k)
  if k == "alien-biomes-reforged-geology" then return {value = geology_on} end
end})}
dofile(mod_dir .. "/scripts/reforged-geology.lua")
check(iface and iface.name == "alien-biomes-reforged", "remote interface registered")
local bias = iface.f.geology_bias

local function one(tile) return bias("nauvis", {tile, tile, tile}) end
local expect = {
  ["mineral-blue-dirt-1"] = nil,
  ["mineral-purple-sand-2"] = "angels-ore1", ["mineral-aubergine-dirt-3"] = "angels-ore1",
  ["vegetation-mauve-grass-1"] = "angels-ore1", ["mineral-violet-dirt-6"] = "angels-ore1",
  ["mineral-cream-dirt-1"] = "angels-ore2", ["vegetation-yellow-grass-2"] = "angels-ore2", ["mineral-tan-sand-1"] = "angels-ore2",
  ["vegetation-green-grass-3"] = "angels-ore3", ["vegetation-olive-grass-1"] = "angels-ore3", ["vegetation-turquoise-grass-2"] = "angels-ore3",
  ["mineral-grey-dirt-4"] = "angels-ore4", ["mineral-white-sand-3"] = "angels-ore4",
  ["mineral-red-dirt-2"] = "angels-ore5", ["mineral-dustyrose-sand-1"] = "angels-ore5", ["vegetation-orange-grass-1"] = "angels-ore5",
  ["mineral-brown-dirt-5"] = "angels-ore6", ["mineral-beige-sand-2"] = "angels-ore6",
  ["mineral-black-dirt-1"] = "coal",
}
for tile, ore in pairs(expect) do
  local r = one(tile)
  check(r and r[ore] == 2, tile .. " -> " .. ore)
end
check(one("vegetation-blue-grass-1")["angels-ore1"] == 2, "blue grass -> sapphirite")
check(one("mineral-red-dirt-1")["infinite-angels-ore5"] == 2, "infinite ore follows its ore")
check(one("mineral-black-sand-1")["infinite-coal"] == 2, "infinite coal follows coal")
local v = one("volcanic-green-heat-3")
check(v and v["crude-oil"] == 2 and v["angels-natural-gas"] == 2 and v["angels-fissure"] == 2 and not v["angels-ore3"], "volcanic -> oil, gas, fissure only")
check(one("frozen-snow-3") == nil, "snow: no bias")
check(one("water") == nil, "water: no bias")
check(bias("vulcanus", {"mineral-red-dirt-1"}) == nil, "other surfaces: no bias")
local mixed = bias("nauvis", {"mineral-red-dirt-1", "mineral-red-dirt-2", "mineral-black-dirt-1", "water", "water", "water", "water"})
check(mixed and mixed["angels-ore5"] == 2 and not mixed["coal"], "dominant AB soil wins, water ignored")
local tie = bias("nauvis", {"mineral-red-dirt-1", "mineral-black-dirt-1"})
check(tie and tie["coal"] == 2 and not tie["angels-ore5"], "tie broken deterministically (black before red)")
geology_on = false
check(one("mineral-red-dirt-1") == nil, "setting off: no bias")

-- noise expressions alien-biomes-geology-<resource>
local spec = dofile(mod_dir .. "/prototypes/biome/biome-spec.lua")
local axes = dofile(mod_dir .. "/prototypes/biome/biome-axes.lua")
local geology = dofile(mod_dir .. "/prototypes/reforged/geology.lua")
local expressions = geology.expressions(spec, axes)
local map = require("scripts/geology-map")
for _, ore in pairs(map.BY_COLOUR) do check(expressions[ore] ~= nil, "expression for " .. ore) end
for _, r in ipairs(map.VOLCANIC) do check(expressions[r] ~= nil, "expression for " .. r) end

-- evaluate an expression at a climate point: comparisons become 0/1
local function evaluate(expression, t, m, a)
  local lua = expression:gsub("%((%a+) ([<>]=?) ([%d%.%-e]+)%)", "b(%1 %2 %3)")
  local env = {temperature = t, moisture = m, aux = a, b = function(c) return c and 1 or 0 end}
  local f = assert((loadstring or load)("return " .. lua))
  if setfenv then setfenv(f, env) else f = assert(load("return " .. lua, "e", "t", env)) end
  return f()
end
local points = {
  {80, 0.3, 0.95, "purple", "angels-ore1"}, {80, 0.3, 0.7, "red", "angels-ore5"},
  {45, 0.3, 0.45, "beige", "angels-ore6"}, {45, 0.3, 0.1, "cream", "angels-ore2"},
  {10, 0.3, 0.9, "black", "coal"}, {10, 0.3, 0.5, "grey", "angels-ore4"},
  {10, 0.8, 0.3, "turquoise", "angels-ore3"}, {70, 0.8, 0.3, "yellow", "angels-ore2"},
  {90, 0.8, 0.9, "red", "angels-ore5"}, {30, 0.8, 0.9, "mauve", "angels-ore1"},
  {120, 0.5, 0.5, "volcanic", "crude-oil"}, {-10, 0.5, 0.5, nil, nil},
}
for _, p in ipairs(points) do
  local t, m, a, colour, ore = p[1], p[2], p[3], p[4], p[5]
  local label = string.format("t=%g m=%g aux=%g", t, m, a)
  check(geology.classify(spec, axes, t, m, a) == colour, label .. " is " .. tostring(colour))
  local favoured = {}
  for resource, expression in pairs(expressions) do
    local v = evaluate(expression, t, m, a)
    check(v == 1 or v == 2, label .. " " .. resource .. " multiplier " .. v)
    if v == 2 then favoured[#favoured + 1] = resource end
  end
  table.sort(favoured)
  local want = colour == "volcanic" and {"angels-fissure", "angels-natural-gas", "crude-oil"} or (ore and {ore} or {})
  check(table.concat(favoured, ",") == table.concat(want, ","), label .. " favours " .. table.concat(want, ","))
end

print(failures == 0 and "ALL OK" or (failures .. " FAILED"))
os.exit(failures == 0 and 0 or 1)
