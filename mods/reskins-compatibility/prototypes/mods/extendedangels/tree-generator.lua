-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then
	return
end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	base_entity_name = "assembling-machine-1",
	mod = "compatibility",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "extendedangels",
	make_remnants = false,
}

local tier_map = {
	["angels-bio-generator-temperate-1"] = { tier = 1, field = "temperate" },
	["angels-bio-generator-temperate-2"] = { tier = 2, field = "temperate" },
	["angels-bio-generator-temperate-3"] = { tier = 3, field = "temperate" },
	["angels-bio-generator-swamp-1"] = { tier = 1, field = "swamp" },
	["angels-bio-generator-swamp-2"] = { tier = 2, field = "swamp" },
	["angels-bio-generator-swamp-3"] = { tier = 3, field = "swamp" },
	["angels-bio-generator-desert-1"] = { tier = 1, field = "desert" },
	["angels-bio-generator-desert-2"] = { tier = 2, field = "desert" },
	["angels-bio-generator-desert-3"] = { tier = 3, field = "desert" },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)

	-- Setup icon_name
	inputs.icon_name = "tree-generator-" .. map.field
	inputs.tint = map.tint or reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.graphics_set.animation = {
		layers = {
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-generator-shadow.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-generator-base.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
			{
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/tree-generator/tree-generator-mask.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				tint = inputs.tint,
			},
			{
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/tree-generator/tree-generator-highlights.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-generator-pipes.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-generator-1.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-generator-top.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
			},
		},
	}

	entity.graphics_set.working_visualisations = {
		{
			fadeout = true,
			animation = {
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-generator-top-on.png",
				priority = "extra-high",
				width = 160,
				height = 160,
				shift = { 0, 0 },
				draw_as_glow = true,
			},
			light = { intensity = 4, size = 4, color = { r = 0.5, g = 1.0, b = 0.5 } },
		},
	}

	::continue::
end
