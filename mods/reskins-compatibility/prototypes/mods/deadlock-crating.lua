-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["DeadlockCrating"] and not mods["IntermodalContainers"] then return end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    base_entity_name = "assembling-machine-1",
    mod = "compatibility",
    particles = { ["big"] = 1, ["medium"] = 2 },
    make_icons = false,
    make_remnants = false,
}

local tier_map = {}

local root
if mods["IntermodalContainers"] then
    root = "__IntermodalContainers__"

    tier_map["ic-containerization-machine-1"] = { tier = 1 }
    tier_map["ic-containerization-machine-2"] = { tier = 2 }
    tier_map["ic-containerization-machine-3"] = { tier = 3 }
    tier_map["ic-containerization-machine-4"] = { tier = 4 }
    tier_map["ic-containerization-machine-5"] = { tier = 5 }
elseif mods["DeadlockCrating"] then
    root = "__DeadlockCrating__"

    tier_map["deadlock-crating-machine-1"] = { tier = 1 }
    tier_map["deadlock-crating-machine-2"] = { tier = 2 }
    tier_map["deadlock-crating-machine-3"] = { tier = 3 }
    tier_map["deadlock-crating-machine-4"] = { tier = 4 }
    tier_map["deadlock-crating-machine-5"] = { tier = 5 }
end

local function light_tint(tint)
    local white = 0.95
    return { r = (tint.r + white) / 2, g = (tint.g + white) / 2, b = (tint.b + white) / 2 }
end

local function tweak_tint(tint)
    local hsl_tint = reskins.lib.RGBtoHSL(tint)
    hsl_tint.s = (hsl_tint.s - 0.1 >= 0) and hsl_tint.s - 0.1 or 0
    -- hsl_tint.l = (hsl_tint.l - 0.2 >= 0) and hsl_tint.l - 0.2 or 0

    return reskins.lib.HSLtoRGB(hsl_tint)
end

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = tweak_tint(reskins.lib.belt_tint_index[map.tier])

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Retint the mask
    entity.animation.layers[2].tint = inputs.tint
    entity.animation.layers[2].hr_version.tint = inputs.tint
    entity.working_visualisations[1].animation.tint = light_tint(inputs.tint)
    entity.working_visualisations[1].animation.hr_version.tint = light_tint(inputs.tint)
    entity.working_visualisations[1].light.color = light_tint(inputs.tint)

    -- Icon handling
    ---@type data.IconData[]
    local icons = {
        {
            icon = root .. "/graphics/icons/mipmaps/crating-icon-base.png",
            icon_size = 64,
            icon_mipmaps = 4,
        },
        {
            icon = root .. "/graphics/icons/mipmaps/crating-icon-mask.png",
            icon_size = 64,
            icon_mipmaps = 4,
            tint = inputs.tint,
        },
    }

    inputs.icon = reskins.lib.add_tier_labels_to_icons(icons, map.tier)
    inputs.icon_picture = reskins.lib.convert_icons_to_sprite(icons, 0.25)

    reskins.lib.assign_icons(name, inputs)

    -- Tech handling
    local technology = data.raw.technology[string.gsub(name, "machine%-", "")]
    if not technology then goto continue end

    technology.icons[2].tint = inputs.tint

    -- Label to skip to next iteration
    ::continue::
end
