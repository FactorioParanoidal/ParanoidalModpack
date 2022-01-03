-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

---Boolean toggles to customize the type of assembling machine sprites used.
---Note that the `use_` flags are mutually exclusive, and if omitted the standard sprite set will be used.
---@class flags.assembly_machine : table
---@field is_small? boolean # 2x2 tile footprint, standard is 3x3
---@field lights? '1-3' # Electronics machine light icon decoratives
---@field use_electronics_set? boolean
---@field use_burner_set? boolean
---@field use_steam_set? boolean

---Prepares icon properties for the `inputs` table
---@param tier '0-5' # Tier gear icon decoratives
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param flags flags.assembly_machine
---@return table inputs
local function icon_sets(tier, tint, flags)
    local inputs = {}

    if flags.use_electronics_set then
        -- Use the small assets
        inputs.icon_base = "mini-assembling-machine"
        inputs.icon_mask = inputs.icon_base
        inputs.icon_highlights = inputs.icon_base

        -- Add the indicator lights
        inputs.icon_extras = {
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/electronics-machine-"..flags.lights..".png",
            },
        }

        inputs.icon_picture_extras = {
            {
                filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/electronics-machine-"..flags.lights..".png",
                size = 64,
                mipmaps = 4,
                scale = 0.25,
            },
        }
    elseif flags.use_burner_set then
        if flags.is_small then
            -- Use the small assets
            inputs.icon_base = "mini-assembling-machine"
            inputs.icon_mask = inputs.icon_base
            inputs.icon_highlights = inputs.icon_base

            -- Smoke stack
            inputs.icon_extras = {
                {
                    icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/small-smoke-stack.png",
                },
            }

            inputs.icon_picture_extras = {
                {
                    filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png",
                    size = 64,
                    mipmaps = 4,
                    scale = 0.25,
                },
            }
        else
            -- Smoke stack
            inputs.icon_extras = {
                {
                    icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png",
                },
            }

            inputs.icon_picture_extras = {
                {
                    filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png",
                    size = 64,
                    mipmaps = 4,
                    scale = 0.25,
                },
            }
        end
    elseif flags.use_steam_set then
        -- Smoke stack with pipe connection
        inputs.icon_extras = {
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png"
            },
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
                tint = tint,
            },
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-highlights.png",
                tint = {1,1,1,0}
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            },
            {
                filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25,
                tint = tint
            },
            {
                filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-highlights.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25,
                blend_mode = "additive"
            }
        }
    else
        if flags.is_small then
            -- Use the small assets
            inputs.icon_base = "mini-assembling-machine"
            inputs.icon_mask = inputs.icon_base
            inputs.icon_highlights = inputs.icon_base

            -- Add gears
            inputs.icon_extras = {
                {
                    icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/mini-gear-"..tier..".png"
                }
            }

            inputs.icon_picture_extras = {
                {
                    filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/mini-gear-"..tier..".png",
                    size = 64,
                    mipmaps = 4,
                    scale = 0.25
                }
            }
        else
            -- Add gears
            inputs.icon_extras = {
                {
                    icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/gear-"..tier..".png"
                }
            }

            inputs.icon_picture_extras = {
                {
                    filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/gear-"..tier..".png",
                    size = 64,
                    mipmaps = 4,
                    scale = 0.25
                }
            }
        end
    end

    return inputs
end

---Provides vanilla-style sprite definition for assembling machine corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/RotatedAnimation](https://wiki.factorio.com/Types/RotatedAnimation)
local function corpse_animation(tint)
    return
    make_rotated_animation_variations_from_sheet (3, {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/remnants/assembling-machine-remnants-base.png",
                line_length = 1,
                width = 164,
                height = 142,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(0, 10),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/remnants/hr-assembling-machine-remnants-base.png",
                    line_length = 1,
                    width = 328,
                    height = 282,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(0, 9.5),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/remnants/assembling-machine-remnants-mask.png",
                line_length = 1,
                width = 164,
                height = 142,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(0, 10),
                tint = tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/remnants/hr-assembling-machine-remnants-mask.png",
                    line_length = 1,
                    width = 328,
                    height = 282,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(0, 9.5),
                    tint = tint,
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/remnants/assembling-machine-remnants-highlights.png",
                line_length = 1,
                width = 164,
                height = 142,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(0, 10),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/remnants/hr-assembling-machine-remnants-highlights.png",
                    line_length = 1,
                    width = 328,
                    height = 282,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(0, 9.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                },
            }
        }
    })
end

