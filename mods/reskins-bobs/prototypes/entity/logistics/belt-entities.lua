-- Copyright (c) 2025 Kirazy
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
	["bob-basic-transport-belt"] = { tier = 0 },
	["bob-turbo-transport-belt"] = { tier = 4, use_express_spritesheet = true },
	["bob-ultimate-transport-belt"] = { tier = 5, use_express_spritesheet = true },
}

for name, map in pairs(transport_belts) do
	reskins.lib.apply_skin.transport_belt(name, map.tier, nil, make_tier_labels, map.use_express_spritesheet, map.reskin_vanilla_entity)
end

-- UNDERGROUND BELTS
local underground_belts = {
	["bob-basic-underground-belt"] = { tier = 0 },
	["bob-turbo-underground-belt"] = { tier = 4 },
	["bob-ultimate-underground-belt"] = { tier = 5 },
}

for name, map in pairs(underground_belts) do
	reskins.lib.apply_skin.underground_belt(name, map.tier, nil, make_tier_labels, map.reskin_vanilla_entity)
end

-- SPLITTERS
local splitters = {
	["bob-basic-splitter"] = { tier = 0 },
	["bob-turbo-splitter"] = { tier = 4 },
	["bob-ultimate-splitter"] = { tier = 5 },
}

for name, map in pairs(splitters) do
	reskins.lib.apply_skin.splitter(name, map.tier, nil, make_tier_labels, map.reskin_vanilla_entity)
end
