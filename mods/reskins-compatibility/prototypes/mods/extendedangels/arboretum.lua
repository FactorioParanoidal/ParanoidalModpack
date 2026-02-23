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
	icon_name = "arboretum",
	base_entity_name = "assembling-machine-1",
	mod = "compatibility",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "extendedangels",
	make_remnants = false,
}

local tier_map = {
	["angels-bio-arboretum-1"] = { tier = 1 },
	["angels-bio-arboretum-2"] = { tier = 2 },
	["angels-bio-arboretum-3"] = { tier = 3 },
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
			-- Shadow
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-arboretum-shadow.png",
				width = 224,
				height = 256,
				shift = { 0, -0.50 },
			},
			-- Base
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-arboretum-base.png",
				width = 224,
				height = 256,
				shift = { 0, -0.50 },
			},
			-- Mask
			{
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/arboretum/arboretum-mask.png",
				priority = "extra-high",
				width = 224,
				height = 256,
				shift = { 0, -0.5 },
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-compatibility__/graphics/entity/extendedangels/arboretum/arboretum-highlights.png",
				priority = "extra-high",
				width = 224,
				height = 256,
				shift = { 0, -0.5 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
			-- Pipes
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-arboretum-pipes.png",
				width = 224,
				height = 256,
				shift = { 0, -0.50 },
			},
			-- Off
			{
				filename = "__angelsbioprocessinggraphics__/graphics/entity/trees/bio-arboretum-off.png",
				width = 224,
				height = 256,
				shift = { 0, -0.50 },
			},
		},
	}

	::continue::
end
