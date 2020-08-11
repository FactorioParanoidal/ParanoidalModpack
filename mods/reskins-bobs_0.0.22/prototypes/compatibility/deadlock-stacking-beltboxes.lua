-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["deadlock-beltboxes-loaders"] then return end
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- We reskin the base entities only if we're doing custom colors
local custom_colors = true
if reskins.lib.setting("reskins-lib-customize-tier-colors") == false then
    custom_colors = false
end

-- Set input parameters
local inputs = {
    base_entity = "underground-belt",
    mod = "bobs",
    particles = {["medium"] = 3, ["small"] = 2},
    make_icons = false,
    make_remnants = false,
}

-- Handle belt tier labels
if reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") == true then
    inputs.tier_labels = true
end

local tier_map = {
    ["basic-transport-belt-loader"] = {0, 1, true},
    ["transport-belt-loader"] = {1, 1, custom_colors},
    ["fast-transport-belt-loader"] = {2, 2, custom_colors},
    ["express-transport-belt-loader"] = {3, 2, custom_colors},
    ["turbo-transport-belt-loader"] = {4, 2, true},
    ["ultimate-transport-belt-loader"] = {5, 2, true},
    ["basic-transport-belt-beltbox"] = {0, 1, true},
    ["transport-belt-beltbox"] = {1, 1, custom_colors},
    ["fast-transport-belt-beltbox"] = {2, 2, custom_colors},
    ["express-transport-belt-beltbox"] = {3, 2, custom_colors},
    ["turbo-transport-belt-beltbox"] = {4, 2, true},
    ["ultimate-transport-belt-beltbox"] = {5, 2, true},
}

local function light_tint(tint)
    local white = 0.95
    return {r = (tint.r + white)/2, g = (tint.g + white)/2, b = (tint.b + white)/2}
end

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Determine type
    local is_loader = string.find(name, "loader")

    if is_loader then
        inputs.type = "loader-1x1"
    else
        inputs.type = "furnace"
    end

    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    local variant = map[2]
    local do_reskin = map[3]

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    reskins.lib.setup_standard_entity(name, tier, inputs)    
    
    if do_reskin then
        if is_loader then
            -- Retint the mask
            entity.structure.direction_in.sheets[3].tint = inputs.tint
            entity.structure.direction_in.sheets[3].hr_version.tint = inputs.tint
            entity.structure.direction_out.sheets[3].tint = inputs.tint
            entity.structure.direction_out.sheets[3].hr_version.tint = inputs.tint

            -- Apply belt set
            entity.belt_animation_set = reskins.bobs.transport_belt_animation_set(inputs.tint, variant)
        else
            -- Retint the mask
            entity.animation.layers[2].tint = inputs.tint
            entity.animation.layers[2].hr_version.tint = inputs.tint
            entity.working_visualisations[1].animation.tint = light_tint(inputs.tint)
            entity.working_visualisations[1].animation.hr_version.tint = light_tint(inputs.tint)
            entity.working_visualisations[1].light.color = light_tint(inputs.tint)

        end
    end

    -- Icon handling
    if is_loader then
        inputs.icon = {
            {
                icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/loader-icon-base.png"
            },
            {
                icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/loader-icon-mask.png",
                tint = inputs.tint,
            }
        }

        inputs.icon_picture = {
            layers = {
                {
                    filename = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/loader-icon-base.png",
                    size = 64,
                    scale = 0.25,
                    mipmaps = 4,
                },
                {
                    filename = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/loader-icon-mask.png",
                    size = 64,
                    scale = 0.25,
                    mipmaps = 4,
                    tint = inputs.tint
                }
            }
        }
    else
        inputs.icon = {
            {
                icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/beltbox-icon-base.png"
            },
            {
                icon = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/beltbox-icon-mask.png",
                tint = inputs.tint,
            }
        }

        inputs.icon_picture = {
            layers = {
                {
                    filename = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/beltbox-icon-base.png",
                    size = 64,
                    scale = 0.25,
                    mipmaps = 4,
                },
                {
                    filename = "__deadlock-beltboxes-loaders__/graphics/icons/mipmaps/beltbox-icon-mask.png",
                    size = 64,
                    scale = 0.25,
                    mipmaps = 4,
                    tint = inputs.tint
                }
            }
        }
    end

    reskins.lib.append_tier_labels(tier, inputs)
    reskins.lib.assign_icons(name, inputs)

    -- Label to skip to next iteration
    ::continue::
end

-- Technology
local tech_map = {
    ["basic-transport-belt-beltbox"] = 0,
    ["deadlock-stacking-1"] = 1,
    ["deadlock-stacking-2"] = 2,
    ["deadlock-stacking-3"] = 3,
    ["deadlock-stacking-4"] = 4,
    ["deadlock-stacking-5"] = 5,
}

-- Reskin technologies
for name, tier in pairs(tech_map) do
    -- Fetch technology
    local technology = data.raw.technology[name]

    -- Check if technology exists, if not, skip this iteration
    if not technology then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    -- Retint the mask
    technology.icons[2].tint = inputs.tint
    
    -- Label to skip to next iteration
    ::continue::
end