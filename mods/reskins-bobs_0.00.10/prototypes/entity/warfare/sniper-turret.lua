-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobwarfare"] then return end
if reskins.lib.setting("reskins-bobs-do-bobwarfare") == false then return end 

-- Set input parameters
local inputs = {
    type = "ammo-turret",
    icon_name = "sniper-turret",
    base_entity = "gun-turret",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "warfare",
    particles = {["medium"] = 2},
    make_remnants = false,
}

local tier_map = {
    ["bob-sniper-turret-1"] = {1, 1},
    ["bob-sniper-turret-2"] = {2, 3},
    ["bob-sniper-turret-3"] = {3, 5},
}

-- Image layer functions
local function sniper_turret_extension(parameters)
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-raising.png",
        priority = "medium",
        width = 119,
        height = 89,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -30.5),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-raising.png",
            priority = "medium",
            width = 238,
            height = 178,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -30.5),
            scale = 0.5
        }
    }
end

local function sniper_turret_extension_tint(parameters)
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-raising-tint.png",
        priority = "medium",
        width = 119,
        height = 89,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -30.5),
        flags = {"mask"},
        apply_runtime_tint = true,
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-raising-tint.png",
            priority = "medium",
            width = 238,
            height = 178,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -30.5),
            flags = {"mask"},
            apply_runtime_tint = true,
            scale = 0.5
        }
    }
end

local function sniper_turret_extension_mask(inputs, parameters)
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-raising-mask.png",
        priority = "medium",
        width = 119,
        height = 89,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -30.5),
        tint = inputs.tint,
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-raising-mask.png",
            priority = "medium",
            width = 238,
            height = 178,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -30.5),
            tint = inputs.tint,
            scale = 0.5
        }
    }
end

local function sniper_turret_extension_highlights(parameters)
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-raising-highlights.png",
        priority = "medium",
        width = 119,
        height = 89,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -30.5),
        blend_mode = "additive",
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-raising-highlights.png",
            priority = "medium",
            width = 238,
            height = 178,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -30.5),
            blend_mode = "additive",
            scale = 0.5
        }
    }
end

local function sniper_turret_extension_shadow(parameters)
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-raising-shadow.png",
        width = 123,
        height = 89,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(21.5, 2),
        draw_as_shadow = true,
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-raising-shadow.png",
            width = 246,
            height = 178,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(21.5, 2),
            draw_as_shadow = true,
            scale = 0.5
        }
    }
end

local function sniper_turret_shooting()
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-shooting.png",
        line_length = 8,
        width = 119,
        height = 89,
        frame_count = 1,
        direction_count = 64,
        shift = util.by_pixel(0, -30.5),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-shooting.png",
            line_length = 8,
            width = 238,
            height = 178,
            frame_count = 1,
            direction_count = 64,
            shift = util.by_pixel(0, -30.5),
            scale = 0.5
        }
    }
end

local function sniper_turret_shooting_tint()
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-tint.png",
        flags = { "mask" },
        line_length = 8,
        width = 119,
        height = 89,
        frame_count = 1,
        apply_runtime_tint = true,
        direction_count = 64,
        shift = util.by_pixel(0, -30.5),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-shooting-tint.png",
            flags = { "mask" },
            line_length = 8,
            width = 238,
            height = 178,
            frame_count = 1,
            apply_runtime_tint = true,
            direction_count = 64,
            shift = util.by_pixel(0, -30.5),
            scale = 0.5
        }
    }
end

local function sniper_turret_shooting_mask(inputs)
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-mask.png",
        line_length = 8,
        width = 119,
        height = 89,
        frame_count = 1,
        tint = inputs.tint,
        direction_count = 64,
        shift = util.by_pixel(0, -30.5),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-shooting-mask.png",
            line_length = 8,
            width = 238,
            height = 178,
            frame_count = 1,
            tint = inputs.tint,
            direction_count = 64,
            shift = util.by_pixel(0, -30.5),
            scale = 0.5
        }
    }
end

