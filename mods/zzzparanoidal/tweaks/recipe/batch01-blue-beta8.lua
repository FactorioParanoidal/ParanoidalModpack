-- Пачка 01 «До синей науки», решение пользователя (сверка Beta 8 → 2.0, 2026-10-11).
-- Возвращаем Beta 8 только в отмеченных отличиях; остальное в рецептах 2.0 не трогаем.
-- После OV.execute, flowfix и поздних портов: значения ниже итоговые.
require("__zzzparanoidal__.paralib")

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end

-- ingredients/results — полный список Beta 8 (все отличия списка отмечены пользователем);
-- time — energy_required; category/additional_categories — набор машин Beta 8.
local recipes = {
	-- Где делать: вручную и в сборочных автоматах, как в Beta 8.
	["angels-solid-wood-pulp"] = { category = "crafting" },
	["deadlock-large-lamp"] = { category = "crafting" },
	["deadlock-floor-lamp"] = { category = "crafting" },
	-- Печи для сплавов вместо доменной печи.
	["angel-solder-alloy-x"] = { category = "bob-mixing-furnace" },
	["gunmetal-alloy-x"] = { category = "bob-mixing-furnace" },
	-- Только автоматы для сборки (включая электронные), без ручной сборки.
	["standart-io"] = { category = "electronics-machine" },

	["bob-basic-underground-belt"] = { time = 1, ingredients = {
		item("bob-basic-transport-belt", 5), item("stone", 2), item("wood", 2) } },
	["bob-basic-splitter"] = { ingredients = {
		item("bob-basic-transport-belt", 5), item("wood", 4), item("iron-gear-wheel", 2), item("copper-cable", 4) } },
	["underground-belt"] = { ingredients = {
		item("bob-basic-underground-belt", 2), item("iron-gear-wheel", 20), item("bob-tin-plate", 14) } },
	["bob-steel-gear-wheel"] = { ingredients = { item("steel-plate", 1) } },
	["bob-electronics-machine-1"] = { time = 5, ingredients = {
		item("iron-plate", 5), item("bob-basic-circuit-board", 5), item("basic-structure-components", 2), item("inserter", 4) } },
	-- Предмет 2.0 сохраняем, рецепт — термиты Beta 8.
	["ammo-nano-levelers"] = { time = 5,
		ingredients = { item("iron-stick", 1), item("bob-basic-circuit-board", 1) },
		results = { item("ammo-nano-levelers", 2) } },
	["ammo-nano-constructors"] = {
		ingredients = { item("iron-stick", 1), item("repair-pack", 1) },
		results = { item("ammo-nano-constructors", 1) } },
	["angelsore-crushed-manganese-processing"] = {
		ingredients = { item("angels-ore8-crushed", 2), item("angels-ore5-crushed", 2), item("angels-catalysator-brown", 1) },
		results = { item("angels-manganese-ore", 4) } },
	["angels-slag-processing-1"] = { time = 2, ingredients = { fluid("angels-mineral-sludge", 50) },
		results = { { type = "item", name = "angels-ore1", amount = 3, probability = 0.9 } } },
	["angels-slag-processing-2"] = { time = 2, ingredients = { fluid("angels-mineral-sludge", 50) },
		results = { { type = "item", name = "angels-ore2", amount = 3, probability = 0.9 } } },
	["angels-slag-processing-3"] = { time = 2, ingredients = { fluid("angels-mineral-sludge", 50) },
		results = { { type = "item", name = "angels-ore3", amount = 3, probability = 0.9 } } },
	["angels-ore-sorting-facility-2"] = { ingredients = {
		item("steel-plate", 36), item("electronic-circuit", 12), item("angels-clay-brick", 60),
		item("bob-steel-gear-wheel", 24), item("basic-structure-components", 2), item("angels-ore-sorting-facility", 2) } },
	["bob-gun-cotton"] = { ingredients = { item("wood", 1), fluid("angels-liquid-nitric-acid", 10) } },
	["big-electric-pole"] = { ingredients = { item("steel-plate", 10), item("copper-cable", 25) } },
	["passive-provider-chest"] = { ingredients = {
		item("steel-chest", 1), item("electronic-circuit", 3), item("advanced-circuit", 1) } },
	["storage-chest"] = { ingredients = {
		item("steel-chest", 1), item("electronic-circuit", 3), item("advanced-circuit", 1) } },
	["storehouse-passive-provider"] = { ingredients = {
		item("storehouse-basic", 1), item("passive-provider-chest", 1), item("iron-stick", 16) } },
	["storehouse-storage"] = { ingredients = {
		item("storehouse-basic", 1), item("storage-chest", 1), item("iron-stick", 16) } },
	["Schall-pickup-tower-R32"] = { time = 30, ingredients = {
		item("radar", 10), item("steel-chest", 10), item("electronic-circuit", 10) } },
	["bob-brass-gear-wheel"] = { ingredients = { item("bob-brass-alloy", 1) } },
	["bob-insulated-cable"] = { time = 15,
		ingredients = { item("bob-rubber", 1), item("bob-tinned-copper-cable", 60) },
		results = { item("bob-insulated-cable", 60) } },
	["bob-radar-2"] = { ingredients = {
		item("electronic-circuit", 5), item("steel-plate", 10), item("bob-steel-gear-wheel", 5), item("radar", 2) } },
	-- Расходится с ПР-040 (турели 2.0): решение пользователя по пачке 01.
	["bob-plasma-turret-1"] = { category = "crafting", ingredients = {
		item("steel-plate", 80), item("electronic-circuit", 80), item("battery", 48),
		item("bob-alien-artifact", 20), item("laser-turret", 4) } },
	["bob-plasma-turret-2"] = { category = "crafting", ingredients = {
		item("steel-plate", 80), item("advanced-circuit", 80), item("battery", 48), item("bob-alien-artifact", 30),
		item("bob-plasma-turret-1", 2), item("bob-laser-turret-2", 2) } },
	["bob-solar-panel-large"] = { ingredients = {
		item("steel-plate", 8), item("electronic-circuit", 24), item("copper-plate", 8), item("basic-structure-components", 3) } },
	["bob-solar-panel-small"] = { ingredients = {
		item("steel-plate", 2), item("electronic-circuit", 6), item("copper-plate", 2), item("basic-structure-components", 1) } },
	["solar-panel"] = { time = 20, ingredients = {
		item("steel-plate", 5), item("electronic-circuit", 5), item("copper-plate", 30), item("basic-structure-components", 2) } },
	["bob-phenolic-board"] = { time = 0.5, ingredients = { item("bob-wooden-board", 2), item("resin", 1) } },
	["advanced-circuit"] = { time = 8, ingredients = {
		item("electronic-circuit", 2), item("bob-electronic-components", 8), item("bob-circuit-board", 2),
		item("bob-tinned-copper-cable", 4), item("bob-solder", 1), item("standart-io", 2), item("condensator2", 8) } },
	["bob-robot-tool-construction"] = { ingredients = { item("steel-plate", 1), item("bob-steel-gear-wheel", 2) } },
	["bob-electronic-components"] = { ingredients = {
		item("plastic-bar", 1), item("angels-wire-silver", 1), item("bob-silicon-wafer", 2) } },
	["electric-engine-unit"] = { ingredients = {
		fluid("lubricant", 60), item("electronic-circuit", 1), item("electric-motor", 2), item("engine-unit", 2) } },
	["storage-tank"] = { ingredients = {
		item("iron-plate", 20), item("steel-plate", 5), item("bob-small-inline-storage-tank", 4) } },
	["bob-storage-tank-all-corners"] = { ingredients = {
		item("iron-plate", 20), item("steel-plate", 5), item("pipe", 2), item("bob-small-storage-tank", 4) } },
	["solar-panel-equipment"] = { time = 10, ingredients = {
		item("steel-plate", 2), item("electronic-circuit", 5), item("copper-cable", 4) } },
	["bob-solar-panel-equipment-2"] = { time = 10, ingredients = {
		item("solar-panel-equipment", 1), item("advanced-circuit", 5), item("bob-glass", 2), item("bob-silver-plate", 2) } },
	["bob-vehicle-battery-equipment-1"] = { ingredients = { item("battery", 5), item("steel-plate", 10) } },
	["bob-vehicle-solar-panel-equipment-1"] = { ingredients = {
		item("steel-plate", 2), item("electronic-circuit", 5), item("copper-cable", 4) } },
	["bob-vehicle-solar-panel-equipment-2"] = { ingredients = {
		item("bob-vehicle-solar-panel-equipment-1", 1), item("advanced-circuit", 5), item("bob-glass", 2), item("bob-silver-plate", 2) } },
}

