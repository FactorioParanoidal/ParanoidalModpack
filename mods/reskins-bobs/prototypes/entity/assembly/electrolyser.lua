-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.electrolysers = true
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "electrolyser",
	base_entity_name = "chemical-plant",
	mod = "bobs",
	group = "assembly",
	particles = { ["big"] = 1, ["medium"] = 2 },
	make_remnants = false,
}

local tier_map = {
	["bob-electrolyser"] = { tier = 1, shadow_tier = 1 },
	["bob-electrolyser-2"] = { tier = 2, shadow_tier = 2 },
	["bob-electrolyser-3"] = { tier = 3, shadow_tier = 3 },
	["bob-electrolyser-4"] = { tier = 4, shadow_tier = 3 },
	["bob-electrolyser-5"] = { tier = 5, shadow_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Handle unique icons
	inputs.icon_base = "electrolyser-" .. tier
	inputs.icon_mask = inputs.icon_base
	inputs.icon_highlights = inputs.icon_base

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.graphics_set.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/electrolyser/electrolyser-" .. tier .. "-base.png",
				width = 272,
				height = 260,
				shift = util.by_pixel(17, 0),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/electrolyser/electrolyser-" .. tier .. "-mask.png",
				width = 272,
				height = 260,
				shift = util.by_pixel(17, 0),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/electrolyser/electrolyser-" .. tier .. "-highlights.png",
				width = 272,
				height = 260,
				shift = util.by_pixel(17, 0),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/electrolyser/electrolyser-" .. map.shadow_tier .. "-shadow.png",
				width = 272,
				height = 260,
				shift = util.by_pixel(17, 0),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	})

	entity.water_reflection = util.copy(data.raw["storage-tank"]["storage-tank"].water_reflection)

	::continue::
end
