-- Paranoidal fork (Space Age branch, user decision 2026-11-08): the build has module categories of its own (Bob's and
-- the Beta 8 modules: god, green, raw, pollution), and a machine without its own list allows all of them. Upstream gave
-- such machines the vanilla categories only, so the build's modules no longer fitted anywhere. Here a machine without
-- a list gets every module category of the build except the restricted ones: the categories of the planet mods
-- (paranoidal-space-age-filter; the AI cores of Moshine are made for its own computers) unless a mod puts them into
-- default_categories, and restricted_categories. With nothing restricted nothing changes (no list means all
-- categories). See autodetect.lua.
ModuleCategoryDefaults = {
    -- "recipe" is excluded on purpose until another discussion leads to the result that it should be included after all.
    -- Paranoidal: agricultural towers always (data.raw has none without Space Age).
    moduled_types = { "beacon", "assembling-machine", "rocket-silo", "furnace", "lab", "mining-drill", "agricultural-tower" },
    default_categories = { "efficiency", "speed", "productivity" },
    restricted_categories = {},
    processed_prototypes = {},
}

if mods["quality"] then
    table.insert(ModuleCategoryDefaults.default_categories, "quality")
end

ModuleCategoryDefaults.recipe_default_categories = table.deepcopy(ModuleCategoryDefaults.default_categories)

require("autodetect")
