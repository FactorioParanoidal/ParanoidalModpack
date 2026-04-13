-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end
if reskins.lib.settings.get_value("bobmods-logistics-trains") == false then
	return
end

-- Set input parameters
local inputs = {
	type = "locomotive",
	icon_name = "locomotive",
	base_entity_name = "locomotive",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["locomotive"] = { tier = 1, prog_tier = 2 },
	["bob-locomotive-2"] = { tier = 2, prog_tier = 3 },
	["bob-locomotive-3"] = { tier = 3, prog_tier = 4 },
	["bob-armoured-locomotive"] = { tier = 1, prog_tier = 4 },
	["bob-armoured-locomotive-2"] = { tier = 2, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.LocomotivePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Setup icon details
	if string.find(name, "armoured") then
		inputs.icon_extras = reskins.lib.icons.get_symbol("shield", inputs.tint)
	else
		inputs.icon_extras = nil
	end

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- TODO: Reskin remnants?

	-- TODO: Reskin entity?

	::continue::
end
