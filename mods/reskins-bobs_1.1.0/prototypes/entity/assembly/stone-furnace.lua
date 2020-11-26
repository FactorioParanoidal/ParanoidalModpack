-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] and not mods["bobplates"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

local standard_furnace_tint = util.color("ffb700")
local mixing_furnace_tint = util.color("00bfff")
local chemical_furnace_tint = util.color("e50000")

local stone_furnace_map = {
    ["stone-furnace"] = {tier = 1, type = "furnace", tint = standard_furnace_tint, is_standard = true},
    ["stone-mixing-furnace"] = {tier = 1, type = "assembling-machine", tint = mixing_furnace_tint, is_mixing = true},
    ["stone-chemical-furnace"] = {tier = 1, type = "assembling-machine", tint = chemical_furnace_tint, is_chemical = true},
}

local function stone_furnace_entities(name, shadow)
    return
    {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/"..name..".png",
                priority = "extra-high",
                width = 76,
                height = 76,
                frame_count = 1,
                shift = util.by_pixel(0, 1),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/hr-"..name..".png",
                    priority = "extra-high",
                    width = 152,
                    height = 152,
                    frame_count = 1,
                    shift = util.by_pixel(0, 1),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/shadows/"..shadow.."-shadow.png",
                priority = "extra-high",
                width = 88,
                height = 70,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(12, 3),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/shadows/hr-"..shadow.."-shadow.png",
                    priority = "extra-high",
                    width = 176,
                    height = 140,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(12, 3),
                    scale = 0.5
                }
            }
        }
    }
end

local base_fire_animation = {
    filename = "__base__/graphics/entity/stone-furnace/stone-furnace-fire.png",
    priority = "extra-high",
    line_length = 8,
    width = 20,
    height = 49,
    frame_count = 48,
    axially_symmetrical = false,
    direction_count = 1,
    shift = util.by_pixel(-0.5, 5.5),
    draw_as_glow = true,
    hr_version = {
        filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-fire.png",
        priority = "extra-high",
        line_length = 8,
        width = 41,
        height = 100,
        frame_count = 48,
        axially_symmetrical = false,
        direction_count = 1,
        shift = util.by_pixel(-0.75, 5.5),
        draw_as_glow = true,
        scale = 0.5
    }
}

local furnace_light = reskins.lib.make_4way_animation_from_spritesheet({
    filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/lights/stone-furnace-light-4way.png",
    blend_mode = "additive",
    width = 76,
    height = 86,
    repeat_count = 48,
    shift = util.by_pixel(0, 1),
    draw_as_glow = true,
    hr_version = {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/lights/hr-stone-furnace-light-4way.png",
        blend_mode = "additive",
        width = 152,
        height = 172,
        repeat_count = 48,
        shift = util.by_pixel(0, 1),
        draw_as_glow = true,
        scale = 0.5,
    }
})

local furnace_ground_light = {
    filename = "__base__/graphics/entity/stone-furnace/stone-furnace-ground-light.png",
    blend_mode = "additive",
    draw_as_light = true,
    width = 56,
    height = 56,
    repeat_count = 48,
    shift = util.by_pixel(0, 44),
    hr_version = {
        filename = "__base__/graphics/entity/stone-furnace/hr-stone-furnace-ground-light.png",
        blend_mode = "additive",
        draw_as_light = true,
        width = 116,
        height = 110,
        repeat_count = 48,
        shift = util.by_pixel(-1, 44),
        scale = 0.5,
    }
}

local function single_fire_light()
return
    {
        layers = {
            base_fire_animation,
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/lights/stone-furnace-light.png",
                blend_mode = "additive",
                width = 76,
                height = 86,
                repeat_count = 48,
                shift = util.by_pixel(0, 1),
                draw_as_glow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/lights/hr-stone-furnace-light.png",
                    blend_mode = "additive",
                    width = 152,
                    height = 172,
                    repeat_count = 48,
                    shift = util.by_pixel(0, 1),
                    draw_as_glow = true,
                    scale = 0.5,
                }
            },
        }
    }
end

