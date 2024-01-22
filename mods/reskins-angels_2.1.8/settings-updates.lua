-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Core mods
-- reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsbioprocessing")
reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsexploration")
-- reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsindustries")
-- reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelspetrochem")
-- reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsrefining")
-- reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelssmelting")

-- Addons
reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsaddons-cab")
reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsaddons-mobility")
-- reskins.lib.setting_override("bool-setting", "reskins-angels-do-angelsaddons-storage")

-- Override Bob's "Deuterium is Blue!" setting based on presence of Angel's Industries
if mods["angelsindustries"] then
    reskins.lib.setting_override("bool-setting", "bobmods-plates-bluedeuterium", true)
end

-- Hide chemical furnace color setting, as Angel's Smelting disables these
if mods["angelssmelting"] then
    reskins.lib.setting_override("string-setting", "reskins-bobs-chemical-furnace-color")
end