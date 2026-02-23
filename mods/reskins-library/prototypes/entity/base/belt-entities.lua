-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then
	return
end

local reskin_vanilla_entity = reskins.lib.settings.get_value("reskins-lib-customize-tier-colors")
local make_tier_labels = reskins.lib.settings.get_value("reskins-bobs-do-belt-entity-tier-labeling") and true or false

-- TRANSPORT BELTS
local transport_belts = {
	["transport-belt"] = { tier = 1, reskin_vanilla_entity = reskin_vanilla_entity },
	["fast-transport-belt"] = { tier = 2, use_express_spritesheet = true, reskin_vanilla_entity = reskin_vanilla_entity },
	["express-transport-belt"] = { tier = 3, use_express_spritesheet = true, reskin_vanilla_entity = reskin_vanilla_entity },
}

for name, map in pairs(transport_belts) do
	reskins.lib.apply_skin.transport_belt(name, map.tier, nil, make_tier_labels, map.use_express_spritesheet, map.reskin_vanilla_entity)
end

-- UNDERGROUND BELTS
local underground_belts = {
	["underground-belt"] = { tier = 1, reskin_vanilla_entity = reskin_vanilla_entity },
	["fast-underground-belt"] = { tier = 2, reskin_vanilla_entity = reskin_vanilla_entity },
	["express-underground-belt"] = { tier = 3, reskin_vanilla_entity = reskin_vanilla_entity },
}

for name, map in pairs(underground_belts) do
	reskins.lib.apply_skin.underground_belt(name, map.tier, nil, make_tier_labels, map.reskin_vanilla_entity)
end

-- SPLITTERS
local splitters = {
	["splitter"] = { tier = 1, reskin_vanilla_entity = reskin_vanilla_entity },
	["fast-splitter"] = { tier = 2, reskin_vanilla_entity = reskin_vanilla_entity },
	["express-splitter"] = { tier = 3, reskin_vanilla_entity = reskin_vanilla_entity },
}

for name, map in pairs(splitters) do
	reskins.lib.apply_skin.splitter(name, map.tier, nil, make_tier_labels, map.reskin_vanilla_entity)
end
