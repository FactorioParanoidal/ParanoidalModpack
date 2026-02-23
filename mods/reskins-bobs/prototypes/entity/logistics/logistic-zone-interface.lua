-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "roboport",
	base_entity_name = "roboport",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
	make_remnants = false,
}

inputs.icon_filename = "__reskins-bobs__/graphics/icons/logistics/zone-interface/zone-interface-icon-base.png"

local name = "bob-logistic-zone-interface"
local tier = 0

---@type data.RoboportPrototype
local entity = data.raw[inputs.type][name]
if not entity then
	return
end

reskins.lib.setup_standard_entity(name, tier, inputs)

entity.base = {
	filename = "__reskins-bobs__/graphics/entity/logistics/zone-interface/logistic-zone-interface.png",
	width = 64,
	height = 70,
	shift = util.by_pixel(0, -4),
	scale = 0.5,
}

entity.base_animation = {
	layers = {
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/antennas/roboport-1-base-animation.png",
			priority = "medium",
			width = 83,
			height = 59,
			frame_count = 8,
			animation_speed = 0.5,
			shift = util.by_pixel(1, -21),
			scale = 0.5,
		},
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/zone-interface/logistic-zone-interface-shadow.png",
			priority = "medium",
			width = 106,
			height = 69,
			frame_count = 8,
			animation_speed = 0.5,
			shift = util.by_pixel(11.5, 1.5),
			draw_as_shadow = true,
			scale = 0.5,
		},
	},
}

-- Fix corpse
entity.corpse = "small-remnants"
