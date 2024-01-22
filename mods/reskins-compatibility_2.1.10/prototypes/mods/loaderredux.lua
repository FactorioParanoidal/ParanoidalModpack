-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["LoaderRedux"] then return end
if mods["vanilla-loaders-hd"] then return end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

-- Set input parameters
local inputs = {
    type = "loader",
    icon_name = "loader",
    base_entity_name = "splitter",
    mod = "compatibility",
    group = "loaderredux",
    particles = { ["medium"] = 1,["big"] = 4 },
    icon_layers = 2,
    make_remnants = false,
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
    ["loader"] = { tier = 1, sprite_variant = 1 },
    ["fast-loader"] = { tier = 2, sprite_variant = 2 },
    ["express-loader"] = { tier = 3, sprite_variant = 2, },
    ["purple-loader"] = { tier = 4, sprite_variant = 2 },
    ["green-loader"] = { tier = 5, sprite_variant = 2 },
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.belt_tint_index[map.tier]

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Retint the entity mask
    entity.structure.direction_in.sheets[2].tint = inputs.tint
    entity.structure.direction_in.sheets[2].hr_version.tint = inputs.tint
    entity.structure.direction_out.sheets[2].tint = inputs.tint
    entity.structure.direction_out.sheets[2].hr_version.tint = inputs.tint

    -- Apply belt set
    -- entity.belt_animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, map.sprite_variant)

    -- Label to skip to next iteration
    ::continue::
end
