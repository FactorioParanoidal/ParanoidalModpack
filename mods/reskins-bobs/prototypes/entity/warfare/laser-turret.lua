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
	type = "electric-turret",
	icon_name = "laser-turret",
	base_entity_name = "laser-turret",
	mod = "bobs",
	group = "warfare",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["laser-turret"] = { tier = 1 },
	["bob-laser-turret-2"] = { tier = 2, lens_type = "sapphire" },
	["bob-laser-turret-3"] = { tier = 3, lens_type = "emerald" },
	["bob-laser-turret-4"] = { tier = 4, lens_type = "topaz" },
	["bob-laser-turret-5"] = { tier = 5, lens_type = "diamond" },
}

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_laser_turret_extension_base(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/laser-turret/laser-turret-raising.png",
		priority = "medium",
		width = 130,
		height = 126,
		frame_count = parameters.frame_count and parameters.frame_count or 15,
		line_length = parameters.line_length and parameters.line_length or 0,
		run_mode = parameters.run_mode and parameters.run_mode or "forward",
		direction_count = 4,
		shift = util.by_pixel(0, -32.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_laser_turret_extension_runtime_mask(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/laser-turret/laser-turret-raising-mask.png",
		flags = { "mask" },
		width = 86,
		height = 80,
		frame_count = parameters.frame_count and parameters.frame_count or 15,
		line_length = parameters.line_length and parameters.line_length or 0,
		run_mode = parameters.run_mode and parameters.run_mode or "forward",
		apply_runtime_tint = true,
		direction_count = 4,
		shift = util.by_pixel(0, -43),
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_laser_turret_extension_shadow(parameters)
	parameters = parameters or {}

	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/laser-turret/laser-turret-raising-shadow.png",
		width = 182,
		height = 96,
		frame_count = parameters.frame_count and parameters.frame_count or 15,
		line_length = parameters.line_length and parameters.line_length or 0,
		run_mode = parameters.run_mode and parameters.run_mode or "forward",
		direction_count = 4,
		draw_as_shadow = true,
		shift = util.by_pixel(47, 2.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_laser_turret_shooting_base()
	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/laser-turret/laser-turret-shooting.png",
		line_length = 8,
		width = 126,
		height = 120,
		direction_count = 64,
		shift = util.by_pixel(0, -35),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_laser_turret_shooting_runtime_mask()
	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/laser-turret/laser-turret-shooting-mask.png",
		flags = { "mask" },
		line_length = 8,
		width = 92,
		height = 80,
		apply_runtime_tint = true,
		direction_count = 64,
		shift = util.by_pixel(0, -43.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_laser_turret_shooting_shadow()
	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__base__/graphics/entity/laser-turret/laser-turret-shooting-shadow.png",
		line_length = 8,
		width = 170,
		height = 92,
		direction_count = 64,
		draw_as_shadow = true,
		shift = util.by_pixel(50.5, 2.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function turret_shooting_glow(lens)
	---@type data.RotatedAnimation
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/beam/" .. lens .. "/" .. lens .. "-laser-turret-shooting-light.png",
		line_length = 8,
		width = 122,
		height = 116,
		direction_count = 64,
		shift = util.by_pixel(-0.5, -35),
		blend_mode = "additive",
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_laser_turret_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/laser-turret/remnants/laser-turret-remnants.png",
				width = 198,
				height = 194,
				direction_count = 1,
				shift = util.by_pixel(2.5, -2),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/laser-turret/remnants/laser-turret-remnants-mask.png",
				width = 198,
				height = 194,
				direction_count = 1,
				shift = util.by_pixel(2.5, -2),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/laser-turret/remnants/laser-turret-remnants-highlights.png",
				width = 198,
				height = 194,
				direction_count = 1,
				shift = util.by_pixel(2.5, -2),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Runtime Mask
			{
				priority = "low",
				filename = "__base__/graphics/entity/laser-turret/remnants/mask/laser-turret-remnants-mask.png",
				width = 114,
				height = 94,
				apply_runtime_tint = true,
				direction_count = 1,
				shift = util.by_pixel(4, -2.5),
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

---@return data.WaterReflectionDefinition
local function get_laser_turret_water_reflection()
	---@type data.WaterReflectionDefinition
	local water_reflection = {
		pictures = {
			filename = "__base__/graphics/entity/laser-turret/laser-turret-reflection.png",
			priority = "extra-high",
			width = 20,
			height = 32,
			shift = util.by_pixel(0, 40),
			variation_count = 1,
			scale = 5,
		},
		rotate = false,
		orientation_to_variation = false,
	}

	return water_reflection
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.ElectricTurretPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_laser_turret_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(3, remnant_animation)

	-- Reskin entities
	entity.folded_animation = {
		layers = {
			get_laser_turret_extension_base({ frame_count = 1, line_length = 1 }),
			get_laser_turret_extension_runtime_mask({ frame_count = 1, line_length = 1 }),
			get_laser_turret_extension_shadow({ frame_count = 1, line_length = 1 }),
		},
	}

	entity.preparing_animation = {
		layers = {
			get_laser_turret_extension_base(),
			get_laser_turret_extension_runtime_mask(),
			get_laser_turret_extension_shadow(),
		},
	}

	entity.prepared_animation = {
		layers = {
			get_laser_turret_shooting_base(),
			get_laser_turret_shooting_runtime_mask(),
			get_laser_turret_shooting_shadow(),
		},
	}

	if map.lens_type then
		-- Light up laser turret when firing
		entity.energy_glow_animation = turret_shooting_glow(map.lens_type)
		entity.glow_light_intensity = 0.5

		-- Fix laser offset
		entity.attack_parameters.source_direction_count = 64
		entity.attack_parameters.source_offset = { 0, -3.423489 / 4 }
	end

	entity.folding_animation = {
		layers = {
			get_laser_turret_extension_base({ run_mode = "backward" }),
			get_laser_turret_extension_runtime_mask({ run_mode = "backward" }),
			get_laser_turret_extension_shadow({ run_mode = "backward" }),
		},
	}

	entity.graphics_set = {
		base_visualisation = {
			animation = {
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/laser-turret/laser-turret-base.png",
						priority = "high",
						width = 138,
						height = 104,
						shift = util.by_pixel(-0.5, 2),
						scale = 0.5,
					},
					-- Mask
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/laser-turret/laser-turret-base-mask.png",
						priority = "high",
						width = 138,
						height = 104,
						shift = util.by_pixel(-0.5, 2),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/laser-turret/laser-turret-base-highlights.png",
						priority = "high",
						width = 138,
						height = 104,
						shift = util.by_pixel(-0.5, 2),
						blend_mode = reskins.lib.settings.blend_mode, -- "additive",
						scale = 0.5,
					},
					-- Shadow
					{
						filename = "__base__/graphics/entity/laser-turret/laser-turret-base-shadow.png",
						width = 132,
						height = 82,
						draw_as_shadow = true,
						shift = util.by_pixel(6, 3),
						scale = 0.5,
					},
				},
			},
		},
	}

	entity.water_reflection = get_laser_turret_water_reflection()

	::continue::
end
