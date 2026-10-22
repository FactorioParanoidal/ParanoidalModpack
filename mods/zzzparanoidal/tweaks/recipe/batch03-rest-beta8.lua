-- Пачка 03 «Остаток науки», решение пользователя (сверка Beta 8 → 2.0, 2026-10-11).
-- Возвращаем Beta 8 только в отмеченных отличиях. Насадка mk5 — в prototypes/recipe/mining-drill-bit.lua.
require("__zzzparanoidal__.paralib")

local function item(name, amount) return { type = "item", name = name, amount = amount } end

local recipes = {
	["bob-nitinol-gear-wheel"] = { ingredients = { item("bob-nitinol-alloy", 1) } },
	["bob-tungsten-gear-wheel"] = { ingredients = { item("tungsten-plate", 1) } },
	["bob-ultimate-underground-belt"] = { time = 0.5 },
	["bob-alien-orange-alloy"] = { ingredients = { item("bob-alien-artifact-orange", 1), item("steel-plate", 10) } },
	-- Аккумуляторный блок поезда МК3: ёмкость, батареи и зарядка Beta 8 (ниже и fuel_value).
	["bet-fuel-3-empty"] = { ingredients = {
		item("steel-plate", 6), item("advanced-circuit", 1), item("processing-unit", 1),
		item("low-density-structure", 1), item("bob-battery-3", 750) } },
	["bet-fuel-3-full"] = { time = 1500 },
}
-- Логистические сундуки 2 снова требуют сундук 1-го уровня.
for _, chest in ipairs({ "active-provider", "buffer", "requester", "passive-provider", "storage" }) do
	recipes["bob-" .. chest .. "-chest-2"] = { ingredients = {
		item("processing-unit", 1), item("bob-brass-chest", 1), item("advanced-circuit", 3), item(chest .. "-chest", 1) } }
end

for name, spec in pairs(recipes) do
	local recipe = data.raw.recipe[name]
	if recipe then
		if spec.time then recipe.energy_required = spec.time end
		if spec.ingredients then recipe.ingredients = spec.ingredients end
	else
		log("zzzparanoidal batch03: recipe not found: " .. name)
	end
end

-- 6 ГДж в 2.0 — следствие стака ракетного топлива 20; в Beta 8 было 3 ГДж.
if data.raw.item["bet-fuel-3-full"] then
	data.raw.item["bet-fuel-3-full"].fuel_value = "3GJ"
end

-- Переработка шлама 8–9 (Beta 8): в Angels 2.0 рецептов нет, создаём по образцу шлама 3.
local base = data.raw.recipe["angels-slag-processing-3"]
local tech = data.raw.technology["angels-slag-processing-3"]
if base and tech then
	local tints = base.icons and base.icons[4] and {
		top = base.icons[2].tint, mid = base.icons[3].tint, bot = base.icons[4].tint }
	local function slag(index, results)
		local names, loc = {}, {}
		for i, r in ipairs(results) do
			names[i] = r.name
			loc[i] = { "item-name." .. r.name }
		end
		local recipe = table.deepcopy(base)
		recipe.name = "angels-slag-processing-" .. index
		recipe.category = "angels-crystallizing-2"
		recipe.energy_required = 8
		recipe.order = "0" .. index
		recipe.main_product = nil
		recipe.results = results
		recipe.localised_name = { "recipe-name.angels-slag_processing_" .. #results, table.unpack(loc) }
		recipe.icons = angelsmods.functions.create_liquid_recipe_icon(names, tints)
		recipe.icon = nil
		data:extend({ recipe })
		paralib.bobmods.lib.tech.add_recipe_unlock("angels-slag-processing-3", recipe.name)
	end
	local function ore(name, probability) return { type = "item", name = name, amount = 1, probability = probability } end
	slag(8, { ore("bob-cobalt-ore", 0.4), ore("tungsten-ore", 0.4) })
	slag(9, { ore("uranium-ore", 0.4), ore("angels-fluorite-ore", 0.2), ore("bob-thorium-ore", 0.005) })
else
	log("zzzparanoidal batch03: angels-slag-processing-3 not found")
end
