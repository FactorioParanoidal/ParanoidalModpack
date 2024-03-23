-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "electrolyser",
    base_entity_name = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["angels-electrolyser"] = {tier = 1},
    ["angels-electrolyser-2"] = {tier = 2},
    ["angels-electrolyser-3"] = {tier = 3},
    ["angels-electrolyser-4"] = {tier = 4},
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

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Setup shared layers
    local entity_mask = {
        filename = reskins.angels.directory.."/graphics/entity/petrochem/electrolyser/electrolyser-mask.png",
        priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 36,
        line_length = 6,
        shift = {0, 0},
        animation_speed = 0.5,
        tint = inputs.tint,
    }

    local entity_highlights = {
        filename = reskins.angels.directory.."/graphics/entity/petrochem/electrolyser/electrolyser-highlights.png",
        priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 36,
        line_length = 6,
        shift = {0, 0},
        animation_speed = 0.5,
        blend_mode = reskins.lib.blend_mode,
    }

    local entity_horizontal_base = {
        filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-east.png",
        width = 224,
        height = 224,
        frame_count = 36,
        line_length = 6,
        shift = {0, 0},
        animation_speed = 0.5,
    }

    local entity_vertical_base = {
        filename = "__angelspetrochem__/graphics/entity/electrolyser/electrolyser-north.png",
        priority = "extra-high",
        width = 224,
        height = 224,
        frame_count = 36,
        line_length = 6,
        shift = {0, 0},
        animation_speed = 0.5,
    }

    -- Reskin entities
    entity.animation = {
        north = {
            layers = {
                entity_vertical_base,
                entity_mask,
                entity_highlights,
            }
        },
        east = {
            layers = {
                entity_horizontal_base,
                entity_mask,
                entity_highlights,
            }
        },
        south = {
            layers = {
                entity_vertical_base,
                entity_mask,
                entity_highlights,
            }
        },
        west = {
            layers = {
                entity_horizontal_base,
                entity_mask,
                entity_highlights,
            }
        },
    }

    -- Label to skip to next iteration
    ::continue::
end