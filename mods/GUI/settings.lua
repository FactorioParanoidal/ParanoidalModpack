local gu_todolist_style_setting_hidden = true
if mods["Todo-List"] then
    gu_todolist_style_setting_hidden = false
end

data:extend({
    {
        type = "string-setting",
        name = "gu_frame_style_setting",
        setting_type = "runtime-per-user",
        default_value = "snouz_normal_frame_style",
        allowed_values = {
            "snouz_normal_frame_style",
            "snouz_barebone_frame_style",
            "snouz_large_barebone_frame_style",
            "snouz_invisible_frame_style",
        },
        order = "a"
    },
    {
        type = "string-setting",
        name = "gu_button_style_setting",
        setting_type = "runtime-per-user",
        default_value = "slot_button_notext",
        allowed_values = {
            "slot_button_notext",
            "slot_sized_button_notext",
            "slot_button_notext_transparent",
            "gui_unifyer_gui_01",
            "gui_unifyer_gui_02",
            "gui_unifyer_gui_03",
            "gui_unifyer_gui_04",
            "gui_unifyer_gui_05",
            "gui_unifyer_gui_06",
            "gui_unifyer_gui_07",
            "gui_unifyer_gui_08",
        },
        order = "b"
    },
    {
        type = "string-setting",
        name = "gu_todolist_style_setting",
        setting_type = "runtime-per-user",
        default_value = "icon",
        allowed_values = {
            "icon",
            "longtext",
        },
        order = "c",
        hidden = gu_todolist_style_setting_hidden,
    },
    {
        type = "bool-setting",
        name = "gu_mod_enabled_perplayer",
        setting_type = "runtime-per-user",
        default_value = true,
        hidden = true,
        order = "d",
    },
})


--Hide icons

local iconlist = require('iconlist')

local settingslist = {}

for k, icon in pairs(iconlist) do
    if mods[icon[1]] and icon[1] ~= "base" then
        local alreadyexists = false
        for _, i in pairs(settingslist) do
            if icon[3] == i then
                alreadyexists = true
            end
        end
        if not alreadyexists then
            table.insert(settingslist, icon[3])
        end
    end
end

for _, setting in pairs(settingslist) do
    data:extend({
        {
            type = "bool-setting",
            name = "gu_button_" .. setting,
            setting_type = "runtime-per-user",
            default_value = true,
            order = "e",
        },
    })
end