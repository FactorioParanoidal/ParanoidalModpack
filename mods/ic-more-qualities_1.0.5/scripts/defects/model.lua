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

-- Independent production failure, configurable in percent. Not a quality roll.
-- Default: 33%, 29.7%, ... 3.3%, 0%. Level ten always has exactly zero loss.
M.default_loss_percent = 33

function M.loss_probability(research_level, initial_percent)
    integer(research_level, 0, 10, "research level")
    if initial_percent == nil then initial_percent = M.default_loss_percent end
    assert(type(initial_percent) == "number" and initial_percent >= 0 and initial_percent <= 100,
        "Invalid initial loss percent")
    return initial_percent * (10 - research_level) / 1000
end

function M.production_failed(research_level, sample, initial_percent)
    assert(type(sample) == "number" and sample >= 0 and sample < 1, "Invalid RNG sample")
    return sample < M.loss_probability(research_level, initial_percent)
end

function M.roll_loss(research_level, random, initial_percent)
    if M.loss_probability(research_level, initial_percent) == 0 then return false end
    return M.production_failed(research_level, random(), initial_percent)
end

function M.multiplier(grade)
    integer(grade, -5, 0, "defect grade")
    return 1 / 3 + (grade + 5) * (2 / 15)
end

function M.quality_name(grade)
    integer(grade, -5, 0, "defect grade")
    return grade == 0 and "normal" or ("ic-defect-" .. -grade)
end

function M.is_defect(name)
    return type(name) == "string" and name:match("^ic%-defect%-[1-5]$") ~= nil
end

-- Grade of a quality name; standard, positive and foreign qualities are 0.
function M.grade_of(name)
    local tier = type(name) == "string" and name:match("^ic%-defect%-([1-5])$")
    return tier and -tonumber(tier) or 0
end

-- Useful-statistic multiplier of an entity/item quality (1 for non-defects).
function M.quality_multiplier(name)
    return M.multiplier(M.grade_of(name))
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
function M.distribution(research_level)
    integer(research_level, 0, 10, "research level")
    local minimum = -5 + math.floor(research_level / 2)
    local lower = geometric(minimum)
    if research_level % 2 == 0 then return lower end
    local upper = geometric(minimum + 1)
    for grade = -5, 0 do lower[grade] = (lower[grade] + upper[grade]) / 2 end
    return lower
end

-- Inject the RNG sample: caller must use Factorio's deterministic RNG.
-- One draw represents one newly produced item, never an existing inventory stack.
function M.draw(research_level, sample)
    assert(type(sample) == "number" and sample >= 0 and sample < 1, "Invalid RNG sample")
    local distribution = M.distribution(research_level)
    local sum = 0
    for grade = -5, 0 do
        sum = sum + distribution[grade]
        if sample < sum then return grade end
    end
    return 0 -- Floating-point accumulation at the final boundary only.
end

-- A confirmed native module upgrade wins over the defect draw, including before
-- research 10. Do not infer this flag from an item's existing quality: that would
-- incorrectly exempt carried-in quality ingredients and reroll old inventory.
-- Returning nil delegates the positive result to the native quality adapter.
function M.draw_unless_upgraded(research_level, sample, module_upgraded)
    assert(type(module_upgraded) == "boolean", "Expected confirmed module upgrade flag")
    local grade = M.draw(research_level, sample)
    if module_upgraded then return nil end
    return grade
end

return M
