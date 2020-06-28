-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

local tiered_item_list = {
    ["repair-pack"] = {tier = 1, icon_name = "repair-pack", type = "repair-tool", group = "logistics", make_entity_pictures = true},
    ["repair-pack-2"] = {tier = 2, icon_name = "repair-pack", type = "repair-tool", group = "logistics", make_entity_pictures = true},
    ["repair-pack-3"] = {tier = 3, icon_name = "repair-pack", type = "repair-tool", group = "logistics", make_entity_pictures = true},
    ["repair-pack-4"] = {tier = 4, icon_name = "repair-pack", type = "repair-tool", group = "logistics", make_entity_pictures = true},
    ["repair-pack-5"] = {tier = 5, icon_name = "repair-pack", type = "repair-tool", group = "logistics", make_entity_pictures = true},
}

for name, inputs in pairs(tiered_item_list) do
    -- Parse map
    inputs.tint = inputs.tint or reskins.lib.tint_index["tier-"..inputs.tier]
    inputs.directory = reskins.bobs.directory
    inputs.mod = "bobs"

    -- Setup input defaults
    reskins.lib.parse_inputs(inputs)

    -- Reskin icons
    reskins.lib.construct_icon(name, inputs.tier, inputs)
end