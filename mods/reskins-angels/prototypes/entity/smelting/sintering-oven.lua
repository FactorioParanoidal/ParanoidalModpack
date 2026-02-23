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
	icon_name = "sintering-oven",
	base_entity_name = "oil-refinery",
	mod = "angels",
	particles = { ["big-tint"] = 5, ["medium"] = 2 },
	group = "smelting",
	make_remnants = false,
}

local tier_map
if angelsmods.trigger.early_sintering_oven then
	tier_map = {
		["angels-sintering-oven"] = { tier = 1, prog_tier = 1 },
		["angels-sintering-oven-2"] = { tier = 2, prog_tier = 2 },
		["angels-sintering-oven-3"] = { tier = 3, prog_tier = 3 },
		["angels-sintering-oven-4"] = { tier = 4, prog_tier = 4 },
		["angels-sintering-oven-5"] = { tier = 5, prog_tier = 5 },
	}
else
	tier_map = {
		["angels-sintering-oven-4"] = { tier = 1, prog_tier = 4, defer_to_data_updates = true },
		["angels-sintering-oven-5"] = { tier = 2, prog_tier = 5, defer_to_data_updates = true },
	}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.defer_to_data_updates = map.defer_to_data_updates
	inputs.tint = map.tint or reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.graphics_set.animation = {
		layers = {
			-- Base
			{
				filename = "__angelssmeltinggraphics__/graphics/entity/sintering-oven/sintering-oven-base.png",
				priority = "extra-high",
				width = 326,
				height = 350,
				shift = util.by_pixel(-1, -6.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/smelting/sintering-oven/sintering-oven-mask.png",
				priority = "extra-high",
				width = 326,
				height = 350,
				shift = util.by_pixel(-1, -6.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-angels__/graphics/entity/smelting/sintering-oven/sintering-oven-highlights.png",
				priority = "extra-high",
				width = 326,
				height = 350,
				shift = util.by_pixel(-1, -6.5),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__angelssmeltinggraphics__/graphics/entity/sintering-oven/sintering-oven-shadow.png",
				priority = "extra-high",
				width = 424,
				height = 227,
				shift = util.by_pixel(23, 28),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
