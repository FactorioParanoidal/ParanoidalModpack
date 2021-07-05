-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then return end
if reskins.lib.setting("bobmods-assembly-chemicalplants") == false then return end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then reskins.compatibility.triggers.minimachines.chemplants.bobs = true end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "chemical-plant",
    base_entity = "chemical-plant",
    mod = "bobs",
    group = "assembly",
    particles = {["big"] = 1, ["medium"] = 2},
}

local tier_map = {
    ["chemical-plant"] = {1, 2},
    ["chemical-plant-2"] = {2, 3},
    ["chemical-plant-3"] = {3, 4},
    ["chemical-plant-4"] = {4, 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- Chemical plant 1 needs the icon re-assigned in final fixes
    if name == "chemical-plant" then
        inputs.defer_to_data_final_fixes = true
    else
        inputs.defer_to_data_final_fixes = nil
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/chemical-plant/remnants/chemical-plant-remnants.png",
                line_length = 1,
                width = 224,
                height = 172,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(16, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/remnants/hr-chemical-plant-remnants.png",
                    line_length = 1,
                    width = 446,
                    height = 342,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(16, -5.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/remnants/chemical-plant-remnants-mask.png",
                line_length = 1,
                width = 224,
                height = 172,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(16, -5),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/remnants/hr-chemical-plant-remnants-mask.png",
                    line_length = 1,
                    width = 446,
                    height = 342,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(16, -5.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/remnants/chemical-plant-remnants-highlights.png",
                line_length = 1,
                width = 224,
                height = 172,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(16, -5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/remnants/hr-chemical-plant-remnants-highlights.png",
                    line_length = 1,
                    width = 446,
                    height = 342,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(16, -5.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    }

    -- Reskin entities
    entity.animation = reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant.png",
                width = 108,
                height = 148,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(1, -9),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant.png",
                    width = 220,
                    height = 292,
                    frame_count = 24,
                    line_length = 12,
                    shift = util.by_pixel(0.5, -9),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/chemical-plant-mask.png",
                width = 108,
                height = 148,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(1, -9),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/hr-chemical-plant-mask.png",
                    width = 220,
                    height = 292,
                    frame_count = 24,
                    line_length = 12,
                    shift = util.by_pixel(0.5, -9),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/chemical-plant-highlights.png",
                width = 108,
                height = 148,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(1, -9),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/chemical-plant/hr-chemical-plant-highlights.png",
                    width = 220,
                    height = 292,
                    frame_count = 24,
                    line_length = 12,
                    shift = util.by_pixel(0.5, -9),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-shadow.png",
                width = 154,
                height = 112,
                repeat_count = 24,
                frame_count = 1,
                shift = util.by_pixel(28, 6),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-shadow.png",
                    width = 312,
                    height = 222,
                    repeat_count = 24,
                    frame_count = 1,
                    shift = util.by_pixel(27, 6),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    })

    entity.working_visualisations = {
        {
            apply_recipe_tint = "primary",
            north_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-north.png",
                frame_count = 24,
                line_length = 6,
                width = 32,
                height = 24,
                shift = util.by_pixel(24, 14),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-liquid-north.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 66,
                    height = 44,
                    shift = util.by_pixel(23, 15),
                    scale = 0.5
                }
            },
            east_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-east.png",
                frame_count = 24,
                line_length = 6,
                width = 36,
                height = 18,
                shift = util.by_pixel(0, 22),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-liquid-east.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 70,
                    height = 36,
                    shift = util.by_pixel(0, 22),
                    scale = 0.5
                }
            },
            south_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-south.png",
                frame_count = 24,
                line_length = 6,
                width = 34,
                height = 24,
                shift = util.by_pixel(0, 16),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-liquid-south.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 66,
                    height = 42,
                    shift = util.by_pixel(0, 17),
                    scale = 0.5
                }
            },
            west_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-liquid-west.png",
                frame_count = 24,
                line_length = 6,
                width = 38,
                height = 20,
                shift = util.by_pixel(-10, 12),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-liquid-west.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 74,
                    height = 36,
                    shift = util.by_pixel(-10, 13),
                    scale = 0.5
                }
            }
        },
        {
            apply_recipe_tint = "secondary",
            north_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-north.png",
                frame_count = 24,
                line_length = 6,
                width = 32,
                height = 22,
                shift = util.by_pixel(24, 14),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-foam-north.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 62,
                    height = 42,
                    shift = util.by_pixel(24, 15),
                    scale = 0.5
                }
            },
            east_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-east.png",
                frame_count = 24,
                line_length = 6,
                width = 34,
                height = 18,
                shift = util.by_pixel(0, 22),
                hr_version = {
                filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-foam-east.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 68,
                    height = 36,
                    shift = util.by_pixel(0, 22),
                    scale = 0.5
                }
            },
            south_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-south.png",
                frame_count = 24,
                line_length = 6,
                width = 32,
                height = 18,
                shift = util.by_pixel(0, 18),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-foam-south.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 60,
                    height = 40,
                    shift = util.by_pixel(1, 17),
                    scale = 0.5
                }
            },
            west_animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-foam-west.png",
                frame_count = 24,
                line_length = 6,
                width = 36,
                height = 16,
                shift = util.by_pixel(-10, 14),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-foam-west.png",
                    frame_count = 24,
                    line_length = 6,
                    width = 68,
                    height = 28,
                    shift = util.by_pixel(-9, 15),
                    scale = 0.5
                }
            }
        },
        {
            apply_recipe_tint = "tertiary",
            fadeout = true,
            constant_speed = true,
            north_position = util.by_pixel_hr(-30, -161),
            east_position = util.by_pixel_hr(29, -150),
            south_position = util.by_pixel_hr(12, -134),
            west_position = util.by_pixel_hr(-32, -130),
            render_layer = "wires",
            animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-smoke-outer.png",
                frame_count = 47,
                line_length = 16,
                width = 46,
                height = 94,
                animation_speed = 0.5,
                shift = util.by_pixel(-2, -40),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-smoke-outer.png",
                    frame_count = 47,
                    line_length = 16,
                    width = 90,
                    height = 188,
                    animation_speed = 0.5,
                    shift = util.by_pixel(-2, -40),
                    scale = 0.5
                }
            }
        },
        {
            apply_recipe_tint = "quaternary",
            fadeout = true,
            constant_speed = true,
            north_position = util.by_pixel_hr(-30, -161),
            east_position = util.by_pixel_hr(29, -150),
            south_position = util.by_pixel_hr(12, -134),
            west_position = util.by_pixel_hr(-32, -130),
            render_layer = "wires",
            animation = {
                filename = "__base__/graphics/entity/chemical-plant/chemical-plant-smoke-inner.png",
                frame_count = 47,
                line_length = 16,
                width = 20,
                height = 42,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -14),
                hr_version = {
                    filename = "__base__/graphics/entity/chemical-plant/hr-chemical-plant-smoke-inner.png",
                    frame_count = 47,
                    line_length = 16,
                    width = 40,
                    height = 84,
                    animation_speed = 0.5,
                    shift = util.by_pixel(0, -14),
                    scale = 0.5
                }
            }
        }
    }

    -- Fix drawing box
    entity.drawing_box = {{-1.5, -2.25}, {1.5, 1.5}}

    -- Label to skip to next iteration
    ::continue::
end