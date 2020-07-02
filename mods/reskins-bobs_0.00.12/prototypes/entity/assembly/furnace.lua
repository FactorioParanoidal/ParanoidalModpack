-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] and not mods["bobplates"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

local stone_furnace_tint = util.color("ffb700")
local mixing_furnace_tint = util.color("00bfff")
local chemical_furnace_tint = util.color("ff0000")

-- STONE FURNACES
local stone_furnace_map = {
    ["stone-furnace"] = {1, "furnace", stone_furnace_tint},

    -- New names as of Bobs MCI 0.18.9
    ["stone-mixing-furnace"] = {1, "assembling-machine", mixing_furnace_tint},
    ["stone-chemical-furnace"] = {1, "assembling-machine", chemical_furnace_tint},

    -- Old Names
    ["mixing-furnace"] = {1, "assembling-machine", mixing_furnace_tint},
    ["chemical-boiler"] = {1, "assembling-machine", chemical_furnace_tint},
}

local function stone_furnace_entities(name, shadow)
    return
    {
        layers = {
            {
                filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/"..name..".png",
                priority = "extra-high",
                width = 76,
                height = 76,
                frame_count = 1,
                shift = util.by_pixel(0, 1),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/hr-"..name..".png",
                    priority = "extra-high",
                    width = 152,
                    height = 152,
                    frame_count = 1,
                    shift = util.by_pixel(0, 1),
                    scale = 0.5
                }
            },
            {
                filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/shadows/"..shadow.."-shadow.png",
                priority = "extra-high",
                width = 88,
                height = 70,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(12, 3),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/shadows/hr-"..shadow.."-shadow.png",
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

local function stone_furnace_remnants(name, rotations)
    local remnants = make_rotated_animation_variations_from_sheet(rotations,
    {
        filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/"..name.."-remnants.png",
        line_length = 1,
        width = 76,
        height = 66,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(0, 10),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/assembly/stone-furnace/remnants/hr-"..name.."-remnants.png",
            line_length = 1,
            width = 152,
            height = 130,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(0, 9.5),
            scale = 0.5,
        }
    })

    return remnants
end

-- Reskin entities, create and assign extra details
for name, map in pairs(stone_furnace_map) do
    -- Setup inputs, parse map
    inputs = {
        type = map[2],
        base_entity = "stone-furnace",
        directory = reskins.bobs.directory,
        mod = "bobs",
        group = "assembly",
        tint = map[3],
        particles = {["medium-stone"] = 2},
        make_icons = false,
        make_remnants = false,
    }

    if reskins.lib.setting("reskins-bobs-do-furnace-tier-labeling") == true then
        inputs.tier_labels = true
    else
        inputs.tier_labels = false
    end

    tier = map[1]

    -- Fetch entity
    entity = data.raw[inputs.type][name]
    entity_source = data.raw["furnace"]["stone-furnace"]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants and entities
    if name == "stone-furnace" then
        entity.animation = stone_furnace_entities("stone-furnace", "stone-furnace")
        inputs.icon_filename = nil
        reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
    end

    if string.find(name, "mixing") then
        entity.animation = stone_furnace_entities("stone-metal-mixing-furnace", "stone-furnace")
        entity.energy_source.smoke = entity_source.energy_source.smoke
        entity.working_visualisations = entity_source.working_visualisations
        
        -- Setup icon
        inputs.icon_filename = inputs.directory.."/graphics/icons/assembly/stone-furnace/stone-metal-mixing-furnace.png"
        reskins.lib.construct_icon(name, tier, inputs)
    end

    if string.find(name, "chemical") then
        entity.animation = make_4way_animation_from_spritesheet(stone_furnace_entities("stone-chemical-furnace", "stone-chemical-furnace", inputs))

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

    -- Label to skip to next iteration
    ::continue::
end

-- STEEL FURNACES
local steel_furnace_map = {
    ["steel-furnace"] = {2, "furnace", stone_furnace_tint, false},

    -- New names as of Bobs MCI 0.18.9
    ["steel-mixing-furnace"] = {2, "assembling-machine", mixing_furnace_tint, false},
    ["steel-chemical-furnace"] = {2, "assembling-machine", chemical_furnace_tint, true},
    ["fluid-furnace"] = {2, "furnace", stone_furnace_tint, true},
    ["fluid-mixing-furnace"] = {2, "assembling-machine", mixing_furnace_tint, true},
    ["fluid-chemical-furnace"] = {2, "assembling-machine", chemical_furnace_tint, true},

    -- Old names
    ["mixing-steel-furnace"] = {2, "assembling-machine", mixing_furnace_tint, false},
    ["chemical-steel-furnace"] = {2, "assembling-machine", chemical_furnace_tint, true},
    ["oil-steel-furnace"] = {2, "furnace", stone_furnace_tint, true},
    ["oil-mixing-steel-furnace"] = {2, "assembling-machine", mixing_furnace_tint, true},
    ["oil-chemical-steel-furnace"] = {2, "assembling-machine", chemical_furnace_tint, true},
}

local function steel_furnace_entity_skin(name, shadow)
    return
    {
        layers = {
            {
                filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/"..name..".png",
                priority = "high",
                width = 86,
                height = 87,
                frame_count = 1,
                shift = util.by_pixel(-1, 2),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/hr-"..name..".png",
                    priority = "high",
                    width = 172,
                    height = 174,
                    frame_count = 1,
                    shift = util.by_pixel(-1, 2),
                    scale = 0.5
                }
            },
            {
                filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/shadows/"..shadow.."-shadow.png",
                priority = "high",
                width = 141,
                height = 71,
                frame_count = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(38.5, 3.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/shadows/hr-"..shadow.."-shadow.png",
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
    if type then
        working_type = "steel-furnace-working-"..type
    else
        working_type = "steel-furnace-working"
    end

    return
    {
        filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/working/"..working_type..".png",
        priority = "high",
        line_length = 8,
        width = 86,
        height = 87,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(-1, 2),
        blend_mode = "additive",
        hr_version = {
            filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/working/hr-"..working_type..".png",
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
    if type then
        fire_type = "steel-furnace-fire-"..type
    else
        fire_type = "steel-furnace-fire"
    end

    return
    {
        filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/working/"..fire_type..".png",
        priority = "high",
        line_length = 8,
        width = 29,
        height = 40,
        frame_count = 48,
        direction_count = 1,
        shift = util.by_pixel(-0.5, 6),
        hr_version = {
            filename = inputs.directory.."/graphics/entity/assembly/steel-furnace/working/hr-"..fire_type..".png",
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
    inputs = {
        type = map[2],
        base_entity = "steel-furnace",
        directory = reskins.bobs.directory,
        mod = "bobs",
        group = "assembly",
        tint = map[3],
        particles = {["medium"] = 2},
        make_icons = false,
        make_remnants = false,
    }

    if reskins.lib.setting("reskins-bobs-do-furnace-tier-labeling") == true then
        inputs.tier_labels = true
    else
        inputs.tier_labels = false
    end

    tier = map[1]
    has_4way = map[4] or false

    -- Fetch entity
    entity = data.raw[inputs.type][name]
    entity_source = data.raw["furnace"]["steel-furnace"]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Abstract from entity name to sprite sheet name
    if string.find(name, "mixing") then
        sprite_name = "steel-metal-mixing-furnace"
        shadow = "steel-furnace"
    elseif string.find(name, "chemical") then
        sprite_name = "steel-chemical-furnace"
        shadow = sprite_name
    else
        sprite_name = "steel-furnace"
        shadow = sprite_name
    end

    -- Prepend oil prefix when working with fluid-based furnaces
    if string.find(name, "fluid") or string.find(name, "oil") then
        sprite_name = "oil-"..sprite_name
        shadow = "oil-"..shadow

        -- Clear out the pipe_picture field
        entity.energy_source.fluid_box.pipe_picture = nil
    end

    -- Setup icon
    inputs.icon_filename = inputs.directory.."/graphics/icons/assembly/steel-furnace/"..sprite_name..".png"
    reskins.lib.construct_icon(name, tier, inputs)

    -- Fetch remnant
    remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin entities and remnants
    if has_4way == true then
        entity.animation = make_4way_animation_from_spritesheet(steel_furnace_entity_skin(sprite_name, shadow))
    else
        entity.animation = steel_furnace_entity_skin(sprite_name, shadow)
    end

    if has_4way ~= true then
        entity.working_visualisations = data.raw["furnace"]["steel-furnace"].working_visualisations
    end

    if string.find(name, "chemical") then
        if string.find(name, "fluid") or string.find(name, "oil") then
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
    elseif string.find(name, "fluid") or string.find(name, "oil") then
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
    end

    -- Label to skip to next iteration
    ::continue::
end

-- -- Electrical Base
-- electric-furnace
-- electric-furnace-2
-- electric-furnace-3
-- chemical-furnace                        -- Old Chemical Electric
-- electric-chemical-furnace               -- New Chemical Electric
-- electric-mixing-furnace                 -- Metal-Mixing Electric
-- electric-chemical-mixing-furnace        -- Multi Purpose 1
-- electric-chemical-mixing-furnace-2      -- Multi Purpose 2

-- animation =
--     {
--       layers =
--       {
--         {
--           filename = "__base__/graphics/entity/electric-furnace/electric-furnace-base.png",
--           priority = "high",
--           width = 129,
--           height = 100,
--           frame_count = 1,
--           shift = {0.421875, 0},
--           hr_version =
--           {
--             filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace.png",
--             priority = "high",
--             width = 239,
--             height = 219,
--             frame_count = 1,
--             shift = util.by_pixel(0.75, 5.75),
--             scale = 0.5
--           }
--         },
--         {
--           filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
--           priority = "high",
--           width = 129,
--           height = 100,
--           frame_count = 1,
--           shift = {0.421875, 0},
--           draw_as_shadow = true,
--           hr_version =
--           {
--             filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
--             priority = "high",
--             width = 227,
--             height = 171,
--             frame_count = 1,
--             draw_as_shadow = true,
--             shift = util.by_pixel(11.25, 7.75),
--             scale = 0.5
--           }
--         }
--       }
--     },
--     working_visualisations =
--     {
--       {
--         animation =
--         {
--           filename = "__base__/graphics/entity/electric-furnace/electric-furnace-heater.png",
--           priority = "high",
--           width = 25,
--           height = 15,
--           frame_count = 12,
--           animation_speed = 0.5,
--           shift = {0.015625, 0.890625},
--           hr_version =
--           {
--             filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-heater.png",
--             priority = "high",
--             width = 60,
--             height = 56,
--             frame_count = 12,
--             animation_speed = 0.5,
--             shift = util.by_pixel(1.75, 32.75),
--             scale = 0.5
--           }
--         },
--         light = {intensity = 0.4, size = 6, shift = {0.0, 1.0}, color = {r = 1.0, g = 1.0, b = 1.0}}
--       },
--       {
--         animation =
--         {
--           filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-1.png",
--           priority = "high",
--           width = 19,
--           height = 13,
--           frame_count = 4,
--           animation_speed = 0.5,
--           shift = {-0.671875, -0.640625},
--           hr_version =
--           {
--             filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-propeller-1.png",
--             priority = "high",
--             width = 37,
--             height = 25,
--             frame_count = 4,
--             animation_speed = 0.5,
--             shift = util.by_pixel(-20.5, -18.5),
--             scale = 0.5
--           }
--         }
--       },
--       {
--         animation =
--         {
--           filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png",
--           priority = "high",
--           width = 12,
--           height = 9,
--           frame_count = 4,
--           animation_speed = 0.5,
--           shift = {0.0625, -1.234375},
--           hr_version =
--           {
--             filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-propeller-2.png",
--             priority = "high",
--             width = 23,
--             height = 15,
--             frame_count = 4,
--             animation_speed = 0.5,
--             shift = util.by_pixel(3.5, -38),
--             scale = 0.5
--           }
--         }
--       }
--     }