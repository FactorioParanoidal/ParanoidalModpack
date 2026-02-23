--замена обычной рыбы на луч санты в рецепте механического паука
bobmods.lib.recipe.replace_ingredient("spidertron", "raw-fish", "angels-alien-fish-3-raw")
--вывод из эксплуатации бесплатного насоса на воду
data.raw.recipe["angels-ground-water-pump"].hidden = true
data.raw.recipe["angels-ground-water-pump"].enabled = false

for k, v in pairs(data.raw["technology"]["angels-water-treatment"].effects) do
	if v.recipe == "angels-ground-water-pump" then
		table.remove(data.raw["technology"]["angels-water-treatment"].effects, k)
	end
end

data.raw.recipe["bob-zinc-plate"].hidden = false
data.raw.recipe["bob-nickel-plate"].hidden = false

data.raw.recipe["bob-invar-alloy"].hidden = false
data.raw.recipe["bob-brass-alloy"].hidden = false

--ребаланс сортировки из KaoExtended
data.raw.recipe["angelsore-crushed-manganese-processing"].results[1].amount = 4
data.raw.recipe["angelsore-pure-chrome-processing"].results[1].amount = 3
data.raw.recipe["angelsore-pure-platinum-processing"].results[1].amount = 2
data.raw.recipe["angelsore-crushed-manganese-processing"].category = "angels-ore-sorting-2"
data.raw.recipe["angelsore-pure-chrome-processing"].category = "angels-ore-sorting-3"
data.raw.recipe["angelsore-pure-platinum-processing"].category = "angels-ore-sorting-3"
angelsmods.functions.allow_productivity("angelsore-crushed-manganese-processing")
angelsmods.functions.allow_productivity("angelsore-pure-chrome-processing")
angelsmods.functions.allow_productivity("angelsore-pure-platinum-processing")
