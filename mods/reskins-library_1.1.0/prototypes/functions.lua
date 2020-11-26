-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Make our function host
if not reskins then reskins = {} end
if not reskins.lib then reskins.lib = {} end

-- Library directory
reskins.lib.directory = "__reskins-library__"

-- Check if a startup setting exists, and if it does, return its value
function reskins.lib.setting(name)
    local startup_setting
    if settings.startup[name] then
        startup_setting = settings.startup[name].value
    else
        startup_setting = nil
    end

    return startup_setting
end

-- Fetch blend mode
reskins.lib.blend_mode = reskins.lib.setting("reskins-lib-blend-mode")

-- Most entities have a common process for reskinning, so consolidate the other functions under one superfunction for ease of use
function reskins.lib.setup_standard_entity(name, tier, inputs)
    -- Parse inputs
    reskins.lib.parse_inputs(inputs)

    -- Create particles and explosions
    if inputs.make_explosions then
        reskins.lib.create_explosions_and_particles(name, inputs)
    end

    -- Create remnants
    if inputs.make_remnants then
        reskins.lib.create_remnant(name, inputs)
    end

    -- Create icons
    if inputs.make_icons then
        reskins.lib.construct_icon(name, tier, inputs)
    end
end

-- Parses the main inputs table of parameters
function reskins.lib.parse_inputs(inputs)
    -- Check that we have a particles table
    if not inputs.particles then
        inputs.make_explosions = false
    end

    -- Constructs defaults for optional input parameters.
    inputs.icon_size = inputs.icon_size or 64 -- Pixel size of icons
    inputs.icon_mipmaps = inputs.icon_mipmaps or 4 -- Number of mipmaps present in the icon image file
    inputs.technology_icon_size = inputs.technology_icon_size or 128 -- Pixel size of technology icons
    inputs.technology_icon_mipmaps = inputs.technology_icon_mipmaps or 1 -- Number of mipmaps present in the technology icon image file
    inputs.make_explosions = (inputs.make_explosions ~= false) -- Create explosions; default true
    inputs.make_remnants = (inputs.make_remnants ~= false) -- Create remnant; default true
    inputs.make_icons = (inputs.make_icons ~= false) -- Create icons; default true
    inputs.tier_labels = (inputs.tier_labels ~= false) -- Display tier labels; default true
    inputs.make_icon_pictures = (inputs.make_icon_pictures ~= false) -- Define the pictures icon field when possible

    return inputs
end

function reskins.lib.assign_order(name, inputs)
    -- Inputs required by this function
    -- type
    -- sort_order
    -- sort_group
    -- sort_subgroup

    -- Initialize paths
    local entity
    if inputs.type then
        entity = data.raw[inputs.type][name]
    end
    local item = data.raw["item"][name]
    local explosion = data.raw["explosion"][name.."-explosion"]
    local remnant = data.raw["corpse"][name.."-remnants"]

    if entity then
        entity.order = inputs.sort_order
        entity.group = inputs.sort_group
        entity.subgroup = inputs.sort_subgroup
    end

    if item then
        item.order = inputs.sort_order
        item.group = inputs.sort_group
        item.subgroup = inputs.sort_subgroup
    end

    if explosion then
        explosion.order = inputs.sort_order
        explosion.group = inputs.sort_group
        explosion.subgroup = inputs.sort_subgroup
    end

    if remnant then
        remnant.order = inputs.sort_order
        remnant.group = inputs.sort_group
        remnant.subgroup = inputs.sort_subgroup
    end
end

-- Create remnant entity; reskin the remnant after calling this function
function reskins.lib.create_remnant(name, inputs)
    -- Inputs required by this function:
    -- base_entity - Entity to copy remnant prototype from
    -- type        - Entity type

    -- Copy remnant prototype
    local remnant = util.copy(data.raw["corpse"][inputs.base_entity.."-remnants"])
    remnant.name = name.."-remnants"
    data:extend({remnant})

    -- Assign corpse to originating entity
    data.raw[inputs.type][name]["corpse"] = remnant.name
