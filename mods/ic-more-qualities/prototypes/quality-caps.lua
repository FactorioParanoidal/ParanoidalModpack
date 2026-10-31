-- Paranoidal (2026-10-31): at the highest quality fuel acceleration, fuel top speed and chest slots are at
-- most x8 of normal, growing linearly with the quality level.
local M = {}
M.factor = 8

local function top_level(raw)
    local top = 0
    for _, quality in pairs(raw.quality or {}) do
        if (quality.level or 0) > top then top = quality.level end
    end
    return top
end

-- Fuel bonus per level: engine default 30% of (multiplier - 1), never raised.
function M.fuel(raw)
    local top = top_level(raw)
    local changed = 0
    if top <= 0 then return changed end
    for _, list in pairs(raw) do
        for _, item in pairs(list) do
            if type(item) == "table" and item.stack_size and item.fuel_value then
                local touched = false
                for _, kind in ipairs({"acceleration", "top_speed"}) do
                    local base = item["fuel_" .. kind .. "_multiplier"] or 1
                    local key = "fuel_" .. kind .. "_multiplier_quality_bonus"
                    local bonus = item[key]
                    if bonus == nil then bonus = base > 1 and 0.3 * (base - 1) or 0 end
                    local cap = (M.factor - 1) * base / top
                    if bonus > cap then
                        item[key] = cap
                        touched = true
                    end
                end
                if touched then changed = changed + 1 end
            end
        end
    end
    return changed
end

-- Chest and cargo wagon slots (inventory_size_multiplier): positive qualities only, defects keep theirs.
function M.inventory(raw)
    local top = top_level(raw)
    local changed = 0
    if top <= 0 then return changed end
    for _, quality in pairs(raw.quality) do
        local level = quality.level or 0
        if level > 0 then
            quality.inventory_size_multiplier = 1 + (M.factor - 1) * level / top
            changed = changed + 1
        end
    end
    return changed
end

return M
