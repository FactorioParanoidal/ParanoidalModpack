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
	icon_name = "crystallizer",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "refining",
	make_remnants = false,
}

local tier_map = {
	["angels-crystallizer"] = { tier = 1, prog_tier = 2 },
	["angels-crystallizer-2"] = { tier = 2, prog_tier = 3 },
	["angels-crystallizer-3"] = { tier = 3, prog_tier = 4 },

	-- Extended Angels
	["angels-crystallizer-4"] = { tier = 4, prog_tier = 5 },
}

-- Sea Block compatibility
if mods["SeaBlock"] then
	tier_map["angels-crystallizer"].prog_tier = 1
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
				filename = "__angelsrefininggraphics__/graphics/entity/crystallizer/crystallizer.png",
				priority = "extra-high",
				width = 390,
				height = 326,
				shift = util.by_pixel(16, 0),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/refining/crystallizer/crystallizer-mask.png",
				priority = "extra-high",
				width = 390,
				height = 326,
				shift = util.by_pixel(16, 0),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/refining/crystallizer/crystallizer-highlights.png",
				priority = "extra-high",
				width = 390,
				height = 326,
				shift = util.by_pixel(16, 0),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__angelsrefininggraphics__/graphics/entity/crystallizer/crystallizer-shadow.png",
				priority = "extra-high",
				width = 390,
				height = 326,
				shift = util.by_pixel(16, 0),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
