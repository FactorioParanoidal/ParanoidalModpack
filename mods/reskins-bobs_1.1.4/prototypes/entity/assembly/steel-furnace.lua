-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] and not mods["bobplates"] then return end
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then return end

local standard_furnace_tint = util.color("ffb700")
local mixing_furnace_tint = util.color("00bfff")
local chemical_furnace_tint = util.color("e50000")

local steel_furnace_map = {
    ["steel-furnace"] = {tier = 2, type = "furnace", tint = standard_furnace_tint, furnace = "standard"},
    ["steel-mixing-furnace"] = {tier = 2, type = "assembling-machine", tint = mixing_furnace_tint, furnace = "mixing"},
    ["steel-chemical-furnace"] = {tier = 2, type = "assembling-machine", tint = chemical_furnace_tint, has_4way = true, furnace = "chemical"},
    ["fluid-furnace"] = {tier = 2, type = "furnace", tint = standard_furnace_tint, has_4way = true, is_fluid = true, furnace = "standard"},
    ["fluid-mixing-furnace"] = {tier = 2, type = "assembling-machine", tint = mixing_furnace_tint, has_4way = true, is_fluid = true, furnace = "mixing"},
    ["fluid-chemical-furnace"] = {tier = 2, type = "assembling-machine", tint = chemical_furnace_tint, has_4way = true, is_fluid = true, furnace = "chemical"},
}

local function steel_furnace_entity_skin(name, shadow)
    return
    {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/"..name..".png",
                priority = "high",
                width = 86,
                height = 87,
                frame_count = 1,
                shift = util.by_pixel(-1, 2),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/hr-"..name..".png",
                    priority = "high",
                    width = 172,
                    height = 174,
                    frame_count = 1,
                    shift = util.by_pixel(-1, 2),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/shadows/"..shadow.."-shadow.png",
                priority = "high",
                width = 141,
                height = 71,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(38.5, 3.5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/shadows/hr-"..shadow.."-shadow.png",
                    priority = "high",
                    width = 282,
                    height = 142,
                    frame_count = 1,
                    draw_as_shadow = true,
                    shift = util.by_pixel(38.5, 3.5),
                    scale = 0.5
                }
            }
        }
    }
end

-- Working light
local function steel_furnace_working(type)
    local working_type = "steel-furnace-working"
    if type then
        working_type = "steel-furnace-working-"..type
    end

    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/"..working_type..".png",
        priority = "high",
        width = 86,
        height = 87,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(-1, 2),
        blend_mode = "additive",
        draw_as_glow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/hr-"..working_type..".png",
            priority = "high",
            width = 172,
            height = 174,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-1, 2),
            blend_mode = "additive",
            draw_as_glow = true,
            scale = 0.5
        }
    }
end

-- Aura Glow
local function steel_furnace_glow()
    return
    {
        filename = "__base__/graphics/entity/steel-furnace/steel-furnace-glow.png",
        priority = "high",
        width = 60,
        height = 43,
        frame_count = 1,
        shift = {0.03125, 0.640625},
        blend_mode = "additive",
        draw_as_glow = true,
    }
end

-- Furnace Fire
local function steel_furnace_fire(type)
    local fire_type = "steel-furnace-fire"
    if type then
        fire_type = "steel-furnace-fire-"..type
    end

    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/"..fire_type..".png",
        priority = "high",
        line_length = 8,
        width = 29,
        height = 40,
        frame_count = 48,
        direction_count = 1,
        shift = util.by_pixel(-0.5, 6),
        draw_as_glow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/hr-"..fire_type..".png",
            priority = "high",
            line_length = 8,
            width = 57,
            height = 81,
            frame_count = 48,
            direction_count = 1,
            shift = util.by_pixel(-0.75, 5.75),
            draw_as_glow = true,
            scale = 0.5
        }
    }
end

