-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "refining",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

local technologies = {
    -- Advanced ore refinining (Ore sorting facility)
    ["advanced-ore-refining-1"] = {tier = 2, icon_name = "advanced-ore-refining"},
    ["advanced-ore-refining-2"] = {tier = 3, icon_name = "advanced-ore-refining"},
    ["advanced-ore-refining-3"] = {tier = 4, icon_name = "advanced-ore-refining"},
    ["advanced-ore-refining-4"] = {tier = 5, icon_name = "advanced-ore-refining"},
    ["advanced-ore-refining-5"] = {tier = 6, icon_name = "advanced-ore-refining"},

    -- Water treatment (Hydro plant)
    ["water-treatment"] = {tier = 1, icon_name = "water-treatment"},
    ["water-treatment-2"] = {tier = 2, icon_name = "water-treatment"},
    ["water-treatment-3"] = {tier = 3, icon_name = "water-treatment"},
    ["water-treatment-4"] = {tier = 4, icon_name = "water-treatment"},
    ["water-treatment-5"] = {tier = 5, icon_name = "water-treatment"},

    -- Mechanical refining (Ore crusher)
    ["ore-crushing"] = {tier = 1, icon_name = "ore-crushing"},
    ["clowns-ore-crushing"] = {tier = 0, icon_name = "ore-crushing", technology_icon_layers = 1},

    -- Thermal refining (Ore refining)
    ["ore-refining"] = {tier = 1, prog_tier = 4, icon_name = "ore-refining"},
    ["clowns-ore-refining"] = {tier = 0, icon_name = "ore-refining", technology_icon_layers = 1},

    -- Hydro-refining (Ore flotation cell)
    ["ore-floatation"] = {tier = 1, prog_tier = 2, icon_name = "ore-flotation"},
    ["clowns-ore-floatation"] = {tier = 0, icon_name = "ore-flotation", technology_icon_layers = 1},
}

-- Sea Block compatibility
if mods["SeaBlock"] then
  technologies["ore-crushing"].icon_name = "advanced-ore-refining"
end

-- Check if we're using Angel's material colors
if mods["bobwarfare"] and mods["bobplates"] and reskins.lib.setting("reskins-angels-use-angels-material-colors") then
    technologies["bob-armor-making-3"] = {group = "smelting", subgroup = "armor", flat_icon = true, technology_icon_mipmaps = 4}
end

reskins.lib.create_icons_from_list(technologies, inputs)