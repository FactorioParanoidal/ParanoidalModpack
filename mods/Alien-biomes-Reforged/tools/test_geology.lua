-- Unit test of the geology logic outside the game (Lua 5.1/5.2):
--   lua tools/test_geology.lua MOD_DIR RSO_CONTROL_LUA
-- Loads scripts/reforged-geology.lua with mocked remote/settings, checks the soil -> resource
-- table, then extracts weighted_allotments() from the patched RSO control.lua and checks that
-- the probability of the favoured resource doubles and that no resource drops to zero.
local mod_dir, rso_control = arg[1], arg[2]
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

-- RSO weighted roll
local src = assert(io.open(rso_control, "r")):read("*a")
local fn = src:match("(local function weighted_allotments%(.-\nend\n)")
check(fn ~= nil, "weighted_allotments found in RSO control.lua")
local weighted_allotments = assert(loadstring(fn .. "\nreturn weighted_allotments"))()
local cfg = {}
local names = {"angels-ore1", "angels-ore2", "angels-ore3", "angels-ore4", "angels-ore5", "angels-ore6", "coal", "crude-oil"}
local total = 0
for i, n in ipairs(names) do
  cfg[i] = {name = n, allotment_range = {min = total, max = total + 60}}
  total = total + 60
end
local ranges, max = weighted_allotments(cfg, {["angels-ore5"] = 2, ["infinite-angels-ore5"] = 2})
local function share(r, idx, m) return (r[idx].max - r[idx].min) / m end
check(max == total + 60, "total weight grows by the favoured allotment (" .. max .. ")")
check(math.abs(share(ranges, 5, max) - 120 / 540) < 1e-9, "favoured share 120/540 (plain 60/480)")
local allpos = true
for i = 1, #names do if share(ranges, i, max) <= 0 then allpos = false end end
check(allpos, "no resource drops to zero")
check(ranges[1].min == 0 and ranges[#names].max == max, "ranges are contiguous from 0 to total")

print(failures == 0 and "ALL OK" or (failures .. " FAILED"))
os.exit(failures == 0 and 0 or 1)
