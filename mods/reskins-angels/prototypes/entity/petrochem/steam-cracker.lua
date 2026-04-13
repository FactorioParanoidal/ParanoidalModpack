-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "steam-cracker",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "petrochem",
	make_remnants = false,
}

local tier_map = {
	["angels-steam-cracker"] = { tier = 1, prog_tier = 2 },
	["angels-steam-cracker-2"] = { tier = 2, prog_tier = 3 },
	["angels-steam-cracker-3"] = { tier = 3, prog_tier = 4 },
	["angels-steam-cracker-4"] = { tier = 4, prog_tier = 5 },
}

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

	-- Reskin entities
	entity.graphics_set.animation = {
		layers = {
			-- Base
			{
				filename = "__angelspetrochemgraphics__/graphics/entity/steam-cracker/steam-cracker.png",
				priority = "extra-high",
				width = 512,
				height = 512,
				scale = 0.5,
				shift = { 0.5, -0.5 },
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/steam-cracker/steam-cracker-mask.png",
				priority = "extra-high",
				width = 512,
				height = 512,
				scale = 0.5,
				shift = { 0.5, -0.5 },
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/steam-cracker/steam-cracker-highlights.png",
				priority = "extra-high",
				width = 512,
				height = 512,
				scale = 0.5,
				shift = { 0.5, -0.5 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	entity.graphics_set.working_visualisations = {
		-- Flame
		{
			fadeout = true,
			constant_speed = true,
			animation = {
				filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
				line_length = 10,
				width = 40,
				height = 81,
				frame_count = 60,
				animation_speed = 0.75,
				shift = util.by_pixel(-66, -110),
				draw_as_glow = true,
				scale = 0.5,
			},
		},

		-- Light
		{
			animation = {
				filename = "__reskins-angels__/graphics/entity/petrochem/steam-cracker/steam-cracker-light.png",
				priority = "extra-high",
				width = 512,
				height = 512,
				scale = 0.5,
				shift = { 0.5, -0.5 },
				blend_mode = "additive-soft",
				draw_as_glow = true,
			},
		},
	}

	::continue::
end