local function sniper_turret_shooting_highlights()
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-highlights.png",
        line_length = 8,
        width = 119,
        height = 89,
        frame_count = 1,
        blend_mode = "additive",
        direction_count = 64,
        shift = util.by_pixel(0, -30.5),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-shooting-highlights.png",
            line_length = 8,
            width = 238,
            height = 178,
            frame_count = 1,
            blend_mode = "additive",
            direction_count = 64,
            shift = util.by_pixel(0, -30.5),
            scale = 0.5
        }
    }
end

local function sniper_turret_shooting_shadow()
    return
    {
        filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-shadow.png",
        line_length = 8,
        width = 123,
        height = 89,
        frame_count = 1,
        direction_count = 64,
        draw_as_shadow = true,
        shift = util.by_pixel(21.5, 2),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-shooting-shadow.png",
            line_length = 8,
            width = 246,
            height = 178,
            frame_count = 1,
            direction_count = 64,
            draw_as_shadow = true,
            shift = util.by_pixel(21.5, 2),
            scale = 0.5
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    if reskins.lib.setting("reskins-lib-tier-mapping") == "name-map" then
        tier = map[1]
    else
        tier = map[2]
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Correct projectile details
    entity.attack_parameters.projectile_creation_distance = 2.3
    entity.attack_parameters.projectile_center = util.by_pixel(0, 0)
    entity.attack_parameters.shell_particle.center = util.by_pixel(4, 0)
    entity.attack_parameters.shell_particle.creation_distance = -2.85
    entity.attack_parameters.shell_particle.direction = -0.25

    -- Reskin entities
    entity.folded_animation = {
        layers = {
            sniper_turret_extension({frame_count = 1, line_length = 1}),
            sniper_turret_extension_tint({frame_count = 1, line_length = 1}),
            sniper_turret_extension_mask(inputs, {frame_count = 1, line_length = 1}),
            sniper_turret_extension_highlights({frame_count = 1, line_length = 1}),
            sniper_turret_extension_shadow({frame_count = 1, line_length = 1})
        }
    }
    entity.preparing_animation = {
        layers = {
            sniper_turret_extension({}),
            sniper_turret_extension_tint({}),
            sniper_turret_extension_mask(inputs, {}),
            sniper_turret_extension_highlights({}),
            sniper_turret_extension_shadow({})
        }
    }
    entity.prepared_animation = {
        layers = {
            sniper_turret_shooting(),
            sniper_turret_shooting_tint(),
            sniper_turret_shooting_mask(inputs),
            sniper_turret_shooting_highlights(),
            sniper_turret_shooting_shadow(),
        }
    }
    entity.attacking_animation = {
        layers = {
            sniper_turret_shooting(),
            sniper_turret_shooting_tint(),
            sniper_turret_shooting_mask(inputs),
            sniper_turret_shooting_highlights(),
            sniper_turret_shooting_shadow(),
        }
    }
    entity.folding_animation = {
        layers = {
            sniper_turret_extension({run_mode = "backward"}),
            sniper_turret_extension_tint({run_mode = "backward"}),
            sniper_turret_extension_mask(inputs, {run_mode = "backward"}),
            sniper_turret_extension_highlights({run_mode = "backward"}),           
            sniper_turret_extension_shadow({run_mode = "backward"})
        }
    }
    entity.base_picture = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-base.png",
                priority = "high",
                width = 75,
                height = 59,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(2, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-base.png",
                    priority = "high",
                    width = 150,
                    height = 118,

                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(2, 0),
                    scale = 0.5
                }
            },
            -- Runtime Mask
            {
                filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-base-runtime-mask.png",
                priority = "high",
                width = 75,
                height = 59,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(2, 0),
                apply_runtime_tint = true,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-base-runtime-mask.png",
                    priority = "high",
                    width = 150,
                    height = 118,

                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(2, 0),
                    apply_runtime_tint = true,
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/sniper-turret-base-shadow.png",
                priority = "high",
                width = 75,
                height = 59,
                draw_as_shadow = true,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(2, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/warfare/sniper-turret/hr-sniper-turret-base-shadow.png",
                    priority = "high",
                    width = 150,
                    height = 118,

                    draw_as_shadow = true,
                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(2, 0),
                    scale = 0.5
                }
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end