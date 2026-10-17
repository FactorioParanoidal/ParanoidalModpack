-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["semi-classic-mining-drill"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.mining.entities) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.miners = true
end

-- Set input parameters
local inputs = {
	type = "mining-drill",
	icon_name = "electric-mining-drill",
	base_entity_name = "electric-mining-drill",
	mod = "compatibility",
	group = "semi-classic-mining-drill",
	particles = { ["medium-long"] = 3 },
}

local tier_map = {
	["electric-mining-drill"] = { tier = 1 },
	["bob-mining-drill-1"] = { tier = 2 },
	["bob-mining-drill-2"] = { tier = 3 },
	["bob-mining-drill-3"] = { tier = 4 },
	["bob-mining-drill-4"] = { tier = 5 },
	["bob-area-mining-drill-1"] = { tier = 1, prog_tier = 2 },
	["bob-area-mining-drill-2"] = { tier = 2, prog_tier = 3 },
	["bob-area-mining-drill-3"] = { tier = 3, prog_tier = 4 },
	["bob-area-mining-drill-4"] = { tier = 4, prog_tier = 5 },
}

-- Setup local functions for reskinning the mining drill animation
local function vertical_drill_animation(speed, inputs)
	return {
		layers = {
			-- Base
			{
				priority = "high",
				filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill.png",
				line_length = 6,
				width = 194,
				height = 154,
				frame_count = 30,
				animation_speed = speed,
				frame_sequence = reskins.bobs.electric_drill_animation_sequence,
				shift = util.by_pixel(0, -21),
				scale = 0.5,
			},
			-- Mask
			{
				priority = "high",
				filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-mask.png",
				line_length = 6,
				width = 194,
				height = 154,
				frame_count = 30,
				animation_speed = speed,
				frame_sequence = reskins.bobs.electric_drill_animation_sequence,
				shift = util.by_pixel(0, -21),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				priority = "high",
				filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-highlights.png",
				line_length = 6,
				width = 194,
				height = 154,
				frame_count = 30,
				animation_speed = speed,
				frame_sequence = reskins.bobs.electric_drill_animation_sequence,
				shift = util.by_pixel(0, -21),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				priority = "high",
				filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-shadow.png",
				line_length = 7,
				width = 232,
				height = 50,
				frame_count = 21,
				animation_speed = speed,
				frame_sequence = reskins.bobs.electric_drill_animation_shadow_sequence,
				draw_as_shadow = true,
				shift = util.by_pixel(49, 7),
				scale = 0.5,
			},
		},
	}
end

local function horizontal_drill_animation(speed, inputs, is_front)
	local function horizontal_drill_shadow(speed)
		return {
			priority = "high",
			filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal-shadow.png",
			line_length = 7,
			width = 236,
			height = 138,
			frame_count = 21,
			animation_speed = speed,
			frame_sequence = reskins.bobs.electric_drill_animation_shadow_sequence,
			draw_as_shadow = true,
			shift = util.by_pixel(48, 5),
			scale = 0.5,
		}
	end

	local drill_animation
	if is_front then
		-- Front horizontal animation
		drill_animation = {
			layers = {
				-- Base
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal-front.png",
					line_length = 6,
					width = 54,
					height = 136,
					frame_count = 30,
					animation_speed = speed,
					frame_sequence = reskins.bobs.electric_drill_animation_sequence,
					shift = util.by_pixel(14, -23),
					scale = 0.5,
				},
				-- Mask
				{
					priority = "high",
					filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-front-mask.png",
					line_length = 6,
					width = 54,
					height = 136,
					frame_count = 30,
					animation_speed = speed,
					frame_sequence = reskins.bobs.electric_drill_animation_sequence,
					shift = util.by_pixel(14, -23),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					priority = "high",
					filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-front-highlights.png",
					line_length = 6,
					width = 54,
					height = 136,
					frame_count = 30,
					animation_speed = speed,
					frame_sequence = reskins.bobs.electric_drill_animation_sequence,
					shift = util.by_pixel(14, -23),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				horizontal_drill_shadow(speed),
			},
		}
	else
		-- Standard horizontal animation
		drill_animation = {
			layers = {
				-- Base
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal.png",
					line_length = 6,
					width = 104,
					height = 178,
					frame_count = 30,
					animation_speed = speed,
					frame_sequence = reskins.bobs.electric_drill_animation_sequence,
					shift = util.by_pixel(-3, -27),
					scale = 0.5,
				},
				-- Mask
				{
					priority = "high",
					filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-mask.png",
					line_length = 6,
					width = 104,
					height = 178,
					frame_count = 30,
					animation_speed = speed,
					frame_sequence = reskins.bobs.electric_drill_animation_sequence,
					shift = util.by_pixel(-3, -27),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					priority = "high",
					filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-highlights.png",
					line_length = 6,
					width = 104,
					height = 178,
					frame_count = 30,
					animation_speed = speed,
					frame_sequence = reskins.bobs.electric_drill_animation_sequence,
					shift = util.by_pixel(-3, -27),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				horizontal_drill_shadow(speed),
			},
		}
	end

	return drill_animation