for name, spec in pairs(recipes) do
	local recipe = data.raw.recipe[name]
	if recipe then
		if spec.category then recipe.category = spec.category end
		if spec.time then recipe.energy_required = spec.time end
		if spec.ingredients then recipe.ingredients = spec.ingredients end
		if spec.results then recipe.results = spec.results end
	else
		log("zzzparanoidal batch01: recipe not found: " .. name)
	end
end

-- Заготовки шестерён: 4 вместо 3, отработанный хладагент без изменений.
for _, name in ipairs({ "angels-iron-gear-wheel-stack-casting-fast", "angels-steel-gear-wheel-stack-casting-fast" }) do
	local recipe = data.raw.recipe[name]
	if recipe then
		for _, result in ipairs(recipe.results or {}) do
			if result.name == recipe.main_product then result.amount = 4 end
		end
	end
end

-- Резина из смолы в печи: видима и открывается «Сетью сигналов», как в Beta 8.
-- OV.disable_recipe Angels оставил заглушку «Что-то пошло не так...» и подгруппу Bob «Материалы Боба»:
-- название снова берётся из результата, место — строка резины нефтехимии после «жидкая резина → резина».
local rubber = data.raw.recipe["bob-rubber"]
if rubber then
	rubber.hidden = false
	rubber.enabled = false
	rubber.localised_name = nil
	if data.raw["item-subgroup"]["paranoidal-petrochem-rubber-products"] then
		rubber.subgroup = "paranoidal-petrochem-rubber-products"
		rubber.order = "03-b"
	end
	paralib.bobmods.lib.tech.add_recipe_unlock("circuit-network", "bob-rubber")
