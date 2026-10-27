-- Rewards fixed at the map start: the variant and the exact contents of the captain's safe and of
-- the severance pod are rolled once on a new map from a generator seeded with the map seed (not
-- math.random: the same seed gives the same rewards, nothing done before the reward changes it)
-- and kept in storage, so reloading a save cannot reroll them. Items of missing mods are skipped.
local config = require("bnl-config")
local quality = require("scripts.quality")
local M = {}

local function weighted(rng, list)
    local total = 0
    for _, entry in ipairs(list) do total = total + entry.weight end
    local pick = rng() * total
    for _, entry in ipairs(list) do
        pick = pick - entry.weight
        if pick < 0 then return entry end
    end
    return list[#list]
end

local function between(rng, range)
    if type(range) == "number" then return range end
    if range[2] <= range[1] then return range[1] end
    return rng(range[1], range[2])
end

-- Every roll is drawn even for a missing item, so the rest of the list does not depend on the mods.
local function roll(rng, variant)
    local items = {}
    for _, entry in ipairs(variant.items) do
        local count = between(rng, {entry[2], entry[3]})
        local q = entry.quality or "normal"
        if entry.quality_steps then q = quality.step_up(between(rng, entry.quality_steps)) end
        if entry.defect then
            local grade = between(rng, entry.defect)
            local name = "ic-defect-" .. grade
            if prototypes.quality[name] and quality.can_defect(entry[1]) then q = name end
        end
        if not prototypes.quality[q] then q = "normal" end
        if prototypes.item[entry[1]] then
            items[#items + 1] = {name = entry[1], count = count, quality = q}
        else
            log("zzzparanoidal-start-bnl: reward item unavailable: " .. entry[1])
        end
    end
    return {key = variant.key, items = items}
end

-- New map (control.lua bnl_init): one generator, a fixed order of rolls.
function M.init()
    local rng = game.create_random_generator()
    storage.bnl.loot = {
        safe = roll(rng, weighted(rng, config.safe.loot)),
        severance = roll(rng, weighted(rng, config.distress.severance)),
    }
end

-- {key, items = {{name, count, quality}}} of "safe" or "severance".
function M.get(kind)
    local loot = storage.bnl and storage.bnl.loot
    if not loot then
        M.init()
        loot = storage.bnl.loot
    end
    return loot[kind]
end

-- Inserts a reward into an inventory; what does not fit spills next to `entity`.
function M.give(kind, inventory, entity)
    for _, stack in ipairs(M.get(kind).items) do
        local n = inventory.insert(stack)
        if n < stack.count and entity and entity.valid then
            entity.surface.spill_item_stack({position = entity.position,
                stack = {name = stack.name, count = stack.count - n, quality = stack.quality},
                enable_looted = true, allow_belts = false})
        end
    end
end

return M
