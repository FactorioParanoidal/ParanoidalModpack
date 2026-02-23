--скрываем рецепты шариков. технология в prototypes/recipe/alien-artifact.lua
data.raw["recipe"]["bob-alien-artifact-red"].enabled = false
data.raw["recipe"]["bob-alien-artifact-orange"].enabled = false
data.raw["recipe"]["bob-alien-artifact-yellow"].enabled = false
data.raw["recipe"]["bob-alien-artifact-green"].enabled = false
data.raw["recipe"]["bob-alien-artifact-blue"].enabled = false
data.raw["recipe"]["bob-alien-artifact-purple"].enabled = false

data.raw["recipe"]["bob-alien-artifact"].enabled = false
data.raw["recipe"]["bob-alien-artifact-red-from-small"].enabled = false
data.raw["recipe"]["bob-alien-artifact-orange-from-small"].enabled = false
data.raw["recipe"]["bob-alien-artifact-yellow-from-small"].enabled = false
data.raw["recipe"]["bob-alien-artifact-green-from-small"].enabled = false
data.raw["recipe"]["bob-alien-artifact-blue-from-small"].enabled = false
data.raw["recipe"]["bob-alien-artifact-purple-from-small"].enabled = false
-------------------------------------------------------------------------------------------------
--перемещаем рецепты и предметы больших шариков куда следует
data.raw["recipe"]["bob-alien-artifact-red"].group = "bio-processing-alien"
data.raw["recipe"]["bob-alien-artifact-orange"].group = "bio-processing-alien"
data.raw["recipe"]["bob-alien-artifact-yellow"].group = "bio-processing-alien"
data.raw["recipe"]["bob-alien-artifact-green"].group = "bio-processing-alien"
data.raw["recipe"]["bob-alien-artifact-blue"].group = "bio-processing-alien"
data.raw["recipe"]["bob-alien-artifact-purple"].group = "bio-processing-alien"

data.raw["recipe"]["bob-alien-artifact-red"].subgroup = "angels-bio-processing-alien-large"
data.raw["recipe"]["bob-alien-artifact-orange"].subgroup = "angels-bio-processing-alien-large"
data.raw["recipe"]["bob-alien-artifact-yellow"].subgroup = "angels-bio-processing-alien-large"
data.raw["recipe"]["bob-alien-artifact-green"].subgroup = "angels-bio-processing-alien-large"
data.raw["recipe"]["bob-alien-artifact-blue"].subgroup = "angels-bio-processing-alien-large"
data.raw["recipe"]["bob-alien-artifact-purple"].subgroup = "angels-bio-processing-alien-large"

data.raw["item"]["bob-alien-artifact"].group = "bio-processing-alien"
data.raw["item"]["bob-alien-artifact-red"].group = "bio-processing-alien"
data.raw["item"]["bob-alien-artifact-orange"].group = "bio-processing-alien"
data.raw["item"]["bob-alien-artifact-yellow"].group = "bio-processing-alien"
data.raw["item"]["bob-alien-artifact-green"].group = "bio-processing-alien"
data.raw["item"]["bob-alien-artifact-blue"].group = "bio-processing-alien"
data.raw["item"]["bob-alien-artifact-purple"].group = "bio-processing-alien"

data.raw["item"]["bob-alien-artifact"].subgroup = "angels-bio-processing-alien-large"
data.raw["item"]["bob-alien-artifact-red"].subgroup = "angels-bio-processing-alien-large"
data.raw["item"]["bob-alien-artifact-orange"].subgroup = "angels-bio-processing-alien-large"
data.raw["item"]["bob-alien-artifact-yellow"].subgroup = "angels-bio-processing-alien-large"
data.raw["item"]["bob-alien-artifact-green"].subgroup = "angels-bio-processing-alien-large"
data.raw["item"]["bob-alien-artifact-blue"].subgroup = "angels-bio-processing-alien-large"
data.raw["item"]["bob-alien-artifact-purple"].subgroup = "angels-bio-processing-alien-large"