end

-- Шлам → дживолит: открытие переработкой шлама 2, как в Beta 8.
paralib.bobmods.lib.tech.remove_recipe_unlock("angels-slag-processing-1", "angels-slag-processing-2")
paralib.bobmods.lib.tech.add_recipe_unlock("angels-slag-processing-2", "angels-slag-processing-2")

-- Плазменные турели I–II снова на зелёной науке: предки Beta 8 вместо материалов рецептов 2.0.
-- Лазерные турели II у плазмы II оставлены (ПР-040, зелёная ступень).
if data.raw.technology["bob-plasma-turrets-1"] then
	data.raw.technology["bob-plasma-turrets-1"].prerequisites = { "laser-turret" }
end
if data.raw.technology["bob-plasma-turrets-2"] then
	data.raw.technology["bob-plasma-turrets-2"].prerequisites = { "bob-plasma-turrets-1", "advanced-circuit", "bob-laser-turrets-2" }
end

-- Получение углерода II (coke-purification-2 Beta 8): в Angels 2.0 рецепта нет.
local carbon = data.raw.recipe["angels-solid-carbon"]
local carbon_item = data.raw.item["angels-solid-carbon"]
if carbon and carbon_item and data.raw.technology["angels-coal-processing-2"] then
	local recipe = table.deepcopy(carbon)
	recipe.name = "angels-coke-purification-2"
	recipe.localised_name = { "item-name.angels-solid-carbon" }
	recipe.order = "045"
	recipe.enabled = false
	recipe.main_product = nil
	recipe.ingredients = {
		item("angels-solid-coke", 4), item("angels-solid-sodium-hydroxide", 1), fluid("angels-gas-nitrogen", 30) }
	recipe.results = {
		item("angels-solid-carbon", 6), item("angels-solid-sodium-carbonate", 1), fluid("water", 10) }
	local icons = carbon_item.icons and table.deepcopy(carbon_item.icons)
		or { { icon = carbon_item.icon, icon_size = carbon_item.icon_size or 64 } }
	recipe.icons = angelsmods.functions.add_number_icon_layer(icons, 2, angelsmods.petrochem.number_tint)
	recipe.icon = nil
	data:extend({ recipe })
	paralib.bobmods.lib.tech.add_recipe_unlock("angels-coal-processing-2", "angels-coke-purification-2")
end
