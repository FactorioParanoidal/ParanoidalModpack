-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.power.nuclear) then return end

-- Set input parameters
local inputs = {
    type = "reactor",
    icon_name = "nuclear-reactor",
    base_entity_name = "nuclear-reactor",
    mod = "bobs",
    group = "power"
}

local tier_map = {
    ["nuclear-reactor"] = {1, 3},
    ["nuclear-reactor-2"] = {2, 4},
    ["nuclear-reactor-3"] = {3, 5},
}

-- Nuclear fuel tints
local nuclear_tint_index = {
    ["uranium"] = util.color("3acc0b"),
    ["thorium"] = util.color("cca500"),
    ["deuterium-blue"] = util.color("008ed0"),
    ["deuterium-pink"] = util.color("d00049"),
}

local function skin_reactor_entity(name, inputs)
    -- Inputs required by this funciton:
    -- tint        - rgb table to tint the reactor, e.g. {0.5, 0.5, 0.5}
    -- pipe_tier   - Heatpipe to use, accepted values: 1 (base), 2 (silver), 3 (gold)

    -- Reskin reactor entities
    local entity = data.raw["reactor"][name]

    entity.picture =
    {
        layers =
        {
            -- Base
            {
                filename = "__base__/graphics/entity/nuclear-reactor/reactor.png",
                width = 154,
                height = 158,
                shift = util.by_pixel(-6, -6),
                hr_version =
                {
                    filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor.png",
                    width = 302,
                    height = 318,
                    scale = 0.5,
                    shift = util.by_pixel(-5, -7),
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/reactor-mask.png",
                width = 154,
                height = 158,
                shift = util.by_pixel(-6, -6),
                tint = inputs.tint,
                hr_version =
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/hr-reactor-mask.png",
                    width = 302,
                    height = 318,
                    scale = 0.5,
                    shift = util.by_pixel(-5, -7),
                    tint = inputs.tint
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/reactor-highlights.png",
                width = 154,
                height = 158,
                shift = util.by_pixel(-6, -6),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version =
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/hr-reactor-highlights.png",
                    width = 302,
                    height = 318,
                    scale = 0.5,
                    shift = util.by_pixel(-5, -7),
                    blend_mode = reskins.lib.blend_mode, -- "additive"
                }
            },
            -- Pipes
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/reactor-piping-"..inputs.pipe_tier..".png",
                width = 154,
                height = 158,
                shift = util.by_pixel(-6, -6),
                hr_version =
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/hr-reactor-piping-"..inputs.pipe_tier..".png",
                    width = 302,
                    height = 318,
                    scale = 0.5,
                    shift = util.by_pixel(-5, -7),
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/nuclear-reactor/reactor-shadow.png",
                width = 263,
                height = 162,
                shift = { 1.625 , 0 },
                draw_as_shadow = true,
                hr_version =
                {
                    filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-shadow.png",
                    width = 525,
                    height = 323,
                    scale = 0.5,
                    shift = { 1.625, 0 },
                    draw_as_shadow = true
                }
            }
        }
    }

    -- Pipes
    entity.lower_layer_picture =
    {
        filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/reactor-base-pipes-"..inputs.pipe_tier..".png",
        width = 156,
        height = 156,
        shift = util.by_pixel(-2, -4),
        hr_version =
        {
            filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/hr-reactor-base-pipes-"..inputs.pipe_tier..".png",
            width = 320,
            height = 316,
            scale = 0.5,
            shift = util.by_pixel(-1, -5),
        }
    }

    entity.connection_patches_connected =
    {
        sheet =
        {
            filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/reactor-connect-patches-"..inputs.pipe_tier..".png",
            width = 32,
            height = 32,
            variation_count = 12,
            hr_version =
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/hr-reactor-connect-patches-"..inputs.pipe_tier..".png",
                width = 64,
                height = 64,
                variation_count = 12,
                scale = 0.5
            }
        }
    }

    entity.connection_patches_disconnected =
    {
        sheet =
        {
            filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/reactor-connect-patches-"..inputs.pipe_tier..".png",
            width = 32,
            height = 32,
            variation_count = 12,
            y = 32,
            hr_version =
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/pipes/hr-reactor-connect-patches-"..inputs.pipe_tier..".png",
                width = 64,
                height = 64,
                variation_count = 12,
                y = 64,
                scale = 0.5
            }
        }
    }
end

