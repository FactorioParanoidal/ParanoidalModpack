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
	icon_name = "ore-refinery",
	base_entity_name = "oil-refinery",
	mod = "angels",
	particles = { ["big-tint"] = 5, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-ore-refinery"] = { tier = 1, prog_tier = 4 },
	["angels-ore-refinery-2"] = { tier = 2, prog_tier = 5 },

	-- Extended Angels
	["angels-ore-refinery-3"] = { tier = 3, prog_tier = 6 },
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
				filename = "__angelsrefininggraphics__/graphics/entity/ore-refinery/ore-refinery-base.png",
				priority = "extra-high",
				width = 440,
				height = 509,
				shift = util.by_pixel(0.5, -16),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/refining/ore-refinery/ore-refinery-mask.png",
				priority = "extra-high",
				width = 440,
				height = 509,
				shift = util.by_pixel(0.5, -16),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/refining/ore-refinery/ore-refinery-highlights.png",
				priority = "extra-high",
				width = 440,
				height = 509,
				shift = util.by_pixel(0.5, -16),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow

			{
				filename = "__angelsrefininggraphics__/graphics/entity/ore-refinery/ore-refinery-shadow.png",
				priority = "extra-high",
				width = 522,
				height = 340,
				shift = util.by_pixel(21.5, 29),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
