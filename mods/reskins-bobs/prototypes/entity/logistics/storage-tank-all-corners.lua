-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "storage-tank",
	icon_name = "storage-tank-all-corners",
	base_entity_name = "storage-tank",
	mod = "bobs",
	group = "logistics",
	particles = { ["big"] = 1 },
}

local tier_map = {
	["bob-storage-tank-all-corners"] = { tier = 1, prog_tier = 2 },
	["bob-storage-tank-all-corners-2"] = { tier = 2, prog_tier = 3 },
	["bob-storage-tank-all-corners-3"] = { tier = 3, prog_tier = 4 },
	["bob-storage-tank-all-corners-4"] = { tier = 4, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.StorageTankPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant, handle dependency on storage-tanks
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/storage-tank/remnants/storage-tank-remnants.png",
				width = 426,
				height = 282,
				shift = util.by_pixel(27, 21),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/storage-tank/remnants/storage-tank-remnants-mask.png",
				width = 426,
				height = 282,
				shift = util.by_pixel(27, 21),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/storage-tank/remnants/storage-tank-remnants-highlights.png",
				width = 426,
				height = 282,
				shift = util.by_pixel(27, 21),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	-- Reskin entities
	entity.pictures = {
		picture = {
			sheets = {
				-- Base
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/storage-tank-all-corners/base/storage-tank-all-corners.png",
					priority = "extra-high",
					frames = 1,
					width = 219,
					height = 215,
					shift = util.by_pixel(-0.25, 3.75),
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/storage-tank-all-corners/storage-tank-all-corners-mask.png",
					priority = "extra-high",
					frames = 1,
					width = 219,
					height = 215,
					shift = util.by_pixel(-0.25, 3.75),
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/storage-tank-all-corners/storage-tank-all-corners-highlights.png",
					priority = "extra-high",
					frames = 1,
					width = 219,
					height = 215,
					shift = util.by_pixel(-0.25, 3.75),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__reskins-bobs__/graphics/entity/logistics/storage-tank-all-corners/base/storage-tank-all-corners-shadow.png",
					priority = "extra-high",
					frames = 1,
					width = 291,
					height = 153,
					shift = util.by_pixel(29.75, 22.25),
					scale = 0.5,
					draw_as_shadow = true,
				},
			},
		},
		fluid_background = {
			filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
			priority = "extra-high",
			width = 32,
			height = 15,
		},
		window_background = {
			filename = "__base__/graphics/entity/storage-tank/window-background.png",
			priority = "extra-high",
			width = 34,
			height = 48,
			scale = 0.5,
		},
		flow_sprite = {
			filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
			priority = "extra-high",
			width = 160,
			height = 20,
		},
		gas_flow = {
			filename = "__base__/graphics/entity/pipe/steam.png",
			priority = "extra-high",
			line_length = 10,
			width = 48,
			height = 30,
			frame_count = 60,
			animation_speed = 0.25,
			scale = 0.5,
		},
	}

	entity.water_reflection = util.copy(data.raw[inputs.type]["storage-tank"].water_reflection)

	::continue::
end
