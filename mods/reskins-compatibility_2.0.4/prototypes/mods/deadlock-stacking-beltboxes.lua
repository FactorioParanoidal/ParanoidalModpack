-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
-- if not reskins.bobs then return end
if not mods["deadlock-beltboxes-loaders"] then return end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

-- Set input parameters
local inputs = {
    base_entity = "underground-belt",
    mod = "compatibility",
    particles = {["medium"] = 3, ["small"] = 2},
    make_icons = false,
    make_remnants = false,
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
    ["basic-transport-belt-loader"] = {tier = 0, is_loader = true, sprite_variant = 1},
    ["transport-belt-loader"] = {tier = 1, is_loader = true, sprite_variant = 1},
    ["fast-transport-belt-loader"] = {tier = 2, is_loader = true, sprite_variant = 2},
    ["express-transport-belt-loader"] = {tier = 3, is_loader = true, sprite_variant = 2},
    ["turbo-transport-belt-loader"] = {tier = 4, is_loader = true, sprite_variant = 2},
    ["ultimate-transport-belt-loader"] = {tier = 5, is_loader = true, sprite_variant = 2},
    ["basic-transport-belt-beltbox"] = {tier = 0, sprite_variant = 1},
    ["transport-belt-beltbox"] = {tier = 1, sprite_variant = 1},
    ["fast-transport-belt-beltbox"] = {tier = 2, sprite_variant = 2},
    ["express-transport-belt-beltbox"] = {tier = 3, sprite_variant = 2},
    ["turbo-transport-belt-beltbox"] = {tier = 4, sprite_variant = 2},
    ["ultimate-transport-belt-beltbox"] = {tier = 5, sprite_variant = 2},
}

local function light_tint(tint)
    local white = 0.95
    return {r = (tint.r + white)/2, g = (tint.g + white)/2, b = (tint.b + white)/2}
end

local function tweak_tint(tint)
    local hsl_tint = reskins.lib.RGBtoHSL(tint)
    hsl_tint.s = (hsl_tint.s - 0.1 >= 0) and hsl_tint.s - 0.1 or 0
    -- hsl_tint.l = (hsl_tint.l - 0.2 >= 0) and hsl_tint.l - 0.2 or 0

    return reskins.lib.HSLtoRGB(hsl_tint)
end

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Determine type
    if map.is_loader then
        inputs.type = "loader-1x1"
    else
        inputs.type = "furnace"
    end

    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = tweak_tint(reskins.lib.belt_tint_index[map.tier])

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    if map.is_loader then
        -- Retint the mask
        entity.structure.direction_in.sheets[3].tint = inputs.tint
        entity.structure.direction_in.sheets[3].hr_version.tint = inputs.tint
        entity.structure.direction_out.sheets[3].tint = inputs.tint
        entity.structure.direction_out.sheets[3].hr_version.tint = inputs.tint

        -- Apply belt set
        -- entity.belt_animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, map.sprite_variant)

        -- Icon handling
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
        -- Retint the mask
        entity.animation.layers[2].tint = inputs.tint
        entity.animation.layers[2].hr_version.tint = inputs.tint
        entity.working_visualisations[1].animation.tint = light_tint(inputs.tint)
        entity.working_visualisations[1].animation.hr_version.tint = light_tint(inputs.tint)
        entity.working_visualisations[1].light.color = light_tint(inputs.tint)

        -- Icon handling
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

    reskins.lib.append_tier_labels(map.tier, inputs)
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

    local inputs = {
        technology_icon = {
            { icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/beltbox-icon-base-128.png" },
            { icon = "__deadlock-beltboxes-loaders__/graphics/icons/square/beltbox-icon-mask-128.png", tint = reskins.lib.belt_tint_index[tier] },
        },
        technology_icon_size = 128,
        technology_icon_mipmaps = 1,
    }

    reskins.lib.assign_technology_icons(name, inputs)

    -- Label to skip to next iteration
    ::continue::
end