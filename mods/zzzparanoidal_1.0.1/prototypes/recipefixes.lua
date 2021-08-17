--замена обычной рыбы на луч санты в рецепте механического паука
bobmods.lib.recipe.replace_ingredient("spidertron", "raw-fish", "alien-fish-3-raw")
--вывод из эксплуатации бесплатного насоса на воду	
data.raw.recipe["ground-water-pump"].hidden = true
data.raw.recipe["ground-water-pump"].enabled = false

for k,v in pairs(data.raw["technology"]["water-treatment"].effects) do
                   if v.recipe=="ground-water-pump" then
                         table.remove(data.raw["technology"]["water-treatment"].effects,k)
                   end
              end


data.raw.recipe["bob-zinc-plate"].hidden = false
data.raw.recipe["bob-nickel-plate"].hidden = false

data.raw.recipe["invar-alloy"].hidden = false
data.raw.recipe["brass-alloy"].hidden = false