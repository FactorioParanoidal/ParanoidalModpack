-- Copyright (c) 2021 Kirazy
-- Part of Prismatic Belts
--
-- See LICENSE.md in the project directory for license information.

-- Make our function host
if not prismatic_belts then prismatic_belts = {} end
prismatic_belts.migration = require("__flib__.migration")

-- Ensure tint is normalized to between 0 and 1
local function normalize_tint(tint)
    local r = tint.r or tint[1]
    local g = tint.g or tint[2]
    local b = tint.b or tint[3]
    local a

    if r > 255 or g > 255 or b > 255 then
        r = r/255
        g = g/255
        b = b/255
        a = tint.a/255 or tint[4]/255 or 1
    end

    return {r = r, g = g, b = b, a = a}
end

-- Adjust the alpha value of a given tint
function prismatic_belts.adjust_alpha(tint, alpha)
    local tint = normalize_tint(tint)
    local adjusted_tint = {r = tint.r, g = tint.g, b = tint.b, a = alpha}
    return adjusted_tint
end

-- Make an icon_pictures table for reskins-library
function prismatic_belts.transport_belt_picture(tint)
    local icon_pictures = {
        {
            filename = "__prismatic-belts__/graphics/icons/transport-belt-icon.png",
            size = 64,
            mipmaps = 4,
            scale = 0.25,
            tint = prismatic_belts.adjust_alpha(tint, 1),
        },
    }

    return icon_pictures
end

----------------------------------------------------------------------------------------------------
-- BELT COLORING API
----------------------------------------------------------------------------------------------------

-- LOGISTICS TECHNOLOGY ICONS
-- DO NOT USE, NOT ACTIVE AS OF YET
-- Returns a complete technology icons definition
-- inputs   Table of parameters:
--      base_tint      Types/Color     Color to tint the base sprite (gears, rails) [Optional; default nil]
--      mask_tint      Types/Color     Color to tint the mask sprite (belt surface, arrows) [Optional; default nil]
function prismatic_belts.logistics_technology_icon(inputs)
    local technology_icons = {
        {
            icon = "__prismatic-belts__/graphics/technology/logistics-technology-base.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = prismatic_belts.adjust_alpha(inputs.base_tint, 1)
        },
        {
            icon = "__prismatic-belts__/graphics/technology/logistics-technology-mask.png",
            icon_size = 256,
            icon_mipmaps = 4,
            tint = inputs.mask_tint,
        }
    }

    return technology_icons
end

-- TRANSPORT BELT ICONS
-- Returns a complete item icons definition
-- tint     Types/Color     Color to tint the icon [Optional; default nil]
function prismatic_belts.transport_belt_icon(tint)
    local item_icons = {
        {
            icon = "__prismatic-belts__/graphics/icons/transport-belt-icon.png",
            icon_size = 64,
            icon_mipmaps = 4,
            tint = prismatic_belts.adjust_alpha(tint, 1),
        },
    }

    return item_icons
end

