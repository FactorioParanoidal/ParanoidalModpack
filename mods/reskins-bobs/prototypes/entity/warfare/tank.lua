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
	type = "car",
	icon_name = "tank",
	base_entity_name = "tank",
	mod = "bobs",
	group = "warfare",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["tank"] = { tier = 1, prog_tier = 3 },
	["bob-tank-2"] = { tier = 2, prog_tier = 4 },
	["bob-tank-3"] = { tier = 3, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.CarPrototype
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
