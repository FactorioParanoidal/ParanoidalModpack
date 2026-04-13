-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "artillery-wagon",
	icon_name = "artillery-wagon",
	base_entity_name = "artillery-wagon",
	mod = "bobs",
	group = "warfare",
	particles = { ["big"] = 4 },
}

local tier_map = {
	["artillery-wagon"] = { tier = 1, prog_tier = 3 },
	["bob-artillery-wagon-2"] = { tier = 2, prog_tier = 4 },
	["bob-artillery-wagon-3"] = { tier = 3, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.ArtilleryWagonPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- TODO: Reskin remnants?

	-- TODO: Reskin entity?

	::continue::
end
