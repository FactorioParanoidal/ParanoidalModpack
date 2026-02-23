local function addingMiningdrillbits()
	KaoExtended.recipe.add_to_recipe("burner-mining-drill", { type = "item", name = "mining-drill-bit-mk0", amount = 1})
	bobmods.lib.recipe.remove_ingredient("burner-mining-drill", "iron-plate")

	KaoExtended.recipe.add_to_recipe("electric-mining-drill", { type = "item", name = "mining-drill-bit-mk1", amount = 1})
	bobmods.lib.recipe.remove_ingredient("burner-mining-drill", "iron-plate")

	KaoExtended.recipe.add_to_recipe("bob-mining-drill-1", { type = "item", name = "mining-drill-bit-mk2", amount = 1})
	bobmods.lib.recipe.remove_ingredient("bob-mining-drill-1", "iron-gear-wheel")

	KaoExtended.recipe.add_to_recipe("bob-mining-drill-2", { type = "item", name = "mining-drill-bit-mk3", amount = 1})

	KaoExtended.recipe.add_to_recipe("bob-mining-drill-3", { type = "item", name = "mining-drill-bit-mk4", amount = 1})
	bobmods.lib.recipe.remove_ingredient("bob-mining-drill-3", "bob-titanium-plate")

	KaoExtended.recipe.add_to_recipe("bob-mining-drill-4", { type = "item", name = "mining-drill-bit-mk5", amount = 1})
	bobmods.lib.recipe.remove_ingredient("bob-mining-drill-4", "bob-tungsten-carbide")

	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-1", { type = "item", name = "mining-drill-bit-mk2", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-2", { type = "item", name = "mining-drill-bit-mk3", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-3", { type = "item", name = "mining-drill-bit-mk4", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-4", { type = "item", name = "mining-drill-bit-mk5", amount = 1})

	KaoExtended.recipe.add_to_recipe("angels-seafloor-pump", { type = "item", name = "mining-drill-bit-mk2", amount = 1})
end

addingMiningdrillbits()