local function steel_furnace_ground_light(type)
    local ground_type = "steel-furnace-ground-light"
    if type then
        ground_type = "steel-furnace-ground-light-"..type
    end
    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/lights/"..ground_type..".png",
        priority = "high",
        line_length = 1,
        draw_as_light = true,
        width = 78,
        height = 64,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(0, 48),
        blend_mode = "additive",
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/lights/hr-"..ground_type..".png",
            priority = "high",
            line_length = 1,
            draw_as_light = true,
            width = 152,
            height = 126,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(1, 48),
            blend_mode = "additive",
            scale = 0.5,
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(steel_furnace_map) do
    -- Setup inputs, parse map
    local inputs = {
        type = map.type,
        base_entity = "steel-furnace",
        directory = reskins.bobs.directory,
        mod = "bobs",
        group = "assembly",
        tint = map.tint,
        particles = {["medium"] = 2},
        make_icons = false,
    }

    if reskins.lib.setting("reskins-bobs-do-furnace-tier-labeling") == true then
        inputs.tier_labels = true
    else
        inputs.tier_labels = false
    end

    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Abstract from entity name to sprite sheet name
    local sprite_name, shadow
    if map.furnace == "mixing" then
        sprite_name = "steel-metal-mixing-furnace"
        shadow = "steel-furnace"
    elseif map.furnace == "chemical" then
        sprite_name = "steel-chemical-furnace"
        shadow = sprite_name
    elseif map.furnace == "standard" then
        sprite_name = "steel-furnace"
        shadow = sprite_name
    end

    -- Prepend oil prefix when working with fluid-based furnaces
    if map.is_fluid == true then
        sprite_name = "oil-"..sprite_name
        shadow = "oil-"..shadow

        -- Clear out the pipe_picture field
        entity.energy_source.fluid_box.pipe_picture = nil
    end

    -- Setup icon
    inputs.icon_filename = reskins.bobs.directory.."/graphics/icons/assembly/steel-furnace/"..sprite_name..".png"
    reskins.lib.construct_icon(name, map.tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin entities and remnants
    if map.has_4way == true then
        remnant.animation = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/remnants/"..sprite_name.."-remnants.png",
            line_length = 4,
            width = 134,
            height = 119,
            frame_count = 1,
            direction_count = 4,
            shift = util.by_pixel(4, 0.5),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/remnants/hr-"..sprite_name.."-remnants.png",
                line_length = 4,
                width = 268,
                height = 238,
                frame_count = 1,
                direction_count = 4,
                shift = util.by_pixel(4, 0.5),
                scale = 0.5,
            }
        }
        entity.animation = reskins.lib.make_4way_animation_from_spritesheet(steel_furnace_entity_skin(sprite_name, shadow))
    else
        remnant.animation = make_rotated_animation_variations_from_sheet(1, {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/remnants/"..sprite_name.."-remnants.png",
            line_length = 1,
            width = 134,
            height = 119,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(4, 0.5),
            hr_version =
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/remnants/hr-"..sprite_name.."-remnants.png",
                line_length = 1,
                width = 268,
                height = 238,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(4, 0.5),
                scale = 0.5,
            }
        })

        entity.animation = steel_furnace_entity_skin(sprite_name, shadow)
    end

    if map.furnace == "chemical" then
        if map.is_fluid then
            -- Skin the fluid-based chemical furnace working visualization
            entity.working_visualisations = {
                -- Fire effect
                {
                    fadeout = true,
                    effect = "flicker",
                    south_animation = steel_furnace_fire("right"),
                    west_animation = steel_furnace_fire("left"),
                },
                -- Small glow around the furnace mouth
                {
                    fadeout = true,
                    effect = "flicker",
                    south_animation = steel_furnace_glow(),
                    west_animation = steel_furnace_glow(),
                },
                -- Furnace flicker
                {
                    fadeout = true,
                    effect = "flicker",
                    south_animation = steel_furnace_working("right"),
                    west_animation = steel_furnace_working("left"),
                },
                -- Ground light
                {
                    fadeout = true,
                    effect = "flicker",
                    south_animation = steel_furnace_ground_light("right"),
                    west_animation = steel_furnace_ground_light("left"),
                }
            }
        else
            -- Skin the basic chemical furnace working visualization
            entity.working_visualisations = {
                -- Fire effect
                {
                    fadeout = true,
                    effect = "flicker",
                    north_animation = steel_furnace_fire(),
                    south_animation = steel_furnace_fire("right"),
                    west_animation = steel_furnace_fire(),
                },
                -- Small glow around the furnace mouth
                {
                    fadeout = true,
                    effect = "flicker",
                    north_animation = steel_furnace_glow(),
                    south_animation = steel_furnace_glow(),
                    west_animation = steel_furnace_glow(),
                },
                -- Furnace flicker
                {
                    fadeout = true,
                    effect = "flicker",
                    north_animation = steel_furnace_working(),
                    south_animation = steel_furnace_working("right"),
                    west_animation = steel_furnace_working(),
                },
                -- Ground light
                {
                    fadeout = true,
                    effect = "flicker",
                    north_animation = steel_furnace_ground_light(),
                    south_animation = steel_furnace_ground_light("right"),
                    west_animation = steel_furnace_ground_light(),
                }
            }
        end
    elseif map.is_fluid then
        -- Skin the fluid-based non-chemical furncace working visualizations
        entity.working_visualisations = {
            -- Fire effect
            {
                fadeout = true,
                effect = "flicker",
                east_animation = steel_furnace_fire("right"),
                south_animation = steel_furnace_fire(),
                west_animation = steel_furnace_fire("left"),
            },
            -- Small glow around the furnace mouth
            {
                fadeout = true,
                effect = "flicker",
                east_animation = steel_furnace_glow(),
                south_animation = steel_furnace_glow(),
                west_animation = steel_furnace_glow(),
            },
            -- Furnace flicker
            {
                fadeout = true,
                effect = "flicker",
                east_animation = steel_furnace_working("right"),
                south_animation = steel_furnace_working(),
                west_animation = steel_furnace_working("left"),
            },
            -- Ground light
            {
                fadeout = true,
                effect = "flicker",
                east_animation = steel_furnace_ground_light("right"),
                south_animation = steel_furnace_ground_light(),
                west_animation = steel_furnace_ground_light("left"),
            }
        }
    else
        -- Skin the standard-type furnace working visualizations
        entity.working_visualisations = data.raw["furnace"]["steel-furnace"].working_visualisations
    end

    -- Handle ambient-light
    entity.energy_source.light_flicker = {
        color = {0, 0, 0},
        minimum_light_size = 0,
        light_intensity_to_size_coefficient = 0,
    }

    if name ~= "steel-furnace" then
        entity.water_reflection = util.copy(data.raw["furnace"]["steel-furnace"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end