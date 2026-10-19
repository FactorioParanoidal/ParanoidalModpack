-- Run with Lua 5.1+; no Factorio process, mutable game data, or RNG seed required.
local directory = assert(arg[0]:match("^(.*[/\\])"), "Run using the test file's path")
local model = dofile(directory .. "../scripts/defects/model.lua")
local function near(a, b) assert(math.abs(a - b) < 1e-12, tostring(a) .. " != " .. tostring(b)) end
local function rejects(fn) assert(not pcall(fn), "Invalid input was accepted") end

near(model.multiplier(-5), 1 / 3)
near(model.multiplier(0), 1)
assert(model.quality_name(0) == "normal" and model.quality_name(-5) == "ic-defect-5")
assert(model.is_defect("ic-defect-1") and not model.is_defect("normal") and not model.is_defect("ic-defect-6"))
assert(model.grade_of("ic-defect-3") == -3 and model.grade_of("legendary") == 0 and model.grade_of(nil) == 0)
near(model.quality_multiplier("ic-defect-5"), 1 / 3)
near(model.quality_multiplier("ic-defect-1"), 13 / 15)
assert(model.quality_multiplier("normal") == 1 and model.quality_multiplier("legendary") == 1)
for grade = -4, 0 do near(model.multiplier(grade) - model.multiplier(grade - 1), 2 / 15) end

local start = model.distribution(0)
assert(start[-5] > .9 and start[-5] < .900001)
for grade = -5, -1 do near(start[grade] / start[grade + 1], 10) end

local previous
for level = 0, 10 do
    local distribution = model.distribution(level)
    local total, cumulative, previous_cumulative = 0, 0, 0
    local minimum = -5 + math.floor(level / 2)
    for grade = -5, 0 do
        local p = distribution[grade]
        assert(p >= 0 and p <= 1)
        if grade < minimum then assert(p == 0) else assert(p > 0) end
        if p > 0 then
            assert(model.draw(level, total + p / 2) == grade)
        end
        total = total + p
        cumulative = cumulative + p
        if previous then
            previous_cumulative = previous_cumulative + previous[grade]
            assert(cumulative <= previous_cumulative + 1e-12, "Research made results worse")
        end
    end
    near(total, 1)
    for grade = minimum + 1, -1 do near(distribution[grade] / distribution[grade + 1], 10) end
    previous = distribution
    assert(model.draw_unless_upgraded(level, .5, true) == nil)
    assert(model.draw_unless_upgraded(level, .5, false) == model.draw(level, .5))
end
assert(model.distribution(10)[0] == 1)
for _, sample in ipairs({0, .1, .5, .9, .999999999999}) do assert(model.draw(10, sample) == 0) end

local total_cost, technologies = 0, {}
assert(model.completed_level(technologies) == 0)
for level = 1, 10 do
    local research = model.research(level)
    assert(research.count == level * 10 and research.science == "automation-science-pack")
    assert(research.time == 15)
    if level > 1 then assert(research.prerequisite == model.research(level - 1).name) end
    total_cost = total_cost + research.count
    technologies[research.name] = {researched = true}
    assert(model.completed_level(technologies) == level)
end
assert(total_cost == 550)
technologies[model.research(4).name].researched = false
assert(model.completed_level(technologies) == 3)
assert(model.completed_level({}) == 0, "Force state leaked")

for _, invalid in ipairs({-1, 11, .5, "1", math.huge}) do
    rejects(function() model.distribution(invalid) end)
end
for _, invalid in ipairs({-1, 1, math.huge, "0"}) do
    rejects(function() model.draw(0, invalid) end)
end
rejects(function() model.distribution(0/0) end)
rejects(function() model.draw(0, 0/0) end)
rejects(function() model.multiplier(-6) end)
rejects(function() model.multiplier(1) end)
rejects(function() model.research(0) end)
rejects(function() model.draw_unless_upgraded(0, .5, nil) end)

print("PASS: multipliers, 11 normalized distributions, monotonic progression, 10:1 tails,")
print("research cost 550 red science, force isolation, module precedence, RNG boundaries.")
print("Pure Lua model test only; not a Factorio runtime test.")
