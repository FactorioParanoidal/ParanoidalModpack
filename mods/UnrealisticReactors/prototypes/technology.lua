data:extend{
	{
		type = "technology",
		name = "breeder-reactors",
		icon = "__UnrealisticReactors__/graphics/technology/breeder-reactors.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "breeder-reactor",
			},
		},
		prerequisites = {"nuclear-power","productivity-module-3","military-4"},
		unit = {
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
			},
			time = 30,
			count = 800,
		},
		order = "a-h-d",
	},
}


do
	local nuclear = data.raw.technology["nuclear-power"]
	table.insert(nuclear.prerequisites, "effectivity-module-2")
	local add = {}
	for i,effect in ipairs(nuclear.effects) do
		if effect.type == "unlock-recipe" then
			if effect.recipe == "nuclear-reactor" then
				table.insert(add, {
					index = 1+i,
					type = "unlock-recipe",
					recipe = "realistic-reactor",
				})
			elseif effect.recipe == "steam-turbine" then
				table.insert(add, {
					index = 1+i,
					type = "unlock-recipe",
					recipe = "rr-cooling-tower",
				})
			end
		end
	end

	table.insert(add, {
		index = 1+#add,
		type = "unlock-recipe",
		recipe = "reactor-sarcophagus",
	})

	for i = #add,1,-1 do
		local effect = add[i]
		table.insert(nuclear.effects, effect.index, effect)
		effect.index = nil
	end
end

