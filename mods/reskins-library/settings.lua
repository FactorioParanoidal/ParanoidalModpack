-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Make our function host
if not reskins then reskins = {} end
if not reskins.lib then reskins.lib = {} end
reskins.lib.default_tint = "#9cdcfe"

---Sets the hidden flag to true and optionally overrides the default value
---@param setting_type '"bool-setting"'|'"double-setting"'|'"int-setting"'|'"string-setting"'
---@param setting_name string
---@param override_value any
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
                setting.allowed_values = { override_value }
            end
        end
    end
end

-- Concatenate the mod description string with the default description string for boolean settings
-- Note that an empty mod setting description is possible, but cannot be detected, and so blank newlines will be present for such settings
function reskins.lib.concatenate_setting_description(setting)
    -- Check for an already set localised_description
    if setting.localised_description then
        return { "", setting.localised_description, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults." .. tostring(setting.default_value) } }
    else
        return { "", { "mod-setting-description." .. setting.name }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults." .. tostring(setting.default_value) } }
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
            allowed_values = { "progression-map", "traditional-map" },
            localised_description = { "", { "mod-setting-description.reskins-lib-tier-mapping" }, "\n\n", { "reskins-defaults.default" }, " [color=" .. reskins.lib.default_tint .. "]", { "string-mod-setting.reskins-lib-tier-mapping-progression-map" }, "[/color]" },
        },
        {
            type = "string-setting",
            name = "reskins-lib-icon-tier-labeling-style",
            setting_type = "startup",
            order = "ca",
            default_value = "rounded-rectangle",
            allowed_values = { "chevron", "dots", "half-circle", "rectangle", "rounded-half-circle", "rounded-rectangle", "teardrop" },
            localised_description = { "", { "mod-setting-description.reskins-lib-icon-tier-labeling-style" }, "\n\n", { "reskins-defaults.default" }, " [color=" .. reskins.lib.default_tint .. "]", { "string-mod-setting.reskins-lib-icon-tier-labeling-style-rounded-rectangle" }, "[/color]" },
        },
        {
            type = "string-setting",
            name = "reskins-lib-blend-mode",
            setting_type = "startup",
            order = "d",
            default_value = "additive",
            allowed_values = { "additive", "additive-soft" },
            localised_description = { "", { "reskins-defaults.default" }, " [color=" .. reskins.lib.default_tint .. "]", { "string-mod-setting.reskins-lib-blend-mode-additive" }, "[/color]" },
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
        {
            type = "bool-setting",
            name = "reskins-lib-scope-interface",
            setting_type = "startup",
            order = "af",
            default_value = true,
        },

        -- Runtime settings
        {
            type = "bool-setting",
            name = "reskins-lib-display-notifications",
            setting_type = "runtime-per-user",
            default_value = true,
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
            setting_type = "startup",
            order = "yy",
            default_value = "808080",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-0" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-0-color" } },
        },
        {
            type = "string-setting",
            name = "reskins-lib-custom-colors-tier-1",
            setting_type = "startup",
            order = "yy",
            default_value = "ffb726",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-1" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-1-color" } },
        },
        {
            type = "string-setting",
            name = "reskins-lib-custom-colors-tier-2",
            setting_type = "startup",
            order = "yy",
            default_value = "f22318",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-2" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-2-color" } },
        },
        {
            type = "string-setting",
            name = "reskins-lib-custom-colors-tier-3",
            setting_type = "startup",
            order = "yy",
            default_value = "33b4ff",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-3" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-3-color" } },
        },
        {
            type = "string-setting",
            name = "reskins-lib-custom-colors-tier-4",
            setting_type = "startup",
            order = "yy",
            default_value = "b459ff",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-4" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-4-color" } },
        },
        {
            type = "string-setting",
            name = "reskins-lib-custom-colors-tier-5",
            setting_type = "startup",
            order = "yy",
            default_value = "2ee55c",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-5" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-5-color" } },
        },
        {
            type = "string-setting",
            name = "reskins-lib-custom-colors-tier-6",
            setting_type = "startup",
            order = "yy",
            default_value = "ff8533",
            localised_description = { "", { "mod-setting-description.reskins-lib-custom-colors-tier-6" }, "\n\n", { "reskins-defaults.default" }, " ", { "reskins-defaults.tier-6-color" } },
        },
    })
