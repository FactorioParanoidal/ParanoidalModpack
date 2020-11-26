-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["miniloader"] then return end
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- We reskin the base entities only if we're doing custom colors
local custom_colors = true
if reskins.lib.setting("reskins-lib-customize-tier-colors") == false then
    custom_colors = false
end

-- Set input parameters
local inputs = {
    icon_name = "miniloader",
    base_entity = "splitter",
    mod = "bobs",
    group = "compatibility",
    subgroup = "miniloader",
    particles = {["medium"] = 1, ["big"] = 4},
    icon_layers = 2,
    technology_icon_layers = 2,
    make_remnants = false,
}

-- Handle belt tier labels
if reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") == true then
    inputs.tier_labels = true
end

local tier_map = {
    -- 1x1 Loader Entities
    ["basic-miniloader-loader"] = {0, 1, true},
    ["chute-miniloader-loader"] = {0, 1, true},
    ["miniloader-loader"] = {1, 1, custom_colors},
    ["fast-miniloader-loader"] = {2, 2, custom_colors},
    ["express-miniloader-loader"] = {3, 2, custom_colors},
    ["turbo-miniloader-loader"] = {4, 2, true},
    ["ultimate-miniloader-loader"] = {5, 2, true},
    ["filter-miniloader-loader"] = {1, 1, custom_colors},
    ["fast-filter-miniloader-loader"] = {2, 2, custom_colors},
    ["express-filter-miniloader-loader"] = {3, 2, custom_colors},
    ["turbo-filter-miniloader-loader"] = {4, 2, true},
    ["ultimate-filter-miniloader-loader"] = {5, 2, true},

    -- Inserter Entities
    ["basic-miniloader-inserter"] = {0},
    ["chute-miniloader-inserter"] = {0},
    ["miniloader-inserter"] = {1},
    ["fast-miniloader-inserter"] = {2},
    ["express-miniloader-inserter"] = {3},
    ["turbo-miniloader-inserter"] = {4},
    ["ultimate-miniloader-inserter"] = {5},
    ["filter-miniloader-inserter"] = {1},
    ["fast-filter-miniloader-inserter"] = {2},
    ["express-filter-miniloader-inserter"] = {3},
    ["turbo-filter-miniloader-inserter"] = {4},
    ["ultimate-filter-miniloader-inserter"] = {5},
}

local item_map = {
    ["basic-miniloader"] = 0,
    ["chute-miniloader"] = 0,
    ["miniloader"] = 1,
    ["fast-miniloader"] = 2,
    ["express-miniloader"] = 3,
    ["turbo-miniloader"] = 4,
    ["ultimate-miniloader"] = 5,
    ["filter-miniloader"] = 1,
    ["fast-filter-miniloader"] = 2,
    ["express-filter-miniloader"] = 3,
    ["turbo-filter-miniloader"] = 4,
    ["ultimate-filter-miniloader"] = 5,
}

-- Reskin entities
for name, map in pairs(tier_map) do
    if not string.find(name, "inserter") then
        inputs.type = "loader-1x1"
        inputs.make_explosions = false
    else
        inputs.type = "inserter"
        inputs.make_explosions = true
    end

    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then
        goto continue
    end

    -- Parse map
    local tier = map[1]
    local variant = map[2] or nil
    local do_reskin = map[3] or nil

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Retint the mask
    if not string.find(name, "inserter") then
            entity.structure.direction_in.sheets[2].tint = inputs.tint
            entity.structure.direction_in.sheets[2].hr_version.tint = inputs.tint
            entity.structure.direction_out.sheets[2].tint = inputs.tint
            entity.structure.direction_out.sheets[2].hr_version.tint = inputs.tint
    else
        entity.corpse = "small-remnants"
        entity.platform_picture.sheets[2].tint = inputs.tint
        entity.platform_picture.sheets[2].hr_version.tint = inputs.tint
    end

    -- Apply belt set
    if variant and do_reskin then
        entity.belt_animation_set = reskins.bobs.transport_belt_animation_set(inputs.tint, variant)
    end

    -- Label to skip to next iteration
    ::continue::
end

-- Reskin icons
for name, tier in pairs(item_map) do
    -- Fetch item
    local item = data.raw["item"][name]

    -- Check if item exists, if not, skip this iteration
    if not item then goto continue end

    -- Setup icon details
    if string.find(name, "filter") then
        inputs.icon_base = "filter-miniloader"
    else
        inputs.icon_base = "miniloader"
    end

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    reskins.lib.construct_icon(name, tier, inputs)

    -- Handle grouping and ordering in the UI
    local base_item
    if name ~= "chute-miniloader" then
        base_item = data.raw["item"][string.gsub(string.gsub(name, "filter%-", ""), "miniloader", "transport-belt")]
    elseif data.raw["item"]["basic-transport-belt"] then
        base_item = data.raw["item"]["basic-transport-belt"]
    end

    if base_item then
        inputs.sort_order = string.gsub(string.gsub(item.order,"^[a-z]","d"),"transport%-belt","miniloader")
        inputs.sort_group = base_item.group
        inputs.sort_subgroup = base_item.subgroup

        if string.find(name, "filter") then
            inputs.sort_order = string.gsub(inputs.sort_order, "filter", "n-filter")
        elseif name == "chute-miniloader" then
            inputs.sort_order = string.gsub(inputs.sort_order, "miniloader", "z-miniloader")
        end

        reskins.lib.assign_order(name, inputs)
    end

    -- Label to skip to next iteration
    ::continue::
end

-- Technologies
local technology_map = {
    ["basic-miniloader"] = 0,
    ["miniloader"] = 1,
    ["fast-miniloader"] = 2,
    ["express-miniloader"] = 3,
    ["turbo-miniloader"] = 4,
    ["ultimate-miniloader"] = 5,
}

-- Reskin technologies
for name, tier in pairs(technology_map) do
    -- Fetch technology
    local technology = data.raw["technology"][name]

    -- Check if entity exists, if not, skip this iteration
    if not technology then goto continue end

    -- Fix inputs
    inputs.icon_base = nil

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    reskins.lib.construct_technology_icon(name, inputs)

    -- Label to skip to next iteration
    ::continue::
end