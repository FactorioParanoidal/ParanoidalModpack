-- Отдельная платиновая цепочка Paranoidal, без включения Components/Tech Overhaul Angels.
-- Предметы: angelsindustriesgraphics; исследования: собственные иконки 256×256.
-- Исходные компоненты Angels не переопределяются.
local graphics = "__angelsindustriesgraphics__/graphics/"
local definitions = {
    {
        name = "paranoidal-platinum-shield", icon = "cable-shield-5.png", time = 3, category = "advanced-crafting",
        ingredients = { { type = "item", name = "angels-plate-platinum", amount = 1 } },
    },
    {
        name = "paranoidal-platinum-harness", icon = "cable-harness-5.png", time = 5, category = "crafting-with-fluid",
        ingredients = {
            { type = "item", name = "paranoidal-platinum-shield", amount = 1 },
            { type = "item", name = "angels-wire-platinum", amount = 1 },
            { type = "fluid", name = "angels-liquid-plastic", amount = 1 },
        },
    },
    {
        name = "paranoidal-platinum-servo", icon = "servo-motor-5.png", time = 6, category = "advanced-crafting",
        ingredients = {
            { type = "item", name = "paranoidal-platinum-harness", amount = 2 },
            { type = "item", name = "electric-engine-unit", amount = 1 },
            { type = "item", name = "bob-advanced-processing-unit", amount = 1 },
        },
    },
}
data:extend({ { type = "item-subgroup", name = "paranoidal-platinum-components", group = "intermediate-products", order = "zz-platinum" } })
for index, definition in ipairs(definitions) do
    data:extend({
        {
            type = "item", name = definition.name, icon = graphics .. "icons/" .. definition.icon, icon_size = 32,
            subgroup = "paranoidal-platinum-components", order = tostring(index), stack_size = 200,
        },
        {
            type = "recipe", name = definition.name, icon = graphics .. "icons/" .. definition.icon, icon_size = 32,
            localised_name = { "item-name." .. definition.name },
            subgroup = "paranoidal-platinum-components", order = tostring(index), enabled = false,
            category = definition.category, energy_required = definition.time, allow_productivity = false,
            ingredients = definition.ingredients, results = { { type = "item", name = definition.name, amount = 1 } },
        },
    })
end
local function technology(name, prerequisites, count, recipes, icons)
    local effects = {}
    for _, recipe in ipairs(recipes) do effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe } end
    return {
        type = "technology", name = name, icons = icons,
        prerequisites = prerequisites, effects = effects,
        unit = { count = count, time = 30, ingredients = {
            { "automation-science-pack", 1 }, { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 }, { "production-science-pack", 1 },
        } },
        order = "zz-platinum-" .. name,
    }
end
data:extend({
    technology("paranoidal-platinum-cabling", { "angels-platinum-smelting-1", "angels-plastic-1" }, 100,
        { "paranoidal-platinum-shield", "paranoidal-platinum-harness" }, {
            { icon = "__zzzparanoidal__/graphics/technology/platinum-components/platinum-cabling.png", icon_size = 256 },
        }),
    technology("paranoidal-platinum-servos", { "paranoidal-platinum-cabling", "electric-engine", "bob-advanced-processing-unit" }, 200,
        { "paranoidal-platinum-servo" }, {
            { icon = "__zzzparanoidal__/graphics/technology/platinum-components/platinum-servos.png", icon_size = 256 },
        }),
})