local function four_way_fire_light(direction)
    return
    {
        layers = {
            base_fire_animation,
            furnace_light[direction],
        },
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(stone_furnace_map) do
    -- Setup inputs, parse map
    local inputs = {
        type = map.type,
        base_entity = "stone-furnace",
        directory = reskins.bobs.directory,
        mod = "bobs",
        group = "assembly",
        tint = map.tint,
        particles = {["medium-stone"] = 2},
        make_icons = false,
    }

    if reskins.lib.setting("reskins-bobs-do-furnace-tier-labeling") == true then
        inputs.tier_labels = true
    else
        inputs.tier_labels = false
    end

    local tier = map.tier

    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants and entities
    -- Standard Furnace
    if map.is_standard then
        remnant.animation = make_rotated_animation_variations_from_sheet(1, {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/remnants/stone-furnace-remnants.png",
            line_length = 1,
            width = 76,
            height = 66,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(0, 10),
            hr_version =
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-stone-furnace-remnants.png",
                line_length = 1,
                width = 152,
                height = 130,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 9.5),
                scale = 0.5,
            }
        })

        entity.animation = stone_furnace_entities("stone-furnace", "stone-furnace")

        -- Handle working_visualisations
        entity.working_visualisations = {
            -- Furnace and stack lights
            {
                fadeout = true,
                effect = "flicker",
                animation = single_fire_light(),
            },

            -- Ground light
            {
                fadeout = true,
                effect = "flicker",
                animation = furnace_ground_light,
            }
        }

        inputs.icon_filename = nil
        reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
    end

    -- Metal Mixing Furnace
    if map.is_mixing then
        remnant.animation = make_rotated_animation_variations_from_sheet(1, {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/remnants/stone-metal-mixing-furnace-remnants.png",
            line_length = 1,
            width = 76,
            height = 66,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(0, 10),
            hr_version =
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-stone-metal-mixing-furnace-remnants.png",
                line_length = 1,
                width = 152,
                height = 130,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 9.5),
                scale = 0.5,
            }
        })

        entity.animation = stone_furnace_entities("stone-metal-mixing-furnace", "stone-furnace")

        -- Handle working_visualisations
        entity.working_visualisations = {
            -- Furnace and stack lights
            {
                fadeout = true,
                effect = "flicker",
                animation = single_fire_light(),
            },

            -- Ground light
            {
                fadeout = true,
                effect = "flicker",
                animation = furnace_ground_light,
            }
        }

        -- Setup icon
        inputs.icon_filename = reskins.bobs.directory.."/graphics/icons/assembly/stone-furnace/stone-metal-mixing-furnace.png"
        reskins.lib.construct_icon(name, tier, inputs)
    end

    -- Chemical Furnace
    if map.is_chemical then
        remnant.animation = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/remnants/stone-chemical-furnace-remnants.png",
            width = 101,
            height = 90,
            line_length = 4,
            direction_count = 4,
            frame_count = 1,
            shift = util.by_pixel(2, 17),
            hr_version =
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-stone-chemical-furnace-remnants.png",
                width = 202,
                height = 180,
                line_length = 4,
                direction_count = 4,
                frame_count = 1,
                shift = util.by_pixel(2, 17),
                scale = 0.5,
            }
        }

        entity.animation = reskins.lib.make_4way_animation_from_spritesheet(stone_furnace_entities("stone-chemical-furnace", "stone-chemical-furnace", inputs))

        -- Handle working_visualisations
        entity.working_visualisations = {
            -- Furnace and stack lights
            {
                fadeout = true,
                effect = "flicker",
                north_animation = four_way_fire_light("north"),
                east_animation = furnace_light["east"],
                south_animation = four_way_fire_light("south"),
                west_animation = four_way_fire_light("west"),
            },

            -- Ground light
            {
                fadeout = true,
                effect = "flicker",
                north_animation = furnace_ground_light,
                south_animation = furnace_ground_light,
                west_animation = furnace_ground_light,
            }
        }

        -- Setup icon
        inputs.icon_filename = reskins.bobs.directory.."/graphics/icons/assembly/stone-furnace/stone-chemical-furnace.png"
        reskins.lib.construct_icon(name, tier, inputs)
    end

    -- Handle ambient-light
    entity.energy_source.light_flicker = {
        color = {0, 0, 0},
        minimum_light_size = 0,
        light_intensity_to_size_coefficient = 0,
    }

    if name ~= "stone-furnace" then
        entity.water_reflection = util.copy(data.raw["furnace"]["stone-furnace"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end