-- Start level, amounts and the per-map quality of every start item (shipwreck-config.lua).
local config = require("shipwreck-config")
local M = {}

function M.level_name()
    local setting = settings.startup[config.setting]
    local value = setting and setting.value
    if config.levels[value] then return value end
    return config.default_level
end

function M.level()
    return config.levels[M.level_name()]
end

-- Level multiplier, rounded up, at least 1 for a non-zero count.
function M.scale(count)
    local factor = M.level().amount or 1
    if factor == 1 or count <= 0 then return count end
    return math.max(1, math.ceil(count * factor))
end

-- Count of one config entry {name, min, max, p = chance} at the current level.
function M.roll(entry)
    if entry.p and math.random() >= entry.p then return 0 end
    local low = M.scale(entry[2])
    local high = M.scale(entry[3] or entry[2])
    if high <= low then return low end
    return math.random(low, high)
end

local function classification()
    local mod_data = prototypes.mod_data[config.classification]
    return mod_data and mod_data.data
end

local function step_up(steps)
    local quality = prototypes.quality.normal
    for _ = 1, steps do
        if not (quality and quality.next) then break end
        quality = quality.next
    end
    return quality and quality.name or "normal"
end

local function place_type(name)
    local item = prototypes.item[name]
    local entity = item and item.place_result
    return entity and entity.type
end

local function always_defect(name)
    return config.always_defect_place_types[place_type(name) or ""] == true
end

local function never_quality(name)
    return config.never_quality_place_types[place_type(name) or ""] == true
end

-- Weighted number of steps 0..quality_steps from level.weights (index 1 = 0 steps).
local function roll_steps(weights)
    local total = 0
    for i = 1, config.quality_steps + 1 do total = total + math.max(0, weights[i] or 0) end
    if total <= 0 then return 0 end
    local pick = math.random() * total
    for i = 1, config.quality_steps + 1 do
        pick = pick - math.max(0, weights[i] or 0)
        if pick < 0 then return i - 1 end
    end
    return config.quality_steps
end

local function roll_quality(name)
    local level = M.level()
    local class = classification()
    local finished = class and class.finished and class.finished[name]
    if not finished or not level.weights or never_quality(name) then return "normal" end
    local steps = roll_steps(level.weights)
    if steps == 0 then return "normal" end
    if level.defects then
        if class.no_defect and class.no_defect[name] and not always_defect(name) then return "normal" end
        local defect = config.defect_prefix .. steps
        return prototypes.quality[defect] and defect or "normal"
    end
    if level.bonus then return step_up(steps) end
    return "normal"
end

-- The same quality for every stack of one item in the start crash of this map.
function M.of(state, name)
    local quality = state.qualities[name]
    if not quality then
        quality = roll_quality(name)
        state.qualities[name] = quality
    end
    return quality
end

function M.available(name)
    if prototypes.item[name] then return true end
    log("zzzparanoidal-shipwreck: optional start item unavailable: " .. name)
    return false
end

return M
