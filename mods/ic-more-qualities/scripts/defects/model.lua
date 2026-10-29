-- Pure probability model used by the runtime adapters.
-- Grades are game-design labels, not QualityPrototype.level values.
local M = {}

M.minimum_grade = -5
M.maximum_research = 10
M.research_prefix = "ic-defect-control-"

local function integer(value, minimum, maximum, label)
    assert(type(value) == "number" and value == math.floor(value)
        and value >= minimum and value <= maximum, "Invalid " .. label)
    return value
end

function M.multiplier(grade)
    integer(grade, -5, 0, "defect grade")
    return 1 / 3 + (grade + 5) * (2 / 15)
end

-- Lookup tables instead of string matching: these run on every look of the scheduler.
local GRADES = {["ic-defect-1"] = -1, ["ic-defect-2"] = -2, ["ic-defect-3"] = -3, ["ic-defect-4"] = -4, ["ic-defect-5"] = -5}
local NAMES = {[0] = "normal", [-1] = "ic-defect-1", [-2] = "ic-defect-2", [-3] = "ic-defect-3", [-4] = "ic-defect-4",
    [-5] = "ic-defect-5"}

function M.quality_name(grade)
    local name = NAMES[grade]
    if not name then integer(grade, -5, 0, "defect grade") end
    return name
end

function M.is_defect(name)
    return GRADES[name] ~= nil
end

-- Grade of a quality name; standard, positive and foreign qualities are 0.
function M.grade_of(name)
    return GRADES[name] or 0
end

-- Useful-statistic multiplier of an entity/item quality (1 for non-defects).
function M.quality_multiplier(name)
    return M.multiplier(M.grade_of(name))
end

-- Resource drain of a defective drill relative to standard (user decision 2026-10-15):
-- -1 -> 2 (200%) ... -5 -> 6 (600%). Does not depend on quality-control research.
-- The engine caps QualityPrototype::mining_drill_resource_drain_multiplier at 1, so the part
-- above standard is drained by script (scripts/defects/drill.lua).
function M.drain_multiplier(grade)
    integer(grade, -5, 0, "defect grade")
    return 1 - grade
end

function M.quality_drain_multiplier(name)
    return M.drain_multiplier(M.grade_of(name))
end

function M.research(level)
    integer(level, 1, 10, "research level")
    return {
        name = M.research_prefix .. level,
        prerequisite = level > 1 and (M.research_prefix .. (level - 1)) or nil,
        science = "automation-science-pack",
        count = level * 10,
        time = 15,
    }
end

-- Only a completed contiguous chain counts; force-specific runtime state belongs
-- to the caller. No module-global cache shared between forces or saved games.
function M.completed_level(technologies)
    assert(type(technologies) == "table" or type(technologies) == "userdata", "Expected technology lookup")
    local completed = 0
    for level = 1, 10 do
        local technology = technologies[M.research_prefix .. level]
        if not technology or not technology.researched then break end
        completed = level
    end
    return completed
end

local function geometric(minimum)
    local result, total, weight = {}, 0, 1
    for grade = -5, 0 do result[grade] = 0 end
    for grade = minimum, 0 do
        result[grade] = weight
        total = total + weight
        weight = weight / 10
    end
    for grade = minimum, 0 do result[grade] = result[grade] / total end
    return result
end

-- Every two research levels eliminate the current lowest grade. Odd levels
-- interpolate the adjacent distributions, avoiding five no-op technologies.
-- All grades ABOVE the shifting leading pair retain the 10:1 rarity ratio.
-- Level 0: normalized 1 : .1 : .01 : .001 : .0001 : .00001.
-- Level 10: exactly 100% standard, not a rounded approximation.
local function build_distribution(research_level)
    local minimum = -5 + math.floor(research_level / 2)
    local lower = geometric(minimum)
    if research_level % 2 == 0 then return lower end
    local upper = geometric(minimum + 1)
    for grade = -5, 0 do lower[grade] = (lower[grade] + upper[grade]) / 2 end
    return lower
end

-- The eleven distributions and their cumulative sums are pure functions of the level: built once.
local distributions, cumulative = {}, {}

-- Returns a shared table: callers must not modify it.
function M.distribution(research_level)
    local result = distributions[research_level]
    if not result then
        integer(research_level, 0, 10, "research level")
        result = build_distribution(research_level)
        distributions[research_level] = result
    end
    return result
end

-- Inject the RNG sample: caller must use Factorio's deterministic RNG.
-- One draw represents one newly produced item, never an existing inventory stack.
function M.draw(research_level, sample)
    local sums = cumulative[research_level]
    if not sums then
        local distribution = M.distribution(research_level)
        sums = {}
        local sum = 0
        for grade = -5, 0 do
            sum = sum + distribution[grade]
            sums[grade] = sum
        end
        cumulative[research_level] = sums
    end
    assert(type(sample) == "number" and sample >= 0 and sample < 1, "Invalid RNG sample")
    for grade = -5, -1 do
        if sample < sums[grade] then return grade end
    end
    return 0 -- Standard, also the floating-point accumulation at the final boundary.
end

return M
