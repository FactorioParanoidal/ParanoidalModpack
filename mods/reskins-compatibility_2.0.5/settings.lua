-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Circuit Processing
if mods["CircuitProcessing"] then
    local circuit_style_locale = {"",
        {"mod-setting-description.reskins-compatibility-do-circuitprocessing-circuit-style"},
        {"reskins-compatibility.reskins-compatibility-do-circuitprocessing-circuit-style-standard"},
        -- {"reskins-compatibility.reskins-compatibility-do-circuitprocessing-circuit-style-tier"},
        "\n\n", {"reskins-defaults.default"}, " [color="..reskins.lib.default_tint.."]", {"string-mod-setting.reskins-compatibility-do-circuitprocessing-circuit-style-colored-standard"}, "[/color]",
    }
    data:extend({
        {
            type = "string-setting",
            name = "reskins-compatibility-do-circuitprocessing-circuit-style",
            setting_type = "startup",
            default_value = "colored-standard",
            allowed_values = {"off", "colored-standard"}, -- "colored-tier"},
            localised_description = circuit_style_locale,
        },
    })
end

if mods["extendedangels"] then
    data:extend({
        {
            type = "bool-setting",
            name = "reskins-compatibility-extendedangels-warehouse-tiering",
            setting_type = "startup",
            default_value = true,
        }
    })
end