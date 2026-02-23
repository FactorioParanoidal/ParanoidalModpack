data:extend(
{
    {
        type = "bool-setting",
        name = "yemtositemcount-disable-mod",
        order = "a",
        setting_type = "runtime-per-user",
        default_value = false
    },{
        type = "bool-setting",
        name = "yemtositemcount-disable-blueprint-items",
        order = "c",
        setting_type = "runtime-per-user",
        default_value = true
    },{
        type = "bool-setting",
        name = "yemtositemcount-disable-artillery-remote",
        order = "d",
        setting_type = "runtime-per-user",
        default_value = true
    },{
        type = "string-setting",
        name = "yemtositemcount-number-format",
        order = "e",
        setting_type = "runtime-per-user",
        default_value = "1,247",
        allowed_values = {
            "1,247",
            "1.247",
            "1 247",
            "1247",
            "1,2k",
            "1.2k"
        }
    }
})
