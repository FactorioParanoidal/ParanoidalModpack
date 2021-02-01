-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Concatenate the mod description string with the default description string for boolean settings
local function concatenate_bool(setting_name, default)
    if default then
        string_default = "true"
    else
        string_default = "false"
    end

    return {"", {"mod-setting-description."..setting_name}, {"reskins-defaults."..string_default}}
end

local valid_prefix = {
    "reskins%-lib",
    "reskins%-bobs",
    "reskins%-angels"
}

-- Iterate through the boolean settings table and grab all the reskins settings and set the description
for _, setting in pairs(data.raw["bool-setting"]) do
    for _, prefix in pairs(valid_prefix) do
        if string.find(setting.name, prefix) then
            setting.localised_description = concatenate_bool(setting.name, setting.default_value)
            goto continue
        end
    end

    ::continue::
end