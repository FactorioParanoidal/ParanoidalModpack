-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides vanilla-style sprite definition for oil refinery `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/Animation4Way](https://wiki.factorio.com/Types/Animation4Way)
local function entity_animation(tint)
    return
    reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/oil-refinery/oil-refinery.png",
                width = 337,
                height = 255,
                frame_count = 1,
                shift = {2.515625, 0.484375},
                hr_version = {
                filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery.png",
                width = 386,
                height = 430,
                frame_count = 1,
                shift = util.by_pixel(0, -7.5),
                scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/oil-refinery-mask.png",
                width = 337,
                height = 255,
                frame_count = 1,
                shift = {2.515625, 0.484375},
                tint = tint,
                hr_version = {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/hr-oil-refinery-mask.png",
                width = 386,
                height = 430,
                frame_count = 1,
                shift = util.by_pixel(0, -7.5),
                tint = tint,
                scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/oil-refinery-highlights.png",
                width = 337,
                height = 255,
                frame_count = 1,
                shift = {2.515625, 0.484375},
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/hr-oil-refinery-highlights.png",
                width = 386,
                height = 430,
                frame_count = 1,
                shift = util.by_pixel(0, -7.5),
                blend_mode = reskins.lib.blend_mode,
                scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/oil-refinery/oil-refinery-shadow.png",
                width = 337,
                height = 213,
                frame_count = 1,
                shift = util.by_pixel(82.5, 26.5),
                draw_as_shadow = true,
                hr_version = {
                filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery-shadow.png",
                width = 674,
                height = 426,
                frame_count = 1,
                shift = util.by_pixel(82.5, 26.5),
                draw_as_shadow = true,
                force_hr_shadow = true,
                scale = 0.5
                }
            }
        }
    })
end

---Provides vanilla-style sprite definition for oil refinery corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/RotatedAnimationVariations](https://wiki.factorio.com/Types/RotatedAnimationVariations)
local function corpse_animation(tint)
    return make_rotated_animation_variations_from_sheet(1, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/oil-refinery/remnants/refinery-remnants.png",
                line_length = 1,
                width = 234,
                height = 200,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 0), --moved from -8.5 to -4.5
                hr_version = {
                    filename = "__base__/graphics/entity/oil-refinery/remnants/hr-refinery-remnants.png",
                    line_length = 1,
                    width = 467,
                    height = 415,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-0.25, -0.25), --moved from -8.5 to -4.5
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/refinery-remnants-mask.png",
                line_length = 1,
                width = 234,
                height = 200,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 0),
                tint = tint,
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/hr-refinery-remnants-mask.png",
                    line_length = 1,
                    width = 467,
                    height = 415,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-0.25, -0.25),
                    tint = tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/refinery-remnants-highlights.png",
                line_length = 1,
                width = 234,
                height = 200,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 0),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/hr-refinery-remnants-highlights.png",
                    line_length = 1,
                    width = 467,
                    height = 415,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-0.25, -0.25),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            }
        }
    })
end

---Reskins the named assembling machine with vanilla-style oil refinery sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param make_tier_labels? boolean
function reskins.lib.apply_skin.oil_refinery(name, tier, tint, make_tier_labels)
    ---@type inputs.setup_standard_entity
    local inputs = {
        type = "assembling-machine",
        icon_name = "oil-refinery",
        base_entity_name = "oil-refinery",
        mod = "lib",
        group = "base",
        particles = {["big-tint"] = 5, ["medium"] = 2},
        tier_labels = make_tier_labels,
        tint = tint and tint or reskins.lib.tint_index[tier],
    }

    local entity = data.raw[inputs.type][name]
    if not entity then return end

    -- angelspetrochem at this version or earlier does icon work in data-final-fixes
    if reskins.lib.migration.is_version_or_older(mods["angelspetrochem"], "0.9.19") then
        inputs.defer_to_data_final_fixes = true
    else
        inputs.defer_to_data_updates = true -- angelspetrochem > 0.9.19 modifies icon in data-updates
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch corpse
    local corpse = data.raw["corpse"][name.."-remnants"]

    -- Reskin corpse
    corpse.animation = corpse_animation(inputs.tint)

    -- Reskin entity
    entity.animation = entity_animation(inputs.tint)
end