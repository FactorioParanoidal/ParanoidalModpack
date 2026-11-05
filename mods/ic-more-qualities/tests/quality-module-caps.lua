-- Module effect caps of qualities (prototypes/quality-caps.lua, M.modules): 1 + 4 x tier / tiers on every
-- positive quality, tiers by level then name; normal and defects untouched. Mocks only, not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local caps = require("prototypes.quality-caps")

-- The 40 positive levels of prototypes/quality-base.lua and qualities.lua (multiplier setting 1).
local levels = {2, 3, 4, 5, 6}
for _, range in ipairs({{8, 12, 1}, {14, 18, 1}, {20, 24, 1}, {26, 34, 2}, {37, 49, 3}, {53, 69, 4}}) do
    for level = range[1], range[2], range[3] do levels[#levels + 1] = level end
end
for _, level in ipairs({77, 85, 97, 109, 133}) do levels[#levels + 1] = level end
assert(#levels == 40)

local raw = {quality = {
    normal = {name = "normal", level = 0},
    ["ic-defect-3"] = {name = "ic-defect-3", level = 0, default_multiplier = 0.6},
    ["quality-unknown"] = {name = "quality-unknown", level = 0},
}}
local by_level = {}
-- Reverse order: the result must not depend on the table order.
for index = #levels, 1, -1 do
    local name = "q" .. levels[index]
    raw.quality[name] = {name = name, level = levels[index]}
    by_level[levels[index]] = raw.quality[name]
end
-- Two qualities of one level: ordered by name.
raw.quality.b_twin = {name = "b_twin", level = 5}
raw.quality.a_twin = {name = "a_twin", level = 5}

assert(caps.modules(raw) == 42)

local function near(a, b) return math.abs(a - b) < 1e-9 end
local function check(quality, expected)
    for _, field in ipairs(caps.module_fields) do
        assert(near(quality[field], expected), quality.name .. " " .. field .. " " .. tostring(quality[field]))
    end
end
-- 42 tiers here: level 2,3,4 are tiers 1-3, a_twin 4, b_twin 5, level 5 (q5) 6.
check(by_level[2], 1 + 4 * 1 / 42)
check(raw.quality.a_twin, 1 + 4 * 4 / 42)
check(raw.quality.b_twin, 1 + 4 * 5 / 42)
check(by_level[5], 1 + 4 * 6 / 42)
check(by_level[133], 5)
for _, name in ipairs({"normal", "ic-defect-3", "quality-unknown"}) do
    for _, field in ipairs(caps.module_fields) do assert(raw.quality[name][field] == nil, name .. " " .. field) end
end
assert(raw.quality["ic-defect-3"].default_multiplier == 0.6)

-- The real 40 tiers: the values agreed with the user (variant B).
local real = {quality = {normal = {name = "normal", level = 0}}}
for _, level in ipairs(levels) do real.quality["q" .. level] = {name = "q" .. level, level = level} end
assert(caps.modules(real) == 40)
for level, expected in pairs({[2] = 1.1, [5] = 1.4, [12] = 2.0, [24] = 3.0, [34] = 3.5, [49] = 4.0, [69] = 4.5,
    [109] = 4.9, [133] = 5.0}) do
    assert(near(real.quality["q" .. level].module_speed_multiplier, expected), level)
end
-- Every tier is stronger than the one below; all values within the engine limit (>= 0.01).
local previous = 1
for _, level in ipairs(levels) do
    local value = real.quality["q" .. level].module_productivity_multiplier
    assert(value > previous and value >= 0.01)
    previous = value
end
assert(caps.modules({}) == 0)

print("Module caps: 40 tiers x1.1 ... x5, linear over the tier, 5 fields, normal and defects untouched. Mocks only.")
