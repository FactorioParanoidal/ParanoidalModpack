-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if reskins.lib.setting("bobmods-power-heatsources") == false then return end

-- Set input parameters
local inputs = {
    type = "reactor",
    base_entity = "nuclear-reactor",
    mod = "bobs",
    group = "power",
    particles = {["big"] = 1, ["medium"] = 2},
    make_remnants = false,
}

local tier_map = {
    ["burner-reactor"] = {tier = 1, prog_tier = 3, icon_name = "heat-source-burner"},
    ["burner-reactor-2"] = {tier = 2, prog_tier = 4, icon_name = "heat-source-burner"},
    ["burner-reactor-3"] = {tier = 3, prog_tier = 5, icon_name = "heat-source-burner"},
    ["fluid-reactor"] = {tier = 1, prog_tier = 3, icon_name = "heat-source-fluid"},
    ["fluid-reactor-2"] = {tier = 2, prog_tier = 4, icon_name = "heat-source-fluid"},
    ["fluid-reactor-3"] = {tier = 3, prog_tier = 5, icon_name = "heat-source-fluid"},
}

local function heat_source_base_pipes(tier)
    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/heat-source-base-pipes-"..tier..".png",
        width = 96,
        height = 96,
        shift = { -0.03125, -0.1875 },
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/hr-heat-source-base-pipes-"..tier..".png",
            width = 192,
            height = 192,
            scale = 0.5,
            shift = { -0.03125, -0.1875 }
        }
    }
end

local function connect_patches_connected(tier)
    return
    {
        sheet = {
            filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/reactor-connect-patches-"..tier..".png",
            width = 32,
            height = 32,
            variation_count = 12,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/hr-reactor-connect-patches-"..tier..".png",
                width = 64,
                height = 64,
                variation_count = 12,
                scale = 0.5
            }
        }
    }
end

local function connect_patches_disconnected(tier)
    return
    {
        sheet = {
            filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/reactor-connect-patches-"..tier..".png",
            width = 32,
            height = 32,
            y = 32,
            variation_count = 12,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/hr-reactor-connect-patches-"..tier..".png",
                width = 64,
                height = 64,
                y = 64,
                variation_count = 12,
                scale = 0.5
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Setup icon details
    inputs.icon_name = map.icon_name

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.picture = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/heat-source-base.png",
                priority = "high",
                width = 84,
                height = 66,
                scale = 1.5,
                shift = {0.4375 *1.5, 0.03125 *1.5}
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/heat-source-mask.png",
                priority = "high",
                width = 84,
                height = 66,
                scale = 1.5,
                tint = inputs.tint,
                shift = {0.4375 *1.5, 0.03125 *1.5}
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/heat-source-highlights.png",
                priority = "high",
                width = 84,
                height = 66,
                scale = 1.5,
                blend_mode = reskins.lib.blend_mode,
                shift = {0.4375 *1.5, 0.03125 *1.5}
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-source/heat-source-shadow.png",
                priority = "high",
                width = 84,
                height = 66,
                scale = 1.5,
                draw_as_shadow = true,
                shift = {0.4375 *1.5, 0.03125 *1.5}
            }
        }
    }

    entity.working_light_picture = {
        filename = "__bobpower__/graphics/burner-reactor/reactor-fire.png",
        priority = "high",
        width = 36,
        height = 19,
        frame_count = 12,
        scale = 1.5,
        draw_as_glow = true,
        shift = {-0.03125 *1.5, 0.671875 *1.5},
    }

    -- Eliminate light
    entity.use_fuel_glow_color = false
    entity.light = {intensity = 0, size = 0, shift = {0.0, 0.0}, color = {r = 0, g = 0, b = 0, a = 0}}
    entity.energy_source.light_flicker = {
        color = {0, 0, 0},
        minimum_light_size = 0,
        light_intensity_to_size_coefficient = 0,
    }

    -- Heat pipes
    entity.lower_layer_picture = heat_source_base_pipes(map.tier)
    entity.connection_patches_connected = connect_patches_connected(map.tier)
    entity.connection_patches_disconnected = connect_patches_disconnected(map.tier)

    -- Overlay tinted pipe pictures
    if entity.energy_source.fluid_box then
        entity.energy_source = util.merge{entity.energy_source, {
            fluid_box = {pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint)}
        }}
    end

    -- Label to skip to next iteration
    ::continue::
end