-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Core reskins-lib series settings
data:extend(
{
    {
        type = "bool-setting",
        name = "reskins-lib-icon-tier-labeling",
        setting_type = "startup",
        order = "a",
        default_value = true,
    },
    {
        type = "string-setting",
        name = "reskins-lib-tier-mapping",
        setting_type = "startup",
        order = "ab",
        default_value = "progression-map",
        allowed_values = {"progression-map","traditional-map"}
    },
    {
        type = "string-setting",
        name = "reskins-lib-icon-tier-labeling-style",
        setting_type = "startup",
        order = "aa",
        default_value = "rounded-rectangle",
        allowed_values = {"dots","half-circle","rectangle","rounded-half-circle","rounded-rectangle","teardrop"}
    },
    {
        type = "string-setting",
        name = "reskins-lib-blend-mode",
        setting_type = "startup",
        order = "b",
        default_value = "additive",
        allowed_values = {"additive","additive-soft"}
    },
})

-- Customize tier coloring settings
data:extend(
{
    {
        type = "bool-setting",
        name = "reskins-lib-customize-tier-colors",
        setting_type = "startup",
        order = "y",
        default_value = false,
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-0",
        setting_type ="startup",
        order = "yy",
        default_value = "4d4d4d",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-1",
        setting_type ="startup",
        order = "yy",
        default_value = "de9400",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-2",
        setting_type ="startup",
        order = "yy",
        default_value = "c20600",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-3",
        setting_type ="startup",
        order = "yy",
        default_value = "0099ff",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-4",
        setting_type ="startup",
        order = "yy",
        default_value = "a600bf",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-5",
        setting_type ="startup",
        order = "yy",
        default_value = "23de55",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-6",
        setting_type ="startup",
        order = "yy",
        default_value = "ff7700"
    }
})