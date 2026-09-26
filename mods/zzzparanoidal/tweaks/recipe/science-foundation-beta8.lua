-- Beta 8 normal: красная наука доступна изначально, химическая выдаёт одну колбу.
-- Ручной крафт 15 научных пакетов восстановлен по отдельному согласованию.
-- Ингредиенты, время, продуктивность и характеристики станков 2.0 не меняем.
local automation = data.raw.recipe["automation-science-pack"]
if automation then automation.enabled = true end

local chemical = data.raw.recipe["chemical-science-pack"]
if chemical then
	chemical.results = { { type = "item", name = "chemical-science-pack", amount = 1 } }
end

-- После позднего запрета ручного крафта науки в AAI data-final-fixes.
-- Только согласованные рецепты: телескопы и sci-компоненты не затрагиваем.
local handcraft = {
	"automation-science-pack", "logistic-science-pack", "chemical-science-pack",
	"military-science-pack", "production-science-pack", "utility-science-pack",
	"bob-advanced-logistic-science-pack", "bob-science-pack-gold", "bob-alien-science-pack",
	"bob-alien-science-pack-blue", "bob-alien-science-pack-orange", "bob-alien-science-pack-purple",
	"bob-alien-science-pack-yellow", "bob-alien-science-pack-green", "bob-alien-science-pack-red",
}
for _, name in ipairs(handcraft) do
	local recipe = data.raw.recipe[name]
	if recipe then recipe.category = "crafting" end
end