end

-- Setup local functions for reskinning the frames
local function drill_dry_animation(speed, inputs)
	local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
	if inputs.is_area_drill then
		drill_type = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/area-frame"
	end

	return {
		north = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-N.png",
					width = 194,
					height = 242,
					animation_speed = speed,
					shift = util.by_pixel(0, -12),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Drill Output
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-N-output.png",
					line_length = 5,
					width = 72,
					height = 66,
					frame_count = 5,
					animation_speed = speed,
					shift = util.by_pixel(-1, -44),
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-shadow.png",
					width = 274,
					height = 206,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(19, -3),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
		east = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-E.png",
					width = 194,
					height = 94,
					animation_speed = speed,
					shift = util.by_pixel(0, -33),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Drill Output
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-output.png",
					line_length = 5,
					width = 50,
					height = 56,
					frame_count = 5,
					animation_speed = speed,
					shift = util.by_pixel(30, -11),
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-shadow.png",
					width = 276,
					height = 170,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(20, 6),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
		south = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-S.png",
					width = 194,
					height = 240,
					animation_speed = speed,
					shift = util.by_pixel(0, -7),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-shadow.png",
					width = 274,
					height = 204,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(19, 2),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
		west = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-W.png",
					width = 194,
					height = 94,
					animation_speed = speed,
					shift = util.by_pixel(0, -33),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Drill Output
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-output.png",
					line_length = 5,
					width = 50,
					height = 56,
					frame_count = 5,
					animation_speed = speed,
					shift = util.by_pixel(-31, -12),
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-shadow.png",
					width = 282,
					height = 170,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(15, 6),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
	}
end

