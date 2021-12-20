-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["spaceblock"] then return end

-- Fix one-off entities
local fixes = {
    ["spaceblock-matter-furnace"] = {
        type = "furnace",
        icon = "__base__/graphics/icons/stone-furnace.png",
    },
    ["spaceblock-matter-refinery"] = {
        type = "assembling-machine",
        icon = "__base__/graphics/icons/chemical-plant.png",
    },
}

for name, parameters in pairs(fixes) do
    local inputs = {
        type = parameters.type,
        icon = {
            {
                icon = parameters.icon,
                icon_size = 64,
                icon_mipmaps = 4,
                tint = {r = 0.85, g = 0.5, b = 1, a = 1},
            }
        }
    }

    reskins.lib.parse_inputs(inputs)
    reskins.lib.assign_icons(name, inputs)
end

-- Setup boiler icons using masked sprites if available
local function boiler_icon(tint)
    local icons
    if reskins.bobs and reskins.bobs.triggers.power.items then
        icons = {
            {
                icon = reskins.bobs.directory.."/graphics/icons/power/boiler/boiler-icon-base.png",
                icon_size = 64,
                icon_mipmaps = 4,
            },
            {
                icon = reskins.bobs.directory.."/graphics/icons/power/boiler/boiler-icon-mask.png",
                icon_size = 64,
                icon_mipmaps = 4,
                tint = tint,
            },
            {
                icon = reskins.bobs.directory.."/graphics/icons/power/boiler/boiler-icon-highlights.png",
                icon_size = 64,
                icon_mipmaps = 4,
                tint = {1, 1, 1, 0},
            },
        }
    else
        icons = {
            {
                icon = "__base__/graphics/icons/boiler.png",
                icon_size = 64,
                icon_mipmaps = 4,
                tint = tint,
            }
        }
    end

    return icons
end

-- Ensure a tint is formatted as expected by reskins.lib functions
local function format_tint(color)
	local tint = {
		r = color.r or color[1],
		g = color.g or color[2],
		b = color.b or color[3],
		a = color.a or color[4] or 1,
	}

	return tint
end

-- Returns a properly formatted icon definition
local function collect_icons(prototype)
    local icons = prototype.icons or {
        {
            icon = prototype.icon,
            icon_size = prototype.icon_size,
            icon_mipmaps = prototype.icon_mipmaps or 0,
        }
    }

    -- Ensure icons is properly populated
    for _, icon_data in pairs(icons) do
        if not icon_data.icon_size then
            icon_data.icon_size = prototype.icon_size
        end

        if not icon_data.icon_mipmaps then
            icon_data.icon_mipmaps = prototype.icon_mipmaps or 0
        end
    end

    return icons
end

-- Returns the name and type of all the minable results of a given prototype
local function get_minable_results(prototype)
    local results = {}

    -- Retrieve the results
    if prototype.minable.results then
        for _, result in pairs(prototype.minable.results) do
            table.insert(results, {
                name = result.name or result,
                type = result.type or "item",
            })
        end
    elseif prototype.minable.result then
        table.insert(results, {
            name = prototype.minable.result,
            type = "item",
        })
    end

    return results
end

local boilers = {}

