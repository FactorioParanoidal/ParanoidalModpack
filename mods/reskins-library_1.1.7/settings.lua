-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Make our function host
if not reskins then reskins = {} end
if not reskins.lib then reskins.lib = {} end

-- Set the hidden flag to true and optionally override the default value
function reskins.lib.setting_override(setting_type, setting_name, override_value)
    if data.raw[setting_type] and data.raw[setting_type][setting_name] then
        -- Fetch the setting, and hide it
        local setting = data.raw[setting_type][setting_name]
        setting.hidden = true

        -- Override the current value
        if override_value then
            if setting_type == "bool-setting" then
                setting.forced_value = override_value
            else
                setting.default_value = override_value
                setting.allowed_values = {override_value}
            end
        end
    end
end

-- Concatenate the mod description string with the default description string for boolean settings
-- Note that an empty mod setting description is possible, but cannot be detected, and so blank newlines will be present for such settings
function reskins.lib.concatenate_setting_description(setting)
    -- Check for an already set localised_description
    if setting.localised_description then
        return {"", setting.localised_description, {"reskins-defaults."..tostring(setting.default_value)}}
    else
        return {"", {"mod-setting-description."..setting.name}, {"reskins-defaults."..tostring(setting.default_value)}}
    end
end

-- Core reskins-lib series settings
data:extend(
{
    -- Startup settings
    {
        type = "bool-setting",
        name = "reskins-lib-icon-tier-labeling",
        setting_type = "startup",
        order = "c",
        default_value = true,
    },
    {
        type = "string-setting",
        name = "reskins-lib-tier-mapping",
        setting_type = "startup",
        order = "cb",
        default_value = "progression-map",
        allowed_values = {"progression-map","traditional-map"}
    },
    {
        type = "string-setting",
        name = "reskins-lib-icon-tier-labeling-style",
        setting_type = "startup",
        order = "ca",
        default_value = "rounded-rectangle",
        allowed_values = {"dots","half-circle","rectangle","rounded-half-circle","rounded-rectangle","teardrop"}
    },
    {
        type = "string-setting",
        name = "reskins-lib-blend-mode",
        setting_type = "startup",
        order = "d",
        default_value = "additive",
        allowed_values = {"additive","additive-soft"}
    },

    -- Reskin scope settings
    {
        type = "bool-setting",
        name = "reskins-lib-scope-entities",
        setting_type = "startup",
        order = "aa",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = "reskins-lib-scope-equipment",
        setting_type = "startup",
        order = "ab",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = "reskins-lib-scope-items-and-fluids",
        setting_type = "startup",
        order = "ac",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = "reskins-lib-scope-technologies",
        setting_type = "startup",
        order = "ad",
        default_value = true,
    },

    -- Runtime settings
    {
        type = "bool-setting",
        name = "reskins-lib-display-notifications",
        setting_type = "runtime-per-user",
        default_value = true,
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
        default_value = "16c746",
    },
    {
        type = "string-setting",
        name = "reskins-lib-custom-colors-tier-6",
        setting_type ="startup",
        order = "yy",
        default_value = "ff7700"
    }
})