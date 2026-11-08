if (mods["any-planet-start"]) then
    APS.add_choice("frozeta")
end



data:extend({
    {
        type = "bool-setting",
        name = "check-this-if-frozeta-start",
        setting_type = "startup",
        default_value = false,
        hidden = true, -- Paranoidal: the game starts at home, the planets come after the rocket
    },
    {
        type = "bool-setting",
        name = "automatically-populate-science-pack-productivity-research",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "ignore-dea-dia-compatibility",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "modify-loaders-for-belt-stack-size-limit",
        setting_type = "startup",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "restrict-steam-recycler-crafting-to-frozeta",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "condense-level-4-modules-into-one-technology",
        setting_type = "startup",
        default_value = false
    }
})