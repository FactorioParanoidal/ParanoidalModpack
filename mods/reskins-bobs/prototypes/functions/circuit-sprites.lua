-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local circuit_names = {
	"basic-circuit-board",
	"basic-electronic-circuit-board",
	"electronic-circuit-board",
	"electronic-logic-board",
	"electronic-processing-board",
}

for tier, circuit_name in pairs(circuit_names) do
	---@type data.SpritePrototype
	local standard_sprite = {
		type = "sprite",
		filename = "__reskins-bobs__/graphics/icons/sprites/circuits/standard/" .. circuit_name .. ".png",
		flags = { "gui-icon" },
		size = 40,
		name = "ar-" .. circuit_name .. "-standard",
		mipmap_count = 2,
	}

	data:extend({ standard_sprite })

	-- Ensure tint has no alpha; circuit coloring does not support partial transparency.
	local tint = reskins.lib.tiers.get_tint(tier)
	local sanitized_tint = util.get_color_with_alpha(tint, 1)

	---@type data.SpritePrototype
	local colored_sprite = {
		type = "sprite",
		name = "ar-" .. circuit_name .. "-colored",
		layers = {
			{
				filename = "__reskins-bobs__/graphics/icons/sprites/circuits/colored/" .. circuit_name .. "/" .. circuit_name .. "-base.png",
				flags = { "gui-icon" },
				size = 40,
				tint = sanitized_tint,
				mipmap_count = 2,
			},
			{
				filename = "__reskins-bobs__/graphics/icons/sprites/circuits/colored/" .. circuit_name .. "/" .. circuit_name .. "-highlights.png",
				flags = { "gui-icon" },
				size = 40,
				blend_mode = "additive",
				mipmap_count = 2,
			},
			{
				filename = "__reskins-bobs__/graphics/icons/sprites/circuits/colored/" .. circuit_name .. "/" .. circuit_name .. "-traces.png",
				flags = { "gui-icon" },
				size = 40,
				mipmap_count = 2,
			},
		},
	}

	data:extend({ colored_sprite })
end
