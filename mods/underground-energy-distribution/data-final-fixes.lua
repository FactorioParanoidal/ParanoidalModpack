-- Paranoidal (Beta 8): the large board also needs structure components.
if data.raw.item["intermediate-structure-components"] then
	data.raw.recipe["ued-large-db"].ingredients = {
		{type = "item", name = "substation", amount = 1},
		{type = "item", name = "copper-plate", amount = 20},
		{type = "item", name = "steel-plate", amount = 5},
		{type = "item", name = "intermediate-structure-components", amount = 3},
	}
end
