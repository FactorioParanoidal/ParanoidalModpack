-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Core settings
data:extend({
    {
        type = "bool-setting",
        name = "reskins-angels-use-angels-tier-colors",
        setting_type = "startup",
        order = "a",
        default_value = false,
        hidden = true,
    },
    {
        type = "bool-setting",
        name = "reskins-angels-use-item-variations",
        setting_type = "startup",
        order = "a",
        default_value = true
    }
})

-- Settings available based on mod loadout
if mods["angelsbioprocessing"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsbioprocessing",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["angelsexploration"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsexploration",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["angelsindustries"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsindustries",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["angelspetrochem"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelspetrochem",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["angelsrefining"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsrefining",
            setting_type = "startup",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-angels-use-vanilla-style-ores",
            setting_type = "startup",
            default_value = false,
            order = "a",
            hidden = true,
        },
    })
end

if mods["angelssmelting"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelssmelting",
            setting_type = "startup",
            default_value = true,
        },
        {
            type = "bool-setting",
            name = "reskins-angels-use-angels-material-colors",
            setting_type = "startup",
            default_value = true,
            order = "a",
        },
        {
            type = "bool-setting",
            name = "reskins-angels-use-angels-material-colors-pipes",
            setting_type = "startup",
            default_value = true,
            order = "a",
        }
    })
end

if mods["angelsaddons-cab"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsaddons-cab",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["angelsaddons-mobility"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsaddons-mobility",
            setting_type = "startup",
            default_value = true,
        }
    })
end

if mods["angelsaddons-storage"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-angels-do-angelsaddons-storage",
            setting_type = "startup",
            default_value = true,
        }
    })
end