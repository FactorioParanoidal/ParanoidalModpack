-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["P-U-M-P-S"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set input parameters
local inputs = {
	icon_name = "offshore-pump",
	base_entity_name = "offshore-pump",
	mod = "compatibility",
	particles = { ["small"] = 3 },
	group = "p-u-m-p-s",
}

local tier_map = {
	["offshore-pump-0"] = { tier = 0, prog_tier = 1 },
	["offshore-pump-1"] = { tier = 1, prog_tier = 2 },
	["offshore-pump-2"] = { tier = 2, prog_tier = 3 },
	["offshore-pump-3"] = { tier = 3, prog_tier = 4 },
	["offshore-pump-4"] = { tier = 4, prog_tier = 5 },
}

-- Sprite functions
local function return_animation(tint, direction)
	local animation = {
		north = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_North-mask.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					tint = tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_North-highlights.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					blend_mode = reskins.lib.settings.blend_mode,
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 150,
					height = 134,
					shift = util.by_pixel(13, -7),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		east = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_East-mask.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					tint = tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_East-highlights.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					blend_mode = reskins.lib.settings.blend_mode,
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 180,
					height = 66,
					shift = util.by_pixel(27, 8),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		south = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_South-mask.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					tint = tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_South-highlights.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					blend_mode = reskins.lib.settings.blend_mode,
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 164,
					height = 128,
					shift = util.by_pixel(15, 23),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		west = {
			layers = {
				-- Base
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_West-mask.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					tint = tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/offshore-pump_West-highlights.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					blend_mode = reskins.lib.settings.blend_mode,
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 172,
					height = 66,
					shift = util.by_pixel(-3, 8),
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
	}

	if direction then
		return animation[direction]
	else
		return animation
	end
end

local function return_fluid_animation(direction)
	local fluid_animation = {
		north = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png",
			apply_runtime_tint = true,
			line_length = 8,
			frame_count = 32,
			animation_speed = 0.25,
			width = 40,
			height = 40,
			shift = util.by_pixel(-1, -22),
			scale = 0.5,
		},
		east = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png",
			apply_runtime_tint = true,
			line_length = 8,
			frame_count = 32,
			animation_speed = 0.25,
			width = 38,
			height = 50,
			shift = util.by_pixel(6, -11),
			scale = 0.5,
		},
		south = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png",
			apply_runtime_tint = true,
			line_length = 8,
			frame_count = 32,
			animation_speed = 0.25,
			width = 36,
			height = 14,
			shift = util.by_pixel(-1, -4),
			scale = 0.5,
		},
		west = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png",
			apply_runtime_tint = true,
			line_length = 8,
			frame_count = 32,
			animation_speed = 0.25,
			width = 36,
			height = 50,
			shift = util.by_pixel(-7, -11),
			scale = 0.5,
		},
	}

	if direction then
		return fluid_animation[direction]
	else
		return fluid_animation
	end
end

local function return_glass_pictures(direction)
	local glass_pictures = {
		north = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png",
			width = 36,
			height = 40,
			shift = util.by_pixel(-2, -22),
			scale = 0.5,
		},
		east = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png",
			width = 30,
			height = 32,
			shift = util.by_pixel(5, -13),
			scale = 0.5,
		},
		south = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png",
			width = 40,
			height = 24,
			shift = util.by_pixel(-1, -6),
			scale = 0.5,
		},
		west = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png",
			width = 30,
			height = 32,
			shift = util.by_pixel(-6, -14),
			scale = 0.5,
		},
	}

	if direction then
		return glass_pictures[direction]
	else
		return glass_pictures
	end
end

local function return_base_pictures(direction)
	local base_pictures = {
		north = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png",
			width = 114,
			height = 106,
			shift = util.by_pixel(-1, -5),
			scale = 0.5,
		},
		east = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png",
			width = 106,
			height = 60,
			shift = util.by_pixel(4, 13),
			scale = 0.5,
		},
		south = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png",
			width = 110,
			height = 108,
			shift = util.by_pixel(-2, 6),
			scale = 0.5,
		},
		west = {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png",
			width = 108,
			height = 64,
			shift = util.by_pixel(-6, 12),
			scale = 0.5,
		},
	}

	if direction then
		return base_pictures[direction]
	else
		return base_pictures
	end
end

local function return_underwater_pictures(direction, use_alternate)
	local filepath = use_alternate and "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/underwater/" or "__base__/graphics/entity/offshore-pump/"
	local adjusted_alpha = use_alternate and { 1, 1, 1, 0.5 } or nil

	local underwater_pictures = {
		north = {
			filename = filepath .. "hr-offshore-pump_North-underwater.png",
			width = 98,
			height = 36,
			shift = util.by_pixel(-1, -32),
			tint = adjusted_alpha,
			scale = 0.5,
		},
		east = {
			filename = filepath .. "hr-offshore-pump_East-underwater.png",
			width = 40,
			height = 72,
			shift = util.by_pixel(39, 17),
			tint = adjusted_alpha,
			scale = 0.5,
		},
		south = {
			filename = filepath .. "hr-offshore-pump_South-underwater.png",
			width = 98,
			height = 48,
			shift = util.by_pixel(-1, 49),
			tint = adjusted_alpha,
			scale = 0.5,
		},
		west = {
			filename = filepath .. "hr-offshore-pump_West-underwater.png",
			width = 40,
			height = 72,
			shift = util.by_pixel(-40, 17),
			tint = adjusted_alpha,
			scale = 0.5,
		},
	}

	if direction then
		return underwater_pictures[direction]
	else
		return underwater_pictures
	end
