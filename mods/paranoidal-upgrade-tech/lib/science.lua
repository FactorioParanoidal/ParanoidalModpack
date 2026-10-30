-- Science pack sets for technology units.
-- Beta 8 used only prefixes of the vanilla pack order for these chains, so a set is "the first N packs".

local science = {}

science.order = {
    "automation-science-pack",
    "logistic-science-pack",
    "chemical-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "space-science-pack",
}

-- Index of every pack in science.order, so a set can be named by its last pack: science.upto("chemical-science-pack").
local position = {}
for index, name in ipairs(science.order) do position[name] = index end

-- Ingredients {{pack, 1}, ...} from the first pack up to and including `last`.
function science.upto(last)
    local count = position[last]
    if not count then error("paranoidal-upgrade-tech: unknown science pack '" .. tostring(last) .. "'") end
    local ingredients = {}
    for index = 1, count do ingredients[index] = {science.order[index], 1} end
    return ingredients
end

return science
