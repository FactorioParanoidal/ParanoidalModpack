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
	icon_name = "sniper-turret",
	base_entity_name = "gun-turret",
	mod = "bobs",
	group = "warfare",
	particles = { ["medium"] = 2 },
	make_remnants = false,
}

local tier_map = {
	["bob-sniper-turret-1"] = { tier = 1, prog_tier = 1 },
	["bob-sniper-turret-2"] = { tier = 2, prog_tier = 3 },
	["bob-sniper-turret-3"] = { tier = 3, prog_tier = 5 },
}

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_sniper_turret_extension_base(parameters)
	parameters = parameters or {}

	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-raising.png",
		priority = "medium",
		width = 238,
		height = 178,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -30.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_sniper_turret_extension_runtime_mask(parameters)
	parameters = parameters or {}

	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-raising-tint.png",
		priority = "medium",
		width = 238,
		height = 178,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -30.5),
		flags = { "mask" },
		apply_runtime_tint = true,
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_sniper_turret_extension_mask(parameters)
	parameters = parameters or {}

	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-raising-mask.png",
		priority = "medium",
		width = 238,
		height = 178,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -30.5),
		tint = parameters.tint,
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_sniper_turret_extension_highlights(parameters)
	parameters = parameters or {}

	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-raising-highlights.png",
		priority = "medium",
		width = 238,
		height = 178,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(0, -30.5),
		blend_mode = reskins.lib.settings.blend_mode, -- "additive",
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_sniper_turret_extension_shadow(parameters)
	parameters = parameters or {}

	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-raising-shadow.png",
		width = 246,
		height = 178,
		direction_count = 4,
		frame_count = parameters.frame_count or 5,
		line_length = parameters.line_length or 0,
		run_mode = parameters.run_mode or "forward",
		shift = util.by_pixel(21.5, 2),
		draw_as_shadow = true,
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_sniper_turret_shooting_base()
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-shooting.png",
		line_length = 8,
		width = 238,
		height = 178,
		direction_count = 64,
		shift = util.by_pixel(0, -30.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_sniper_turret_shooting_runtime_mask()
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-tint.png",
		flags = { "mask" },
		line_length = 8,
		width = 238,
		height = 178,
		apply_runtime_tint = true,
		direction_count = 64,
		shift = util.by_pixel(0, -30.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@param parameters? TurretAnimationParameters
---@return data.RotatedAnimation
local function get_sniper_turret_shooting_mask(parameters)
	parameters = parameters or {}

	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-mask.png",
		line_length = 8,
		width = 238,
		height = 178,
		tint = parameters.tint,
		direction_count = 64,
		shift = util.by_pixel(0, -30.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_sniper_turret_shooting_highlights()
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-highlights.png",
		line_length = 8,
		width = 238,
		height = 178,
		blend_mode = reskins.lib.settings.blend_mode, -- "additive",
		direction_count = 64,
		shift = util.by_pixel(0, -30.5),
		scale = 0.5,
	}

	return rotated_animation
end

---@return data.RotatedAnimation
local function get_sniper_turret_shooting_shadow()
	local rotated_animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-shooting-shadow.png",
		line_length = 8,
		width = 246,
		height = 178,
		direction_count = 64,
		draw_as_shadow = true,
		shift = util.by_pixel(21.5, 2),
		scale = 0.5,
	}

	return rotated_animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AmmoTurretPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Assign generic remnants
	entity.corpse = "medium-remnants"

	-- Correct projectile details
	entity.attack_parameters.projectile_creation_distance = 2.3
	entity.attack_parameters.projectile_center = util.by_pixel(0, 0)
	entity.attack_parameters.shell_particle.center = util.by_pixel(4, 0)
	entity.attack_parameters.shell_particle.creation_distance = -2.85
	entity.attack_parameters.shell_particle.direction = -0.25

	-- Reskin entities
	entity.folded_animation = {
		layers = {
			get_sniper_turret_extension_base({ frame_count = 1, line_length = 1 }),
			get_sniper_turret_extension_runtime_mask({ frame_count = 1, line_length = 1 }),
			get_sniper_turret_extension_mask({ tint = inputs.tint, frame_count = 1, line_length = 1 }),
			get_sniper_turret_extension_highlights({ frame_count = 1, line_length = 1 }),
			get_sniper_turret_extension_shadow({ frame_count = 1, line_length = 1 }),
		},
	}
	entity.preparing_animation = {
		layers = {
			get_sniper_turret_extension_base(),
			get_sniper_turret_extension_runtime_mask(),
			get_sniper_turret_extension_mask({ tint = inputs.tint }),
			get_sniper_turret_extension_highlights(),
			get_sniper_turret_extension_shadow(),
		},
	}
	entity.prepared_animation = {
		layers = {
			get_sniper_turret_shooting_base(),
			get_sniper_turret_shooting_runtime_mask(),
			get_sniper_turret_shooting_mask({ tint = inputs.tint }),
			get_sniper_turret_shooting_highlights(),
			get_sniper_turret_shooting_shadow(),
		},
	}
	entity.attacking_animation = {
		layers = {
			get_sniper_turret_shooting_base(),
			get_sniper_turret_shooting_runtime_mask(),
			get_sniper_turret_shooting_mask({ tint = inputs.tint }),
			get_sniper_turret_shooting_highlights(),
			get_sniper_turret_shooting_shadow(),
		},
	}
	entity.folding_animation = {
		layers = {
			get_sniper_turret_extension_base({ run_mode = "backward" }),
			get_sniper_turret_extension_runtime_mask({ run_mode = "backward" }),
			get_sniper_turret_extension_mask({ tint = inputs.tint, run_mode = "backward" }),
			get_sniper_turret_extension_highlights({ run_mode = "backward" }),
			get_sniper_turret_extension_shadow({ run_mode = "backward" }),
		},
	}
	entity.graphics_set = {
		base_visualisation = {
			animation = {
				layers = {
					-- Base
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-base.png",
						priority = "high",
						width = 150,
						height = 118,
						shift = util.by_pixel(2, 0),
						scale = 0.5,
					},
					-- Runtime Mask
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-base-runtime-mask.png",
						priority = "high",
						width = 150,
						height = 118,
						shift = util.by_pixel(2, 0),
						apply_runtime_tint = true,
						scale = 0.5,
					},
					-- Shadow
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/sniper-turret/sniper-turret-base-shadow.png",
						priority = "high",
						width = 150,
						height = 118,
						draw_as_shadow = true,
						shift = util.by_pixel(2, 0),
						scale = 0.5,
					},
				},
			},
		},
	}

	entity.water_reflection = util.copy(data.raw[inputs.type]["gun-turret"].water_reflection)

	::continue::
end
