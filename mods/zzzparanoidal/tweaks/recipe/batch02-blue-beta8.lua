-- Пачка 02 «Синяя наука», решение пользователя (сверка Beta 8 → 2.0, 2026-10-11).
-- Возвращаем Beta 8 только в отмеченных отличиях; исследования и их предков не трогаем.
-- Насадки mk3–mk4 — в prototypes/recipe/mining-drill-bit.lua.

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end

-- ingredients/results — полный список Beta 8 с именами 2.0; time — energy_required.
local recipes = {
	-- Только автоматы для сборки электроники, без ручной сборки.
	["advanced-io"] = { category = "electronics-machine" },
	-- 10 руды вместо 50 (Clowns-Nuclear 2.0). Выход U-234 Angels оставлен: он нужен angels-uranium-fuel-cell.
	["uranium-processing"] = { ingredients = { item("uranium-ore", 10) } },
	["storehouse-active-provider"] = { ingredients = {
		item("storehouse-basic", 1), item("active-provider-chest", 1), item("iron-stick", 16) } },
	["storehouse-buffer"] = { ingredients = {
		item("storehouse-basic", 1), item("buffer-chest", 1), item("iron-stick", 16) } },
	["storehouse-requester"] = { ingredients = {
		item("storehouse-basic", 1), item("requester-chest", 1), item("iron-stick", 16) } },
	-- Литьё изолированного провода: вдвое больше расплавов и выхода; открытие 2.0 не меняем.
	["angels-wire-coil-insulated-casting"] = {
		ingredients = { fluid("angels-liquid-rubber", 10), fluid("angels-liquid-molten-tin", 128),
			fluid("angels-liquid-molten-copper", 128), fluid("water", 40) },
		results = { item("angels-wire-coil-insulated", 16) } },
	["angels-wire-coil-insulated-casting-fast"] = {
		ingredients = { fluid("angels-liquid-rubber", 18), fluid("angels-liquid-molten-tin", 224),
			fluid("angels-liquid-molten-copper", 224), fluid("angels-liquid-coolant", 40) },
		results = { item("angels-wire-coil-insulated", 32), fluid("angels-liquid-coolant-used", 40) } },
	["bob-titanium-gear-wheel"] = { ingredients = { item("bob-titanium-plate", 1) } },
	["bob-large-accumulator-2"] = { ingredients = {
		item("accumulator", 1), item("steel-plate", 2), item("advanced-circuit", 2), item("bob-battery-2", 10) } },
	["bob-assembling-machine-4"] = { time = 20, ingredients = {
		item("advanced-circuit", 3), item("bob-aluminium-plate", 9), item("bob-steel-bearing", 5),
		item("bob-brass-gear-wheel", 5), item("intermediate-structure-components", 5), item("assembling-machine-3", 2) } },
	-- Расходится с ПР-040 (турели 2.0): решение пользователя по пачке 02; предки исследования 2.0 оставлены.
	["bob-plasma-turret-3"] = { category = "crafting", ingredients = {
		item("advanced-circuit", 80), item("bob-invar-alloy", 80), item("bob-battery-2", 48),
		item("bob-alien-artifact-orange", 10), item("bob-alien-artifact-blue", 10),
		item("bob-plasma-turret-2", 2), item("bob-laser-turret-3", 2) } },
	-- Только рецепт; открытие 2.0 (bob-solar-energy-2) оставлено.
	["bi-bio-solar-farm"] = { ingredients = {
		item("medium-electric-pole", 25), item("concrete", 400), item("bob-solar-panel-large-2", 10) } },
}

for name, spec in pairs(recipes) do
	local recipe = data.raw.recipe[name]
	if recipe then
		if spec.category then recipe.category = spec.category end
		if spec.time then recipe.energy_required = spec.time end
		if spec.ingredients then recipe.ingredients = spec.ingredients end
		if spec.results then recipe.results = spec.results end
	else
		log("zzzparanoidal batch02: recipe not found: " .. name)
	end
end
