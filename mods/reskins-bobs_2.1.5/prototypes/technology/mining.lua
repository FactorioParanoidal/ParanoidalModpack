-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.mining.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "mining",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

-- Filenames and effect overlays
local steel_axe_icon = "__base__/graphics/technology/steel-axe.png"
local constant_mining = reskins.lib.return_technology_effect_icon("mining")

local technologies = {
    -- Standard Drills
    ["bob-drills-1"] = {tier = 2, icon_name = "mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-drills-2"] = {tier = 3, icon_name = "mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-drills-3"] = {tier = 4, icon_name = "mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-drills-4"] = {tier = 5, icon_name = "mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},

    -- Area Drills
    ["bob-area-drills-1"] = {tier = 1, prog_tier = 2, icon_name = "mining-drill", icon_base = "area-mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-area-drills-2"] = {tier = 2, prog_tier = 3, icon_name = "mining-drill", icon_base = "area-mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-area-drills-3"] = {tier = 3, prog_tier = 4, icon_name = "mining-drill", icon_base = "area-mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-area-drills-4"] = {tier = 4, prog_tier = 5, icon_name = "mining-drill", icon_base = "area-mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0},

    -- Water pumpjacks
    ["water-miner-1"] =  {tier = 1, icon_name = "pumpjack", icon_base = "water-pumpjack"},
    ["water-miner-2"] =  {tier = 2, icon_name = "pumpjack", icon_base = "water-pumpjack"},
    ["water-miner-3"] =  {tier = 3, icon_name = "pumpjack", icon_base = "water-pumpjack"},
    ["water-miner-4"] =  {tier = 4, icon_name = "pumpjack", icon_base = "water-pumpjack"},
    ["water-miner-5"] =  {tier = 5, icon_name = "pumpjack", icon_base = "water-pumpjack"},

    -- Oil pumpjacks
    ["pumpjack"] = {tier = 1, icon_name = "pumpjack"},
    ["bob-pumpjacks-1"] = {tier = 2, icon_name = "pumpjack"},
    ["bob-pumpjacks-2"] = {tier = 3, icon_name = "pumpjack"},
    ["bob-pumpjacks-3"] = {tier = 4, icon_name = "pumpjack"},
    ["bob-pumpjacks-4"] = {tier = 5, icon_name = "pumpjack"},

    -- TECHNOLOGY EFFECTS
    ["steel-axe"] = {technology_icon_filename = steel_axe_icon, technology_icon_extras = {constant_mining}, flat_icon = true},
    ["steel-axe-2"] = {technology_icon_filename = steel_axe_icon, technology_icon_extras = {constant_mining}, flat_icon = true},
    ["steel-axe-3"] = {technology_icon_filename = steel_axe_icon, technology_icon_extras = {constant_mining}, flat_icon = true},
    ["steel-axe-4"] = {technology_icon_filename = steel_axe_icon, technology_icon_extras = {constant_mining}, flat_icon = true},
    ["steel-axe-5"] = {technology_icon_filename = steel_axe_icon, technology_icon_extras = {constant_mining}, flat_icon = true},
    ["steel-axe-6"] = {technology_icon_filename = steel_axe_icon, technology_icon_extras = {constant_mining}, flat_icon = true},
}

if mods["aai-industry"] then
    technologies["electric-mining"] = {tier = 1, icon_name = "mining-drill", technology_icon_size = 128, technology_icon_mipmaps = 0}
end

reskins.lib.create_icons_from_list(technologies, inputs)