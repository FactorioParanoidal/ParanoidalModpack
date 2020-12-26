-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angelssmelting"] then return end
-- if reskins.lib.setting("reskins-angels-do-angelssmelting") == false then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "smelting",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    flat_icon = true,
}

local technologies = {
    ["angels-brass-smelting-1"] = {subgroup = "casting", image = "casting-brass-technology-icon"},
    ["angels-brass-smelting-2"] = {subgroup = "casting", image = "casting-brass-technology-icon"},
    ["angels-brass-smelting-3"] = {subgroup = "casting", image = "casting-brass-technology-icon"},

    ["angels-nitinol-smelting-1"] = {subgroup = "casting", image = "casting-nitinol-technology-icon"},

    ["angels-gunmetal-smelting-1"] = {subgroup = "casting", image = "casting-gunmetal-technology-icon"},

    ["angels-invar-smelting-1"] = {subgroup = "casting", image = "casting-invar-technology-icon"},

    ["angels-cobalt-steel-smelting-1"] = {subgroup = "casting", image = "casting-cobalt-technology-icon"},

    ["angels-bronze-smelting-1"] = {subgroup = "casting", image = "casting-bronze-technology-icon"},
    ["angels-bronze-smelting-2"] = {subgroup = "casting", image = "casting-bronze-technology-icon"},
    ["angels-bronze-smelting-3"] = {subgroup = "casting", image = "casting-bronze-technology-icon"},

    ["angels-tungsten-smelting-1"] = {subgroup = "casting", image = "casting-tungsten-technology-icon"},
    ["angels-tungsten-smelting-2"] = {subgroup = "casting", image = "casting-tungsten-technology-icon"},
    ["angels-tungsten-smelting-3"] = {subgroup = "casting", image = "casting-tungsten-technology-icon"},

    ["angels-alloys-smelting-1"] = {subgroup = "casting", image = "casting-alloy-1-technology-icon"},
    ["angels-alloys-smelting-2"] = {subgroup = "casting", image = "casting-alloy-2-technology-icon"},
    ["angels-alloys-smelting-3"] = {subgroup = "casting", image = "casting-alloy-3-technology-icon"},
}

reskins.lib.create_icons_from_list(technologies, inputs)