local function drill_dry_working_visualisation(speed, inputs)
	local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
	if inputs.is_area_drill then
		drill_type = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/area-frame"
	end

	return {
		-- Dust Animation 1
		{
			constant_speed = true,
			synced_fadeout = true,
			align_to_waypoint = true,
			apply_tint = "resource-color",
			animation = reskins.bobs.electric_mining_drill_smoke(),
			north_position = { 0, 0.25 },
			east_position = { 0, 0 },
			south_position = { 0, 0.25 },
			west_position = { 0, 0 },
		},

		-- Directional Dust Animation 1
		{
			constant_speed = true,
			fadeout = true,
			apply_tint = "resource-color",
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-smoke.png",
						line_length = 5,
						width = 46,
						height = 58,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(1, -44),
						scale = 0.5,
					},
				},
			},
			east_animation = nil,
			south_animation = nil,
			west_animation = nil,
		},

		-- Drill Back Animation
		{
			animated_shift = true,
			always_draw = true,
			north_animation = vertical_drill_animation(speed, inputs),
			east_animation = horizontal_drill_animation(speed, inputs),
			south_animation = vertical_drill_animation(speed, inputs),
			west_animation = horizontal_drill_animation(speed, inputs),
		},

		-- Dust Animation 2
		{
			constant_speed = true,
			synced_fadeout = true,
			align_to_waypoint = true,
			apply_tint = "resource-color",
			animation = reskins.bobs.electric_mining_drill_smoke_front(),
			north_position = { 0, 0.25 },
			east_position = { 0, 0 },
			south_position = { 0, 0.25 },
			west_position = { 0, 0 },
		},

		-- Directional Dust Animation 2
		{
			constant_speed = true,
			fadeout = true,
			apply_tint = "resource-color",
			north_animation = nil,
			east_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-smoke.png",
						line_length = 5,
						width = 52,
						height = 56,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(25, -12),
						scale = 0.5,
					},
				},
			},
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-smoke.png",
						line_length = 5,
						width = 48,
						height = 36,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(-2, 20),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-smoke.png",
						line_length = 5,
						width = 46,
						height = 54,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(-25, -11),
						scale = 0.5,
					},
				},
			},
		},

		-- Front Frame
		{
			always_draw = true,
			north_animation = nil,
			east_animation = {
				priority = "high",
				filename = drill_type .. "/electric-mining-drill-E-front.png",
				width = 208,
				height = 186,
				animation_speed = speed,
				shift = util.by_pixel(3, 2),
				scale = 0.5,
			},
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = drill_type .. "/electric-mining-drill-S-output.png",
						line_length = 5,
						width = 82,
						height = 56,
						frame_count = 5,
						animation_speed = speed,
						shift = util.by_pixel(-1, 34),
						scale = 0.5,
					},
					{
						priority = "high",
						filename = drill_type .. "/electric-mining-drill-S-front.png",
						width = 172,
						height = 42,
						animation_speed = speed,
						repeat_count = 5,
						shift = util.by_pixel(0, 13),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				priority = "high",
				filename = drill_type .. "/electric-mining-drill-W-front.png",
				width = 210,
				height = 190,
				animation_speed = speed,
				shift = util.by_pixel(-4, 1),
				scale = 0.5,
			},
		},

		-- Drill Front Animation
		{
			animated_shift = true,
			always_draw = true,
			east_animation = horizontal_drill_animation(speed, inputs, true),
			west_animation = horizontal_drill_animation(speed, inputs, true),
		},

		-- LEDs
		electric_mining_drill_status_leds_working_visualisation(),

		-- Light
		{
			light = { intensity = 1, size = 2, color = { r = 1, g = 1, b = 1 } },
			north_position = { 1, -2.0 },
			east_position = { 1.5, -1.5 },
			south_position = { 1, 0.5 },
			west_position = { -1.5, -1.5 },
		},
	}
end

local function drill_wet_animation(speed, inputs)
	local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
	if inputs.is_area_drill then
		drill_type = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/area-frame"
	end

	return {
		north = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-N-wet.png",
					width = 194,
					height = 242,
					animation_speed = speed,
					shift = util.by_pixel(0, -12),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Drill Output
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-N-output.png",
					line_length = 5,
					width = 72,
					height = 66,
					frame_count = 5,
					animation_speed = speed,
					shift = util.by_pixel(-1, -44),
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-shadow.png",
					width = 276,
					height = 222,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(19, 1),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
		east = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet.png",
					width = 194,
					height = 94,
					animation_speed = speed,
					shift = util.by_pixel(0, -33),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Drill Output
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-output.png",
					line_length = 5,
					width = 50,
					height = 56,
					frame_count = 5,
					animation_speed = speed,
					shift = util.by_pixel(30, -11),
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-shadow.png",
					width = 276,
					height = 194,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(20, 8),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
		south = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-S-wet.png",
					width = 194,
					height = 240,
					animation_speed = speed,
					shift = util.by_pixel(0, -7),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-shadow.png",
					width = 276,
					height = 204,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(19, 2),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
		west = {
			layers = {
				-- Drill
				{
					priority = "high",
					filename = drill_type .. "/electric-mining-drill-W-wet.png",
					width = 194,
					height = 94,
					animation_speed = speed,
					shift = util.by_pixel(0, -33),
					repeat_count = 5,
					scale = 0.5,
				},
				-- Drill Output
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-output.png",
					line_length = 5,
					width = 50,
					height = 56,
					frame_count = 5,
					animation_speed = speed,
					shift = util.by_pixel(-31, -12),
					scale = 0.5,
				},
				-- Shadow
				{
					priority = "high",
					filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-shadow.png",
					width = 284,
					height = 194,
					animation_speed = speed,
					draw_as_shadow = true,
					shift = util.by_pixel(15, 8),
					repeat_count = 5,
					scale = 0.5,
				},
			},
		},
	}
