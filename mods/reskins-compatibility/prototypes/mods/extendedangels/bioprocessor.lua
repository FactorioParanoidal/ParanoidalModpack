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
	icon_name = "bioprocessor",
	base_entity_name = "assembling-machine-1",
	mod = "compatibility",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "extendedangels",
	make_remnants = false,
}

local tier_map = {
	["angels-bio-processor"] = { tier = 1 },
	["angels-bio-processor-2"] = { tier = 2 },
	["angels-bio-processor-3"] = { tier = 3 },
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
	table.insert(entity.graphics_set.working_visualisations, {
		always_draw = true,
		animation = {
			layers = {
				-- Mask
				{
					filename = "__reskins-compatibility__/graphics/entity/extendedangels/bioprocessor/bioprocessor-mask.png",
					priority = "extra-high",
					width = 224,
					height = 224,
					line_length = 5,
					frame_count = 25,
					shift = { 0, 0 },
					animation_speed = 0.5,
					tint = inputs.tint,
				},
				-- Highlights
				{
					filename = "__reskins-compatibility__/graphics/entity/extendedangels/bioprocessor/bioprocessor-highlights.png",
					priority = "extra-high",
					width = 224,
					height = 224,
					line_length = 5,
					frame_count = 25,
					shift = { 0, 0 },
					animation_speed = 0.5,
					blend_mode = reskins.lib.settings.blend_mode,
				},
			},
		},
	})

	::continue::
end
