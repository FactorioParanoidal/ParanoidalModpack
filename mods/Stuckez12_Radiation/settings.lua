local mod_name = "Stuckez12-Radiation-"

data:extend({
    {
        type = "bool-setting",
        name = mod_name .. "Menu-Simulations",
        setting_type = "startup",
        default_value = true,
        order = "a",
        localised_description = {"mod-setting-description." .. mod_name .. "Menu-Simulations"}
    },
    {
        type = "int-setting",
        name = mod_name .. "Radiation-Radius",
        setting_type = "runtime-global",
        default_value = 12,
        minimum_value = 8,
        maximum_value = 20,
        order = "a",
        localised_description = {"mod-setting-description." .. mod_name .. "Radiation-Radius"}
    },
    {
        type = "int-setting",
        name = mod_name .. "Protection-Radius",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 0,
        maximum_value = 125,
        order = "b",
        localised_description = {"mod-setting-description." .. mod_name .. "Protection-Radius"}
    },
    {
        type = "double-setting",
        name = mod_name .. "Base-Radiation",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.1,
        maximum_value = 100,
        order = "c",
        localised_description = {"mod-setting-description." .. mod_name .. "Base-Radiation"}
    },
    {
        type = "double-setting",
        name = mod_name .. "Damage-Multiplier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.1,
        maximum_value = 100,
        order = "d",
        localised_description = {"mod-setting-description." .. mod_name .. "Damage-Multiplier"}
    },
    {
        type = "int-setting",
        name = mod_name .. "Chunk-Effect-Radius",
        setting_type = "runtime-global",
        default_value = 8,
        minimum_value = 4,
        maximum_value = 48,
        order = "e",
        localised_description = {"mod-setting-description." .. mod_name .. "Chunk-Effect-Radius"}
    },
    {
        type = "int-setting",
        name = mod_name .. "Chunks-Per-Call",
        setting_type = "runtime-global",
        default_value = 6,
        minimum_value = 1,
        maximum_value = 12,
        order = "f",
        localised_description = {"mod-setting-description." .. mod_name .. "Chunks-Per-Call"}
    },
    {
        type = "bool-setting",
        name = mod_name .. "Enable-Chunk-Range-Radiation",
        setting_type = "runtime-global",
        default_value = true,
        order = "g",
        localised_description = {"mod-setting-description." .. mod_name .. "Enable-Chunk-Range-Radiation"}
    },
    {
        type = "bool-setting",
        name = mod_name .. "Enable-Biter-Radiation",
        setting_type = "runtime-global",
        default_value = true,
        order = "h",
        localised_description = {"mod-setting-description." .. mod_name .. "Enable-Biter-Radiation"}
    },
    {
        type = "bool-setting",
        name = mod_name .. "Enable-GUI-Effect",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "a",
        localised_description = {"mod-setting-description." .. mod_name .. "Enable-GUI-Effect"}
    }
})
