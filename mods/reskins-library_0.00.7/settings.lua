-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Core Library
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
    -- {
    --     type = "int-setting",
    --     name = "reskins-lib-target-drone-health",
    --     setting_type = "startup",
    --     order = "zzzzzz",
    --     default_value = 50000000,
    --     maximum_value = 2147483648,
    --     minimum_value = 1000
    -- },
    {
        type = "string-setting",
        name = "reskins-lib-tier-mapping",
        setting_type = "startup",
        order = "ab",
        default_value = "ingredients-map",
        allowed_values = {"ingredients-map","name-map"}
    },
    {
        type = "string-setting",
        name = "reskins-lib-icon-tier-labeling-style",
        setting_type = "startup",
        order = "aa",
        default_value = "rounded-rectangle",
        allowed_values = {"dots","half-circle","rectangle","rounded-half-circle","rounded-rectangle","teardrop"}
    }
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
        default_value = "1b87c2",
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
    }
})