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
	icon_name = "refugium-fish",
	base_entity_name = "assembling-machine-1",
	mod = "compatibility",
	particles = { ["big"] = 1, ["medium"] = 2 },
	group = "extendedangels",
	make_remnants = false,
}

local tier_map = {
	["angels-bio-refugium-fish"] = { tier = 1, prog_tier = 2 },
	["angels-bio-refugium-fish-2"] = { tier = 2, prog_tier = 3 },
	["angels-bio-refugium-fish-3"] = { tier = 3, prog_tier = 4 },
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
					filename = "__reskins-compatibility__/graphics/entity/extendedangels/refugium-fish/refugium-fish-mask.png",
					priority = "extra-high",
					width = 288,
					height = 288,
					shift = { 0, 0 },
					tint = inputs.tint,
				},
				-- Highlights
				{
					filename = "__reskins-compatibility__/graphics/entity/extendedangels/refugium-fish/refugium-fish-highlights.png",
					priority = "extra-high",
					width = 288,
					height = 288,
					shift = { 0, 0 },
					blend_mode = reskins.lib.settings.blend_mode,
				},
			},
		},
	})

	::continue::
end
