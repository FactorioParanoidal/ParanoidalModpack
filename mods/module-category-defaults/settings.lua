data:extend{
    {
        type = "bool-setting",
        name = "module-category-defaults-dynamic",
        setting_type = "startup",
        default_value = false,
        hidden = true, -- Paranoidal fork: every module category of the build is a default one, no detection
        order = "a"
    }
}