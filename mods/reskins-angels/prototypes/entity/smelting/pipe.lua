-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if reskins.lib.setting("reskins-angels-use-angels-material-colors-pipes") == false then return end
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then return end

-- Set trigger
reskins.angels.triggers.smelting.pipes_use_material_colors = true

-- Set input parameters
local inputs = {
    mod = "angels",
    group = "smelting",
}

local material_map = {
    ["titanium"] = { tier = 4, tint = util.color("995f92") },
    ["ceramic"] = { tier = 4, tint = util.color("ffffff") },
    ["tungsten"] = { tier = 4, tint = util.color("7e5f45") },
    ["nitinol"] = { tier = 5, tint = util.color("7664a9") },
}

-- Reskin pipes, create and assign extra details
for material, map in pairs(material_map) do
    -- Fetch entities
    local pipe_entity = data.raw["pipe"][material .. "-pipe"]
    local pipe_to_ground_entity = data.raw["pipe-to-ground"][material .. "-pipe-to-ground"]

    -- Check if entity exists, if not, skip this iteration; assume if we have one we have both
    if not pipe_entity then goto continue end

    -- Create explosions
    reskins.lib.create_explosion(material .. "-pipe", { type = "pipe", base_entity_name = "pipe" })
    reskins.lib.create_explosion(material .. "-pipe-to-ground", { type = "pipe-to-ground", base_entity_name = "pipe-to-ground" })

    -- Create particles
    reskins.lib.create_particle(material .. "-pipe", "pipe", reskins.lib.particle_index["medium"], 1, map.tint)
    reskins.lib.create_particle(material .. "-pipe", "pipe", reskins.lib.particle_index["small"], 2, map.tint)
    reskins.lib.create_particle(material .. "-pipe-to-ground", "pipe-to-ground", reskins.lib.particle_index["medium"], 1, map.tint)
    reskins.lib.create_particle(material .. "-pipe-to-ground", "pipe-to-ground", reskins.lib.particle_index["small"], 2, map.tint)

    -- Create remnants
    reskins.lib.create_remnant(material .. "-pipe", { type = "pipe", base_entity_name = "pipe" })
    reskins.lib.create_remnant(material .. "-pipe-to-ground", { type = "pipe-to-ground", base_entity_name = "pipe-to-ground" })

    -- Fetch remnant
    local pipe_remnant = data.raw["corpse"][material .. "-pipe-remnants"]
    local pipe_to_ground_remnant = data.raw["corpse"][material .. "-pipe-to-ground-remnants"]

    -- Reskin remnants
    pipe_remnant.animation = make_rotated_animation_variations_from_sheet(2, {
        filename = reskins.angels.directory .. "/graphics/entity/smelting/pipe/" .. material .. "/remnants/pipe-remnants.png",
        width = 61,
        height = 60,
        line_length = 1,
        frame_count = 1,
        direction_count = 2,
        shift = util.by_pixel(1.5, 2.5),
        hr_version = {
            filename = reskins.angels.directory .. "/graphics/entity/smelting/pipe/" .. material .. "/remnants/hr-pipe-remnants.png",
            width = 122,
            height = 120,
            line_length = 1,
            frame_count = 1,
            direction_count = 2,
            shift = util.by_pixel(1.5, 2.5),
            scale = 0.5,
        },
    })

    pipe_to_ground_remnant.animation = {
        filename = reskins.angels.directory .. "/graphics/entity/smelting/pipe-to-ground/" .. material .. "/remnants/pipe-to-ground-remnants.png",
        width = 45,
        height = 40,
        line_length = 1,
        frame_count = 1,
        direction_count = 1,
        shift = util.by_pixel(0.5, -3),
        hr_version = {
            filename = reskins.angels.directory .. "/graphics/entity/smelting/pipe-to-ground/" .. material .. "/remnants/hr-pipe-to-ground-remnants.png",
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
    pipe_entity.pictures = reskins.lib.get_pipe_pictures("angels-"..material)
    pipe_to_ground_entity.pictures = reskins.lib.get_pipe_to_ground_pictures("angels-"..material)

    -- Fix fluid window
    pipe_entity.horizontal_window_bounding_box = { { -0.25, -0.28125 }, { 0.25, 0.15625 } }
    pipe_entity.vertical_window_bounding_box = { { -0.28125, -0.5 }, { 0.03125, 0.125 } }

    -- Handle pipe covers for underground pipes
    pipe_to_ground_entity.fluid_box.pipe_covers = reskins.lib.get_pipe_covers("angels-"..material)

    ---@type data.IconData[]
    local pipe_icons = { {
        icon = reskins.angels.directory .. "/graphics/icons/smelting/pipe/" .. material .. "-pipe-icon.png",
        icon_size = 64,
        icon_mipmaps = 4,
    } }

    ---@type data.IconData[]
    local pipe_to_ground_icons = { {
        icon = reskins.angels.directory .. "/graphics/icons/smelting/pipe-to-ground/" .. material .. "-pipe-to-ground-icon.png",
        icon_size = 64,
        icon_mipmaps = 4,
    } }

    ---@type boolean
    local do_labels = reskins.lib.setting("reskins-bobs-do-pipe-tier-labeling") or false

    -- Setup Icons
    local pipe_icon_inputs = {
        mod = "angels",
        icon = do_labels and reskins.lib.add_tier_labels_to_icons(pipe_icons, map.tier) or pipe_icons,
        icon_picture = do_labels and reskins.lib.convert_icons_to_sprite(pipe_icons, 0.25) or nil,
        type = "pipe",
    }

    local pipe_to_ground_icon_inputs = {
        mod = "angels",
        icon = do_labels and reskins.lib.add_tier_labels_to_icons(pipe_to_ground_icons, map.tier),
        icon_picture = do_labels and reskins.lib.convert_icons_to_sprite(pipe_to_ground_icons, 0.25) or nil,
        type = "pipe-to-ground",
    }

    reskins.lib.assign_icons(material .. "-pipe", pipe_icon_inputs)
    reskins.lib.assign_icons(material .. "-pipe-to-ground", pipe_to_ground_icon_inputs)

    -- Label to skip to next iteration
    ::continue::
end
