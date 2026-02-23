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
	type = "construction-robot",
	icon_name = "construction-robot",
	base_entity_name = "construction-robot",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["construction-robot"] = { tier = 1, prog_tier = 2 },
	["bob-construction-robot-2"] = { tier = 2, prog_tier = 3 },
	["bob-construction-robot-3"] = { tier = 3, prog_tier = 4 },
	["bob-construction-robot-4"] = { tier = 4, prog_tier = 5 },
	["bob-construction-robot-5"] = { tier = 5, prog_tier = 6, fusion_robot_color = reskins.lib.settings.get_value("reskins-bobs-fusion-robot-color") },
}

-- Animations
---comment
---@param tint data.Color
---@return table
local function generate_robot_animations(tint)
	return {
		idle = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/construction-robot/construction-robot.png",
					priority = "high",
					line_length = 16,
					width = 66,
					height = 76,
					shift = util.by_pixel(0, -4.5),
					direction_count = 16,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/construction-robot-mask.png",
					priority = "high",
					line_length = 16,
					width = 66,
					height = 76,
					shift = util.by_pixel(0, -4.5),
					tint = tint,
					direction_count = 16,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/construction-robot-highlights.png",
					priority = "high",
					line_length = 16,
					width = 66,
					height = 76,
					shift = util.by_pixel(0, -4.5),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					direction_count = 16,
					scale = 0.5,
				},
			},
		},
		in_motion = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/construction-robot/construction-robot.png",
					priority = "high",
					line_length = 16,
					width = 66,
					height = 76,
					shift = util.by_pixel(0, -4.5),
					direction_count = 16,
					y = 76,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/construction-robot-mask.png",
					priority = "high",
					line_length = 16,
					width = 66,
					height = 76,
					shift = util.by_pixel(0, -4.5),
					tint = tint,
					direction_count = 16,
					y = 76,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/construction-robot-highlights.png",
					priority = "high",
					line_length = 16,
					width = 66,
					height = 76,
					shift = util.by_pixel(0, -4.5),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					direction_count = 16,
					y = 76,
					scale = 0.5,
				},
			},
		},
		working = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/construction-robot/construction-robot-working.png",
					priority = "high",
					line_length = 2,
					width = 57,
					height = 74,
					frame_count = 2,
					shift = util.by_pixel(-0.25, -5),
					direction_count = 16,
					animation_speed = 0.3,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/construction-robot-working-mask.png",
					priority = "high",
					line_length = 2,
					width = 57,
					height = 74,
					frame_count = 2,
					shift = util.by_pixel(-0.25, -5),
					tint = tint,
					direction_count = 16,
					animation_speed = 0.3,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/construction-robot-working-highlights.png",
					priority = "high",
					line_length = 2,
					width = 57,
					height = 74,
					frame_count = 2,
					shift = util.by_pixel(-0.25, -5),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					direction_count = 16,
					animation_speed = 0.3,
					scale = 0.5,
				},
			},
		},
		shadow_idle = {
			filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 104,
			height = 49,
			shift = util.by_pixel(33.5, 18.75),
			direction_count = 16,
			scale = 0.5,
			draw_as_shadow = true,
		},
		shadow_in_motion = {
			filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 104,
			height = 49,
			shift = util.by_pixel(33.5, 18.75),
			direction_count = 16,
			scale = 0.5,
			draw_as_shadow = true,
		},
		shadow_working = {
			filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 104,
			height = 49,
			repeat_count = 2,
			shift = util.by_pixel(33.5, 18.75),
			direction_count = 16,
			scale = 0.5,
			draw_as_shadow = true,
		},
	}
end

local function get_tint(fusion_robot_color, tier)
	if fusion_robot_color and reskins.lib.settings.get_value("reskins-bobs-do-progression-based-robots") then
		return fusion_robot_color
	else
		return reskins.lib.tiers.get_tint(tier)
	end
end

for name, map in pairs(tier_map) do
	---@type data.ConstructionRobotPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = get_tint(map.fusion_robot_color, tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)
	local animations = generate_robot_animations(inputs.tint)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = make_rotated_animation_variations_from_sheet(3, {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/construction-robot/remnants/construction-robot-remnants.png",
				width = 120,
				height = 114,
				direction_count = 1,
				shift = util.by_pixel(2, 1),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/remnants/construction-robot-remnants-mask.png",
				width = 120,
				height = 114,
				direction_count = 1,
				shift = util.by_pixel(2, 1),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/construction-robot/remnants/construction-robot-remnants-highlights.png",
				width = 120,
				height = 114,
				direction_count = 1,
				shift = util.by_pixel(2, 1),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})

	-- Clear this, construction robots do not generate the corpse directly
	entity.corpse = nil

	-- Reskin entities
	entity.idle = animations.idle
	entity.in_motion = animations.in_motion
	entity.working = animations.working
	entity.shadow_idle = animations.shadow_idle
	entity.shadow_in_motion = animations.shadow_in_motion
	entity.shadow_working = animations.shadow_working

	-- Setup remnants and destruction animation
	reskins.bobs.make_robot_particle(entity)

	::continue::
end