-- Setup icons for spaceblock matter entities and recipes
for name, resource in pairs(data.raw.resource) do
    local results = get_minable_results(resource)

    for _, result in pairs(results) do
        if result.type == "fluid" then
            local fluid = data.raw.fluid[result.name]

            if fluid then
                -- Boiler
                local item = data.raw.item["spaceblock-dupe-boiler-"..name]
                local boiler = data.raw.boiler["spaceblock-dupe-boiler-"..name]
                local recipe = data.raw.recipe["spaceblock-dupe-boiler-"..name]

                local icon_tint = reskins.bobs and reskins.bobs.triggers.power.items and format_tint(fluid.base_color) or format_tint(fluid.flow_color)
                local entity_tint = reskins.bobs and reskins.bobs.triggers.power.entities and format_tint(fluid.base_color) or format_tint(fluid.flow_color)

                local boiler_icons = boiler_icon(icon_tint)
                reskins.lib.composite_existing_icons_onto_icons_definition(fluid.name, boiler_icons, {type = "fluid", shift = {-8, 8}, scale = 0.5})

                if recipe then recipe.icons = boiler_icons end
                if boiler then
                    boiler.icons = boiler_icons
                    boilers["spaceblock-dupe-boiler-"..name] = {tint = entity_tint}
                end
                if item then item.icons = boiler_icons end

                -- Chemical Plant
                local recipe = data.raw.recipe["spaceblock-dupe-boil-"..name]

                local boil_icon = collect_icons(fluid)
                reskins.lib.composite_existing_icons_onto_icons_definition("spaceblock-matter-refinery", boil_icon, {type = "assembling-machine", shift = {-8, 8}, scale = 0.5})

                if recipe then recipe.icons = boil_icon end
            end
        else
            local item = data.raw.item[result.name]

            if item then
                -- Stone Furnace
                local recipe = data.raw.recipe["spaceblock-dupe-smelt-"..result.name]

                local smelter_icons = collect_icons(item)
                reskins.lib.composite_existing_icons_onto_icons_definition("spaceblock-matter-furnace", smelter_icons, {type = "furnace", shift = {-8, 8}, scale = 0.5})

                if recipe then recipe.icons = smelter_icons end
            end
        end
    end
end

