-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobtech"] then return end

local inputs = {
    mod = "bobs",
    group = "technology",
    type = "tool",
    icon_name = "science-pack",
    tier_labels = false,
}

local items = {
    ["advanced-logistic-science-pack"] = {tint = util.color("de00a3")}
}

-- Color overhaul for science packs
if reskins.lib.setting("bobmods-tech-colorupdate") == true and reskins.lib.setting("reskins-lib-customize-tier-colors") == true then
    items["automation-science-pack"] = {tier = 1}
    items["logistic-science-pack"] = {tier = 2}
    items["chemical-science-pack"] = {tier = 3}
    items["production-science-pack"] = {tier = 4}
    items["utility-science-pack"] = {tier = 5}
end

-- Burner phase is enabled
if reskins.lib.setting("bobmods-burnerphase") == true then
    items["steam-science-pack"] = {subgroup = "science-pack", flat_icon = true}
end

-- Alien science packs
if reskins.lib.setting("bobmods-enemies-enablenewartifacts") == true then
    items["alien-science-pack"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["alien-science-pack-blue"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["alien-science-pack-orange"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["alien-science-pack-purple"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["alien-science-pack-yellow"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["alien-science-pack-green"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["alien-science-pack-red"] = {subgroup = "alien-science-pack", flat_icon = true}
    items["science-pack-gold"] = {subgroup = "alien-science-pack", flat_icon = true}
end

reskins.lib.create_icons_from_list(items, inputs)