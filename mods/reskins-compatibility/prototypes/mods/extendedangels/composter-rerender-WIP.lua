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
	type = "furnace",
	icon_name = "composter",
	base_entity_name = "assembling-machine-1",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "bioprocessing",
	make_remnants = false,
}

local tier_map = {
	["angels-composter"] = { tier = 1 },
	["angels-composter-2"] = { tier = 2 },
	["angels-composter-3"] = { tier = 3 },
}

local function composter_base()
	return {
		filename = "__reskins-angels__/graphics/entity/bioprocessing/composter/composter-base.png",
		priority = "extra-high",
		width = 234,
		height = 252,
		shift = util.by_pixel(0, 0),
		scale = 0.5,
	}
end

local function composter_mask(tint)
	return {
		filename = "__reskins-angels__/graphics/entity/bioprocessing/composter/composter-mask.png",
		priority = "extra-high",
		width = 234,
		height = 252,
		shift = util.by_pixel(0, 0),
		tint = tint,
		scale = 0.5,
	}
end

local function composter_highlights()
	return {
		filename = "__reskins-angels__/graphics/entity/bioprocessing/composter/composter-highlights.png",
		priority = "extra-high",
		width = 234,
		height = 252,
		shift = util.by_pixel(0, 0),
		blend_mode = reskins.lib.settings.blend_mode,
		scale = 0.5,
	}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.FurnacePrototype
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
			composter_base(),
			composter_mask(inputs.tint),
			composter_highlights(),
		},
	}

	entity.graphics_set.idle_animation = {
		layers = {
			composter_base(),
			composter_mask(inputs.tint),
			composter_highlights(),
			-- Idle outputs
			{
				filename = "__reskins-angels__/graphics/entity/bioprocessing/composter/composter-idle.png",
				priority = "extra-high",
				width = 222,
				height = 79,
				shift = util.by_pixel(0, 0),
				scale = 0.5,
			},
		},
	}

	entity.graphics_set.working_visualisations = {
		-- Animation
		{
			animation = {
				filename = "__reskins-angels__/graphics/entity/bioprocessing/composter/composter-animation.png",
				priority = "extra-high",
				width = 222,
				height = 79,
				frame_count = 25,
				line_length = 5,
				shift = util.by_pixel(0, 0),
				scale = 0.5,
			},
		},

		-- Shadow
		{
			always_draw = true,
			animation = {
				filename = "__reskins-angels__/graphics/entity/bioprocessing/composter/composter-shadow.png",
				priority = "extra-high",
				width = 287,
				height = 165,
				shift = util.by_pixel(0, 0),
				-- draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
