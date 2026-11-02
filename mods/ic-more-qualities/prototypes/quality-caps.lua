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

-- Factorio 2.1 (user decision D29 "A", 2026-11-03): keep the 2.0 rolling stock. 2.1 added quality multipliers for
-- locomotive power and rolling stock top speed (default 1 + 0.01 x level; vanilla tiers 1.2 ... 2.0 and 1.03 ... 1.15;
-- the vanilla locomotive and its copies set quality_affects_max_speed) and a separate cargo wagon inventory multiplier
-- (vanilla tiers 1.25 ... 2.5). In 2.0 quality changed neither locomotive power nor speed, and cargo wagons used
-- inventory_size_multiplier: so every quality gets 1 / 1 and the cargo wagon multiplier is removed (the engine then
-- takes inventory_size_multiplier).
function M.rolling_stock(raw)
    local changed = 0
    for _, quality in pairs(raw.quality) do
        quality.locomotive_power_multiplier = 1
        quality.rolling_stock_max_speed_multiplier = 1
        quality.cargo_wagon_inventory_size_multiplier = nil
        changed = changed + 1
    end
    return changed
end

return M
