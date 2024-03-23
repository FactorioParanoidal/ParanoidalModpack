-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides vanilla-style sprite definition for chemical plant `working_visualisations` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@return table working_visualisations # [Types/WorkingVisualisations](https://wiki.factorio.com/Types/WorkingVisualisation)
local function working_visualisations()
    return
    {
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
end

---Provides vanilla-style sprite definition for chemical plant `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/Animation4Way](https://wiki.factorio.com/Types/Animation4Way)
local function entity_animation(tint)
    return
    reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/chemical-plant-base.png",
                width = 108,
                height = 148,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(1, -9),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/hr-chemical-plant-base.png",
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
                filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/chemical-plant-mask.png",
                width = 108,
                height = 148,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(1, -9),
                tint = tint,
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/hr-chemical-plant-mask.png",
                    width = 220,
                    height = 292,
                    frame_count = 24,
                    line_length = 12,
                    shift = util.by_pixel(0.5, -9),
                    tint = tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/chemical-plant-highlights.png",
                width = 108,
                height = 148,
                frame_count = 24,
                line_length = 12,
                shift = util.by_pixel(1, -9),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/hr-chemical-plant-highlights.png",
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
end

---Provides vanilla-style sprite definition for chemical plant corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/RotatedAnimation](https://wiki.factorio.com/Types/RotatedAnimation)
local function corpse_animation(tint)
    return
    {
        layers = {
            -- Base
            {
                filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/remnants/chemical-plant-remnants-base.png",
                line_length = 1,
                width = 224,
                height = 172,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(16, -5),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/remnants/hr-chemical-plant-remnants-base.png",
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
                filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/remnants/chemical-plant-remnants-mask.png",
                line_length = 1,
                width = 224,
                height = 172,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(16, -5),
                tint = tint,
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/remnants/hr-chemical-plant-remnants-mask.png",
                    line_length = 1,
                    width = 446,
                    height = 342,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(16, -5.5),
                    tint = tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/remnants/chemical-plant-remnants-highlights.png",
                line_length = 1,
                width = 224,
                height = 172,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(16, -5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/common/chemical-plant/remnants/hr-chemical-plant-remnants-highlights.png",
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
end

---Reskins the named assembling machine with vanilla-style chemical plant sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param make_tier_labels? boolean
function reskins.lib.apply_skin.chemical_plant(name, tier, tint, make_tier_labels)
    ---@type inputs.setup_standard_entity
    local inputs = {
        type = "assembling-machine",
        icon_name = "chemical-plant",
        base_entity_name = "chemical-plant",
        mod = "lib",
        group = "common",
        particles = {["big"] = 1, ["medium"] = 2},
        tier_labels = make_tier_labels,
        tint = tint and tint or reskins.lib.tint_index[tier],
    }

    local entity = data.raw[inputs.type][name]
    if not entity then return end

    -- angelspetrochem at this version or earlier does icon work in data-final-fixes
    if reskins.lib.migration.is_version_or_older(mods["angelspetrochem"], "0.9.19") and (name == "chemical-plant") then
        inputs.defer_to_data_final_fixes = true
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch corpse
    local corpse = data.raw["corpse"][name.."-remnants"]

    -- Reskin corpse
    corpse.animation = corpse_animation(inputs.tint)

    -- Reskin entity
    entity.animation = entity_animation(inputs.tint)
    entity.working_visualisations = working_visualisations()
    entity.drawing_box = {{-1.5, -2.25}, {1.5, 1.5}}
end

