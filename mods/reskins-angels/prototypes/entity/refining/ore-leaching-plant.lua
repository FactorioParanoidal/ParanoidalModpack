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
	icon_name = "ore-leaching-plant",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-ore-leaching-plant"] = { tier = 1, prog_tier = 3 },
	["angels-ore-leaching-plant-2"] = { tier = 2, prog_tier = 4 },
	["angels-ore-leaching-plant-3"] = { tier = 3, prog_tier = 5 },

	-- Extended Angels
	["angels-ore-leaching-plant-4"] = { tier = 4, prog_tier = 6 },
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
				filename = "__angelsrefininggraphics__/graphics/entity/ore-leaching-plant/1ore-leaching-plant.png",
				priority = "extra-high",
				width = 192,
				height = 192,
				shift = { 0.4, -0.14 },
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/refining/ore-leaching-plant/ore-leaching-plant-mask.png",
				priority = "extra-high",
				width = 192,
				height = 192,
				shift = { 0.4, -0.14 },
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/refining/ore-leaching-plant/ore-leaching-plant-highlights.png",
				priority = "extra-high",
				width = 192,
				height = 192,
				shift = { 0.4, -0.14 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
