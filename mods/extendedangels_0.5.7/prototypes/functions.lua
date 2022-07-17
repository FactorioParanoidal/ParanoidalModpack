-- Setup function host
extangels = {}
extangels.triggers = {}

-- Import migration module from flib
extangels.migration = require("__flib__.migration")

-- Append angel numerals and return an icons definition
function extangels.numeral_tier(icon_data, tier, tint)
    local icons = angelsmods.functions.add_number_icon_layer({icon_data}, tier, tint)
    return icons
end