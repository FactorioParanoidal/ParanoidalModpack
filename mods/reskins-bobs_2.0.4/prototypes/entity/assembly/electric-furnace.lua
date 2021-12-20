-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and (reskins.bobs.triggers.assembly.entities or reskins.bobs.triggers.plates.entities)) then return end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then reskins.compatibility.triggers.minimachines.furnaces = true end

local electric_furnace_map = {
    -- Standard furnaces
    ["electric-furnace"] = {icon_name = "electric-furnace", furnace = "standard", tier = 3, type = "furnace", tint = reskins.bobs.furnace_tint_index.standard},
    ["electric-furnace-2"] = {icon_name = "electric-furnace", furnace = "standard", tier = 4, type = "furnace"},
    ["electric-furnace-3"] = {icon_name = "electric-furnace", furnace = "standard", tier = 5, type = "furnace"},

    -- Mixing furnace
    ["electric-mixing-furnace"] = {furnace = "mixing", tier = 3, type = "assembling-machine", tint = reskins.bobs.furnace_tint_index.mixing},

    -- Chemical furnace
    ["electric-chemical-furnace"] = {furnace = "chemical", tier = 3, type = "assembling-machine", tint = reskins.bobs.furnace_tint_index.chemical, has_fluids = true},

    -- Chemical mixing furnaces
    ["electric-chemical-mixing-furnace"] = {icon_name = "electric-chemical-mixing-furnace", furnace = "chemical-mixing", tier = 4, type = "assembling-machine", has_fluids = true},
    ["electric-chemical-mixing-furnace-2"] = {icon_name = "electric-chemical-mixing-furnace", furnace = "chemical-mixing", tier = 5, type = "assembling-machine", has_fluids = true},
}

-- Angel's Compatibility
if mods["angelssmelting"] then
    -- Use metal-mixing sprites to be consistent with new "Filtering Furnace" progression
    electric_furnace_map["electric-chemical-mixing-furnace"].furnace = "mixing"
    electric_furnace_map["electric-chemical-mixing-furnace"].icon_name = "electric-mixing-furnace"
    electric_furnace_map["electric-chemical-mixing-furnace-2"].furnace = "mixing"
    electric_furnace_map["electric-chemical-mixing-furnace-2"].icon_name = "electric-mixing-furnace"
end

local function furnace_heater_animation()
    return
        {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/animations/electric-furnace-heater.png",
        priority = "high",
        width = 30,
        height = 28,
        frame_count = 12,
        animation_speed = 0.5,
        shift = util.by_pixel(2, 33),
        draw_as_glow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/animations/hr-electric-furnace-heater.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(2, 33),
            draw_as_glow = true,
            scale = 0.5
        }
    }
end

local function furnace_heater(has_fluids)
    if has_fluids then
        return
        {
            fadeout = true,
            north_animation = furnace_heater_animation(),
            east_animation = furnace_heater_animation(),
            west_animation = furnace_heater_animation(),
        }
    else
        return
        {
            fadeout = true,
            animation = furnace_heater_animation(),
        }
    end
end

local function furnace_working_light(type, has_partial)
    local working_type = "electric-furnace-light"
    if type then
        if has_partial then
            working_type = "electric-"..type.."-furnace-light-obstructed"
        else
            working_type = "electric-"..type.."-furnace-light"
        end
    end

    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/lights/"..working_type..".png",
        priority = "high",
        width = 119,
        height = 106,
        shift = util.by_pixel(1, 1),
        blend_mode = "additive",
        draw_as_glow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/lights/hr-"..working_type..".png",
            priority = "high",
            width = 238,
            height = 212,
            shift = util.by_pixel(1, 1),
            blend_mode = "additive",
            draw_as_glow = true,
            scale = 0.5
        }
    }
end

local function furnace_ground_light()
    return
    {
        filename = "__base__/graphics/entity/electric-furnace/electric-furnace-ground-light.png",
        blend_mode = "additive",
        width = 82,
        height = 64,
        shift = util.by_pixel(4, 68),
        draw_as_light = true,
        hr_version = {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-ground-light.png",
            blend_mode = "additive",
            width = 166,
            height = 124,
            shift = util.by_pixel(3, 69),
            draw_as_light = true,
            scale = 0.5,
        }
    }
end

