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
	icon_name = "strand-casting-machine",
	base_entity_name = "oil-refinery",
	mod = "angels",
	particles = { ["big-tint"] = 5, ["medium"] = 2 },
	group = "smelting",
	make_remnants = false,
}

local tier_map = {
	["angels-strand-casting-machine"] = { tier = 1, prog_tier = 2 },
	["angels-strand-casting-machine-2"] = { tier = 2, prog_tier = 3 },
	["angels-strand-casting-machine-3"] = { tier = 3, prog_tier = 4 },
	["angels-strand-casting-machine-4"] = { tier = 4, prog_tier = 5 },
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
	entity.graphics_set.animation = nil

	table.insert(
		entity.graphics_set.working_visualisations,
		#entity.graphics_set.working_visualisations - 1,
		-- Color Mask
		{
			always_draw = true,
			animation = {
				layers = {
					-- Mask
					{
						filename = "__reskins-angels__/graphics/entity/smelting/strand-casting-machine/strand-casting-machine-mask.png",
						priority = "extra-high",
						width = 329,
						height = 392,
						shift = util.by_pixel(0, -16.5),
						tint = inputs.tint,
						scale = 0.5,
					},
					-- Highlights
					{
						filename = "__reskins-angels__/graphics/entity/smelting/strand-casting-machine/strand-casting-machine-highlights.png",
						priority = "extra-high",
						width = 329,
						height = 392,
						shift = util.by_pixel(0, -16.5),
						blend_mode = reskins.lib.settings.blend_mode,
						scale = 0.5,
					},
				},
			},
		}
	)

	::continue::
end
