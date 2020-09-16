data:extend({
    -- Settings for character scaling
    {
        type = "int-setting",
        name = "minime_character-size",
        setting_type = "startup",
        default_value = 70,
        -- 2000% is too much, mining becomes almost impossible because mining range doesn't scale with character size.
        --~ maximum_value = 2000,
        maximum_value = 500,
        -- 1 is too low, it's already hard to see the character at 10%, at 1% it will be close to invisible.
        --~ minimum_value = 1,
        minimum_value = 10,
        order = "[minime]-aa"
    },
    {
        type = "bool-setting",
        name = "minime_scale-reach_resource_distance",
        setting_type = "startup",
        default_value = false,
        order = "[minime]-ab"
    },
    {
        type = "bool-setting",
        name = "minime_scale-tool-attack-distance",
        setting_type = "startup",
        default_value = false,
        order = "[minime]-ac"
    },

    -- Settings for GUI
    {
        type = "bool-setting",
        name = "minime_character-selector",
        setting_type = "startup",
        default_value = true,
        order = "[minime]-ba"
    },
    {
        type = "bool-setting",
        name = "minime_close-gui-on-selection",
        setting_type = "startup",
        default_value = false,
        order = "[minime]-bb"
    },
})
