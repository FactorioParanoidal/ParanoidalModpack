-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["RealisticReactorGlow"] then return end
if not (reskins.bobs and reskins.bobs.triggers.power.technologies) then return end
if not (reskins.bobs.nuclear_reactor_index) then return end -- version check
if reskins.lib.setting("bobmods-power-nuclear") == false then return end

-- Setup standard inputs
local inputs = {
    mod = "compatibility",
    group = "realisticreactorglow",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    icon_name = "nuclear-power",
}


local light_color = ""
if reskins.lib.setting("RealisticReactorGlow-cyan") then
    light_color = "_cyan"
end

local technologies = {
    ["nuclear-power"] = {tier = 1, prog_tier = 3, icon_base = "nuclear-power-1-color"..light_color, tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor"].tint}, -- t3 reactor
    ["bob-nuclear-power-2"] = {tier = 2, prog_tier = 4, icon_base = "nuclear-power-2-color"..light_color, tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor-2"].tint}, -- t4 reactor
    ["bob-nuclear-power-3"] = {tier = 3, prog_tier = 5, icon_base = "nuclear-power-3-color"..light_color, tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].tint}, -- t5 reactor
}

reskins.lib.create_icons_from_list(technologies, inputs)