end

-- Create explosion entity; create particles after calling this function
function reskins.lib.create_explosion(name, inputs)
    -- Inputs required by this function:
    -- base_entity - Entity to copy explosion prototype from
    -- type        - Entity type

    local explosion = util.copy(data.raw["explosion"][inputs.base_entity.."-explosion"])
    explosion.name = name.."-explosion"
    data:extend({explosion})

    -- Assign explosion to originating entity
    data.raw[inputs.type][name]["dying_explosion"] = explosion.name
end

-- Create tinted particle
function reskins.lib.create_particle(name, base_entity, base_particle, key, tint)
    -- Copy the particle prototype
    local particle = util.copy(data.raw["optimized-particle"][base_entity.."-"..base_particle])
    particle.name = name.."-"..base_particle.."-tinted"
    particle.pictures.sheet.tint = tint
    particle.pictures.sheet.hr_version.tint = tint
    data:extend({particle})

    -- Assign particle to originating explosion
    data.raw["explosion"][name.."-explosion"]["created_effect"]["action_delivery"]["target_effects"][key].particle_name = particle.name
end

-- Batch the explosion and particle function together for ease of use
function reskins.lib.create_explosions_and_particles(name, inputs)
    -- Inputs required by this function:
    -- base_entity - Entity to copy explosion prototype from
    -- type        - Entity type
    -- tint        - Particle color

    -- Create explosions and related particles
    reskins.lib.create_explosion(name, inputs)

    -- Create and assign needed particles with appropriate tints
    for particle, key in pairs(inputs.particles) do
        -- Create and assign the particle
        reskins.lib.create_particle(name, inputs.base_entity, reskins.lib.particle_index[particle], key, inputs.tint)
    end
end

-- Adjust the alpha value of a given tint
function reskins.lib.adjust_alpha(tint, alpha)
    local adjusted_tint = {r = tint.r, g = tint.g, b = tint.b, a = alpha}
    return adjusted_tint
end

-- Shift the rgb values of a given tint by shift amount, and optionally adjust the alpha value
function reskins.lib.adjust_tint(tint, shift, alpha)
    local adjusted_tint = {}

    -- Adjust the tint
    adjusted_tint.r = tint.r + shift
    adjusted_tint.g = tint.g + shift
    adjusted_tint.b = tint.b + shift
    adjusted_tint.a = alpha or tint.a

    -- Check boundary conditions
    if adjusted_tint.r > 1 then
        adjusted_tint.r = 1
    elseif adjusted_tint.r < 0 then
        adjusted_tint.r = 0
    end

    if adjusted_tint.g > 1 then
        adjusted_tint.g = 1
    elseif adjusted_tint.g < 0 then
        adjusted_tint.g = 0
    end

    if adjusted_tint.b > 1 then
        adjusted_tint.b = 1
    elseif adjusted_tint.b < 0 then
        adjusted_tint.b = 0
    end

    return adjusted_tint
end

-- This function prepares a given tint for entities that use a base and mask layer instead of a base, mask, and highlights layer
-- Primarily this means belt-related entities
function reskins.lib.belt_mask_tint(tint)
    -- Define correction constants
    local color_shift = 40/255
    local alpha = 0.82

    -- Color correct the tint
    local belt_mask_tint = reskins.lib.adjust_tint(tint, color_shift, alpha)

    return belt_mask_tint
end

reskins.lib.tint_defaults = {
    bobs = {
        ["tier-0"] = util.color("4d4d4d"),
        ["tier-1"] = util.color("de9400"),
        ["tier-2"] = util.color("c20600"),
        ["tier-3"] = util.color("1b87c2"),
        ["tier-4"] = util.color("a600bf"),
        ["tier-5"] = util.color("23de55"),
        ["tier-6"] = util.color("ff7700"),
    },
    angels = {
        ["tier-0"] = util.color("262626"),
        ["tier-1"] = util.color("595959"),
        ["tier-2"] = util.color("2957cc"),
        ["tier-3"] = util.color("cc2929"),
        ["tier-4"] = util.color("ccae29"),
        ["tier-5"] = util.color("23de55"),
        ["tier-6"] = util.color("ff7700"),
    }
}

