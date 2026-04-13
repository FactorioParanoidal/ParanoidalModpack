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
	icon_name = "casting-machine",
	base_entity_name = "chemical-plant",
	mod = "angels",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "smelting",
	make_remnants = false,
}

local tier_map = {
	["angels-casting-machine"] = { tier = 1 },
	["angels-casting-machine-2"] = { tier = 2 },
	["angels-casting-machine-3"] = { tier = 3 },
	["angels-casting-machine-4"] = { tier = 4 },
}

---@param is_flipped boolean?
---@return data.WorkingVisualisation
local function get_color_mask_working_visualisation(is_flipped)
	local flipped = is_flipped == true and "-flipped" or ""

	local working_vis = {
		always_draw = true,
		animation = {
			layers = {
				util.sprite_load("__reskins-angels__/graphics/entity/smelting/casting-machine/casting-machine-mask" .. flipped, {
					priority = "high",
					frame_count = 49,
					animation_speed = 0.5,
					tint = inputs.tint,
					scale = 0.5,
				}),
				util.sprite_load("__reskins-angels__/graphics/entity/smelting/casting-machine/casting-machine-highlights" .. flipped, {
					priority = "high",
					frame_count = 49,
					animation_speed = 0.5,
					blend_mode = reskins.lib.settings.blend_mode,
					scale = 0.5,
				}),
			},
		},
	}

	return working_vis
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

	if entity.graphics_set and entity.graphics_set.working_visualisations then
		table.insert(entity.graphics_set.working_visualisations, get_color_mask_working_visualisation())
	end

	if entity.graphics_set_flipped and entity.graphics_set_flipped.working_visualisations then
		table.insert(entity.graphics_set_flipped.working_visualisations, get_color_mask_working_visualisation(true))
	end

	::continue::
end
