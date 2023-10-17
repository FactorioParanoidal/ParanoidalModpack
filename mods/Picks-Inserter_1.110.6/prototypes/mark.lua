--[[ Copyright (c) 2019 - 2023 Picklock
 * Part of Picklocks Inserter
 * mark.lua
 * Version 1.110.6.54
 *
 * See LICENSE.MD in the project directory for license information.
--]]

--mark
	--item
local myMark = {
    type = "simple-entity-with-force",
    name = "PI_mark",
    flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid"},
    icon = myModName.."/graphics/mark/PI_mark_32.png",
    icon_size = 32,
    max_health = 100,
    selectable_in_game = false,
    mined_sound = nil,
    minable = nil,
    collision_box = nil,
    selection_box = nil,
    collision_mask = {},
    render_layer = "explosion",
    vehicle_impact_sound = nil,
    pictures =
    {
        {
            --1 marked
            filename = myModName.."/graphics/mark/PI_mark_32.png",
            priority = "extra-high",
            x = 0,
            y = 0,
            width = 32,
            height = 32,
            scale = 0.3,
            shift = {0, -0.3}
        },
    },
}

data:extend({myMark})
	
	