--Фикс огромных аккумуляторов
bobmods.lib.recipe.add_ingredient("bi-bio-accumulator", { type = "item", name = "accumulator", amount = 30 })
--Добавляем осмий в лейт гейм рецепты
bobmods.lib.recipe.add_ingredient("hull-component", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("space-thruster", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("fuel-cell", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("habitation", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("life-support", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("command", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("astrometrics", { type = "item", name = "clowns-plate-osmium", amount = 100 })
bobmods.lib.recipe.add_ingredient("ftl-drive", { type = "item", name = "clowns-plate-osmium", amount = 100 })

--Фикс пластин вольфрама и дешевых труб
bobmods.lib.recipe.set_ingredients("bob-tungsten-carbide-x", {
	{ type = "item", name = "angels-solid-carbon", amount = 8 },
	{ type = "item", name = "bob-tungsten-oxide", amount = 12 },
})

--рецепты для новых донных насосов
bobmods.lib.recipe.set_ingredients("angels-seafloor-pump", {
	{ type = "item", name = "mining-drill-bit-mk1", amount = 3 },
	{ type = "item", name = "pipe", amount = 25 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 10 },
	{ type = "item", name = "iron-plate", amount = 25 },
})

--Разжижители
bobmods.lib.recipe.set_ingredients("angels-liquifier", {
	{ type = "item", name = "iron-plate", amount = 40 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 3 },
	{ type = "item", name = "pipe", amount = 40 },
	{ type = "item", name = "stone-brick", amount = 60 },
})
bobmods.lib.recipe.set_ingredients("angels-liquifier-2", {
	{ type = "item", name = "bob-bronze-alloy", amount = 40 },
	{ type = "item", name = "electronic-circuit", amount = 3 },
	{ type = "item", name = "bob-bronze-pipe", amount = 40 },
	{ type = "item", name = "angels-clay-brick", amount = 60 },
	{ type = "item", name = "angels-liquifier", amount = 2 },
})
bobmods.lib.recipe.set_ingredients("angels-liquifier-3", {
	{ type = "item", name = "bob-aluminium-plate", amount = 40 },
	{ type = "item", name = "advanced-circuit", amount = 3 },
	{ type = "item", name = "bob-brass-pipe", amount = 40 },
	{ type = "item", name = "concrete", amount = 60 },
	{ type = "item", name = "angels-liquifier-2", amount = 2 },
})
bobmods.lib.recipe.set_ingredients("angels-liquifier-4", {
	{ type = "item", name = "bob-titanium-plate", amount = 40 },
	{ type = "item", name = "processing-unit", amount = 3 },
	{ type = "item", name = "bob-titanium-pipe", amount = 40 },
	{ type = "item", name = "refined-concrete", amount = 60 },
	{ type = "item", name = "angels-liquifier-3", amount = 2 },
})
-- --Термальный экстрактор
bobmods.lib.recipe.set_ingredients("angels-thermal-extractor", {
	{ type = "item", name = "bob-aluminium-plate", amount = 24 },
	{ type = "item", name = "advanced-circuit", amount = 5 },
	{ type = "item", name = "bob-brass-pipe", amount = 12 },
	{ type = "item", name = "concrete", amount = 20 },
	{ type = "item", name = "bob-brass-gear-wheel", amount = 12 },
	{ type = "item", name = "intermediate-structure-components", amount = 5 },
})
-- --Хим заводы
bobmods.lib.recipe.set_ingredients("chemical-plant", {
	{ type = "item", name = "iron-plate", amount = 40 },
	{ type = "item", name = "bob-basic-circuit-board", amount = 3 },
	{ type = "item", name = "pipe", amount = 40 },
	{ type = "item", name = "iron-gear-wheel", amount = 25 },
})
bobmods.lib.recipe.set_ingredients("angels-chemical-plant-2", {
	{ type = "item", name = "bob-bronze-alloy", amount = 40 },
	{ type = "item", name = "electronic-circuit", amount = 3 },
	{ type = "item", name = "bob-bronze-pipe", amount = 40 },
	{ type = "item", name = "bob-steel-gear-wheel", amount = 25 },
	{ type = "item", name = "chemical-plant", amount = 2 },
})
bobmods.lib.recipe.set_ingredients("angels-chemical-plant-3", {
	{ type = "item", name = "bob-aluminium-plate", amount = 40 },
	{ type = "item", name = "advanced-circuit", amount = 3 },
	{ type = "item", name = "bob-brass-pipe", amount = 40 },
	{ type = "item", name = "bob-brass-gear-wheel", amount = 25 },
	{ type = "item", name = "angels-chemical-plant-2", amount = 2 },
})
bobmods.lib.recipe.set_ingredients("angels-chemical-plant-4", {
	{ type = "item", name = "bob-titanium-plate", amount = 40 },
	{ type = "item", name = "processing-unit", amount = 3 },
	{ type = "item", name = "bob-titanium-pipe", amount = 40 },
	{ type = "item", name = "bob-titanium-gear-wheel", amount = 25 },
	{ type = "item", name = "angels-chemical-plant-3", amount = 2 },
})

--Исправление цена на бойлеры (SEO)
bobmods.lib.recipe.set_ingredients("bob-boiler-2", {
	{ type = "item", name = "bob-steel-pipe", amount = 15 },
	{ type = "item", name = "boiler", amount = 2 },
	{ type = "item", name = "steel-plate", amount = 20 },
})
bobmods.lib.recipe.set_ingredients("bob-boiler-3", {
	{ type = "item", name = "bob-brass-pipe", amount = 15 },
	{ type = "item", name = "bob-boiler-2", amount = 2 },
	{ type = "item", name = "bob-invar-alloy", amount = 20 },
})
bobmods.lib.recipe.set_ingredients("bob-boiler-4", {
	{ type = "item", name = "bob-ceramic-pipe", amount = 15 },
	{ type = "item", name = "bob-boiler-3", amount = 2 },
	{ type = "item", name = "bob-tungsten-plate", amount = 20 },
})
bobmods.lib.recipe.set_ingredients("bob-boiler-5", {
	{ type = "item", name = "bob-copper-tungsten-pipe", amount = 15 },
	{ type = "item", name = "bob-boiler-4", amount = 2 },
	{ type = "item", name = "bob-copper-tungsten-alloy", amount = 20 },
})

bobmods.lib.recipe.set_ingredients("inserter", {
	{ type = "item", name = "electric-motor", amount = 2 },
	{ type = "item", name = "burner-filter-inserter", amount = 1 },
	{ type = "item", name = "electronic-circuit", amount = 4 },
}) --в рецепт к фильтрующему добавляем фитльтрующий твердотопливный
--13.08 починка рецепта кристаллического раствора
bobmods.lib.recipe.set_ingredients("angels-crystal-powder-slurry", {
	{ type = "item", name = "angels-crystal-powder", amount = 10 },
	{ type = "fluid", name = "angels-water-purified", amount = 10 },
})
bobmods.lib.recipe.set_result(
	"angels-crystal-powder-slurry",
	{ name = "angels-crystal-slurry", type = "fluid", amount = 10 }
)
--19.08 починка рецепта взрывчатки 3
data.raw["recipe"]["angels-solid-trinitrotoluene"].category = "angels-advanced-chemistry"

--добавление табличек holographic_signs в технологию (AKMF)
if data.raw.recipe["hs_holo_sign"] then
	data.raw["recipe"]["hs_holo_sign"].enabled = false
	bobmods.lib.tech.add_recipe_unlock("circuit-network", "hs_holo_sign")
end

--Убрана левая печь из электо печи для сплавов (AKMF)
bobmods.lib.recipe.remove_ingredient("bob-electric-mixing-furnace", "bob-electric-chemical-furnace")
KaoExtended.recipe.add_to_recipe(
	"bob-electric-mixing-furnace",
	{ type = "item", name = "electric-furnace", amount = 1 }
)

-- Unlock iron-stick by default
bobmods.lib.recipe.enabled("iron-stick", true)
