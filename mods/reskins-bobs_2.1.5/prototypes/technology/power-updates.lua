-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "power",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

local technologies = {
    ["bob-steam-engine-1"] = {tier = 1, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0}, -- Bob technology burner phase
}

local material_tiers = {
    "base",
    "silver-aluminum",
    "gold-copper",
}

if reskins.lib.migration.is_version_or_newer(mods["bobpower"], "1.1.6") then
    material_tiers = {
        "aluminum-invar",
        "silver-titanium",
        "gold-copper",
    }
end

-- Nuclear reactors
if reskins.bobs.triggers.power.nuclear then
    technologies["nuclear-power"] = {tier = 1, prog_tier = 3, icon_name = "nuclear-power", tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor"].tint} -- t3 reactor
    technologies["nuclear-power"].icon_base = "nuclear-power-uranium-"..material_tiers[1]
    technologies["bob-nuclear-power-2"] = {tier = 2, prog_tier = 4, icon_name = "nuclear-power", tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor-2"].tint} -- t4 reactor
    technologies["bob-nuclear-power-2"].icon_base = "nuclear-power-uranium-"..material_tiers[2]
    technologies["bob-nuclear-power-3"] = {tier = 3, prog_tier = 5, icon_name = "nuclear-power", tint = reskins.bobs.nuclear_reactor_index["nuclear-reactor-3"].tint} -- t5 reactor
    technologies["bob-nuclear-power-3"].icon_base = "nuclear-power-uranium-"..material_tiers[3]

    if reskins.lib.setting("bobmods-revamp-nuclear") == true then
        technologies["bob-nuclear-power-2"].icon_base = "nuclear-power-thorium-"..material_tiers[2]

        if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
            technologies["bob-nuclear-power-3"].icon_base = "nuclear-power-deuterium-blue-"..material_tiers[3]
        else
            technologies["bob-nuclear-power-3"].icon_base = "nuclear-power-deuterium-pink-"..material_tiers[3]
        end
    end
end

reskins.lib.create_icons_from_list(technologies, inputs)