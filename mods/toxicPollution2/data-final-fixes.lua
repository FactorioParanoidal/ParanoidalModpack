-- Recipe integration: respirator is the first step in the armor upgrade chain
-- (light-armor → heavy-armor → modular → power → mk2). In 1.1 aai-industry did
-- this; its 2.0 version dropped the respirator step. Do it ourselves so the
-- chain remains complete whenever toxicPollution is installed.

local function add_ingredient_once(recipe_name, ingredient)
    local r = data.raw.recipe[recipe_name]
    if not r or not r.ingredients then return end
    for _, it in pairs(r.ingredients) do
        if (it.name or it[1]) == ingredient.name then return end
    end
    table.insert(r.ingredients, ingredient)
end

if data.raw.armor["respirator"] and data.raw.recipe["light-armor"] then
    add_ingredient_once("light-armor", { type = "item", name = "respirator", amount = 1 })
end

-- Armor max-durability lookup table for runtime. Factorio 2.0 removed
-- LuaItemPrototype.durability — durability is only on LuaItemStack now. We
-- capture max durability per armor here so runtime can compute "% remaining"
-- and find best/worst armors in inventory.
local armor_durability = {}
for name, armor in pairs(data.raw.armor) do
    armor_durability[name] = armor.durability or 0
end
data:extend({
    {
        type = "mod-data",
        name = "toxicPollution2-armor-durability",
        data = armor_durability,
    },
})