if reskins.bobs and reskins.bobs.triggers.power.entities then
    -- Set input parameters
    local inputs = {
        type = "boiler",
        base_entity = "boiler",
        mod = "bobs",
        group = "power",
        particles = {["big"] = 3},
        make_icons = false,
    }

    for name, map in pairs(boilers) do
        -- Fetch entity
        local entity = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not entity then goto continue end

        inputs.tint = map.tint

        reskins.lib.setup_standard_entity(name, 0, inputs)

        -- Fetch remnant
        local remnant = data.raw["corpse"][name.."-remnants"]

        -- Reskin remnants
        remnant.animation = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/boiler/remnants/boiler-remnants.png",
                    line_length = 1,
                    width = 138,
                    height = 110,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0, -3),
                    hr_version = {
                        filename = "__base__/graphics/entity/boiler/remnants/hr-boiler-remnants.png",
                        line_length = 1,
                        width = 274,
                        height = 220,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(-0.5, -3),
                        scale = 0.5,
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/boiler-remnants-mask.png",
                    line_length = 1,
                    width = 138,
                    height = 110,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0, -3),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/hr-boiler-remnants-mask.png",
                        line_length = 1,
                        width = 274,
                        height = 220,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(-0.5, -3),
                        tint = inputs.tint,
                        scale = 0.5,
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/boiler-remnants-highlights.png",
                    line_length = 1,
                    width = 138,
                    height = 110,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0, -3),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/hr-boiler-remnants-highlights.png",
                        line_length = 1,
                        width = 274,
                        height = 220,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(-0.5, -3),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    }
                }
            }
        }

        -- Reskin entities
        entity.structure = {
            north = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-N-idle.png",
                        priority = "extra-high",
                        width = 131,
                        height = 108,
                        shift = util.by_pixel(-0.5, 4),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-N-idle.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(-1.25, 5.25),
                            scale = 0.5
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-N-idle-mask.png",
                        priority = "extra-high",
                        width = 131,
                        height = 108,
                        shift = util.by_pixel(-0.5, 4),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-N-idle-mask.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(-1.25, 5.25),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-N-idle-highlights.png",
                        priority = "extra-high",
                        width = 131,
                        height = 108,
                        shift = util.by_pixel(-0.5, 4),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-N-idle-highlights.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(-1.25, 5.25),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
                        priority = "extra-high",
                        width = 137,
                        height = 82,
                        shift = util.by_pixel(20.5, 9),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-N-shadow.png",
                            priority = "extra-high",
                            width = 274,
                            height = 164,
                            scale = 0.5,
                            shift = util.by_pixel(20.5, 9),
                            draw_as_shadow = true
                        }
                    }
                }
            },
            east = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-E-idle.png",
                        priority = "extra-high",
                        width = 105,
                        height = 147,
                        shift = util.by_pixel(-3.5, -0.5),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-E-idle.png",
                            priority = "extra-high",
                            width = 216,
                            height = 301,
                            shift = util.by_pixel(-3, 1.25),
                            scale = 0.5
                        }
                    },
                    -- Color mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-E-idle-mask.png",
                        priority = "extra-high",
                        width = 105,
                        height = 147,
                        shift = util.by_pixel(-3.5, -0.5),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-E-idle-mask.png",
                            priority = "extra-high",
                            width = 216,
                            height = 301,
                            shift = util.by_pixel(-3, 1.25),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-E-idle-highlights.png",
                        priority = "extra-high",
                        width = 105,
                        height = 147,
                        shift = util.by_pixel(-3.5, -0.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-E-idle-highlights.png",
                            priority = "extra-high",
                            width = 216,
                            height = 301,
                            shift = util.by_pixel(-3, 1.25),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
                        priority = "extra-high",
                        width = 92,
                        height = 97,
                        shift = util.by_pixel(30, 9.5),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-E-shadow.png",
                            priority = "extra-high",
                            width = 184,
                            height = 194,
                            scale = 0.5,
                            shift = util.by_pixel(30, 9.5),
                            draw_as_shadow = true
                        }
                    }
                }
            },
            south = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-S-idle.png",
                        priority = "extra-high",
                        width = 128,
                        height = 95,
                        shift = util.by_pixel(3, 12.5),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-S-idle.png",
                            priority = "extra-high",
                            width = 260,
                            height = 192,
                            shift = util.by_pixel(4, 13),
                            scale = 0.5
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-S-idle-mask.png",
                        priority = "extra-high",
                        width = 128,
                        height = 95,
                        shift = util.by_pixel(3, 12.5),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-S-idle-mask.png",
                            priority = "extra-high",
                            width = 260,
                            height = 192,
                            shift = util.by_pixel(4, 13),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-S-idle-highlights.png",
                        priority = "extra-high",
                        width = 128,
                        height = 95,
                        shift = util.by_pixel(3, 12.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-S-idle-highlights.png",
                            priority = "extra-high",
                            width = 260,
                            height = 192,
                            shift = util.by_pixel(4, 13),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
                        priority = "extra-high",
                        width = 156,
                        height = 66,
                        shift = util.by_pixel(30, 16),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-S-shadow.png",
                            priority = "extra-high",
                            width = 311,
                            height = 131,
                            scale = 0.5,
                            shift = util.by_pixel(29.75, 15.75),
                            draw_as_shadow = true
                        }
                    }
                }
            },
            west = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-W-idle.png",
                        priority = "extra-high",
                        width = 96,
                        height = 132,
                        shift = util.by_pixel(1, 5),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-W-idle.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(1.5, 7.75),
                            scale = 0.5
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-W-idle-mask.png",
                        priority = "extra-high",
                        width = 96,
                        height = 132,
                        shift = util.by_pixel(1, 5),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-W-idle-mask.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(1.5, 7.75),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-W-idle-highlights.png",
                        priority = "extra-high",
                        width = 96,
                        height = 132,
                        shift = util.by_pixel(1, 5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-W-idle-highlights.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(1.5, 7.75),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
                        priority = "extra-high",
                        width = 103,
                        height = 109,
                        shift = util.by_pixel(19.5, 6.5),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-W-shadow.png",
                            priority = "extra-high",
                            width = 206,
                            height = 218,
                            scale = 0.5,
                            shift = util.by_pixel(19.5, 6.5),
                            draw_as_shadow = true
                        }
                    }
                }
            }
        }

        entity.fluid_box.pipe_covers = pipecoverspictures()
        entity.output_fluid_box.pipe_covers = pipecoverspictures()

        -- Handle ambient-light
        entity.energy_source.light_flicker = {
            color = {0, 0, 0},
            minimum_light_size = 0,
            light_intensity_to_size_coefficient = 0,
        }

        -- Label to skip to next iteration
        ::continue::
    end
end