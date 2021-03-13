-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

local valid_prefix = {
    "reskins%-lib",
    "reskins%-bobs",
    "reskins%-angels",
    "reskins%-compatibility",
}

-- Iterate through the boolean settings table and grab all the reskins settings and set the description
for _, setting in pairs(data.raw["bool-setting"]) do
    for _, prefix in pairs(valid_prefix) do
        if string.find(setting.name, prefix) then
            setting.localised_description = reskins.lib.concatenate_setting_description(setting)
            goto continue
        end
    end

    ::continue::
end