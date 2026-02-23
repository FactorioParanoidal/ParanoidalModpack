-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "blast-furnace",
	base_entity_name = "oil-refinery",
	mod = "angels",
	particles = { ["big-tint"] = 5, ["medium"] = 2 },
	group = "smelting",
	make_remnants = false,
}

local tier_map = {
	["angels-blast-furnace"] = { tier = 1 },
	["angels-blast-furnace-2"] = { tier = 2 },
	["angels-blast-furnace-3"] = { tier = 3 },
	["angels-blast-furnace-4"] = { tier = 4 },
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
				filename = "__angelssmeltinggraphics__/graphics/entity/blast-furnace/blast-furnace-base.png",
				priority = "extra-high",
				width = 328,
				height = 376,
				shift = util.by_pixel(0, -13.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/smelting/blast-furnace/blast-furnace-mask.png",
				priority = "extra-high",
				width = 328,
				height = 376,
				shift = util.by_pixel(0, -13.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/smelting/blast-furnace/blast-furnace-highlights.png",
				priority = "extra-high",
				width = 328,
				height = 376,
				shift = util.by_pixel(0, -13.5),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__angelssmeltinggraphics__/graphics/entity/blast-furnace/blast-furnace-shadow.png",
				priority = "extra-high",
				width = 445,
				height = 245,
				shift = util.by_pixel(29, 19.5),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	-- Handle ambient-light
	entity.energy_source.light_flicker = {
		color = { 0, 0, 0 },
		minimum_light_size = 0,
		light_intensity_to_size_coefficient = 0,
	}

	::continue::
end
