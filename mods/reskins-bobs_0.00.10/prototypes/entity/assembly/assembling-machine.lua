-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "assembling-machine",
    base_entity = "assembling-machine-1",
    directory = reskins.bobs.directory,
    mod = "bobs",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "assembly",
    make_remnants = false,
}

local tier_map = {
    ["assembling-machine-1"] = {0, 0, false},
    ["assembling-machine-2"] = {1, 1, true},
    ["assembling-machine-3"] = {2, 2, true},
    ["assembling-machine-4"] = {3, 3, true},
    ["assembling-machine-5"] = {4, 4, true},
    ["assembling-machine-6"] = {5, 4, true},
    ["burner-assembling-machine"] = {0, 0, false, util.color("262626")},
    ["steam-assembling-machine"] = {0, 0, true, util.color("d9d9d9")},
}

-- Append electronics assembling machines
if reskins.lib.setting("reskins-lib-tier-mapping") == "name-map" then
    tier_map["electronics-machine-1"] = {1, 1, false}
    tier_map["electronics-machine-2"] = {2, 2, false}
    tier_map["electronics-machine-3"] = {3, 3, false}
else
    tier_map["electronics-machine-1"] = {1, 1, false}
    tier_map["electronics-machine-2"] = {3, 3, false}
    tier_map["electronics-machine-3"] = {4, 4, false}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Extract tier, shadow, has_fluids from map
    tier = map[1]
    shadow = map[2]  
    has_fluids = map[3]  
       
    -- Determine what tint we're using
    inputs.tint = map[4] or reskins.lib.tint_index["tier-"..tier]

    -- Setup icon details
    if string.find(name, "electronics") then
        -- Use the small assets
        inputs.icon_base = "mini-assembling-machine"
        inputs.icon_mask = inputs.icon_base
        inputs.icon_highlights = inputs.icon_base

        -- Add the indicator lights
        inputs.icon_extras = {
            {
                icon = inputs.directory.."/graphics/icons/assembly/assembling-machine/"..name..".png"
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = inputs.directory.."/graphics/icons/assembly/assembling-machine/"..name..".png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            }
        }
    elseif name == "burner-assembling-machine" then
        -- Use the small assets
        inputs.icon_base = "mini-assembling-machine"
        inputs.icon_mask = inputs.icon_base
        inputs.icon_highlights = inputs.icon_base

        -- Smoke stack
        inputs.icon_extras = {
            {
                icon = inputs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png"
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = inputs.directory.."/graphics/icons/assembly/assembling-machine/smoke-stack.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            }
        }
    elseif name == "steam-assembling-machine" then
        -- Use the standard assets
        inputs.icon_base = nil
        inputs.icon_mask = nil
        inputs.icon_highlights = nil

        -- Add steam
        inputs.icon_extras = {
            {
                icon = inputs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png"
            },
            {
                icon = inputs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
                tint = inputs.tint,
            },
            {
                icon = inputs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-highlights.png",
                tint = {1,1,1,0}
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = inputs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-base.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            },
            {
                filename = inputs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-mask.png",
                size = 64,
                mipmaps = 4,
                scale = 0.25,
                tint = inputs.tint
            },
            {
                filename = inputs.directory.."/graphics/icons/assembly/assembling-machine/steam-smoke-stack-highlights.png",
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
                icon = inputs.directory.."/graphics/icons/assembly/assembling-machine/gear-"..tier..".png"
            }
        }

        inputs.icon_picture_extras = {
            {
                filename = inputs.directory.."/graphics/icons/assembly/assembling-machine/gear-"..tier..".png",
                size = 64,
                mipmaps = 4,
                scale = 0.25
            }
        }
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/base/assembling-machine-base.png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base.png",
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
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/base/assembling-machine-base-mask.png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.5),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base-mask.png",
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
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/base/assembling-machine-base-highlights.png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.5),
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/base/hr-assembling-machine-base-highlights.png",
                    priority="high",
                    width = 214,
                    height = 237,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 32,
                    shift = util.by_pixel(0, -0.75),
                    blend_mode = "additive",
                    scale = 0.5
                }
            },
            -- Animation
            {
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/animations/assembling-machine-animation-"..tier..".png",
                priority="high",
                width = 108,
                height = 119,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(0, -0.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/animations/hr-assembling-machine-animation-"..tier..".png",
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
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/shadows/assembling-machine-"..shadow.."-shadow.png",
                priority="high",
                width = 132,
                height = 83,
                frame_count = 32,
                line_length = 8,
                draw_as_shadow = true,
                shift = util.by_pixel(27, 5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/shadows/hr-assembling-machine-"..shadow.."-shadow.png",
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
            filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-base.png",
            priority="high",
            width = 108,
            height = 119,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(0, -0.5),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-base.png",
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
            filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-mask.png",
            priority="high",
            width = 108,
            height = 119,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(0, -0.5),
            tint = inputs.tint,
            hr_version = {
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-mask.png",
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
            filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-highlights.png",
            priority="high",
            width = 108,
            height = 119,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            shift = util.by_pixel(0, -0.5),
            blend_mode = "additive",
            hr_version = {
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-highlights.png",
                priority="high",
                width = 214,
                height = 237,
                frame_count = 1,
                line_length = 1,
                repeat_count = 32,
                shift = util.by_pixel(0, -0.75),
                blend_mode = "additive",
                scale = 0.5
            }
        })
        table.insert(entity.animation.layers, 
        -- Shadow
        {
            filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/electronics-shadow.png",
            priority="high",
            width = 132,
            height = 83,
            frame_count = 1,
            line_length = 1,
            repeat_count = 32,
            draw_as_shadow = true,
            shift = util.by_pixel(27, 5),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/assembly/assembling-machine/electronics/hr-electronics-shadow.png",
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
    
    -- Rescale for electronics and burner assembling machines
    if string.find(name, "electronics") or name == "burner-assembling-machine" then
        reskins.lib.rescale_entity(entity.animation, 2/3)
    end

    -- Handle pipes
    if has_fluids then
        entity.fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint),
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {0, -2} }},
                secondary_draw_orders = { north = -1 }
            },
            {
                production_type = "output",
                pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint),
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = 1,
                pipe_connections = {{ type="output", position = {0, 2} }},
                secondary_draw_orders = { north = -1 }
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

    -- Label to skip to next iteration
    ::continue::    
end