local function skin_reactor_remnants(name, inputs)
    -- Inputs required by this funciton:
    -- tint        - rgb table to tint the reactor, e.g. {0.5, 0.5, 0.5}
    -- pipe_tier   - Heatpipe to use, accepted values: 1 (base), 2 (silver), 3 (gold)

    -- Reskin reactor remnants
    local remnant = data.raw["corpse"][name.."-remnants"]

    remnant.animation =
    {
        layers =
        {
            -- Base
            {
                filename = "__base__/graphics/entity/nuclear-reactor/remnants/nuclear-reactor-remnants.png",
                line_length = 1,
                width = 206,
                height = 198,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 4),
                hr_version =
                {
                    filename = "__base__/graphics/entity/nuclear-reactor/remnants/hr-nuclear-reactor-remnants.png",
                    line_length = 1,
                    width = 410,
                    height = 396,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                    filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/remnants/nuclear-reactor-remnants-mask.png",
                    line_length = 1,
                    width = 206,
                    height = 198,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    tint = inputs.tint,
                    hr_version =
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/remnants/hr-nuclear-reactor-remnants-mask.png",
                        line_length = 1,
                        width = 410,
                        height = 396,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 1,
                        shift = util.by_pixel(7, 4),
                        tint = inputs.tint,
                        scale = 0.5,
                    }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/remnants/nuclear-reactor-remnants-highlights.png",
                line_length = 1,
                width = 206,
                height = 198,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 4),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version =
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/remnants/hr-nuclear-reactor-remnants-highlights.png",
                    line_length = 1,
                    width = 410,
                    height = 396,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            },
            -- Pipes
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/remnants/pipes/reactor-piping-"..inputs.pipe_tier.."-remnants.png",
                line_length = 1,
                width = 206,
                height = 198,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 4),
                hr_version =
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/nuclear-reactor/remnants/pipes/hr-reactor-piping-"..inputs.pipe_tier.."-remnants.png",
                    line_length = 1,
                    width = 410,
                    height = 396,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    scale = 0.5,
                }
            }
        }
    }
end

-- Construct default inputs
reskins.lib.parse_inputs(inputs)

-- Map fuel type to reactor entity name
reskins.bobs.nuclear_reactor_index = {
    ["nuclear-reactor"] = {name = "uranium", tint = nuclear_tint_index["uranium"]},
    ["nuclear-reactor-2"] = {name = "uranium", tint = nuclear_tint_index["uranium"]},
    ["nuclear-reactor-3"] = {name = "uranium", tint = nuclear_tint_index["uranium"]},
}

-- Nucelar reactors have two modes, revamped or standard; determine which we are using
if reskins.lib.setting("bobmods-revamp-nuclear") == true then
    -- Map fuel type to reactor entity name
    reskins.bobs.nuclear_reactor_index["nuclear-reactor-2"].name = "thorium"
    reskins.bobs.nuclear_reactor_index["nuclear-reactor-2"].tint = nuclear_tint_index["thorium"]

    if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
        reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].name = "deuterium-blue"
        reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].tint = nuclear_tint_index["deuterium-blue"]
    else
        reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].name = "deuterium-pink"
        reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].tint = nuclear_tint_index["deuterium-pink"]
    end
end

-- Permit tier-based tint lookup
if not (reskins.lib.setting("bobmods-revamp-nuclear") and reskins.lib.setting("reskins-bobs-do-bobrevamp-reactor-color")) then
    reskins.bobs.nuclear_reactor_index["nuclear-reactor"].tint = nil
    reskins.bobs.nuclear_reactor_index["nuclear-reactor-2"].tint = nil
    reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].tint = nil
end

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Initialize table address
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- We need to assaign fuel, pipe-tier, and reactor inputs
    inputs.pipe_tier = map[1]
    inputs.fuel = reskins.bobs.nuclear_reactor_index[name]

    -- Create explosions
    reskins.lib.create_explosion(name, inputs)

    if reskins.lib.setting("bobmods-revamp-nuclear") == true and reskins.lib.setting("reskins-bobs-do-bobrevamp-reactor-color") == true then
        inputs.reactor = reskins.bobs.nuclear_reactor_index[name]
        inputs.tint = reskins.bobs.nuclear_reactor_index[name].tint

        -- Create particles
        reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["big"], 1, inputs.tint)
        reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["medium"], 2, inputs.tint)
    else
        inputs.reactor = "reactor-"..tier
        inputs.tint = reskins.lib.tint_index[tier]

        -- Create particles
        reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["big"], 1, inputs.tint)
        reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["medium"], 2, inputs.tint)
    end

    -- Create remnants
    reskins.lib.create_remnant(name, inputs)

    -- Reskin remnants
    skin_reactor_remnants(name, inputs)

    -- Reskin entities
    skin_reactor_entity(name, inputs)

    -- Reskin icons
    inputs.icon_base = "nuclear-reactor-"..reskins.bobs.nuclear_reactor_index[name].name.."-"..inputs.pipe_tier
    reskins.lib.construct_icon(name, tier, inputs)

    -- Label to skip to next iteration
    ::continue::
end