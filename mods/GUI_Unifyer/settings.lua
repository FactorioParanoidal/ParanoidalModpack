local gu_todolist_style_setting_hidden = true
if mods["Todo-List"] then
    gu_todolist_style_setting_hidden = false
end

data:extend({
    {
        type = "bool-setting",
        name = "gu_enable_logging",
        setting_type = "runtime-per-user",
        default_value = false,
        order = "a-a"
    },
    {
        type = "string-setting",
        name = "gu_log_level",
        setting_type = "runtime-per-user",
        default_value = "INFO",
        allowed_values = {"DEBUG", "INFO", "WARNING", "ERROR"},
        order = "a-b"
    },
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
            "gui_Unifier_gui_01",
            "gui_Unifier_gui_02",
            "gui_Unifier_gui_03",
            "gui_Unifier_gui_04",
            "gui_Unifier_gui_05",
            "gui_Unifier_gui_06",
            "gui_Unifier_gui_07",
            "gui_Unifier_gui_08",
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

-- Hide icons
local icons = require('icons')
local settingslist = {}

-- Convert new icon format to settings
for _, icon in pairs(icons) do
    -- Use array indices for backward compatibility since we're still in transition
    -- icon[1] is mod name, icon[3] is button name
    if mods[icon[1]] and icon[1] ~= "base" then
        local button_name = icon[3]
        local alreadyexists = false
        
        for _, existing_button in pairs(settingslist) do
            if button_name == existing_button then
                alreadyexists = true
                break
            end
        end
        
        if not alreadyexists then
            table.insert(settingslist, button_name)
        end
    end
end

-- Create settings for each button
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