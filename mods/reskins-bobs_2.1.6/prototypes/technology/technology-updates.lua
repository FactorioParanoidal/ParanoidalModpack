-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["ScienceCostTweakerM"] then return end
if not (reskins.bobs and reskins.bobs.triggers.technology.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "technology",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    flat_icon = true,
}

local technologies = {
    -- Science Packs
    ["advanced-logistic-science-pack"] = {icon_name = "science-pack", tint = util.color("de00a3"), flat_icon = false},
    ["steam-automation"] = {group = "assembly", icon_name = "automation", tint = util.color("d9d9d9"), flat_icon = false},
}

-- Color overhaul for science packs
if reskins.lib.setting("bobmods-tech-colorupdate") == true then
    if reskins.lib.setting("reskins-lib-customize-tier-colors") == true then
        technologies["automation-science-pack"] = {tier = 1, icon_name = "science-pack", flat_icon = false}
        technologies["logistic-science-pack"] = {tier = 2, icon_name = "science-pack", flat_icon = false}
        technologies["chemical-science-pack"] = {tier = 3, icon_name = "science-pack", flat_icon = false}
        technologies["production-science-pack"] = {tier = 4, icon_name = "science-pack", flat_icon = false}
        technologies["utility-science-pack"] = {tier = 5, icon_name = "science-pack", flat_icon = false}
    else
        technologies["automation-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/utility-science-pack.png"}
        technologies["logistic-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/automation-science-pack.png"}
        technologies["chemical-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/chemical-science-pack.png"}
        technologies["production-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/production-science-pack.png"}
        technologies["utility-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/logistic-science-pack.png"}
    end
else
    technologies["automation-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/automation-science-pack.png"}
    technologies["logistic-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/logistic-science-pack.png"}
    technologies["chemical-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/chemical-science-pack.png"}
    technologies["production-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/production-science-pack.png"}
    technologies["utility-science-pack"] = {technology_icon_filename = "__base__/graphics/technology/utility-science-pack.png"}
end

reskins.lib.create_icons_from_list(technologies, inputs)