-- Intoxication model: formulas, tiers and the reference timings of the specification.
-- Mocks only, not Factorio. Run: lua tests/model.lua (Lua 5.1/5.2).
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local C = require("shared.config")
local M = require("scripts.model")
local V = require("shared.vehicles")

local function near(a, b, tolerance, message)
	assert(math.abs(a - b) <= (tolerance or 1e-9), (message or "") .. ": " .. tostring(a) .. " ~= " .. tostring(b))
end

-- Tolerance and filtration ------------------------------------------------------------------------------
near(M.tolerance(150, 0), 150)
near(M.tolerance(150, 10), 300)
near(M.total_filtration({ 0, 0, 0 }), 0)
near(M.total_filtration({ 0.5, 0.5 }), 0.75)
near(M.total_filtration({ 0.4, 0.5, 0.7 }), 1 - 0.6 * 0.5 * 0.3)
near(M.total_filtration({ 1, 0 }), 1)
near(M.total_filtration({ 1.5, -1 }), 1, 1e-9, "clamped")
near(M.safe_level(150, 0.5), 300)
assert(M.safe_level(150, 1) == math.huge)

-- Rate ------------------------------------------------------------------------------------------------
near(M.rate(750, 150), 8 * 600 / 1200, 1e-9, "half of rate_max at excess 600")
assert(M.rate(151, 150) > 0 and M.rate(151, 150) < 0.02)
near(M.rate(150, 150), -1, 1e-9, "at tolerance: decay_min")
near(M.rate(0, 150), -5, 1e-9, "clean air: decay_max")
near(M.rate(0, 150, true), -10, 1e-9, "clean-air zone doubles decay")
near(M.rate(75, 150), -3, 1e-9, "half way")
assert(M.rate(1e9, 150) < C.MODEL.rate_max)

-- Damage: only over 50 % and only while inhaling over the tolerance -------------------------------------
assert(M.damage(100, 250, 150, 150) == 0, "no damage at tolerance: leaving the smog stops damage")
assert(M.damage(100, 250, 100, 150) == 0)
assert(M.damage(50, 250, 1000, 150) == 0)
near(M.damage(100, 250, 1000, 150), 20)
near(M.damage(75, 250, 1000, 150), 10)

-- Wear ------------------------------------------------------------------------------------------------
assert(M.wear(150, 150, 0.8, 0) == 0, "nothing wears at the tolerance")
assert(M.wear(1000, 150, 0, 0) == 0, "a non-filtering item never wears")
near(M.wear(1000, 150, 0.8, 0), 850 * 0.8 / 50)
near(M.wear(1000, 150, 0.8, 10), 850 * 0.8 / 50 / 2)

-- Tiers and ETA ---------------------------------------------------------------------------------------
assert(M.tier(0) == 0 and M.tier(24.9) == 0 and M.tier(25) == 1 and M.tier(50) == 2 and M.tier(75) == 3 and M.tier(100) == 3)
near(M.eta(0, 2), 25)
near(M.eta(40, -4), 10)
assert(M.eta(60, 2) == nil and M.eta(0, -1) == nil)

-- Reference timings (unprotected, level 0, 250 HP), simulated in 1 s steps as the runtime does ------
local function simulate(pollution, filtration, limit)
	local x, health, first_damage = 0, 250, nil
	for second = 1, limit do
		local inhaled = pollution * (1 - filtration)
		x = M.step(x, M.rate(inhaled, 150), 1)
		local damage = M.damage(x, 250, inhaled, 150)
		if damage > 0 and not first_damage then first_damage = second end
		health = health - damage
		if health <= 0 then return first_damage, second end
	end
	return first_damage, nil
end
local function check(pollution, damage_low, damage_high, death_low, death_high)
	local first, death = simulate(pollution, 0, 1200)
	assert(first and first >= damage_low and first <= damage_high, pollution .. ": damage at " .. tostring(first))
	assert(death and death >= death_low and death <= death_high, pollution .. ": death at " .. tostring(death))
	print(string.format("P=%d: damage after %d s, death after %d s", pollution, first, death))
end
check(170, 150, 220, 220, 300)
check(250, 38, 50, 65, 90)
check(1150, 8, 13, 20, 35)
check(5150, 6, 10, 15, 28)
local first = simulate(250, 0.5, 600)
assert(first == nil, "a respirator makes P=250 harmless")
local _, death = simulate(500, 0.5, 600)
assert(death, "respirator at P=500: inhaled 250, still harmful")

-- Leaving the smog: no damage at all afterwards, intoxication falls to zero ---------------------------
do
	local x = 100
	for _ = 1, 60 do
		local inhaled = 100
		assert(M.damage(x, 250, inhaled, 150) == 0)
		x = M.step(x, M.rate(inhaled, 150), 1)
	end
	assert(x == 0, "clean after a minute at P=100: " .. x)
end

-- Vehicles ------------------------------------------------------------------------------------------
near(V.filtration("car", "car"), 0.40)
near(V.filtration("car", "tank"), 0.85)
near(V.filtration("car", "Schall-tank-H-mk2"), 0.85)
near(V.filtration("car", "flying-fortress"), 0.85)
near(V.filtration("locomotive", "locomotive"), 0.75)
near(V.filtration("cargo-wagon", "bob-armoured-cargo-wagon-2"), 0.90)
near(V.filtration("spider-vehicle", "spidertron"), 0.95)
near(V.filtration("assembling-machine", "x"), 0)

-- Config sanity ---------------------------------------------------------------------------------------
for name, spec in pairs(C.ARMORS) do
	assert(spec.filtration > 0 and spec.filtration < 100 and spec.durability > 0, name)
end
assert(C.ARMORS["bob-power-armor-mk3"].filtration > C.ARMORS["power-armor-mk2"].filtration, "monotonic Bob armor")
assert(C.ARMORS["bob-power-armor-mk5"].filtration > C.ARMORS["bob-power-armor-mk4"].filtration)
assert(C.MODULES[1].filtration >= C.MODULES[2].filtration, "best module first")

print("model: OK")