---Provides vanilla-style sprite definition for assembling machine `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param flags flags.assembly_machine
---@return table animation # [Types/Animation4Way](https://wiki.factorio.com/Types/Animation4Way)
local function entity_animation(tier, tint, flags)
    local shadow_tier = (tier >= 5) and 4 or tier

    local animation = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/assembling-machine-base.png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base.png",
                    priority="high",
                    width = 214,
                    height = 237,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 32,
                    shift = util.by_pixel(0, -0.75),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/assembling-machine-base-mask.png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.5),
                tint = tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base-mask.png",
                    priority="high",
                    width = 214,
                    height = 237,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 32,
                    shift = util.by_pixel(0, -0.75),
                    tint = tint,
                    scale = 0.5
                }
            },
            -- Highlight
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/assembling-machine-base-highlights.png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base-highlights.png",
                    priority="high",
                    width = 214,
                    height = 237,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 32,
                    shift = util.by_pixel(0, -0.75),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Animation
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/animations/assembling-machine-animation-"..tier..".png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(0, -0.5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/animations/hr-assembling-machine-animation-"..tier..".png",
                    priority="high",
                    width = 214,
                    height = 237,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(0, -0.75),
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/shadows/assembling-machine-"..shadow_tier.."-shadow.png",
                priority="high",
                width = 132,
                height = 83,
                frame_count = 32,
                line_length = 8,
                draw_as_shadow = true,
                shift = util.by_pixel(27, 5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/shadows/hr-assembling-machine-"..shadow_tier.."-shadow.png",
                    priority="high",
                    width = 264,
                    height = 165,
                    frame_count = 32,
                    line_length = 8,
                    draw_as_shadow = true,
                    shift = util.by_pixel(27, 5),
                    scale = 0.5
                }
            }
        }
    }

    if flags.use_electronics_set then
        table.insert(animation.layers,
        -- Base
        {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-base.png",
            priority="high",
            width = 108,
            height = 119,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(0, -0.5),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-base.png",
                priority="high",
                width = 214,
                height = 237,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.75),
                scale = 0.5
            }
        })
        table.insert(animation.layers,
        -- Mask
        {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-mask.png",
            priority="high",
            width = 108,
            height = 119,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(0, -0.5),
            tint = tint,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-mask.png",
                priority="high",
                width = 214,
                height = 237,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.75),
                tint = tint,
                scale = 0.5
            }
        })
        table.insert(animation.layers,
        -- Highlights
        {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-highlights.png",
            priority="high",
            width = 108,
            height = 119,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(0, -0.5),
            blend_mode = reskins.lib.blend_mode, -- "additive",
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-highlights.png",
                priority="high",
                width = 214,
                height = 237,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.75),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                scale = 0.5
            }
        })
        table.insert(animation.layers,
        -- Shadow
        {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-shadow.png",
            priority="high",
            width = 132,
            height = 83,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            draw_as_shadow = true,
            shift = util.by_pixel(27, 5),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-shadow.png",
                priority="high",
                width = 264,
                height = 165,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                draw_as_shadow = true,
                shift = util.by_pixel(27, 5),
                scale = 0.5
            }
        })
    end

    return animation
end

---Reskins the named splitter with vanilla-style splitter sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param make_tier_labels? boolean
---@param flags? flags.assembly_machine
function reskins.lib.apply_skin.assembling_machine(name, tier, tint, make_tier_labels, flags)
    if not flags then flags = {} end

    local inputs = util.merge({
        {
            type = "assembling-machine",
            icon_name = "assembling-machine",
            base_entity_name = "assembling-machine-1",
            mod = "bobs",
            group = "assembly",
            particles = {["big"] = 1, ["medium"] = 2},
            tier_labels = make_tier_labels,
            tint = tint and tint or reskins.lib.tint_index[tier],
        },
        icon_sets(tier, tint, flags)
    })

    local entity = data.raw[inputs.type][name]
    if not entity then return end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch corpse
    local corpse = data.raw["corpse"][name.."-remnants"]

    -- Reskin corpse
    corpse.animation = corpse_animation(inputs.tint)

    -- Reskin entity
    entity.animation = entity_animation(tier, inputs.tint, flags)
    entity.drawing_box = nil

    local draw_order_shift = (flags.use_electronics_set or flags.use_steam_set) and 6 or 3
    if entity.fluid_boxes then
        for _, fluid_box in pairs(entity.fluid_boxes) do
            if type(fluid_box) == "table" then
                fluid_box.pipe_picture = fluid_box.pipe_picture and reskins.bobs.assembly_pipe_pictures(inputs.tint)
                fluid_box.pipe_covers = fluid_box.pipe_covers and pipecoverspictures()
                fluid_box.secondary_draw_orders = { north = -1, east = draw_order_shift, south = draw_order_shift, west = draw_order_shift }
            end
        end
    end

    local fluid_box = entity.energy_source.fluid_box
    if fluid_box then
        fluid_box.pipe_picture = fluid_box.pipe_picture and reskins.bobs.assembly_pipe_pictures(inputs.tint)
        fluid_box.pipe_covers = fluid_box.pipe_covers and pipecoverspictures()
        fluid_box.secondary_draw_orders = { north = -1, east = draw_order_shift, south = draw_order_shift, west = draw_order_shift }
    end

    -- Handle sounds
    if tier > 3 then
        entity.working_sound.sound = {
            {
                filename = "__base__/sound/assembling-machine-t3-1.ogg",
                volume = 0.45
            }
        }
    elseif tier > 1 then
        entity.working_sound.sound = {
            {
                filename = "__base__/sound/assembling-machine-t2-1.ogg",
                volume = 0.45
            }
        }
    else
        entity.working_sound.sound = {
            {
                filename = "__base__/sound/assembling-machine-t1-1.ogg",
                volume = 0.5
            }
        }
    end

    -- Rescale entity
    if flags.is_small then
        reskins.lib.rescale_entity(entity.animation, 2/3)
        reskins.lib.rescale_remnant(corpse, 2/3)
    end
end