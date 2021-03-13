-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then return end

-- Set input parameters
local inputs = {
    mod = "angels",
    group = "smelting",
}

local material_map = {
    ["titanium"] = {4, "995f92"},
    ["ceramic"] = {4, "ffffff"},
    ["tungsten"] = {4, "7e5f45"},
    ["nitinol"] = {5, "7664a9"},
}

-- Reskin pipes, create and assign extra details
for material, map in pairs(material_map) do
    -- This needs to be done earlier
    inputs.material = material

    -- Parse map
    local tier = map[1]
    local tint = util.color(map[2])

    -- Fetch entities
    local pipe_entity = data.raw["pipe"][material.."-pipe"]
    local underground_pipe_entity =  data.raw["pipe-to-ground"][material.."-pipe-to-ground"]

    -- Check if entity exists, if not, skip this iteration; assume if we have one we have both
    if not pipe_entity then goto continue end

    -- Create explosions
    reskins.lib.create_explosion(inputs.material.."-pipe", {type = "pipe", base_entity = "pipe"})
    reskins.lib.create_explosion(inputs.material.."-pipe-to-ground", {type = "pipe-to-ground", base_entity = "pipe-to-ground"})

    -- Create particles
    reskins.lib.create_particle(inputs.material.."-pipe", "pipe", reskins.lib.particle_index["medium"], 1, tint)
    reskins.lib.create_particle(inputs.material.."-pipe", "pipe", reskins.lib.particle_index["small"], 2, tint)
    reskins.lib.create_particle(inputs.material.."-pipe-to-ground", "pipe-to-ground", reskins.lib.particle_index["medium"], 1, tint)
    reskins.lib.create_particle(inputs.material.."-pipe-to-ground", "pipe-to-ground", reskins.lib.particle_index["small"], 2, tint)

    -- Create remnants
    reskins.lib.create_remnant(inputs.material.."-pipe", {type = "pipe", base_entity = "pipe"})
    reskins.lib.create_remnant(inputs.material.."-pipe-to-ground", {type = "pipe-to-ground", base_entity = "pipe-to-ground"})

    -- Fetch remnant
    local pipe_remnant = data.raw["corpse"][inputs.material.."-pipe-remnants"]
    local underground_pipe_remnant = data.raw["corpse"][inputs.material.."-pipe-to-ground-remnants"]

    -- Reskin remnants
    pipe_remnant.animation = make_rotated_animation_variations_from_sheet(2, {
        filename = reskins.angels.directory.."/graphics/entity/smelting/pipe/"..inputs.material.."/remnants/pipe-remnants.png",
        width = 61,
        height = 60,
        line_length = 1,
        frame_count = 1,
        direction_count = 2,
        shift = util.by_pixel(1.5, 2.5),
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/smelting/pipe/"..inputs.material.."/remnants/hr-pipe-remnants.png",
            width = 122,
            height = 120,
            line_length = 1,
            frame_count = 1,
            direction_count = 2,
            shift = util.by_pixel(1.5, 2.5),
            scale = 0.5,
        },
    })

    underground_pipe_remnant.animation = {
        filename = reskins.angels.directory.."/graphics/entity/smelting/pipe-to-ground/"..inputs.material.."/remnants/pipe-to-ground-remnants.png",
        width = 45,
        height = 40,
        line_length = 1,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(0.5, -3),
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/smelting/pipe-to-ground/"..inputs.material.."/remnants/hr-pipe-to-ground-remnants.png",
            width = 90,
            height = 80,
            line_length = 1,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(0.5, -3),
            scale = 0.5,
        },
    }

    -- Reskin entities
    pipe_entity.pictures = reskins.lib.pipe_pictures(inputs)
    underground_pipe_entity.pictures = reskins.lib.underground_pipe_pictures(inputs)

    -- Fix fluid window
    pipe_entity.horizontal_window_bounding_box = {{-0.25, -0.28125}, {0.25, 0.15625}}
    pipe_entity.vertical_window_bounding_box = {{-0.28125, -0.5}, {0.03125, 0.125}}

    -- Handle pipe covers for underground pipes
    underground_pipe_entity.fluid_box.pipe_covers = reskins.lib.pipe_covers(inputs)

    -- Setup Icons
    local pipe_icon_inputs = {
        mod = "angels",
        icon = reskins.angels.directory.."/graphics/icons/smelting/pipe/"..inputs.material.."-pipe-icon.png",
        icon_picture = {
            filename = reskins.angels.directory.."/graphics/icons/smelting/pipe/"..inputs.material.."-pipe-icon.png",
            size = 64,
            mipmaps = 4,
            scale = 0.25
        },
        icon_size = 64,
        icon_mipmaps = 4,
        type = "pipe",
        make_icon_pictures = true,
    }

    local pipe_to_ground_icon_inputs = {
        mod = "angels",
        icon = reskins.angels.directory.."/graphics/icons/smelting/pipe-to-ground/"..inputs.material.."-pipe-to-ground-icon.png",
        icon_picture = {
            filename = reskins.angels.directory.."/graphics/icons/smelting/pipe-to-ground/"..inputs.material.."-pipe-to-ground-icon.png",
            size = 64,
            mipmaps = 4,
            scale = 0.25
        },
        icon_size = 64,
        icon_mipmaps = 4,
        type = "pipe-to-ground",
        make_icon_pictures = true,
    }

    -- Setup tier labels
    if reskins.lib.setting("reskins-bobs-do-pipe-tier-labeling") == true then
        pipe_icon_inputs.icon = {{icon = pipe_icon_inputs.icon}}
        pipe_to_ground_icon_inputs.icon = {{icon = pipe_to_ground_icon_inputs.icon}}
        pipe_icon_inputs.tier_labels = true
        pipe_to_ground_icon_inputs.tier_labels = true
        reskins.lib.append_tier_labels(tier, pipe_icon_inputs)
        reskins.lib.append_tier_labels(tier, pipe_to_ground_icon_inputs)
    else
        pipe_icon_inputs.tier_labels = false
        pipe_to_ground_icon_inputs.tier_labels = false
    end

    -- Handle naming
    local pipe_icon_name, pipe_to_ground_icon_name
    pipe_icon_name = inputs.material.."-pipe"
    pipe_to_ground_icon_name = inputs.material.."-pipe-to-ground"
    reskins.lib.assign_icons(pipe_icon_name, pipe_icon_inputs)
    reskins.lib.assign_icons(pipe_to_ground_icon_name, pipe_to_ground_icon_inputs)

    -- Label to skip to next iteration
    ::continue::
end