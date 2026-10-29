-- Pure rules of the expansion: refinement cost/outcome, modes, boost math, post routing. No engine.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local rules = require("scripts.expansion.rules")
local mock = dofile(directory .. "mock.lua")
local near = mock.near

-- Cost: 2.5 basic packs (750 durability) and 10 s for an average item (2 sciences, 300 health).
local function packs(kinds, health)
    local cost, seconds = rules.attempt(kinds, health)
    return cost / rules.PACK_DURABILITY, seconds
end
local p, t = packs(2, 300); near(p, 2.5); near(t, 10)
-- Agreed examples (science kinds, health) -> packs.
local examples = {
    {1, 125, 0.3225}, {1, 300, 0.5}, {2, 350, 2.7}, {2, 1200, 5}, {3, 500, 9.68}, {4, 2000, 19.365},
    {6, 3000, 60}, {6, 8000, 60},
}
for _, e in ipairs(examples) do
    local value, seconds = packs(e[1], e[2])
    near(value, e[3], 0.01)
    near(seconds, value * 4, 0.02)
end
assert(rules.science_factor(nil) == 1 and rules.science_factor(0) == 0.2 and rules.science_factor(7) == 20)
assert(rules.health_factor(nil) == 1 and rules.health_factor(10) == 0.5 and rules.health_factor(1e6) == 3)
-- Items without health and without research: an average item.
p = packs(nil, nil); near(p, 2.5)
-- The grade never changes the cost: the formula has no grade input at all.

-- Outcome distribution from -5: 10 / 81 / 8.1 / 0.81 / 0.081 / 0.009 %.
local d = rules.refine_distribution(-5)
near(d[-5], .1); near(d[-4], .81); near(d[-3], .081); near(d[-2], .0081); near(d[-1], .00081); near(d[0], .00009)
local total = 0
for _, value in pairs(d) do total = total + value end
near(total, 1)
d = rules.refine_distribution(-1)
near(d[-1], .1); near(d[0], .9)
assert(not pcall(rules.refine_distribution, 0) and not pcall(rules.refine_distribution, -6))

-- Sampled outcomes agree with the distribution (RNG sequences are explicit).
assert(rules.refine_outcome(-3, mock.sequence({.95})) == -3)          -- 10% failure
assert(rules.refine_outcome(-3, mock.sequence({.5, .5})) == -2)       -- success, no jump
assert(rules.refine_outcome(-3, mock.sequence({.5, .05, .5})) == -1)  -- success + one jump
assert(rules.refine_outcome(-3, mock.sequence({.5, .05, .05})) == 0)  -- capped at standard
assert(rules.refine_outcome(-1, mock.sequence({.5})) == 0)

-- Expected attempts: -1 needs 1/0.9; deeper grades need more, monotonically.
near(rules.expected_attempts(-1), 1 / .9)
local previous = 0
for grade = -1, -5, -1 do
    local expected = rules.expected_attempts(grade)
    assert(expected > previous)
    previous = expected
end
assert(rules.expected_attempts(0) == 0)

-- Prepayment keeps the paid share two ticks ahead and never above one attempt.

-- Modes: agreed costs and the derived extra power (machine itself runs `time` times longer).
local m = rules.modes
assert(m.careful.time == 5 and m.careful.energy == 25 and m.precise.time == 20 and m.precise.energy == 400)
near(rules.extra_power(m.normal), 0); near(rules.extra_power(m.careful), 4); near(rules.extra_power(m.precise), 19)
assert(rules.effective_level(3, m.careful) == 7 and rules.effective_level(8, m.careful) == 10)
assert(rules.effective_level(3, nil) == 3 and m.precise.no_defect and not m.careful.no_defect)
for _, name in ipairs(rules.mode_order) do assert(m[name].loss == nil, "no loss factor any more") end

-- Boost: native p plus the conditional extra chance equals 1 - (1-p)^n.
for _, chance in ipairs({.01, .05, .1, .2, .5}) do
    for _, n in ipairs({3, 10}) do
        local extra = rules.extra_chance(chance, n)
        near(chance + (1 - chance) * extra, rules.boosted_chance(chance, n))
    end
end
near(rules.boosted_chance(.1, 3), .271); near(rules.boosted_chance(.2, 10), 0.8926258176)
assert(rules.extra_chance(0, 10) == 0 and rules.extra_chance(.3, 1) == 0)

-- Control post routing.
local q = {normal = {grade = 0, rank = 0, normal = true}, defect = {grade = -3, rank = -1, normal = false},
    rare = {grade = 0, rank = 3, normal = false}, uncommon = {grade = 0, rank = 2, normal = false}}
local strict = {item = "gear", condition = "strict"}
assert(rules.route(strict, "gear", q.normal, 5) == "good")
assert(rules.route(strict, "gear", q.normal, 0) == "other")
assert(rules.route(strict, "gear", q.defect, 5) == "refine")
assert(rules.route(strict, "gear", q.rare, 5) == "refine")
assert(rules.route(strict, "plate", q.normal, 5) == "other")
local at_least = {item = "gear", condition = "at-least", rank = 3}
assert(rules.route(at_least, "gear", q.rare, 1) == "good")
assert(rules.route(at_least, "gear", q.uncommon, 1) == "other")
assert(rules.route(at_least, "gear", q.normal, 1) == "other")
assert(rules.route(at_least, "gear", q.defect, 1) == "refine")
assert(rules.route(nil, "gear", q.normal, 1) == "other")
-- An item the workshop does not take (a material): what would go to refinement goes to "other".
assert(rules.route(strict, "gear", q.defect, 5, false) == "other")
assert(rules.route(strict, "gear", q.rare, 5, false) == "other")
assert(rules.route(strict, "gear", q.normal, 5, false) == "good")
assert(rules.route(at_least, "gear", q.defect, 1, false) == "other")
assert(rules.route(strict, "gear", q.defect, 5, true) == "refine")
-- Outputs: forward / left / right relative to the facing.
assert(rules.output_direction(0, "good") == 0 and rules.output_direction(0, "refine") == 3 and rules.output_direction(0, "other") == 1)
assert(rules.output_direction(1, "good") == 1 and rules.output_direction(1, "refine") == 0 and rules.output_direction(3, "other") == 0)

-- Workshop modes: guaranteed +2 / standard, never above standard, attempts to standard.
local wm = rules.workshop_modes
assert(rules.mode_outcome(-5, wm.careful) == -3 and rules.mode_outcome(-1, wm.careful) == 0)
assert(rules.mode_outcome(-5, wm.precise) == 0 and rules.mode_outcome(-1, wm.precise) == 0)
assert(rules.mode_distribution(-4, wm.careful)[-2] == 1 and rules.mode_distribution(-4, wm.precise)[0] == 1)
assert(rules.mode_attempts(-5, wm.careful) == 3 and rules.mode_attempts(-2, wm.careful) == 1)
assert(rules.mode_attempts(-5, wm.precise) == 1 and rules.mode_attempts(0, wm.precise) == 0)
assert(math.abs(rules.mode_attempts(-1, wm.normal) - rules.expected_attempts(-1)) < 1e-12)
assert(rules.workshop_mode("bogus") == wm.normal and wm.careful.time == 5 and wm.precise.time == 20)

print("PASS: refinement cost (science x sqrt health, agreed examples), 90%+10% chain distribution,")
print("expected attempts, mode costs/extra power/levels, boost identity, post routing.")
print("Pure Lua rules only; not a Factorio test.")