if settings.startup["reskins-lib-customize-tier-colors"].value == true then
    reskins.lib.tint_index = {
        ["tier-0"] = util.color(settings.startup["reskins-lib-custom-colors-tier-0"].value),
        ["tier-1"] = util.color(settings.startup["reskins-lib-custom-colors-tier-1"].value),
        ["tier-2"] = util.color(settings.startup["reskins-lib-custom-colors-tier-2"].value),
        ["tier-3"] = util.color(settings.startup["reskins-lib-custom-colors-tier-3"].value),
        ["tier-4"] = util.color(settings.startup["reskins-lib-custom-colors-tier-4"].value),
        ["tier-5"] = util.color(settings.startup["reskins-lib-custom-colors-tier-5"].value),
        ["tier-6"] = util.color(settings.startup["reskins-lib-custom-colors-tier-6"].value),
    }
-- elseif reskins.lib.setting("reskins-angels-use-angels-tier-colors") then
--     reskins.lib.tint_index = reskins.lib.tint_defaults.angels
else
    reskins.lib.tint_index = reskins.lib.tint_defaults.bobs
end

reskins.lib.particle_index = {
    ["tiny-stone"] = "stone-particle-tiny",
    ["small"] = "metal-particle-small",
    ["small-stone"] = "stone-particle-small",
    ["medium"] = "metal-particle-medium",
    ["medium-long"] = "long-metal-particle-medium",
    ["medium-stone"] = "stone-particle-medium",
    ["big"] = "metal-particle-big",
    ["big-stone"] = "stone-particle-big",
    ["big-tint"] = "metal-particle-big-tint",

}

function reskins.lib.make_4way_animation_from_spritesheet(animation)
    local function make_animation_layer(idx, anim)
        local start_frame = (anim.frame_count or 1) * idx
        local x = 0
        local y = 0
        if anim.vertically_oriented then
            if anim.line_length then
                y = idx * anim.height * math.floor(start_frame / (anim.line_length or 1))
            else
                y = idx * anim.height
            end
        else
            if anim.line_length then
                y = anim.height * math.floor(start_frame / (anim.line_length or 1))
            else
                x = idx * anim.width
            end
        end
        return
        {
            filename = anim.filename,
            priority = anim.priority or "high",
            flags = anim.flags,
            x = x,
            y = y,
            width = anim.width,
            height = anim.height,
            frame_count = anim.frame_count or 1,
            line_length = anim.line_length,
            repeat_count = anim.repeat_count,
            run_mode = anim.run_mode,
            frame_sequence = anim.frame_sequence,
            shift = anim.shift,
            draw_as_shadow = anim.draw_as_shadow,
            draw_as_light = anim.draw_as_light,
            draw_as_glow = anim.draw_as_glow,
            force_hr_shadow = anim.force_hr_shadow,
            apply_runtime_tint = anim.apply_runtime_tint,
            animation_speed = anim.animation_speed,
            scale = anim.scale or 1,
            tint = anim.tint,
            blend_mode = anim.blend_mode
        }
    end

    local function make_animation_layer_with_hr_version(idx, anim)
        local anim_parameters = make_animation_layer(idx, anim)
        if anim.hr_version and anim.hr_version.filename then
            anim_parameters.hr_version = make_animation_layer(idx, anim.hr_version)
        end
        return anim_parameters
    end

    local function make_animation(idx)
        if animation.layers then
            local tab = { layers = {} }
            for k,v in ipairs(animation.layers) do
            table.insert(tab.layers, make_animation_layer_with_hr_version(idx, v))
            end
            return tab
        else
            return make_animation_layer_with_hr_version(idx, animation)
        end
    end

    return
    {
        north = make_animation(0),
        east = make_animation(1),
        south = make_animation(2),
        west = make_animation(3)
    }
end