end

local function drill_wet_working_visualisation(speed, inputs)
	local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
	if inputs.is_area_drill then
		drill_type = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/area-frame"
	end

	return {
		-- Dust Animation 1
		{
			constant_speed = true,
			synced_fadeout = true,
			align_to_waypoint = true,
			apply_tint = "resource-color",
			animation = reskins.bobs.electric_mining_drill_smoke(),
			north_position = { 0, 0.25 },
			east_position = { 0, 0 },
			south_position = { 0, 0.25 },
			west_position = { 0, 0 },
		},

		-- Directional Dust Animation 1
		{
			constant_speed = true,
			fadeout = true,
			apply_tint = "resource-color",
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-smoke.png",
						line_length = 5,
						width = 46,
						height = 58,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(1, -44),
						scale = 0.5,
					},
				},
			},
			east_animation = nil,
			south_animation = nil,
			west_animation = nil,
		},

		-- Drill Back Animation
		{
			animated_shift = true,
			always_draw = true,
			north_animation = vertical_drill_animation(speed, inputs),
			east_animation = horizontal_drill_animation(speed, inputs),
			south_animation = vertical_drill_animation(speed, inputs),
			west_animation = horizontal_drill_animation(speed, inputs),
		},

		-- Dust Animation 2
		{
			constant_speed = true,
			synced_fadeout = true,
			align_to_waypoint = true,
			apply_tint = "resource-color",
			animation = reskins.bobs.electric_mining_drill_smoke_front(),
			north_position = { 0, 0.25 },
			east_position = { 0, 0 },
			south_position = { 0, 0.25 },
			west_position = { 0, 0 },
		},

		-- Directional Dust Animation 2
		{
			constant_speed = true,
			fadeout = true,
			apply_tint = "resource-color",
			north_animation = nil,
			east_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-smoke.png",
						line_length = 5,
						width = 52,
						height = 56,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(25, -12),
						scale = 0.5,
					},
				},
			},
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-smoke.png",
						line_length = 5,
						width = 48,
						height = 36,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(-2, 20),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-smoke.png",
						line_length = 5,
						width = 46,
						height = 54,
						frame_count = 10,
						animation_speed = speed,
						shift = util.by_pixel(-25, -11),
						scale = 0.5,
					},
				},
			},
		},

		-- Fluid Window Background (Bottom)
		{
			secondary_draw_order = -49,
			always_draw = true,
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-window-background-front.png",
						width = 132,
						height = 28,
						animation_speed = speed,
						shift = util.by_pixel(-1, -18),
						scale = 0.5,
					},
				},
			},
			east_animation = nil,
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-window-background.png",
						width = 132,
						height = 88,
						animation_speed = speed,
						shift = util.by_pixel(-1, -33),
						scale = 0.5,
					},
				},
			},
			west_animation = nil,
		},

		-- Fluid Window Background (Front)
		{
			always_draw = true,
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-window-background.png",
						width = 30,
						height = 20,
						animation_speed = speed,
						shift = util.by_pixel(1, 21),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-window-background-front.png",
						width = 88,
						height = 86,
						animation_speed = speed,
						shift = util.by_pixel(11, 0),
						scale = 0.5,
					},
				},
			},
			south_animation = nil,
			east_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-window-background-front.png",
						width = 86,
						height = 86,
						animation_speed = speed,
						shift = util.by_pixel(-12, 0),
						scale = 0.5,
					},
				},
			},
		},
		-- Fluid Base (Bottom)
		{
			always_draw = true,
			secondary_draw_order = -48,
			apply_tint = "input-fluid-base-color",
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-background-front.png",
						width = 130,
						height = 36,
						animation_speed = speed,
						shift = util.by_pixel(0, -17),
						scale = 0.5,
					},
				},
			},
			east_animation = nil,
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-fluid-background.png",
						width = 130,
						height = 96,
						animation_speed = speed,
						shift = util.by_pixel(0, -32),
						scale = 0.5,
					},
				},
			},
			west_animation = nil,
		},

		-- Fluid Base (Front)
		{
			always_draw = true,
			apply_tint = "input-fluid-base-color",
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-background.png",
						width = 28,
						height = 22,
						animation_speed = speed,
						shift = util.by_pixel(2, 21),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-fluid-background-front.png",
						width = 82,
						height = 88,
						animation_speed = speed,
						shift = util.by_pixel(12, -1),
						scale = 0.5,
					},
				},
			},
			south_animation = nil,
			east_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-fluid-background-front.png",
						width = 82,
						height = 88,
						animation_speed = speed,
						shift = util.by_pixel(-12, -1),
						scale = 0.5,
					},
				},
			},
		},

		-- Fluid Flow (Bottom)
		{
			secondary_draw_order = -47,
			always_draw = true,
			apply_tint = "input-fluid-flow-color",
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-flow-front.png",
						width = 130,
						height = 28,
						animation_speed = speed,
						shift = util.by_pixel(-2, -17),
						scale = 0.5,
					},
				},
			},
			east_animation = nil,
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-fluid-flow.png",
						width = 130,
						height = 88,
						animation_speed = speed,
						shift = util.by_pixel(-2, -32),
						scale = 0.5,
					},
				},
			},
			west_animation = nil,
		},

		-- Fluid Flow (Front)
		{
			always_draw = true,
			apply_tint = "input-fluid-flow-color",
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-flow.png",
						width = 26,
						height = 20,
						animation_speed = speed,
						shift = util.by_pixel(2, 22),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-fluid-flow-front.png",
						width = 84,
						height = 86,
						animation_speed = speed,
						shift = util.by_pixel(11, 0),
						scale = 0.5,
					},
				},
			},
			south_animation = nil,
			east_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-fluid-flow-front.png",
						width = 82,
						height = 86,
						animation_speed = speed,
						shift = util.by_pixel(-12, 0),
						scale = 0.5,
					},
				},
			},
		},

		-- Front Frame (Wet)
		{
			always_draw = true,
			north_animation = {
				layers = {
					{
						priority = "high",
						filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-front.png",
						width = 162,
						height = 124,
						animation_speed = speed,
						shift = util.by_pixel(-2, 20),
						scale = 0.5,
					},
				},
			},
			west_animation = {
				layers = {
					{
						priority = "high",
						filename = drill_type .. "/electric-mining-drill-W-wet-front.png",
						width = 210,
						height = 190,
						animation_speed = speed,
						shift = util.by_pixel(-4, 1),
						scale = 0.5,
					},
				},
			},
			south_animation = {
				layers = {
					{
						priority = "high",
						filename = drill_type .. "/electric-mining-drill-S-output.png",
						line_length = 5,
						width = 82,
						height = 56,
						frame_count = 5,
						animation_speed = speed,
						shift = util.by_pixel(-1, 34),
						scale = 0.5,
					},
					{
						priority = "high",
						filename = drill_type .. "/electric-mining-drill-S-wet-front.png",
						width = 192,
						height = 70,
						animation_speed = speed,
						repeat_count = 5,
						shift = util.by_pixel(0, 19),
						scale = 0.5,
					},
				},
			},
			east_animation = {
				layers = {
					{
						priority = "high",
						filename = drill_type .. "/electric-mining-drill-E-wet-front.png",
						width = 208,
						height = 186,
						animation_speed = speed,
						shift = util.by_pixel(3, 2),
						scale = 0.5,
					},
				},
			},
		},

		-- Drill Front Animation
		{
			animated_shift = true,
			always_draw = true,
			east_animation = horizontal_drill_animation(speed, inputs, true),
			west_animation = horizontal_drill_animation(speed, inputs, true),
		},

		-- LEDs
		electric_mining_drill_status_leds_working_visualisation(),

		-- Light
		{
			light = { intensity = 1, size = 2, color = { r = 1, g = 1, b = 1 } },
			north_position = { 1, -2.0 },
			east_position = { 1.5, -1.5 },
			south_position = { 1, 0.5 },
			west_position = { -1.5, -1.5 },
		},
	}
