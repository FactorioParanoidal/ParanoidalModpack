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

})