end

-- Patch water recipe with appropriate tint for apply_recipe_tint parameter
data.raw.recipe["water-offshore"].crafting_machine_tint = {
	primary = { r = 0, g = 0.34, b = 0.6 },
}

-- Reskin entities
for name, map in pairs(tier_map) do
	local entities = {
		pump_placeholder = {
			name = name .. "-placeholder",
			entity = data.raw["offshore-pump"][name .. "-placeholder"],
			type = "offshore-pump",
		},
		pump_assembly = {
			name = name,
			entity = data.raw["assembling-machine"][name],
			type = "assembling-machine",
		},
		pump_offshore = {
			name = name,
			entity = data.raw["offshore-pump"][name],
			type = "offshore-pump",
		},
	}

	for _, properties in pairs(entities) do
		local entity = properties.entity

		-- Check if entity exists, if not, skip this iteration
		if not entity then
			goto continue
		end

		local tier = reskins.lib.tiers.get_tier(map)
		inputs.tint = reskins.lib.tiers.get_tint(tier)
		inputs.type = properties.type

		reskins.lib.setup_standard_entity(properties.name, tier, inputs)

		-- Reskin remnants
		local remnant = data.raw["corpse"][properties.name .. "-remnants"]

		remnant.animation = {
			-- Variation 1
			-- Complaining about missing field direction_count, which is not required if using layers and variations...
			---@diagnostic disable-next-line: missing-fields
			{
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/offshore-pump/remnants/offshore-pump-remnants-variation-1.png",
						width = 146,
						height = 140,
						direction_count = 4,
						shift = util.by_pixel(2, -2.5),
						scale = 0.5,
					},
					-- Mask
					{
						filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/remnants/offshore-pump-remnants-variation-1-mask.png",
						width = 146,
						height = 140,
						direction_count = 4,
						shift = util.by_pixel(2, -2.5),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/remnants/offshore-pump-remnants-variation-1-highlights.png",
						width = 146,
						height = 140,
						direction_count = 4,
						shift = util.by_pixel(2, -2.5),
						blend_mode = reskins.lib.settings.blend_mode,
						scale = 0.5,
					},
				},
			},
			-- Variation 2
			-- Complaining about missing field direction_count, which is not required if using layers and variations...
			---@diagnostic disable-next-line: missing-fields
			{
				layers = {
					-- Base
					{
						filename = "__base__/graphics/entity/offshore-pump/remnants/offshore-pump-remnants-variation-2.png",
						width = 136,
						height = 134,
						direction_count = 4,
						shift = util.by_pixel(1.5, 0.5),
						scale = 0.5,
					},
					-- Mask
					{
						filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/remnants/offshore-pump-remnants-variation-2-mask.png",
						width = 136,
						height = 134,
						direction_count = 4,
						shift = util.by_pixel(1.5, 0.5),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-compatibility__/graphics/entity/p-u-m-p-s/offshore-pump/remnants/offshore-pump-remnants-variation-2-highlights.png",
						width = 136,
						height = 134,
						direction_count = 4,
						shift = util.by_pixel(1.5, 0.5),
						blend_mode = reskins.lib.settings.blend_mode,
						scale = 0.5,
					},
				},
			},
		}

		-- Reskin entities
		if inputs.type == "offshore-pump" then
			---@cast entity data.OffshorePumpPrototype
			entity.graphics_set = {
				underwater_layer_offset = 30,
				base_render_layer = "ground-patch",
				animation = return_animation(inputs.tint),
				fluid_animation = return_fluid_animation(),
				glass_pictures = return_glass_pictures(),
				base_pictures = return_base_pictures(),
				underwater_pictures = return_underwater_pictures(),
			}
		else
			---@cast entity data.AssemblingMachinePrototype
			entity.graphics_set.animation = return_animation(inputs.tint)
			entity.graphics_set.working_visualisations = {
				-- Underwater pictures
				{
					always_draw = true,
					render_layer = "decorative",
					north_animation = return_underwater_pictures("north", true),
					east_animation = return_underwater_pictures("east", true),
					south_animation = return_underwater_pictures("south", true),
					west_animation = return_underwater_pictures("west", true),
				},

				-- Base pictures
				{
					always_draw = true,
					render_layer = "ground-patch",
					north_animation = return_base_pictures("north"),
					east_animation = return_base_pictures("east"),
					south_animation = return_base_pictures("south"),
					west_animation = return_base_pictures("west"),
				},

				-- Glass pictures
				{
					always_draw = true,
					render_layer = "object",
					secondary_draw_order = 40,
					north_animation = return_glass_pictures("north"),
					east_animation = return_glass_pictures("east"),
					south_animation = return_glass_pictures("south"),
					west_animation = return_glass_pictures("west"),
				},

				-- Fluid animation
				{
					always_draw = true,
					render_layer = "object",
					secondary_draw_order = 20,
					apply_recipe_tint = "primary",
					north_animation = return_fluid_animation("north"),
					east_animation = return_fluid_animation("east"),
					south_animation = return_fluid_animation("south"),
					west_animation = return_fluid_animation("west"),
				},
			}
		end

		-- Label to skip to next iteration
		::continue::
	end
end
