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
	type = "logistic-robot",
	icon_name = "logistic-robot",
	base_entity_name = "logistic-robot",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["logistic-robot"] = { tier = 1, prog_tier = 2 },
	["bob-logistic-robot-2"] = { tier = 2, prog_tier = 3 },
	["bob-logistic-robot-3"] = { tier = 3, prog_tier = 4 },
	["bob-logistic-robot-4"] = { tier = 4, prog_tier = 5 },
	["bob-logistic-robot-5"] = { tier = 5, prog_tier = 6, fusion_robot_color = reskins.lib.settings.get_value("reskins-bobs-fusion-robot-color") },
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
					filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					direction_count = 16,
					y = 84,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					tint = tint,
					direction_count = 16,
					y = 84,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					direction_count = 16,
					y = 84,
					scale = 0.5,
				},
			},
		},
		idle_with_cargo = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					direction_count = 16,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					tint = tint,
					direction_count = 16,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
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
					filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					direction_count = 16,
					y = 252,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					tint = tint,
					direction_count = 16,
					y = 252,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					direction_count = 16,
					y = 252,
					scale = 0.5,
				},
			},
		},
		in_motion_with_cargo = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					direction_count = 16,
					y = 168,
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					tint = tint,
					direction_count = 16,
					y = 168,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
					priority = "high",
					line_length = 16,
					width = 80,
					height = 84,
					shift = util.by_pixel(0, -3),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					direction_count = 16,
					y = 168,
					scale = 0.5,
				},
			},
		},
		shadow_idle = {
			filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 115,
			height = 57,
			shift = util.by_pixel(31.75, 19.75),
			direction_count = 16,
			y = 57,
			scale = 0.5,
			draw_as_shadow = true,
		},
		shadow_idle_with_cargo = {
			filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 115,
			height = 57,
			shift = util.by_pixel(31.75, 19.75),
			direction_count = 16,
			scale = 0.5,
			draw_as_shadow = true,
		},
		shadow_in_motion = {
			filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 115,
			height = 57,
			shift = util.by_pixel(31.75, 19.75),
			direction_count = 16,
			y = 57 * 3,
			scale = 0.5,
			draw_as_shadow = true,
		},
		shadow_in_motion_with_cargo = {
			filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
			priority = "high",
			line_length = 16,
			width = 115,
			height = 57,
			shift = util.by_pixel(31.75, 19.75),
			direction_count = 16,
			y = 114,
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
	---@type data.LogisticRobotPrototype
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
				filename = "__base__/graphics/entity/logistic-robot/remnants/logistic-robot-remnants.png",
				width = 116,
				height = 114,
				direction_count = 1,
				shift = util.by_pixel(1, 1),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/remnants/logistic-robot-remnants-mask.png",
				width = 116,
				height = 114,
				direction_count = 1,
				shift = util.by_pixel(1, 1),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/logistic-robot/remnants/logistic-robot-remnants-highlights.png",
				width = 116,
				height = 114,
				direction_count = 1,
				shift = util.by_pixel(1, 1),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})

	-- Clear this, logistic robots do not generate the corpse directly
	entity.corpse = nil

	-- Reskin entities
	entity.idle = animations.idle
	entity.idle_with_cargo = animations.idle_with_cargo
	entity.in_motion = animations.in_motion
	entity.in_motion_with_cargo = animations.in_motion_with_cargo
	entity.shadow_idle = animations.shadow_idle
	entity.shadow_idle_with_cargo = animations.shadow_idle_with_cargo
	entity.shadow_in_motion = animations.shadow_in_motion
	entity.shadow_in_motion_with_cargo = animations.shadow_in_motion_with_cargo

	-- Setup remnants and destruction animation
	reskins.bobs.make_robot_particle(entity)

	::continue::
end
