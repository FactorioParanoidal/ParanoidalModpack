-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.technology.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "lab",
	root_name = "lab",
	base_entity_name = "lab",
	mod = "bobs",
	group = "technology",
	-- particles = {["big"] = 3}
}

local function reskin_lab(name)
	---@type data.LabPrototype
	local entity = data.raw["lab"][name]

	if not entity then
		return
	end

	entity.on_animation = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/technology/lab/" .. name .. ".png",
				width = 194,
				height = 174,
				frame_count = 33,
				line_length = 11,
				animation_speed = 1 / 3,
				shift = util.by_pixel(0, 1.5),
				scale = 0.5,
			},
			{
				filename = "__base__/graphics/entity/lab/lab-integration.png",
				width = 242,
				height = 162,
				repeat_count = 33,
				animation_speed = 1 / 3,
				shift = util.by_pixel(0, 15.5),
				scale = 0.5,
			},
			{
				filename = "__base__/graphics/entity/lab/lab-shadow.png",
				width = 242,
				height = 136,
				repeat_count = 33,
				animation_speed = 1 / 3,
				shift = util.by_pixel(13, 11),
				scale = 0.5,
				draw_as_shadow = true,
			},
		},
	}

	entity.off_animation = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/technology/lab/" .. name .. ".png",
				width = 194,
				height = 174,
				shift = util.by_pixel(0, 1.5),
				scale = 0.5,
			},
			{
				filename = "__base__/graphics/entity/lab/lab-integration.png",
				width = 242,
				height = 162,
				shift = util.by_pixel(0, 15.5),
				scale = 0.5,
			},
			{
				filename = "__base__/graphics/entity/lab/lab-shadow.png",
				width = 242,
				height = 136,
				shift = util.by_pixel(13, 11),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}
end

reskin_lab("bob-lab-2")
reskin_lab("bob-lab-alien")

-- lab
-- lab-2
-- lab-alien
-- burner-lab

-- Check to see if reskinning needs to be done.
if not mods["bobmodules"] then
	return
end
if reskins.lib.settings.get_value("reskins-bobs-do-bobmodules") == false then
	return
end

-- lab-module
