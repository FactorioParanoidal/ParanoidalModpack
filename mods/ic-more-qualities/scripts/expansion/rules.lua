-- Pure rules of the quality-control expansion: refinement cost and outcome, production modes,
-- module quality boost and control-post routing. No Factorio API; used by data stage, runtime and tests.
local M = {}

---------------------------------------------------------------------------------------------------
-- Refinement workshop
---------------------------------------------------------------------------------------------------
M.PACK_DURABILITY = 300   -- one basic repair pack: the unit in which costs are expressed
M.BASE_PACKS = 5          -- an average item costs 5 basic packs per attempt...
M.SECONDS_PER_PACK = 2    -- ...and takes 10 seconds
M.SUCCESS = 0.9           -- 10% of attempts leave the item unchanged
M.JUMP = 0.1              -- after a success, every further grade is gained with 10%
M.RESET_SHARE = 0.2       -- resetting positive quality takes 1/5 of the attempt time, no packs
M.MAX_SPEED = 4           -- positive-quality workshops are capped at x4 speed (whole-tick control)

-- Science factor S by the number of science pack kinds of the earliest research of the item.
-- nil: no researchable recipe (treated as an average item).
function M.science_factor(kinds)
    if kinds == nil then return 1 end
    assert(type(kinds) == "number" and kinds >= 0, "Invalid science kind count")
    if kinds <= 1 then return 0.2 end
    if kinds == 2 then return 1 end
    if kinds <= 4 then return 3 end
    if kinds <= 6 then return 8 end
    return 20
end

-- Health factor H = sqrt(health / 300) clamped to 0.5 .. 3; items without health: 1.
function M.health_factor(health)
    if type(health) ~= "number" or health <= 0 then return 1 end
    return math.min(3, math.max(0.5, math.sqrt(health / 300)))
end

-- Cost of one attempt in durability units and its duration in seconds. Independent of the grade.
function M.attempt(kinds, health)
    local s, h = M.science_factor(kinds), M.health_factor(health)
    local packs = M.BASE_PACKS * s * h
    local cost = math.floor(packs * M.PACK_DURABILITY + 0.5)
    return cost, cost / M.PACK_DURABILITY * M.SECONDS_PER_PACK, s, h
end

local function check_grade(grade)
    assert(type(grade) == "number" and grade == math.floor(grade) and grade >= -5 and grade <= -1,
        "Refinement needs a defect grade -5..-1")
end

-- One attempt. random() must be Factorio's deterministic generator.
function M.refine_outcome(grade, random)
    check_grade(grade)
    if random() >= M.SUCCESS then return grade end
    local result = grade + 1
    while result < 0 and random() < M.JUMP do result = result + 1 end
    return result
end

-- Exact distribution of one attempt: {[resulting grade] = probability}.
function M.refine_distribution(grade)
    check_grade(grade)
    local result = {[grade] = 1 - M.SUCCESS}
    local carry, g = M.SUCCESS, grade + 1
    while g < 0 do
        result[g] = (result[g] or 0) + carry * (1 - M.JUMP)
        carry, g = carry * M.JUMP, g + 1
    end
    result[0] = (result[0] or 0) + carry
    return result
end

-- Expected number of attempts to reach standard quality from a grade (0 for standard).
function M.expected_attempts(grade)
    if grade >= 0 then return 0 end
    local expected = {[0] = 0}
    for g = -1, grade, -1 do
        local d = M.refine_distribution(g)
        local sum = 1
        for target = g + 1, 0 do sum = sum + (d[target] or 0) * expected[target] end
        expected[g] = sum / (1 - d[g])
    end
    return expected[grade]
end

-- Resource that still has to be paid so that the paid share stays ahead of the progress by
-- `lead` (fraction of the attempt). Returns the durability units to drain now.
function M.prepay(cost, paid_share, progress, lead)
    local target = math.min(1, progress + lead)
    if paid_share >= target then return 0 end
    return (target - paid_share) * cost
end

---------------------------------------------------------------------------------------------------
-- Production modes
---------------------------------------------------------------------------------------------------
-- time: duration multiplier; energy: energy per operation multiplier; loss: production loss
-- multiplier; level_bonus: extra quality-control levels for the defect distribution;
-- no_defect: new results are never below standard; boost: equivalent independent quality rolls.
M.modes = {
    normal = {name = "normal", time = 1, energy = 1, loss = 1, level_bonus = 0, no_defect = false, boost = 1},
    careful = {name = "careful", time = 5, energy = 10, loss = 0.1, level_bonus = 4, no_defect = false, boost = 3},
    precise = {name = "precise", time = 20, energy = 100, loss = 0, level_bonus = 0, no_defect = true, boost = 10},
}
M.mode_order = {"normal", "careful", "precise"}

-- The slowed machine keeps drawing its own power for `time` times longer; the remainder of the
-- energy is drawn additionally: extra power in multiples of the machine's own power.
function M.extra_power(mode)
    return mode.energy / mode.time - 1
end

-- Defect-control level used for the defect distribution of a mode (capped at 10).
function M.effective_level(level, mode)
    return math.min(10, level + (mode and mode.level_bonus or 0))
end

-- Chance that at least one of n independent rolls with chance p succeeds.
function M.boosted_chance(p, n)
    if p <= 0 then return 0 end
    if p >= 1 then return 1 end
    return 1 - (1 - p) ^ n
end

-- Conditional chance to upgrade after the native roll (chance p) has already failed, so that the
-- total chance equals boosted_chance(p, n).
function M.extra_chance(p, n)
    if p <= 0 or p >= 1 or n <= 1 then return 0 end
    return 1 - (1 - p) ^ (n - 1)
end

---------------------------------------------------------------------------------------------------
-- Control post
---------------------------------------------------------------------------------------------------
M.conditions = {"strict", "at-least"}

-- quality: {grade = -5..0 (defect grades negative), rank = level of non-defect quality, normal = bool}
-- Returns "good", "refine" or "other".
function M.route(order, item, quality, remaining)
    if not order or not order.item or item ~= order.item then return "other" end
    local target
    if quality.grade < 0 then
        return "refine"
    elseif order.condition == "strict" then
        if not quality.normal then return "refine" end
        target = "good"
    else
        target = quality.rank >= (order.rank or 0) and "good" or "other"
    end
    if target == "good" and (remaining or 0) <= 0 then return "other" end
    return target
end

-- Output side for a route relative to the facing direction (0 north .. 3 west).
-- Forward: accepted; left: refinement; right: everything else.
function M.output_direction(facing, route)
    local turn = route == "good" and 0 or route == "refine" and 3 or 1
    return (facing + turn) % 4
end

M.direction_vectors = {[0] = {0, -1}, [1] = {1, 0}, [2] = {0, 1}, [3] = {-1, 0}}

return M
