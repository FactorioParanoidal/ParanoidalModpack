-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] and not mods["bobplates"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

local standard_furnace_tint = util.color("ffb700")
local mixing_furnace_tint = util.color("00bfff")
local chemical_furnace_tint = util.color("e50000")

-- STONE FURNACES
local stone_furnace_map = {
    ["stone-furnace"] = {tier = 1, type = "furnace", tint = standard_furnace_tint, is_standard = true},

    -- Names as of Bob's MCI 0.18.9
    ["stone-mixing-furnace"] = {tier = 1, type = "assembling-machine", tint = mixing_furnace_tint, is_mixing = true},
    ["stone-chemical-furnace"] = {tier = 1, type = "assembling-machine", tint = chemical_furnace_tint, is_chemical = true},

    -- Old Names
    ["mixing-furnace"] = {tier = 1, type = "assembling-machine", tint = mixing_furnace_tint, is_mixing = true},
    ["chemical-boiler"] = {tier = 1, type = "assembling-machine", tint = chemical_furnace_tint, is_chemical = true},
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
    local entity_source = data.raw["furnace"]["stone-furnace"]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants and entities
    -- Standard Furnace
    if map.is_standard then
        remnant.animation = make_rotated_animation_variations_from_sheet(1, {
            filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/stone-furnace-remnants.png",
            line_length = 1,
            width = 76,
            height = 66,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(0, 10),
            hr_version =
            {
                filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-stone-furnace-remnants.png",
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
        inputs.icon_filename = nil
        reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
    end

    -- Metal Mixing Furnace
    if map.is_mixing then
        remnant.animation = make_rotated_animation_variations_from_sheet(1, {
            filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/stone-metal-mixing-furnace-remnants.png",
            line_length = 1,
            width = 76,
            height = 66,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(0, 10),
            hr_version =
            {
                filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-stone-metal-mixing-furnace-remnants.png",
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
        entity.energy_source.smoke = entity_source.energy_source.smoke
        entity.working_visualisations = entity_source.working_visualisations
        
        -- Setup icon
        inputs.icon_filename = inputs.directory.."/graphics/icons/assembly/stone-furnace/stone-metal-mixing-furnace.png"
        reskins.lib.construct_icon(name, tier, inputs)
    end

    -- Chemical Furnace
    if map.is_chemical then
        remnant.animation = {
            filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/stone-chemical-furnace-remnants.png",
            width = 101,
            height = 90,
            line_length = 4,
            direction_count = 4,
            frame_count = 1,
            shift = util.by_pixel(2, 17),
            hr_version =
            {
                filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-stone-chemical-furnace-remnants.png",
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
            {
                north_position = {0, 0},
                east_position = {0, 0},
                south_position = {0, 0},
                west_position = {0, 0},
                north_animation = entity_source.working_visualisations[1].animation,
                east_animation = util.empty_sprite(),
                south_animation = entity_source.working_visualisations[1].animation,
                west_animation = entity_source.working_visualisations[1].animation,
                light = entity_source.working_visualisations[1].light
            }
        }

        -- Setup icon
        inputs.icon_filename = inputs.directory.."/graphics/icons/assembly/stone-furnace/stone-chemical-furnace.png"
        reskins.lib.construct_icon(name, tier, inputs)
    end

    if name ~= "stone-furnace" then
        entity.water_reflection = util.copy(data.raw["furnace"]["stone-furnace"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end

-- STEEL FURNACES
local steel_furnace_map = {
    ["steel-furnace"] = {tier = 2, type = "furnace", tint = standard_furnace_tint, furnace = "standard"},

    -- Names as of Bob's MCI 0.18.9
    ["steel-mixing-furnace"] = {tier = 2, type = "assembling-machine", tint = mixing_furnace_tint, furnace = "mixing"},
    ["steel-chemical-furnace"] = {tier = 2, type = "assembling-machine", tint = chemical_furnace_tint, has_4way = true, furnace = "chemical"},
    ["fluid-furnace"] = {tier = 2, type = "furnace", tint = standard_furnace_tint, has_4way = true, is_fluid = true, furnace = "standard"},
    ["fluid-mixing-furnace"] = {tier = 2, type = "assembling-machine", tint = mixing_furnace_tint, has_4way = true, is_fluid = true, furnace = "mixing"},
    ["fluid-chemical-furnace"] = {tier = 2, type = "assembling-machine", tint = chemical_furnace_tint, has_4way = true, is_fluid = true, furnace = "chemical"},

    -- Old names
    ["mixing-steel-furnace"] = {tier = 2, type = "assembling-machine", tint = mixing_furnace_tint, furnace = "mixing"},
    ["chemical-steel-furnace"] = {tier = 2, type = "assembling-machine", tint = chemical_furnace_tint, has_4way = true, furnace = "chemical"},
    ["oil-steel-furnace"] = {tier = 2, type = "furnace", tint = standard_furnace_tint, has_4way = true, is_fluid = true, furnace = "standard"},
    ["oil-mixing-steel-furnace"] = {tier = 2, type = "assembling-machine", tint = mixing_furnace_tint, has_4way = true, is_fluid = true, furnace = "mixing"},
    ["oil-chemical-steel-furnace"] = {tier = 2, type = "assembling-machine", tint = chemical_furnace_tint, has_4way = true, is_fluid = true, furnace = "chemical"},
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

local function steel_furnace_working(type)
    local working_type = "steel-furnace-working"
    if type then
        working_type = "steel-furnace-working-"..type
    end

    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/"..working_type..".png",
        priority = "high",
        line_length = 8,
        width = 86,
        height = 87,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(-1, 2),
        blend_mode = "additive",
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/hr-"..working_type..".png",
            priority = "high",
            line_length = 8,
            width = 172,
            height = 174,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-1, 2),
            blend_mode = "additive",
            scale = 0.5
        }
    }
end

local function steel_furnace_glow()
    return
    {
        filename = "__base__/graphics/entity/steel-furnace/steel-furnace-glow.png",
        priority = "high",
        width = 60,
        height = 43,
        frame_count = 1,
        shift = {0.03125, 0.640625},
        blend_mode = "additive"
    }
end

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
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/steel-furnace/working/hr-"..fire_type..".png",
            priority = "high",
            line_length = 8,
            width = 57,
            height = 81,
            frame_count = 48,
            direction_count = 1,
            shift = util.by_pixel(-0.75, 5.75),
            scale = 0.5
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
    local entity_source = data.raw["furnace"]["steel-furnace"]

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
    inputs.icon_filename = inputs.directory.."/graphics/icons/assembly/steel-furnace/"..sprite_name..".png"
    reskins.lib.construct_icon(name, map.tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin entities and remnants
    if map.has_4way == true then
        remnant.animation = {
          filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/remnants/"..sprite_name.."-remnants.png",
          line_length = 4,
          width = 134,
          height = 119,
          frame_count = 1,
          direction_count = 4,
          shift = util.by_pixel(4, 0.5),
          hr_version =
          {
            filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/remnants/hr-"..sprite_name.."-remnants.png",
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
            filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/remnants/"..sprite_name.."-remnants.png",
            line_length = 1,
            width = 134,
            height = 119,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(4, 0.5),
            hr_version =
            {
                filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/remnants/hr-"..sprite_name.."-remnants.png",
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
                    position = {0, 0},                    
                    north_animation = util.empty_sprite(),
                    east_animation = util.empty_sprite(),
                    south_animation = steel_furnace_fire("right"),
                    west_animation = steel_furnace_fire("left"),
                    light = {intensity = 1, size = 1, color = {r = 1.0, g = 1.0, b = 1.0}}
                },
                  -- Small glow around the furnace mouth
                {
                    position = {0, 0},
                    effect = "flicker",
                    north_animation = util.empty_sprite(),
                    east_animation = util.empty_sprite(),
                    south_animation = steel_furnace_glow(),
                    west_animation = steel_furnace_glow(),
                },
                -- Furnace flicker
                {
                    position = {0, 0},
                    effect = "flicker",
                    north_animation = util.empty_sprite(), 
                    east_animation = util.empty_sprite(),
                    south_animation = steel_furnace_working("right"),
                    west_animation = steel_furnace_working("left"),
                }
            }
        else
            -- Skin the basic chemical furnace working visualization
            entity.working_visualisations = {
                -- Fire effect
                {
                    position = {0, 0},                    
                    north_animation = steel_furnace_fire(), 
                    east_animation = util.empty_sprite(),
                    south_animation = steel_furnace_fire("right"),
                    west_animation = steel_furnace_fire(),
                    light = {intensity = 1, size = 1, color = {r = 1.0, g = 1.0, b = 1.0}}
                },
                  -- Small glow around the furnace mouth
                {
                    position = {0.0, 0.0},
                    effect = "flicker",
                    north_animation = steel_furnace_glow(),
                    east_animation = util.empty_sprite(),
                    south_animation = steel_furnace_glow(),
                    west_animation = steel_furnace_glow(),
                },
                -- Furnace flicker
                {
                    position = {0, 0},
                    effect = "flicker",
                    north_animation = steel_furnace_working(), 
                    east_animation = util.empty_sprite(),
                    south_animation = steel_furnace_working("right"),
                    west_animation = steel_furnace_working(),
                }
            }
        end
    elseif map.is_fluid then
        -- Skin the fluid-based non-chemical furncace working visualizations
        entity.working_visualisations = {
            -- Fire effect
            {
                position = {0, 0},                    
                north_animation = util.empty_sprite(), 
                east_animation = steel_furnace_fire("right"),
                south_animation = steel_furnace_fire(),
                west_animation = steel_furnace_fire("left"),
                light = {intensity = 1, size = 1, color = {r = 1.0, g = 1.0, b = 1.0}}
            },
              -- Small glow around the furnace mouth
            {
                position = {0.0, 0.0},
                effect = "flicker",
                north_animation = util.empty_sprite(),
                east_animation = steel_furnace_glow(),
                south_animation = steel_furnace_glow(),
                west_animation = steel_furnace_glow(),
            },
            -- Furnace flicker
            {
                position = {0, 0},
                effect = "flicker",
                north_animation = util.empty_sprite(), 
                east_animation = steel_furnace_working("right"),
                south_animation = steel_furnace_working(),
                west_animation = steel_furnace_working("left"),
            }
        }
    else
        -- Skin the standard-type furnace working visualizations
        entity.working_visualisations = data.raw["furnace"]["steel-furnace"].working_visualisations
    end

    if name ~= "steel-furnace" then
        entity.water_reflection = util.copy(data.raw["furnace"]["steel-furnace"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end

-- ELECTRIC FURNACES
local electric_furnace_map = {
    ["electric-furnace"] = {furnace = "standard", tier = 3, type = "furnace", tint = standard_furnace_tint},
    ["electric-furnace-2"] = {furnace = "standard", tier = 4, type = "furnace"},
    ["electric-furnace-3"] = {furnace = "standard", tier = 5, type = "furnace"},

    -- Names as of Bob's MCI 0.18.9
    ["electric-mixing-furnace"] = {furnace = "mixing", tier = 3, type = "assembling-machine", tint = mixing_furnace_tint},
    ["electric-chemical-furnace"] = {furnace = "chemical", tier = 3, type = "assembling-machine", tint = chemical_furnace_tint, has_fluids = true},
    ["electric-chemical-mixing-furnace"] = {furnace = "multi", tier = 4, type = "assembling-machine", has_fluids = true},
    ["electric-chemical-mixing-furnace-2"] = {furnace = "multi", tier = 5, type = "assembling-machine", has_fluids = true},

    -- Old names
    ["chemical-furnace"] = {furnace = "chemical", tier = 3, type = "assembling-machine", tint = chemical_furnace_tint, has_fluids = true},
}

local function electric_furnace_shadow()
    return 
    {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/electric-furnace-shadow.png",
        priority = "high",
        width = 114,
        height = 86,
        shift = util.by_pixel(10.75, 7.25),
        draw_as_shadow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-furnace-shadow.png",
            priority = "high",
            width = 228,
            height = 172,
            shift = util.by_pixel(10.75, 7.25),
            draw_as_shadow = true,
            scale = 0.5
        }
    }
end

local function furnace_heater(has_fluids)
    local furnace_heater = {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/electric-furnace-heater.png",
        priority = "high",
        width = 30,
        height = 28,
        frame_count = 12,
        animation_speed = 0.5,
        shift = util.by_pixel(2, 33),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-furnace-heater.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(2, 33),
            scale = 0.5
        }
    }

    if has_fluids then
        return
        {
            north_animation = furnace_heater,
            east_animation = furnace_heater,
            west_animation = furnace_heater,
            south_animation = util.empty_sprite(),
            light = {intensity = 0.4, size = 6, shift = {0.0, 1.0}, color = {r = 1.0, g = 1.0, b = 1.0}}
        }
    else
        return
        {
            animation = furnace_heater,
            light = {intensity = 0.4, size = 6, shift = {0.0, 1.0}, color = {r = 1.0, g = 1.0, b = 1.0}}
        }
    end
end

local function furnace_large_propeller()
    return
    {
        animation = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/propeller-large.png",
            priority = "high",
            width = 19,
            height = 13,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(-20, -18),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-propeller-large.png",
                priority = "high",
                width = 38,
                height = 26,
                frame_count = 4,
                animation_speed = 0.5,
                shift = util.by_pixel(-20, -18),
                scale = 0.5
            }
        }
    }
end

local function furnace_small_propeller(is_shifted)
    local shift = util.by_pixel(4, -37.5)
    if is_shifted then
        shift = util.by_pixel(1, -24)
    end
    
    return
    {
        animation = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/propeller-small.png",
            priority = "high",
            width = 12,
            height = 8,
            frame_count = 4,
            animation_speed = 0.5,
            shift = shift,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-propeller-small.png",
                priority = "high",
                width = 24,
                height = 16,
                frame_count = 4,
                animation_speed = 0.5,
                shift = shift,
                scale = 0.5
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(electric_furnace_map) do
    -- Setup inputs, parse map
    local tier = map.tier

    local inputs = {
        type = map.type,
        base_entity = "electric-furnace",
        directory = reskins.bobs.directory,
        mod = "bobs",
        group = "assembly",
        particles = {["medium"] = 2},
        tint = map.tint or reskins.lib.tint_index["tier-"..tier],
        icon_name = "electric-furnace",
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

    -- Setup icons
    if map.furnace == "chemical" then
        inputs.icon_base = "electric-chemical-furnace"
        inputs.icon_layers = 1
    elseif map.furnace == "mixing" then
        inputs.icon_base = "electric-metal-mixing-furnace"
        inputs.icon_layers = 1
    elseif map.furnace == "multi" then
        inputs.icon_base = "electric-multi-purpose-furnace"
        inputs.icon_mask = inputs.icon_base
        inputs.icon_highlights = inputs.icon_base
        inputs.icon_layers = nil
    elseif map.furnace == "standard" then
        inputs.icon_base = nil
        inputs.icon_mask = nil
        inputs.icon_highlights = nil
        inputs.icon_layers = nil
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/electric-furnace/remnants/electric-furnace-remnants.png",
                line_length = 1,
                width = 228,
                height = 224,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3, 7),
                hr_version = {
                    filename = "__base__/graphics/entity/electric-furnace/remnants/hr-electric-furnace-remnants.png",
                    line_length = 1,
                    width = 454,
                    height = 448,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-3.25, 7.25),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/electric-furnace-remnants-mask.png",
                line_length = 1,
                width = 108,
                height = 104,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3, 7),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-electric-furnace-remnants-mask.png",
                    line_length = 1,
                    width = 214,
                    height = 208,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-3.25, 7.25),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/electric-furnace-remnants-highlights.png",
                line_length = 1,
                width = 108,
                height = 104,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3, 7),
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-electric-furnace-remnants-highlights.png",
                    line_length = 1,
                    width = 214,
                    height = 208,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-3.25, 7.25),
                    blend_mode = "additive",
                    scale = 0.5,
                }
            }
        }
    }

    -- Reskin entities
    if map.furnace == "chemical" then
        entity.animation = {
            layers = {
                -- Base
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-chemical-furnace-base.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-chemical-furnace-base.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        scale = 0.5
                    }
                },
                -- Shadow
                electric_furnace_shadow()
            }
        }

        entity.working_visualisations = {
            furnace_heater(true)
        }

        -- Add chemical furnace remnants details
        table.insert(remnant.animation.layers, {
            filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/chemical-furnace-remnants-overlay.png",
            line_length = 1,
            width = 108,
            height = 104,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-3, 7),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-chemical-furnace-remnants-overlay.png",
                line_length = 1,
                width = 214,
                height = 208,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3.25, 7.25),
                scale = 0.5,
            }
        })
    elseif map.furnace == "mixing" then
        entity.animation = {
            layers = {
                -- Base
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-metal-mixing-furnace-base.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-metal-mixing-furnace-base.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        scale = 0.5
                    }
                },
                -- Shadow
                electric_furnace_shadow()
            }
        }

        entity.working_visualisations = {
            furnace_heater(),
            furnace_large_propeller(),
            furnace_small_propeller(true),
        }
    elseif map.furnace == "multi" then
        entity.animation = {
            layers = {
                -- Base
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-multi-purpose-furnace-base.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-multi-purpose-furnace-base.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-multi-purpose-furnace-mask.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    tint = inputs.tint,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-multi-purpose-furnace-mask.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-multi-purpose-furnace-highlights.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    blend_mode = "additive",
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-multi-purpose-furnace-highlights.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        blend_mode = "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                electric_furnace_shadow()
            }
        }

        entity.working_visualisations = {
            furnace_heater(true),
            furnace_small_propeller(true),
        }

        -- Add multi-purpose furnace remnants details
        table.insert(remnant.animation.layers, {
            filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/multi-purpose-furnace-remnants-overlay.png",
            line_length = 1,
            width = 108,
            height = 104,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-3, 7),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-multi-purpose-furnace-remnants-overlay.png",
                line_length = 1,
                width = 214,
                height = 208,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3.25, 7.25),
                scale = 0.5,
            }
        })
    elseif map.furnace == "standard" then
        entity.animation = {
            layers = {
                -- Base
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-furnace-base.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-furnace-base.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-furnace-mask.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    tint = inputs.tint,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-furnace-mask.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/electric-furnace-highlights.png",
                    priority = "high",
                    width = 119,
                    height = 106,
                    shift = util.by_pixel(1, 1),
                    blend_mode = "additive",
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/assembly/electric-furnace/hr-electric-furnace-highlights.png",
                        priority = "high",
                        width = 238,
                        height = 212,
                        shift = util.by_pixel(1, 1),
                        blend_mode = "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                electric_furnace_shadow()
            }
        }

        entity.working_visualisations = {
            furnace_heater(),
            furnace_large_propeller(),
            furnace_small_propeller(),
        }
    end

    -- Handle pipe pictures
    if map.has_fluids then
        entity.fluid_boxes = {
            {
                production_type = "input",
                pipe_picture = reskins.bobs.furnace_pipe_pictures(inputs.tint),
                pipe_covers = pipecoverspictures(),
                base_area = 10,
                base_level = -1,
                pipe_connections = {{ type="input", position = {0, -2} }},
                secondary_draw_orders = { north = -1 }
            },
            off_when_no_fluid_recipe = true
        }       
    end

    if name ~= "electric-furnace" then
        entity.water_reflection = util.copy(data.raw["furnace"]["electric-furnace"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end