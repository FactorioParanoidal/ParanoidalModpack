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
	icon_name = "filtration-unit",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-filtration-unit"] = { tier = 1, prog_tier = 2 },
	["angels-filtration-unit-2"] = { tier = 2, prog_tier = 3 },
	["angels-filtration-unit-3"] = { tier = 3, prog_tier = 4 },

	-- Extended Angels
	["angels-filtration-unit-4"] = { tier = 4, prog_tier = 5 },
}

-- Sea Block compatibility
if mods["SeaBlock"] then
	tier_map["angels-filtration-unit"].prog_tier = 1
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

	-- Reskin entities
	entity.graphics_set.animation = {
		layers = {
			-- Base
			{
				filename = "__angelsrefininggraphics__/graphics/entity/filtration-unit/filtration-unit.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				shift = { 0, -0.2 },
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/refining/filtration-unit/filtration-unit-mask.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				shift = { 0, -0.2 },
				tint = inputs.tint,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/refining/filtration-unit/filtration-unit-highlights.png",
				priority = "extra-high",
				width = 224,
				height = 224,
				shift = { 0, -0.2 },
				blend_mode = reskins.lib.settings.blend_mode,
			},
		},
	}

	::continue::
end
