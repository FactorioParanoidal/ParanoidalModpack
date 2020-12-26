-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

local function hide_setting(setting_type, setting_name, setting_default)
    if data.raw[setting_type] and data.raw[setting_type][setting_name] then
        data.raw[setting_type][setting_name].hidden = true
        if setting_default ~= nil then
            data.raw[setting_type][setting_name].default_value = setting_default
        end
    end
end

-- Core mods
hide_setting("bool-setting", "reskins-angels-do-angelsbioprocessing")
hide_setting("bool-setting", "reskins-angels-do-angelsexploration")
-- hide_setting("bool-setting", "reskins-angels-do-angelsindustries")
-- hide_setting("bool-setting", "reskins-angels-do-angelspetrochem")
hide_setting("bool-setting", "reskins-angels-do-angelsrefining")
-- hide_setting("bool-setting", "reskins-angels-do-angelssmelting")

-- Addons
hide_setting("bool-setting", "reskins-angels-do-angelsaddons-cab")
hide_setting("bool-setting", "reskins-angels-do-angelsaddons-mobility")
-- hide_setting("bool-setting", "reskins-angels-do-angelsaddons-storage")