-- TRANSPORT BELT ANIMATION SET
-- Returns a complete belt_animation_set definition
-- inputs   Table of parameters:
--      base_tint           Types/Color     Color to tint the base sprite (gears, rails) [Optional; default nil]
--      mask_tint           Types/Color     Color to tint the mask sprite (belt surface, arrows) [Optional; default nil]
--      brighten_arrows     Boolean         When true, blends a white arrow with the underlying tinted belts to brighen the arrows [Optional; default nil]
--      variant             Integer (1|2)   Spritesheet to return (1 for slow, 2 for fast) [Optional; default 1]
-- and the given varient (1 = slow (yellow), 2 = fast (red, blue))
function prismatic_belts.transport_belt_animation_set(inputs)
    local transport_belt_animation_set
    local variant = inputs.variant or 1

    -- Setup belt transport set
    if variant == 1 then
        transport_belt_animation_set = {
            animation_set = {
                layers = {
                    -- Base
                    {
                        filename = "__prismatic-belts__/graphics/entity/transport-belt/transport-belt-1-base.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 16,
                        tint = inputs.base_tint and prismatic_belts.adjust_alpha(inputs.base_tint, 1) or nil,
                        direction_count = 20,
                        hr_version = {
                            filename = "__prismatic-belts__/graphics/entity/transport-belt/hr-transport-belt-1-base.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 16,
                            tint = inputs.base_tint and prismatic_belts.adjust_alpha(inputs.base_tint, 1) or nil,
                            direction_count = 20
                        }
                    },
                    -- Mask
                    {
                        filename = "__prismatic-belts__/graphics/entity/transport-belt/transport-belt-1-mask.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 16,
                        tint = inputs.mask_tint,
                        direction_count = 20,
                        hr_version = {
                            filename = "__prismatic-belts__/graphics/entity/transport-belt/hr-transport-belt-1-mask.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 16,
                            tint = inputs.mask_tint,
                            direction_count = 20
                        }
                    },
                }
            }
        }

        if inputs.brighten_arrows then
            table.insert(transport_belt_animation_set.animation_set.layers, {
                filename = "__prismatic-belts__/graphics/entity/transport-belt/transport-belt-1-mask.png",
                priority = "extra-high",
                width = 64,
                height = 64,
                frame_count = 16,
                tint = util.color("4"),
                blend_mode = "additive-soft",
                direction_count = 20,
                hr_version = {
                    filename = "__prismatic-belts__/graphics/entity/transport-belt/hr-transport-belt-1-mask.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    frame_count = 16,
                    tint = util.color("4"),
                    blend_mode = "additive-soft",
                    direction_count = 20
                }
            })
        end
    else
        transport_belt_animation_set = {
            animation_set = {
                layers = {
                    -- Base
                    {
                        filename = "__prismatic-belts__/graphics/entity/transport-belt/transport-belt-2-base.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 32,
                        tint = inputs.base_tint and prismatic_belts.adjust_alpha(inputs.base_tint, 1) or nil,
                        direction_count = 20,
                        hr_version = {
                            filename = "__prismatic-belts__/graphics/entity/transport-belt/hr-transport-belt-2-base.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 32,
                            tint = inputs.base_tint and prismatic_belts.adjust_alpha(inputs.base_tint, 1) or nil,
                            direction_count = 20
                        }
                    },
                    -- Mask
                    {
                        filename = "__prismatic-belts__/graphics/entity/transport-belt/transport-belt-2-mask.png",
                        priority = "extra-high",
                        width = 64,
                        height = 64,
                        frame_count = 32,
                        tint = inputs.mask_tint,
                        direction_count = 20,
                        hr_version = {
                            filename = "__prismatic-belts__/graphics/entity/transport-belt/hr-transport-belt-2-mask.png",
                            priority = "extra-high",
                            width = 128,
                            height = 128,
                            scale = 0.5,
                            frame_count = 32,
                            tint = inputs.mask_tint,
                            direction_count = 20
                        }
                    },
                }
            }
        }

        if inputs.brighten_arrows then
            table.insert(transport_belt_animation_set.animation_set.layers, {
                filename = "__prismatic-belts__/graphics/entity/transport-belt/transport-belt-2-arrows.png",
                priority = "extra-high",
                width = 64,
                height = 64,
                frame_count = 32,
                tint = util.color("4"),
                blend_mode = "additive-soft",
                direction_count = 20,
                hr_version = {
                    filename = "__prismatic-belts__/graphics/entity/transport-belt/hr-transport-belt-2-arrows.png",
                    priority = "extra-high",
                    width = 128,
                    height = 128,
                    scale = 0.5,
                    frame_count = 32,
                    tint = util.color("4"),
                    blend_mode = "additive-soft",
                    direction_count = 20
                }
            })
        end
    end

    return transport_belt_animation_set
end

