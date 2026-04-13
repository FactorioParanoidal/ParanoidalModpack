-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "ore-flotation-cell",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-ore-floatation-cell"] = { tier = 1, prog_tier = 2 },
	["angels-ore-floatation-cell-2"] = { tier = 2, prog_tier = 3 },
	["angels-ore-floatation-cell-3"] = { tier = 3, prog_tier = 4 },

	-- Extended Angels
	["angels-ore-floatation-cell-4"] = { tier = 4, prog_tier = 5 },
}

local function return_pipe_overlay(direction)
	local animation = {
		filename = "__angelsrefininggraphics__/graphics/entity/ore-floatation-cell/ore-flotation-cell-pipe-cover-overlays.png",
		priority = "extra-high",
		width = 333,
		height = 363,
		x = direction * 333,
		shift = util.by_pixel_hr(-1, -1),
		scale = 0.5,
	}
	return animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = map.tint or reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	entity.graphics_set.working_visualisations = {
		-- Idle animation
		{
			always_draw = true,
			animation = {
				filename = "__angelsrefininggraphics__/graphics/entity/ore-floatation-cell/ore-flotation-cell-animation-idle.png",
				priority = "extra-high",
				width = 166,
				height = 117,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel_hr(62, 5),
				scale = 0.5,
			},
		},

		-- Animation
		{
			fadeout = true,
			animation = {
				filename = "__angelsrefininggraphics__/graphics/entity/ore-floatation-cell/ore-flotation-cell-animation-base.png",
				priority = "extra-high",
				width = 166,
				height = 117,
				frame_count = 64,
				line_length = 8,
				shift = util.by_pixel_hr(62, 5),
				scale = 0.5,
			},
		},

		-- Water recipe mask
		{
			fadeout = true,
			apply_recipe_tint = "primary",
			animation = {
				filename = "__angelsrefininggraphics__/graphics/entity/ore-floatation-cell/ore-flotation-cell-animation-water-tintable.png",
				priority = "extra-high",
				width = 166,
				height = 117,
				frame_count = 64,
				line_length = 8,
				shift = util.by_pixel_hr(62, 5),
				scale = 0.5,
			},
		},

		-- Froth recipe mask
		{
			fadeout = true,
			apply_recipe_tint = "secondary",
			animation = {
				filename = "__angelsrefininggraphics__/graphics/entity/ore-floatation-cell/ore-flotation-cell-animation-froth-tintable.png",
				priority = "extra-high",
				width = 166,
				height = 117,
				frame_count = 64,
				line_length = 8,
				shift = util.by_pixel_hr(62, 5),
				scale = 0.5,
			},
		},

		-- Color mask
		{
			always_draw = true,
			animation = {
				layers = {
					-- Mask
					{
						filename = "__reskins-angels__/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-mask.png",
						priority = "extra-high",
						width = 333,
						height = 363,
						shift = util.by_pixel_hr(-1, -1),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-angels__/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-highlights.png",
						priority = "extra-high",
						width = 333,
						height = 363,
						shift = util.by_pixel_hr(-1, -1),
						blend_mode = reskins.lib.settings.blend_mode,
						scale = 0.5,
					},
				},
			},
		},

		-- Pipe cover overlays
		{
			always_draw = true,
			render_layer = "higher-object-under",
			north_animation = return_pipe_overlay(0),
			east_animation = return_pipe_overlay(1),
			south_animation = return_pipe_overlay(0),
			west_animation = return_pipe_overlay(1),
		},

		-- Vertical Pipe Shadow Patch
		{
			always_draw = true,
			north_animation = reskins.lib.sprites.pipes.get_vertical_pipe_shadow({ 0, -2 }),
			south_animation = reskins.lib.sprites.pipes.get_vertical_pipe_shadow({ 0, -2 }),
		},
	}

	-- Clear out pipe_pictures
	entity.fluid_boxes[1].pipe_picture = nil
	entity.fluid_boxes[2].pipe_picture = nil

	-- Maybe fix animation speed shenanigans?
	entity.match_animation_speed_to_activity = false

	::continue::
end
