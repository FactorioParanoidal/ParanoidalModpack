-- Paranoidal: reinforced hull of factory buildings (script/hull.lua).
-- Each level reduces the damage factory buildings take; the first one also adds the alarm inside.
-- The wall on the technology picture is added in data-final-fixes (prototypes/hull-icons.lua) from the final wall icons.

local F = "__factorissimo-2-notnotmelon__"
local pf = "p-q-"

local HULL = require("prototypes.hull-config")

for _, hull in ipairs(HULL) do
    local effects = {{
        type = "nothing",
        icon = F .. "/graphics/icon/factory-" .. hull.level .. ".png",
        icon_size = 64,
        effect_description = {"technology-effect.factory-hull", tostring(hull.reduction)},
    }}
    if hull.level == 1 then
        effects[2] = {
            type = "nothing",
            icon = F .. "/graphics/icon/factory-1.png",
            icon_size = 64,
            effect_description = {"technology-effect.factory-hull-alarm"},
        }
    end

    data:extend {{
        type = "technology",
        name = "factory-hull-" .. hull.level,
        icons = {{icon = F .. "/graphics/technology/factory-architecture-" .. hull.level .. ".png", icon_size = 256}},
        localised_description = {"technology-description.factory-hull-" .. hull.level, tostring(hull.reduction)},
        prerequisites = hull.prerequisites,
        effects = effects,
        unit = {count = hull.count, ingredients = hull.ingredients, time = hull.time},
        order = pf .. "e-" .. hull.level,
    }}
end

-- Alarm inside an attacked factory: alarm-2 of the programmable speaker (1 s), played three times.
data:extend {{
    type = "sound",
    name = "factorissimo-alarm",
    filename = "__base__/sound/programmable-speaker/alarm-2.ogg",
    volume = 0.7,
    category = "alert",
}}
