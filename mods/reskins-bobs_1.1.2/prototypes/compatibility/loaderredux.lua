-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["LoaderRedux"] then return end
if mods["vanilla-loaders-hd"] then return end
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Check if we're using the re-rendered graphics in LoaderRedux
local migration, using_new_graphics
if mods["flib"] then -- LoaderRedux requires flib as a dependency, but just in case
    migration = require("__flib__.migration")
    using_new_graphics = migration.is_newer_version("1.5.3", mods["LoaderRedux"])
end

-- Set input parameters
local inputs = {
    type = "loader",
    icon_name = "loader",
    base_entity = "splitter",
    mod = "bobs",
    group = "compatibility",
    particles = {["medium"] = 1, ["big"] = 4},
    icon_layers = 2,
    make_remnants = false,
}

-- Handle belt tier labels
if reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") == true then
    inputs.tier_labels = true
end

local tier_map = {
    ["loader"] = {tier = 1, variant = 1},
    ["fast-loader"] = {tier = 2, variant = 2},
    ["express-loader"] = {tier = 3, variant = 2,},
    ["purple-loader"] = {tier = 4, variant = 2},
    ["green-loader"] = {tier = 5, variant = 2},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, map.tier)

    -- Specify the icon we're using
    if using_new_graphics then
        inputs.subgroup = "loaderredux/new"
    else
        inputs.subgroup = "loaderredux/old"
    end

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Retint the entity mask
    if using_new_graphics then
        entity.structure.direction_in.sheets[2].tint = inputs.tint
        entity.structure.direction_in.sheets[2].hr_version.tint = inputs.tint
        entity.structure.direction_out.sheets[2].tint = inputs.tint
        entity.structure.direction_out.sheets[2].hr_version.tint = inputs.tint
    else
        entity.structure.direction_in.sheets = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/loader-base.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/hr-loader-base.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/loader-mask.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/hr-loader-mask.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    tint = inputs.tint,
                    scale = 0.5,
                }
            }
        }
        entity.structure.direction_out.sheets = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/loader-base.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                y = 128,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/hr-loader-base.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    y = 256,
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/loader-mask.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                y = 128,
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/loaderredux/loader/hr-loader-mask.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    y = 256,
                    tint = inputs.tint,
                    scale = 0.5,
                }
            }
        }
    end

    -- Apply belt set
    entity.belt_animation_set = reskins.bobs.transport_belt_animation_set(inputs.tint, map.variant)

    -- Label to skip to next iteration
    ::continue::
end