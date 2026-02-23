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
	type = "beam",
}

local beam_map = {
	["bob-laser-beam-glass"] = "glass",
	["bob-laser-beam-sapphire"] = "sapphire",
	["bob-laser-beam-emerald"] = "emerald",
	["bob-laser-beam-amethyst"] = "amethyst",
	["bob-laser-beam-topaz"] = "topaz",
	["bob-laser-beam-diamond"] = "diamond",
	["bob-laser-beam-glass-ammo"] = "glass",
	["bob-laser-beam-ruby-ammo"] = "ruby",
	["bob-laser-beam-sapphire-ammo"] = "sapphire",
	["bob-laser-beam-emerald-ammo"] = "emerald",
	["bob-laser-beam-amethyst-ammo"] = "amethyst",
	["bob-laser-beam-topaz-ammo"] = "topaz",
	["bob-laser-beam-diamond-ammo"] = "diamond",
}

local light_tint_map = {
	["glass"] = util.color("#4F4F4F"),
	["ruby"] = util.color("#800223"),
	["emerald"] = util.color("#0D802A"),
	["sapphire"] = util.color("#023B80"),
	["topaz"] = util.color("#80590D"),
	["amethyst"] = util.color("#1E0D80"),
	["diamond"] = util.color("#F9F9F9"),
}

local laser_beam_blend_mode = "additive"

for name, lens in pairs(beam_map) do
	---@type data.BeamPrototype
	local beam = data.raw[inputs.type][name]

	-- Check if beam exists, if not, skip this iteration
	if not beam then
		goto continue
	end

	beam.graphics_set = {
		beam = {
			head = {
				layers = {
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/beam/" .. lens .. "/" .. lens .. "-laser-body.png",
						flags = beam_non_light_flags,
						line_length = 8,
						width = 64,
						height = 12,
						frame_count = 8,
						scale = 0.5,
						animation_speed = 0.5,
						blend_mode = laser_beam_blend_mode,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/beam/base/laser-body-light.png",
						draw_as_light = true,
						flags = { "light" },
						line_length = 8,
						width = 64,
						height = 12,
						frame_count = 8,
						scale = 0.5,
						animation_speed = 0.5,
					},
				},
			},
			tail = {
				layers = {
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/beam/" .. lens .. "/" .. lens .. "-laser-end.png",
						flags = beam_non_light_flags,
						width = 110,
						height = 62,
						frame_count = 8,
						shift = util.by_pixel(11.5, 1),
						scale = 0.5,
						animation_speed = 0.5,
						blend_mode = laser_beam_blend_mode,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/beam/base/laser-end-light.png",
						draw_as_light = true,
						flags = { "light" },
						width = 110,
						height = 62,
						frame_count = 8,
						shift = util.by_pixel(11.5, 1),
						scale = 0.5,
						animation_speed = 0.5,
					},
				},
			},
			body = {
				layers = {
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/beam/" .. lens .. "/" .. lens .. "-laser-body.png",
						flags = beam_non_light_flags,
						line_length = 8,
						width = 64,
						height = 12,
						frame_count = 8,
						scale = 0.5,
						animation_speed = 0.5,
						blend_mode = laser_beam_blend_mode,
					},
					{
						filename = "__reskins-bobs__/graphics/entity/warfare/beam/base/laser-body-light.png",
						draw_as_light = true,
						flags = { "light" },
						line_length = 8,
						width = 64,
						height = 12,
						frame_count = 8,
						scale = 0.5,
						animation_speed = 0.5,
					},
				},
			},
		},
		ground = {
			head = {
				filename = "__reskins-bobs__/graphics/entity/warfare/beam/base/laser-ground-light-head.png",
				draw_as_light = true,
				flags = { "light" },
				width = 256,
				height = 256,
				repeat_count = 8,
				scale = 0.5,
				shift = util.by_pixel(-32, 0),
				animation_speed = 0.5,
				tint = light_tint_map[lens],
			},
			tail = {
				filename = "__reskins-bobs__/graphics/entity/warfare/beam/base/laser-ground-light-tail.png",
				draw_as_light = true,
				flags = { "light" },
				width = 256,
				height = 256,
				repeat_count = 8,
				scale = 0.5,
				shift = util.by_pixel(32, 0),
				animation_speed = 0.5,
				tint = light_tint_map[lens],
			},
			body = {
				filename = "__reskins-bobs__/graphics/entity/warfare/beam/base/laser-ground-light-body.png",
				draw_as_light = true,
				flags = { "light" },
				width = 64,
				height = 256,
				repeat_count = 8,
				scale = 0.5,
				animation_speed = 0.5,
				tint = light_tint_map[lens],
			},
		},
	}

	::continue::
end