-- TRANSPORT BELT REMNANTS
-- This function reskins (or creates as needed) appropriate transport belt remnants
-- name     Prototype name of the transport belt
-- inputs   Table of parameters:
--      base_tint           Types/Color - Color to tint the base sprite (gears, rails) [Optional; default nil]
--      mask_tint           Types/Color - Color to tint the mask sprite (belt surface, arrows) [Optional; default nil]
--      brighten_arrows     Boolean     - When true, blends a white arrow with the underlying tinted belts to brighen the arrows [Optional; default nil]
function prismatic_belts.create_remnant(name, inputs)
    -- Create remnant animation
    local remnant_layers = {
        -- Base
        {
            filename ="__prismatic-belts__/graphics/entity/transport-belt/remnants/transport-belt-remnants-base.png",
            line_length = 1,
            width = 54,
            height = 52,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            tint = inputs.base_tint and prismatic_belts.adjust_alpha(inputs.base_tint, 1) or nil,
            shift = util.by_pixel(1, 0),
            hr_version = {
                filename ="__prismatic-belts__/graphics/entity/transport-belt/remnants/hr-transport-belt-remnants-base.png",
                line_length = 1,
                width = 106,
                height = 102,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                tint = inputs.base_tint and prismatic_belts.adjust_alpha(inputs.base_tint, 1) or nil,
                shift = util.by_pixel(1, -0.5),
                scale = 0.5,
            }
        },
        -- Mask
        {
            filename ="__prismatic-belts__/graphics/entity/transport-belt/remnants/transport-belt-remnants-mask.png",
            line_length = 1,
            width = 54,
            height = 52,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            tint = inputs.mask_tint,
            shift = util.by_pixel(1, 0),
            hr_version = {
                filename ="__prismatic-belts__/graphics/entity/transport-belt/remnants/hr-transport-belt-remnants-mask.png",
                line_length = 1,
                width = 106,
                height = 102,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                tint = inputs.mask_tint,
                shift = util.by_pixel(1, -0.5),
                scale = 0.5,
            }
        },
    }

    -- Brighten the arrows
    if inputs.brighten_arrows then
        table.insert(remnant_layers, {
            filename ="__prismatic-belts__/graphics/entity/transport-belt/remnants/transport-belt-remnants-arrows.png",
            line_length = 1,
            width = 54,
            height = 52,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            tint = util.color("4"),
            blend_mode = "additive-soft",
            shift = util.by_pixel(1, 0),
            hr_version = {
                filename ="__prismatic-belts__/graphics/entity/transport-belt/remnants/hr-transport-belt-remnants-arrows.png",
                line_length = 1,
                width = 106,
                height = 102,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                tint = util.color("4"),
                blend_mode = "additive-soft",
                shift = util.by_pixel(1, -0.5),
                scale = 0.5,
            }
        })
    end

    -- Fetch remnant
    local remnants = data.raw["corpse"][name.."-remnants"]

    -- If there is no existing remnant, create one
    if not remnants then
        remnants = {
            type = "corpse",
            name = "prismatic-belts-"..name.."-remnants",
            icons = data.raw["transport-belt"][name].icons,
            icon = data.raw["transport-belt"][name].icon,
            icon_size = data.raw["transport-belt"][name].icon_size,
            icon_mipmaps = data.raw["transport-belt"][name].icon_mipmaps,
            flags = {"placeable-neutral", "not-on-map"},
            subgroup = "belt-remnants",
            order = (data.raw.item[name] and data.raw.item[name].order) and data.raw.item[name].order.."-a["..name.."-remnants]" or "a-a-a",
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            tile_width = 1,
            tile_height = 1,
            selectable_in_game = false,
            time_before_removed = 60 * 60 * 15, -- 15 minutes
            final_render_layer = "remnants",
            animation = make_rotated_animation_variations_from_sheet(2, { layers = remnant_layers })
        }

        data:extend({remnants})

        -- Assign the corpse
        data.raw["transport-belt"][name].corpse = "prismatic-belts-"..name.."-remnants"
    else
        remnants.icons = data.raw["transport-belt"][name].icons
        remnants.icon = data.raw["transport-belt"][name].icon
        remnants.icon_size = data.raw["transport-belt"][name].icon_size
        remnants.animation = make_rotated_animation_variations_from_sheet(2, { layers = remnant_layers })
    end
end