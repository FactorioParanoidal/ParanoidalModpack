data:extend({
	{
		type = "recipe-category",
		name = "electronics-or-handcrafting"
	}
})

table.insert(data.raw["assembling-machine"]["assembling-machine-1"].crafting_categories, "electronics-or-handcrafting")
table.insert(data.raw["assembling-machine"]["assembling-machine-2"].crafting_categories, "electronics-or-handcrafting")
table.insert(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories, "electronics-or-handcrafting")
table.insert(data.raw["character"]["character"].crafting_categories, "electronics-or-handcrafting")

if mods["space-age"] then
	table.insert(data.raw["assembling-machine"]["electromagnetic-plant"].crafting_categories, "electronics-or-handcrafting")
end