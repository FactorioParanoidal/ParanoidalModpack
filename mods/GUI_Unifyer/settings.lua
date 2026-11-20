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
local seen = {}
for _, icon in ipairs(icons) do
    local mod, button = icon[1], icon[3]
    if mods[mod] and mod ~= "base" and not seen[button] then
        seen[button] = true
        data:extend({{
            type = "bool-setting",
            name = "gu_button_" .. button,
            setting_type = "runtime-per-user",
            default_value = true,
            order = "e",
        }})
    end
end