end

-- Rescale mining drill animation playback speed to something visually appealing
local max_playback = 1.2 -- Maximum animation playback speed
local min_playback = 0.4 -- Minimum animation playback speed

local mining_speeds = {}
local index = 1

-- Loop through all the drills, figure out the mining speeds
for name, _ in pairs(tier_map) do
	---@type data.MiningDrillPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	-- Fetch mining speed
	mining_speeds[index] = data.raw[inputs.type][name].mining_speed
	index = index + 1

	::continue::
end

-- Determine max and min mining speeds
table.sort(mining_speeds)
local max_speed = mining_speeds[#mining_speeds]
local min_speed = mining_speeds[1]

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.MiningDrillPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)

	-- Handle icon base
	if string.find(name, "area") then
		inputs.icon_base = "large-area-electric-mining-drill"
		inputs.is_area_drill = true
		inputs.icon_extras = reskins.lib.icons.get_symbol("area-drill", reskins.lib.tiers.get_tint(tier))
	else
		inputs.icon_base = "electric-mining-drill"
		inputs.is_area_drill = false
		inputs.icon_extras = nil
	end

	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Calculate new animation playback speed
	local speed
	if max_speed - min_speed == 0 then
		speed = entity.mining_speed
	else
		speed = ((entity.mining_speed / (max_speed - min_speed)) - (min_speed / (max_speed - min_speed))) * max_playback + ((max_speed / (max_speed - min_speed)) - (entity.mining_speed / (max_speed - min_speed))) * min_playback
	end

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = make_rotated_animation_variations_from_sheet(4, {
		layers = {
			{
				filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/remnants/electric-mining-drill-remnants.png",
				width = 356,
				height = 328,
				direction_count = 1,
				shift = util.by_pixel(7, -0.5),
				scale = 0.5,
			},
			{
				filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/remnants/electric-mining-drill-remnants-mask.png",
				width = 356,
				height = 328,
				direction_count = 1,
				shift = util.by_pixel(7, -0.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			{
				filename = "__reskins-compatibility__/graphics/entity/semi-classic-mining-drill/electric-mining-drill/remnants/electric-mining-drill-remnants-highlights.png",
				width = 356,
				height = 328,
				direction_count = 1,
				shift = util.by_pixel(7, -0.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})

	-- Reskin entities
	entity.graphics_set.drilling_vertical_movement_duration = 10 / speed
	entity.graphics_set.animation = drill_dry_animation(speed, inputs)
	entity.graphics_set.shift_animation_waypoint_stop_duration = 195 / speed
	entity.graphics_set.shift_animation_transition_duration = 30 / speed
	entity.graphics_set.working_visualisations = drill_dry_working_visualisation(speed, inputs)

	entity.wet_mining_graphics_set.drilling_vertical_movement_duration = 10 / speed
	entity.wet_mining_graphics_set.animation = drill_wet_animation(speed, inputs)
	entity.wet_mining_graphics_set.shift_animation_waypoint_stop_duration = 195 / speed
	entity.wet_mining_graphics_set.shift_animation_transition_duration = 30 / speed
	entity.wet_mining_graphics_set.working_visualisations = drill_wet_working_visualisation(speed, inputs)

	::continue::
end
