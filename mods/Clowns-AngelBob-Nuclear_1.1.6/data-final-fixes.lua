data.raw.technology["kovarex-enrichment-process"].enabled = false
--data.raw.technology["nuclear-fuel-reprocessing"].enabled = false
data.raw.recipe["advanced-uranium-processing"] = nil

table.insert(data.raw["technology"]["centrifuging-2"].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-65%"})
table.insert(data.raw["technology"]["centrifuging-2"].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-70%"})
table.insert(data.raw["technology"]["centrifuging-2"].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-75%"})
table.insert(data.raw["technology"]["centrifuging-2"].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-80%"})
table.insert(data.raw["technology"]["centrifuging-1"].effects, {type = "unlock-recipe", recipe = "depleted-uranium-reprocessing"})
table.insert(data.raw["technology"]["centrifuging-1"].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-45%"})
table.insert(data.raw["technology"]["centrifuging-1"].effects, {type = "unlock-recipe", recipe = "clowns-centrifuging-55%"})

table.insert(data.raw["technology"]["water-treatment-4"].effects, {type = "unlock-recipe", recipe = "radioactive-waste-water-purification"})


--Add ingredients to thermonuclear bomb
data.raw["recipe"]["thermonuclear-bomb"].ingredients = {}

if mods["bobmodules"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"speed-module-6", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"productivity-module-6", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"effectivity-module-6", 3})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"speed-module-3", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"productivity-module-3", 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"effectivity-module-3", 3})
end

if data.raw.item["fusion-reactor-equipment-2"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"fusion-reactor-equipment-2", 1})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"fusion-reactor-equipment", 1})
end

if data.raw.item["advanced-processing-unit"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"advanced-processing-unit", 200})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {"processing-unit", 200})
end
