data:extend {{
    type = "double-setting",
    name = "maraxsis-water-opacity",
    setting_type = "startup",
    default_value = 255,
    minimum_value = 0,
    maximum_value = 255,
    order = "b"
}}

data:extend {{
    type = "bool-setting",
    name = "maraxsis-add-hydraulic-science",
    setting_type = "startup",
    default_value = true,
    order = "a"
}}

data:extend {{
    type = "bool-setting",
    name = "maraxsis-runtime-entity-replacement",
    setting_type = "startup",
    default_value = true,
    order = "a",
    hidden = true,
    forced_value = true,
}}

data:extend {{
    type = "bool-setting",
    name = "maraxsis-fish-rocket",
    setting_type = "startup",
    default_value = true,
    order = "a",
}}

-- Offer Maraxsis as a starting planet for Any Planet Start. The inverted tech
-- tree and the rest of the maraxsis-start content only load when it is picked.
if mods["any-planet-start"] then
    require "maraxsis-start.settings"
end

