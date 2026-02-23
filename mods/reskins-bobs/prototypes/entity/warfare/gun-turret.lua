-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "ammo-turret",
	icon_name = "gun-turret",
	base_entity_name = "gun-turret",
	mod = "bobs",
	group = "warfare",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["gun-turret"] = 1,
	["bob-gun-turret-2"] = 2,
	["bob-gun-turret-3"] = 3,
	["bob-gun-turret-4"] = 4,
	["bob-gun-turret-5"] = 5,
}

---@class TurretAnimationParameters
---
---Can't be `0`.
---@field frame_count uint32?
---
---Specifies how many pictures are on each horizontal line in the image file. 0 means that all the pictures are in one
---horizontal line. Once the specified number of pictures are loaded from a line, the pictures from the next line are
---loaded. This is to allow having longer animations loaded in to Factorio's graphics matrix than the game engine's
---width limit of 8192px per input file. The restriction on input files is to be compatible with most graphics cards.
---@field line_length uint32?
---@field run_mode data.AnimationRunMode? Defaults to `"forward"`.
---How many times to repeat the animation to complete an animation cycle. E.g. if one layer is 10 frames, a second layer
---of 1 frame would need repeat_count = 10 to match the complete cycle.
---@field repeat_count uint8?
---@field tint data.Color?

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_gun_turret_extension_base(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/gun-turret/gun-turret-raising.png",
		priority = "medium",
		width = 130,
		height = 126,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -26.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_gun_turret_extension_mask(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-raising-mask.png",
		priority = "medium",
		width = 130,
		height = 126,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -26.5),
		tint = parameters.tint,
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_gun_turret_extension_highlights(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-raising-highlights.png",
		priority = "medium",
		width = 130,
		height = 126,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -26.5),
		blend_mode = reskins.lib.settings.blend_mode, -- "additive",
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_gun_turret_extension_runtime_mask(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/gun-turret/gun-turret-raising-mask.png",
		flags = { "mask" },
		width = 48,
		height = 62,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -28),
		apply_runtime_tint = true,
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_gun_turret_extension_shadow(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/gun-turret/gun-turret-raising-shadow.png",
		width = 250,
		height = 124,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(19, 2.5),
		draw_as_shadow = true,
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function turret_attack(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		layers = {
			-- Base
			{
				width = 132,
				height = 130,
				frame_count = parameters.frame_count and parameters.frame_count or 2,
				direction_count = 64,
				shift = util.by_pixel(0, -27.5),
				stripes = {
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-1.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-2.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-3.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-4.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
				},
				scale = 0.5,
			},
			-- Mask
			{
				width = 132,
				height = 130,
				frame_count = parameters.frame_count and parameters.frame_count or 2,
				direction_count = 64,
				shift = util.by_pixel(0, -27.5),
				tint = parameters.tint,
				stripes = {
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-1-mask.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-2-mask.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-3-mask.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-4-mask.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
				},
				scale = 0.5,
			},
			-- Highlights
			{
				width = 132,
				height = 130,
				frame_count = parameters.frame_count and parameters.frame_count or 2,
				direction_count = 64,
				shift = util.by_pixel(0, -27.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				stripes = {
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-1-highlights.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-2-highlights.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-3-highlights.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/gun-turret-shooting-4-highlights.png",
						width_in_frames = parameters.frame_count or 2,
						height_in_frames = 16,
					},
				},
				scale = 0.5,
			},
			-- Runtime Mask
			{
				flags = { "mask" },
				line_length = parameters.frame_count or 2,
				width = 58,
				height = 54,
				frame_count = parameters.frame_count or 2,
				direction_count = 64,
				shift = util.by_pixel(0, -32.5),
				apply_runtime_tint = true,
				stripes = {
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-1.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-2.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-3.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-4.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
				},
				scale = 0.5,
			},
			-- Shadow
			{
				width = 250,
				height = 124,
				frame_count = parameters.frame_count and parameters.frame_count or 2,
				direction_count = 64,
				shift = util.by_pixel(22, 2.5),
				draw_as_shadow = true,
				stripes = {
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-1.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-2.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-3.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-4.png",
						width_in_frames = parameters.frame_count and parameters.frame_count or 2,
						height_in_frames = 16,
					},
				},
				scale = 0.5,
			},
		},
	}

	return rotated_animation
end

---@param tint data.Color
---@return data.RotatedAnimation
local function get_gun_turret_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/gun-turret/remnants/gun-turret-remnants.png",
				width = 252,
				height = 242,
				direction_count = 1,
				shift = util.by_pixel(3, -1.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/remnants/gun-turret-remnants-mask.png",
				width = 252,
				height = 242,
				direction_count = 1,
				shift = util.by_pixel(3, -1.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/gun-turret/remnants/gun-turret-remnants-highlights.png",
				width = 252,
				height = 242,
				direction_count = 1,
				shift = util.by_pixel(3, -1.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Runtime Mask
			{
				priority = "low",
				filename = "__base__/graphics/entity/gun-turret/remnants/mask/gun-turret-remnants-mask.png",
				width = 68,
				height = 64,
				apply_runtime_tint = true,
				direction_count = 1,
				shift = util.by_pixel(-1, -11),
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, tier in pairs(tier_map) do
	---@type data.AmmoTurretPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_gun_turret_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(3, remnant_animation)

	-- Reskin entities
	entity.folded_animation = {
		layers = {
			get_gun_turret_extension_base({ frame_count = 1, line_length = 1 }),
			get_gun_turret_extension_mask({ tint = inputs.tint, frame_count = 1, line_length = 1 }),
			get_gun_turret_extension_highlights({ frame_count = 1, line_length = 1 }),
			get_gun_turret_extension_runtime_mask({ frame_count = 1, line_length = 1 }),
			get_gun_turret_extension_shadow({ frame_count = 1, line_length = 1 }),
		},
	}
	entity.preparing_animation = {
		layers = {
			get_gun_turret_extension_base(),
			get_gun_turret_extension_mask({ tint = inputs.tint }),
			get_gun_turret_extension_highlights(),
			get_gun_turret_extension_runtime_mask(),
			get_gun_turret_extension_shadow(),
		},
	}
	entity.prepared_animation = turret_attack({ tint = inputs.tint, frame_count = 1 })
	entity.attacking_animation = turret_attack({ tint = inputs.tint })
	entity.folding_animation = {
		layers = {
			get_gun_turret_extension_base({ run_mode = "backward" }),
			get_gun_turret_extension_mask({ tint = inputs.tint, run_mode = "backward" }),
			get_gun_turret_extension_highlights({ run_mode = "backward" }),
			get_gun_turret_extension_runtime_mask({ run_mode = "backward" }),
			get_gun_turret_extension_shadow({ run_mode = "backward" }),
		},
	}
	entity.graphics_set = {
		base_visualisation = {
			animation = {
				layers = {
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-base.png",
						priority = "high",
						width = 150,
						height = 118,
						shift = util.by_pixel(0.5, -1),
						scale = 0.5,
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-base-mask.png",
						flags = { "mask", "low-object" },
						width = 122,
						height = 102,
						shift = util.by_pixel(0, -4.5),
						apply_runtime_tint = true,
						scale = 0.5,
					},
				},
			},
		},
	}

	if name ~= "gun-turret" then
		entity.water_reflection = util.copy(data.raw[inputs.type]["gun-turret"].water_reflection)
	end

	::continue::
end
