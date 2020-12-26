-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "assembling-machine",
    base_entity = "assembling-machine-1",
    mod = "bobs",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "assembly",
}

local tier_map = {
    ["assembling-machine-1"] = {tier = 0, shadow = 0},
    ["assembling-machine-2"] = {tier = 1, shadow = 1, has_fluids = true},
    ["assembling-machine-3"] = {tier = 2, shadow = 2, has_fluids = true},
    ["assembling-machine-4"] = {tier = 3, shadow = 3, has_fluids = true},
    ["assembling-machine-5"] = {tier = 4, shadow = 4, has_fluids = true},
    ["assembling-machine-6"] = {tier = 5, shadow = 4, has_fluids = true},
    ["burner-assembling-machine"] = {tier = 0, shadow = 0, tint = util.color("262626")},
    ["steam-assembling-machine"] = {tier = 0, shadow = 0, has_fluids = true, tint = util.color("d9d9d9")},
}

-- Append electronics assembling machines
if reskins.lib.setting("reskins-lib-tier-mapping") == "traditional-map" then
    tier_map["electronics-machine-1"] = {tier = 1, shadow = 1}
    tier_map["electronics-machine-2"] = {tier = 2, shadow = 2}
    tier_map["electronics-machine-3"] = {tier = 3, shadow = 3}
else
    tier_map["electronics-machine-1"] = {tier = 0, shadow = 1}
    tier_map["electronics-machine-2"] = {tier = 2, shadow = 3}
    tier_map["electronics-machine-3"] = {tier = 4, shadow = 4}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index["tier-"..map.tier]

    -- Setup icon details
    if string.find(name, "electronics") then
        -- Use the small assets
        inputs.icon_base = "mini-assembling-machine"
        inputs.icon_mask = inputs.icon_base
        inputs.icon_highlights = inputs.icon_base

        -- Add the indicator lights
        inputs.icon_extras = {
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/"..name..".png"
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/"..name..".png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            }
        }
    elseif name == "burner-assembling-machine" then
        if reskins.bobs.triggers.burner_assembling_machine_is_small then
            -- Use the normal assets
            inputs.icon_base = nil
            inputs.icon_mask = nil
            inputs.icon_highlights = nil

            -- Smoke stack
            inputs.icon_extras = {
                {
                    icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png"
                }
            }

            inputs.icon_picture_extras = {
                {
                    filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png",
                    size = 64,
                    mipmaps = 4,
                    scale = 0.25
                }
            }
        else
            -- Use the small assets
            inputs.icon_base = "mini-assembling-machine"
            inputs.icon_mask = inputs.icon_base
            inputs.icon_highlights = inputs.icon_base

            -- Smoke stack
            inputs.icon_extras = {
                {
                    icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/small-smoke-stack.png"
                }
            }

            inputs.icon_picture_extras = {
                {
                    filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png",
                    size = 64,
                    mipmaps = 4,
                    scale = 0.25
                }
            }
        end
    elseif name == "steam-assembling-machine" then
        -- Use the standard assets
        inputs.icon_base = nil
        inputs.icon_mask = nil
        inputs.icon_highlights = nil

        -- Add steam
        inputs.icon_extras = {
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png"
            },
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
                tint = inputs.tint,
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
                tint = inputs.tint
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
        -- Use the standard assets
        inputs.icon_base = nil
        inputs.icon_mask = nil
        inputs.icon_highlights = nil

        -- Add gears
        inputs.icon_extras = {
            {
                icon = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/gear-"..map.tier..".png"
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = reskins.bobs.directory.."/graphics/icons/assembly/assembling-machine/gear-"..map.tier..".png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            }
        }
    end

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (3, {
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
                tint = inputs.tint,
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
                    tint = inputs.tint,
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

    -- Reskin entities
    entity.animation = {
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
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base-mask.png",
                    priority="high",
                    width = 214,
                    height = 237,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 32,
                    shift = util.by_pixel(0, -0.75),
                    tint = inputs.tint,
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
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/animations/assembling-machine-animation-"..map.tier..".png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(0, -0.5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/animations/hr-assembling-machine-animation-"..map.tier..".png",
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
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/shadows/assembling-machine-"..map.shadow.."-shadow.png",
                priority="high",
                width = 132,
                height = 83,
                frame_count = 32,
                line_length = 8,
                draw_as_shadow = true,
                shift = util.by_pixel(27, 5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/shadows/hr-assembling-machine-"..map.shadow.."-shadow.png",
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

    -- Insert the electronics assembling machine decoratives
    if string.find(name, "electronics") then
        table.insert(entity.animation.layers,
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
        table.insert(entity.animation.layers,
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
            tint = inputs.tint,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-mask.png",
                priority="high",
                width = 214,
                height = 237,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.75),
                tint = inputs.tint,
                scale = 0.5
            }
        })
        table.insert(entity.animation.layers,
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
        table.insert(entity.animation.layers,
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

    -- Fix drawing box
    entity.drawing_box = nil

    local test = reskins.bobs.triggers.assembly.burner_assembling_machine_is_small

    -- Rescale for electronics and burner assembling machines
    if string.find(name, "electronics") or (reskins.bobs.triggers.assembly.burner_assembling_machine_is_small and name == "burner-assembling-machine") then
        reskins.lib.rescale_entity(entity.animation, 2/3)
        reskins.lib.rescale_remnant(entity, 2/3)
    end

    -- Handle pipes
    if map.has_fluids then
        entity.fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint),
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {0, -2} }},
                secondary_draw_orders = { north = -1, east = 3, south = 3, west = 3 }
            },
            {
                production_type = "output",
                pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint),
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = 1,
                pipe_connections = {{ type="output", position = {0, 2} }},
                secondary_draw_orders = { north = -1, east = 3, south = 3, west = 3 }
            },
            off_when_no_fluid_recipe = true
        }
    end

    if name == "steam-assembling-machine" then
        entity.energy_source.fluid_box = {
            base_area = 1,
            height = 2,
            base_level = -1,
            pipe_connections = {
                {type = "input-output", position = { 2, 0}},
                {type = "input-output", position = {-2, 0}}
            },
            pipe_covers = pipecoverspictures(),
            pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint),
            production_type = "input-output",
            filter = "steam"
        }
    end

    -- Handle sounds
    if map.tier > 3 then
        entity.working_sound.sound = {
            {
                filename = "__base__/sound/assembling-machine-t3-1.ogg",
                volume = 0.45
            }
        }
    elseif map.tier > 1 then
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

    -- Label to skip to next iteration
    ::continue::
end