local function furnace_large_propeller()
    return
    {
        animation = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/animations/propeller-large.png",
            priority = "high",
            width = 19,
            height = 13,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(-20, -18),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/animations/hr-propeller-large.png",
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
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/animations/propeller-small.png",
            priority = "high",
            width = 12,
            height = 8,
            frame_count = 4,
            animation_speed = 0.5,
            shift = shift,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/animations/hr-propeller-small.png",
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
        tint = map.tint or reskins.lib.tint_index[tier],
        icon_name = map.icon_name or name,
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
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/electric-furnace-remnants-mask.png",
                line_length = 1,
                width = 108,
                height = 104,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3, 7),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-electric-furnace-remnants-mask.png",
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
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/electric-furnace-remnants-highlights.png",
                line_length = 1,
                width = 108,
                height = 104,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(-3, 7),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-electric-furnace-remnants-highlights.png",
                    line_length = 1,
                    width = 214,
                    height = 208,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-3.25, 7.25),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    }

    -- Reskin entities
    entity.animation = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/"..inputs.icon_name.."-base.png",
                priority = "high",
                width = 119,
                height = 106,
                shift = util.by_pixel(1, 1),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-"..inputs.icon_name.."-base.png",
                    priority = "high",
                    width = 238,
                    height = 212,
                    shift = util.by_pixel(1, 1),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/"..inputs.icon_name.."-mask.png",
                priority = "high",
                width = 119,
                height = 106,
                shift = util.by_pixel(1, 1),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-"..inputs.icon_name.."-mask.png",
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
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/"..inputs.icon_name.."-highlights.png",
                priority = "high",
                width = 119,
                height = 106,
                shift = util.by_pixel(1, 1),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/hr-"..inputs.icon_name.."-highlights.png",
                    priority = "high",
                    width = 238,
                    height = 212,
                    shift = util.by_pixel(1, 1),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
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
        }
    }

    if map.furnace == "chemical" then
        entity.working_visualisations = {
            -- Furnace Heater
            furnace_heater(true),

            -- Furnace Light
            {
                fadeout = true,
                north_animation = furnace_working_light("chemical"),
                east_animation = furnace_working_light("chemical"),
                west_animation = furnace_working_light("chemical"),
            },

            -- Furnace Ground Light
            {
                fadeout = true,
                north_animation = furnace_ground_light(),
                east_animation = furnace_ground_light(),
                west_animation = furnace_ground_light(),
            },
        }

        -- Add chemical furnace remnants details
        table.insert(remnant.animation.layers, {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/chemical-furnace-remnants-overlay.png",
            line_length = 1,
            width = 108,
            height = 104,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-3, 7),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-chemical-furnace-remnants-overlay.png",
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
        entity.working_visualisations = {
            -- Furnace Heater
            furnace_heater(),

            -- Furnace Light
            {
                fadeout = true,
                animation = furnace_working_light("mixing"),
            },

            -- Furnace Ground Light
            {
                fadeout = true,
                animation = furnace_ground_light(),
            },

            -- Propellers
            furnace_large_propeller(),
            furnace_small_propeller(true),
        }
    elseif map.furnace == "chemical-mixing" then
        entity.working_visualisations = {
            -- Furnace Heater
            furnace_heater(true),

            -- Furnace Light
            {
                fadeout = true,
                north_animation = furnace_working_light("chemical-mixing"),
                east_animation = furnace_working_light("chemical-mixing"),
                south_animation = furnace_working_light("chemical-mixing", true),
                west_animation = furnace_working_light("chemical-mixing"),
            },

            -- Furnace Ground Light
            {
                fadeout = true,
                north_animation = furnace_ground_light(),
                east_animation = furnace_ground_light(),
                west_animation = furnace_ground_light(),
            },

            -- Propeller
            furnace_small_propeller(true),
        }

        -- Add chemical-mixing furnace remnants details
        table.insert(remnant.animation.layers, {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/chemical-mixing-furnace-remnants-overlay.png",
            line_length = 1,
            width = 108,
            height = 104,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(-3, 7),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/remnants/hr-chemical-mixing-furnace-remnants-overlay.png",
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
        entity.working_visualisations = {
            -- Furnace Heater
            furnace_heater(),

            -- Furnace Light
            {
                fadeout = true,
                animation = furnace_working_light(),
            },

            -- Furnace Ground Light
            {
                fadeout = true,
                animation = furnace_ground_light(),
            },

            -- Propellers
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