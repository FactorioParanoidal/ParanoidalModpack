-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["aai-industry"] then return end
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then return end

-- We want to use the aai industry-style burner assembling machine
local entity = data.raw["assembling-machine"]["burner-assembling-machine"]

-- Verify the entity exists
if not entity then return end

-- Reskin the burner assembling machine in the appropriate style
entity.animation = {
    layers = {
        -- aai-industry Base
        {
            filename = "__aai-industry__/graphics/entity/burner-assembling-machine/burner-assembling-machine.png",
            priority="high",
            width = 107,
            height = 113,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(0, 2),
            hr_version = {
                filename = "__aai-industry__/graphics/entity/burner-assembling-machine/hr-burner-assembling-machine.png",
                priority="high",
                width = 214,
                height = 226,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(0, 2),
                scale = 0.5
            }
        },
        -- Shadow
        {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/shadows/assembling-machine-0-shadow.png",
            priority="high",
            width = 132,
            height = 83,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(27, 5),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/shadows/hr-assembling-machine-0-shadow.png",
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

-- Ensure the working visualisation is properly set
entity.working_visualisations = {
    {
        fadeout = true,
        effect = "flicker",
        animation = {
            filename = "__aai-industry__/graphics/entity/burner-assembling-machine/burner-assembling-machine-light.png",
            priority = "high",
            width = 107,
            height = 113,
            blend_mode = "additive",
            draw_as_glow = true,
            shift = util.by_pixel(0, 2),
            hr_version = {
                filename = "__aai-industry__/graphics/entity/burner-assembling-machine/hr-burner-assembling-machine-light.png",
                priority = "high",
                width = 214,
                height = 226,
                blend_mode = "additive",
                draw_as_glow = true,
                shift = util.by_pixel(0, 2),
                scale = 0.5,
            }
        }
    },
}

-- Handle ambient-light
entity.energy_source.light_flicker = {
    color = {0, 0, 0},
    minimum_light_size = 0,
    light_intensity_to_size_coefficient = 0,
}

-- Tweak smoke
entity.energy_source.smoke = {
    {
        name = "smoke",
        deviation = {0.1, 0.1},
        position = {0.5, -1.5},
        frequency = 7.5
    }
}

-- Rescale as needed
if reskins.bobs.triggers.assembly.burner_assembling_machine_is_small then
    reskins.lib.rescale_entity(entity.animation, 2/3)
    reskins.lib.rescale_entity(entity.working_visualisations, 2/3)
    reskins.lib.rescale_entity(entity.energy_source.smoke, 2/3)
end