-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if reskins.lib.check_scope("technologies", "bobs", "boblogistics") == false then return end

-- Setup standard inputs
local inputs = {
    mod = "lib",
    group = "base",
    type = "technology",
}

local technologies = {
    -- Logistics
    ["logistics-0"] = {tier = 0, icon_name = "logistics", technology_icon_layers = 2, uses_belt_mask = true},
    ["logistics-4"] = {tier = 4, icon_name = "logistics", technology_icon_layers = 2, uses_belt_mask = true},
    ["logistics-5"] = {tier = 5, icon_name = "logistics", technology_icon_layers = 2, uses_belt_mask = true},
}

-- Only do logistics 1, 2 and 3 if we're doing custom colors
if reskins.lib.setting("reskins-lib-customize-tier-colors") == true then
    technologies["logistics"] = {tier = 1, icon_name = "logistics", technology_icon_layers = 2, uses_belt_mask = true}
    technologies["logistics-2"] = {tier = 2, icon_name = "logistics", technology_icon_layers = 2, uses_belt_mask = true}
    technologies["logistics-3"] = {tier = 3, icon_name = "logistics", technology_icon_layers = 2, uses_belt_mask = true}
end

reskins.lib.create_icons_from_list(technologies, inputs)