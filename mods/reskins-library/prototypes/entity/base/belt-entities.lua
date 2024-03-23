-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

local reskin_vanilla_entity = reskins.lib.setting("reskins-lib-customize-tier-colors")
local make_tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

-- TRANSPORT BELTS
local transport_belts = {
    ["basic-transport-belt"] = {tier = 0},
    ["transport-belt"] = {tier = 1, reskin_vanilla_entity = reskin_vanilla_entity},
    ["fast-transport-belt"] = {tier = 2, use_express_spritesheet = true, reskin_vanilla_entity = reskin_vanilla_entity},
    ["express-transport-belt"] = {tier = 3, use_express_spritesheet = true, reskin_vanilla_entity = reskin_vanilla_entity},
    ["turbo-transport-belt"] = {tier = 4, use_express_spritesheet = true},
    ["ultimate-transport-belt"] = {tier = 5, use_express_spritesheet = true},
}

for name, map in pairs(transport_belts) do
    reskins.lib.apply_skin.transport_belt(name, map.tier, nil, make_tier_labels, map.use_express_spritesheet, map.reskin_vanilla_entity)
end

-- UNDERGROUND BELTS
local underground_belts = {
    ["basic-underground-belt"] = {tier = 0},
    ["underground-belt"] = {tier = 1, reskin_vanilla_entity = reskin_vanilla_entity},
    ["fast-underground-belt"] = {tier = 2, reskin_vanilla_entity = reskin_vanilla_entity},
    ["express-underground-belt"] = {tier = 3, reskin_vanilla_entity = reskin_vanilla_entity},
    ["turbo-underground-belt"] = {tier = 4},
    ["ultimate-underground-belt"] = {tier = 5},
}

for name, map in pairs(underground_belts) do
    reskins.lib.apply_skin.underground_belt(name, map.tier, nil, make_tier_labels, map.reskin_vanilla_entity)
end

-- SPLITTERS
local splitters = {
    ["basic-splitter"] = {tier = 0},
    ["splitter"] = {tier = 1, reskin_vanilla_entity = reskin_vanilla_entity},
    ["fast-splitter"] = {tier = 2, reskin_vanilla_entity = reskin_vanilla_entity},
    ["express-splitter"] = {tier = 3, reskin_vanilla_entity = reskin_vanilla_entity},
    ["turbo-splitter"] = {tier = 4},
    ["ultimate-splitter"] = {tier = 5},
}

for name, map in pairs(splitters) do
    reskins.lib.apply_skin.splitter(name, map.tier, nil, make_tier_labels, map.reskin_vanilla_entity)
end