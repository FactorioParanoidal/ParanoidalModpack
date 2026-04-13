-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "electrolyser",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "petrochem",
	make_remnants = false,
}

local tier_map = {
	["angels-electrolyser"] = { tier = 1 },
	["angels-electrolyser-2"] = { tier = 2 },
	["angels-electrolyser-3"] = { tier = 3 },
	["angels-electrolyser-4"] = { tier = 4 },
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

	-- Setup shared layers
	local entity_mask = {
		filename = "__reskins-angels__/graphics/entity/petrochem/electrolyser/electrolyser-mask.png",
		priority = "extra-high",
		width = 224,
		height = 224,
		frame_count = 36,
		line_length = 6,
		shift = { 0, 0 },
		animation_speed = 0.5,
		tint = inputs.tint,
	}

	local entity_highlights = {
		filename = "__reskins-angels__/graphics/entity/petrochem/electrolyser/electrolyser-highlights.png",
		priority = "extra-high",
		width = 224,
		height = 224,
		frame_count = 36,
		line_length = 6,
		shift = { 0, 0 },
		animation_speed = 0.5,
		blend_mode = reskins.lib.settings.blend_mode,
	}

	local entity_horizontal_base = {
		filename = "__angelspetrochemgraphics__/graphics/entity/electrolyser/electrolyser-east.png",
		width = 224,
		height = 224,
		frame_count = 36,
		line_length = 6,
		shift = { 0, 0 },
		animation_speed = 0.5,
	}

	local entity_vertical_base = {
		filename = "__angelspetrochemgraphics__/graphics/entity/electrolyser/electrolyser-north.png",
		priority = "extra-high",
		width = 224,
		height = 224,
		frame_count = 36,
		line_length = 6,
		shift = { 0, 0 },
		animation_speed = 0.5,
	}

	-- Reskin entities
	entity.graphics_set.animation = {
		north = {
			layers = {
				entity_vertical_base,
				entity_mask,
				entity_highlights,
			},
		},
		east = {
			layers = {
				entity_horizontal_base,
				entity_mask,
				entity_highlights,
			},
		},
		south = {
			layers = {
				entity_vertical_base,
				entity_mask,
				entity_highlights,
			},
		},
		west = {
			layers = {
				entity_horizontal_base,
				entity_mask,
				entity_highlights,
			},
		},
	}

	::continue::
end
