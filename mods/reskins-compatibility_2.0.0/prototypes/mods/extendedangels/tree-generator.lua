-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then return end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    base_entity = "assembling-machine-1",
    mod = "compatibility",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "extendedangels",
    make_remnants = false,
}

local tier_map = {
    ["bio-generator-temperate-1"] = {tier = 1, field = "temperate"},
    ["bio-generator-temperate-2"] = {tier = 2, field = "temperate"},
    ["bio-generator-temperate-3"] = {tier = 3, field = "temperate"},
    ["bio-generator-swamp-1"] = {tier = 1, field = "swamp"},
    ["bio-generator-swamp-2"] = {tier = 2, field = "swamp"},
    ["bio-generator-swamp-3"] = {tier = 3, field = "swamp"},
    ["bio-generator-desert-1"] = {tier = 1, field = "desert"},
    ["bio-generator-desert-2"] = {tier = 2, field = "desert"},
    ["bio-generator-desert-3"] = {tier = 3, field = "desert"},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Setup icon_name
    inputs.icon_name = "tree-generator-"..map.field

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        layers = {
            {
                filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-shadow.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
            },
            {
                filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-base.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
            },
            {
                filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/tree-generator/tree-generator-mask.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
                tint = inputs.tint,
            },
            {
                filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/tree-generator/tree-generator-highlights.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
                blend_mode = reskins.lib.blend_mode,
            },
            {
                filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-pipes.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
            },
            {
                filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-1.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
            },
            {
                filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
            },
        }
    }

    entity.working_visualisations = {
        {
            fadeout = true,
            animation = {
                filename = "__angelsbioprocessing__/graphics/entity/trees/bio-generator-top-on.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                line_length = 1,
                frame_count = 1,
                shift = {0, 0},
                draw_as_glow = true,
            },
            light = {intensity = 4, size = 4, color = {r = 0.5, g = 1.0, b = 0.5}}
        },
    }

    -- Label to skip to next iteration
    ::continue::
end