-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end

-- Set input parameters
local inputs = {
    type = "heat-pipe",
    base_entity_name = "heat-pipe",
    mod = "bobs",
}

local tier_map = {
    ["heat-pipe"] = {1, 3},
    ["heat-pipe-2"] = {2, 4, {"d4d4d4", "dff5ff"}},
    ["heat-pipe-3"] = {3, 5, {"d6b968", "ff7f3f"}},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- Setup inputs defaults
    reskins.lib.parse_inputs(inputs)

    -- Setup icons
    local heat_pipe_icon_inputs = {
        mod = "bobs",
        icon = reskins.bobs.directory.."/graphics/icons/power/heat-pipe/"..name.."-icon-base.png",
        icon_picture = {
            filename = reskins.bobs.directory.."/graphics/icons/power/heat-pipe/"..name.."-icon-base.png",
            size = 64,
            mipmaps = 4,
            scale = 0.25
        },
        icon_size = 64,
        icon_mipmaps = 4,
        type = "heat-pipe",
        make_icon_pictures = true,
    }

    -- Setup tier labels
    if reskins.lib.setting("reskins-bobs-do-pipe-tier-labeling") == true then
        heat_pipe_icon_inputs.icon = {{icon = heat_pipe_icon_inputs.icon}}
        heat_pipe_icon_inputs.tier_labels = true
        reskins.lib.append_tier_labels(tier, heat_pipe_icon_inputs)
    end

    reskins.lib.assign_icons(name, heat_pipe_icon_inputs)

    --- Don't reskin the base pipes
    if name == "heat-pipe" then goto continue end

    -- Create particles and explosions
    local particle_tints = {util.color(map[3][1]), util.color(map[3][2])}
    reskins.lib.create_explosion(name, inputs)
    reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["small"], 1, particle_tints[1])
    reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["medium"], 2, particle_tints[2])

    -- Create and skin remnants
    reskins.lib.create_remnant(name, inputs)
    local remnant = data.raw["corpse"][name.."-remnants"]
    remnant.animation = make_rotated_animation_variations_from_sheet (6, {
        filename = reskins.bobs.directory.."/graphics/entity/power/heat-pipe/"..name.."/remnants/"..name.."-remnants.png",
        line_length = 1,
        width = 62,
        height = 52,
        frame_count = 1,
        direction_count = 2,
        shift = util.by_pixel(1, -1),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/power/heat-pipe/"..name.."/remnants/hr-"..name.."-remnants.png",
            line_length = 1,
            width = 122,
            height = 100,
            frame_count = 1,
            direction_count = 2,
            shift = util.by_pixel(0.5, -1.5),
            scale = 0.5,
        },
    })

    -- Reskin entities
    entity.connection_sprites = make_heat_pipe_pictures(reskins.bobs.directory.."/graphics/entity/power/heat-pipe/"..name.."/", name,
    {
        single = { name = "straight-vertical-single", ommit_number = true },
        straight_vertical = { variations = 6 },
        straight_horizontal = { variations = 6 },
        corner_right_up = { name = "corner-up-right", variations = 6 },
        corner_left_up = { name = "corner-up-left", variations = 6 },
        corner_right_down = { name = "corner-down-right", variations = 6 },
        corner_left_down = { name = "corner-down-left", variations = 6 },
        t_up = {},
        t_down = {},
        t_right = {},
        t_left = {},
        cross = { name = "t" },
        ending_up = {},
        ending_down = {},
        ending_right = {},
        ending_left = {}
    })

    -- Label to skip to next iteration
    ::continue::
end