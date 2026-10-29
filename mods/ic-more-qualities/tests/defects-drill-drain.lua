-- Resource drain of defective drills: x2 (-1) ... x6 (-5) of standard at every research level.
-- The engine drains the standard part; the script removes the rest. Mocks only, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

defines = mock.defines()
storage = {}
game = {tick = 0, forces = {}}
local model = require("scripts.defects.model")
local drill = require("scripts.defects.drill")

-- Scale ---------------------------------------------------------------------------------------------
for grade = -5, 0 do assert(model.drain_multiplier(grade) == 1 - grade, "grade " .. grade) end
assert(model.quality_drain_multiplier("ic-defect-5") == 6 and model.quality_drain_multiplier("ic-defect-1") == 2)
assert(model.quality_drain_multiplier("normal") == 1 and model.quality_drain_multiplier("legendary") == 1)
assert(not pcall(model.drain_multiplier, 1) and not pcall(model.drain_multiplier, -6), "range checked")

-- remove() ------------------------------------------------------------------------------------------
local function ore(amount, prototype)
    local target = {valid = true, name = "ore", amount = amount, depleted = false,
        prototype = prototype or {mineable_properties = {mining_time = 1}}}
    target.deplete = function() target.depleted = true target.valid = false end
    return target
end
local function rng(...)
    local values, index = {...}, 0
    return function()
        index = index + 1
        return assert(values[index], "unexpected random() call " .. index)
    end
end

local target = ore(100)
assert(drill.remove(target, 5, {random = rng()}) == "drained" and target.amount == 95, "whole units, no RNG")
assert(drill.remove(target, 2.5, {random = rng(0.4)}) == "drained" and target.amount == 92, "fraction drained")
assert(drill.remove(target, 2.5, {random = rng(0.6)}) == "drained" and target.amount == 90, "fraction kept")
assert(drill.remove(target, 0.5, {random = rng(0.7)}) == "not-drained" and target.amount == 90)
target = ore(3)
assert(drill.remove(target, 5, {random = rng()}, true) == "drained" and target.amount == 1 and not target.depleted,
    "keep_last leaves the last unit to the engine")
assert(drill.remove(target, 5, {random = rng()}, true) == "not-drained" and target.amount == 1)
assert(drill.remove(target, 5, {random = rng()}) == "depleted" and target.depleted, "failed cycle depletes")
-- Infinite resource: depletion amount per unit, not below the minimum.
local oil = {infinite_resource = true, minimum_resource_amount = 60000, infinite_depletion_resource_amount = 10,
    mineable_properties = {mining_time = 1}}
target = ore(100000, oil)
assert(drill.remove(target, 5, {random = rng()}) == "drained" and target.amount == 99950, "infinite: 5 x 10")
target = ore(60020, oil)
assert(drill.remove(target, 5, {random = rng()}) == "drained" and target.amount == 60000, "clamped at minimum")
assert(drill.remove(target, 5, {random = rng()}) == "not-drained" and target.amount == 60000)

-- step() --------------------------------------------------------------------------------------------
-- A drill first seen at 99% of a 1 s cycle (0.5 speed: 120 ticks): the slowed rest fits into the cycle,
-- so the cycle is committed in this look (extra drain) and the engine progress set to 1 - 0.01 / m.
local function drill_entity(quality, amount, percent)
    return {
        valid = true, name = "drill-" .. (percent or 100), quality = {name = quality}, speed_bonus = 0,
        mining_progress = 0.99, bonus_mining_progress = 0, force = {index = 1},
        prototype = {mining_speed = 0.5, resource_drain_rate_percent = percent},
        mining_target = ore(amount),
    }
end
local function context(random)
    return {random = random or rng()}
end

for tier = 1, 5 do
    for _, level in ipairs({0, 5, 10}) do
        local entity = drill_entity("ic-defect-" .. tier, 1000)
        local record = {entity = entity}
        drill.step(record, level, context())
        assert(record.cycle.committed and record.drain == tier + 1, "committed")
        assert(entity.mining_target.amount == 1000 - tier,
            "defect -" .. tier .. " level " .. level .. ": extra " .. (1000 - entity.mining_target.amount))
        mock.near(entity.mining_progress, 1 - 0.01 / model.quality_multiplier("ic-defect-" .. tier))
    end
end
for _, quality in ipairs({"normal", "legendary"}) do
    local entity = drill_entity(quality, 1000)
    local record = {entity = entity}
    assert(drill.step(record, 0, context()) == false, quality .. ": not tracked")
    assert(record.cycle == nil and entity.mining_target.amount == 1000, quality .. ": no extra drain")
end
-- Drill with 50% drain: defect -5 removes 2.5 more units on average (2 + one unit with chance 0.5).
local half = drill_entity("ic-defect-5", 1000, 50)
drill.step({entity = half}, 10, context(rng(0.49)))
assert(half.mining_target.amount == 997, "50%: 2 + 1 by chance, got " .. half.mining_target.amount)
half = drill_entity("ic-defect-5", 1000, 50)
drill.step({entity = half}, 10, context(rng(0.51)))
assert(half.mining_target.amount == 998, "50%: 2, got " .. half.mining_target.amount)
-- The tail of a finite resource stays for the engine's own last cycle.
local tail = drill_entity("ic-defect-5", 3)
drill.step({entity = tail}, 10, context())
assert(tail.mining_target.amount == 1 and tail.mining_target.valid, "tail kept")
-- A cycle completed between two looks while the engine progress was positive still pays its extra drain.
local missed = drill_entity("ic-defect-2", 1000)
local missed_record = {entity = missed,
    cycle = {source = missed.mining_target, time = 1, engine = 0.5, virtual = 0.8, bonus = 0}}
missed.mining_progress = 0.1
local _, warning = drill.step(missed_record, 0, context())
assert(warning == "missed-cycle" and missed.mining_target.amount == 998, "missed cycle: extra x2 drained")
assert(not missed_record.cycle.committed, "new cycle is not committed yet")
mock.near(missed_record.cycle.virtual, 0.1 * model.quality_multiplier("ic-defect-2"))
assert(missed.mining_progress == 0, "new cycle: engine progress rewound to 0")
-- A record without the drain field gets it from the quality.
local old = {entity = drill_entity("ic-defect-4", 1000), multiplier = model.quality_multiplier("ic-defect-4")}
drill.step(old, 10, context())
assert(old.drain == 5 and old.entity.mining_target.amount == 996, "old record")

print("PASS: defect drain x2...x6 (scale -1...-5), independent of research 0/5/10; standard/positive: none;")
print("drain rate percent with a chance for the fraction; last unit left to the engine;")
print("missed cycle pays its extra drain; infinite resources use the depletion amount and stop at the minimum.")
print("Mocks only, not Factorio.")
