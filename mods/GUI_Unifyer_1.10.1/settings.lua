data:extend({
    {
        type = "string-setting",
        name = "gu_frame_style_setting",
        setting_type = "runtime-per-user",
        default_value = "normal_frame_style",
        allowed_values = {"normal_frame_style", "barebone_frame_style", "invisible_frame_style"},
        order = "a"
    },
    {
        type = "string-setting",
        name = "gu_button_style_setting",
        setting_type = "runtime-per-user",
        default_value = "slot_button_notext",
        allowed_values = {"slot_button_notext", "slot_sized_button_notext"},
        order = "b"
    },

})
