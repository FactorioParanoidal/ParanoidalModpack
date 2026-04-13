require("__zzzparanoidal__.paralib")
local function addingMiningdrillbits()
	paralib.bobmods.lib.recipe.add_ingredient("burner-mining-drill", { type = "item", name = "mining-drill-bit-mk0", amount = 1})
	paralib.bobmods.lib.recipe.remove_ingredient("burner-mining-drill", "iron-plate")

	paralib.bobmods.lib.recipe.add_ingredient("electric-mining-drill", { type = "item", name = "mining-drill-bit-mk1", amount = 1})
	paralib.bobmods.lib.recipe.remove_ingredient("burner-mining-drill", "iron-plate")

	paralib.bobmods.lib.recipe.add_ingredient("bob-mining-drill-1", { type = "item", name = "mining-drill-bit-mk2", amount = 1})
	paralib.bobmods.lib.recipe.remove_ingredient("bob-mining-drill-1", "iron-gear-wheel")

	paralib.bobmods.lib.recipe.add_ingredient("bob-mining-drill-2", { type = "item", name = "mining-drill-bit-mk3", amount = 1})

	paralib.bobmods.lib.recipe.add_ingredient("bob-mining-drill-3", { type = "item", name = "mining-drill-bit-mk4", amount = 1})
	paralib.bobmods.lib.recipe.remove_ingredient("bob-mining-drill-3", "bob-titanium-plate")

	paralib.bobmods.lib.recipe.add_ingredient("bob-mining-drill-4", { type = "item", name = "mining-drill-bit-mk5", amount = 1})
	paralib.bobmods.lib.recipe.remove_ingredient("bob-mining-drill-4", "bob-tungsten-carbide")

	paralib.bobmods.lib.recipe.add_ingredient("bob-area-mining-drill-1", { type = "item", name = "mining-drill-bit-mk2", amount = 1})
	paralib.bobmods.lib.recipe.add_ingredient("bob-area-mining-drill-2", { type = "item", name = "mining-drill-bit-mk3", amount = 1})
	paralib.bobmods.lib.recipe.add_ingredient("bob-area-mining-drill-3", { type = "item", name = "mining-drill-bit-mk4", amount = 1})
	paralib.bobmods.lib.recipe.add_ingredient("bob-area-mining-drill-4", { type = "item", name = "mining-drill-bit-mk5", amount = 1})

	paralib.bobmods.lib.recipe.add_ingredient("angels-seafloor-pump", { type = "item", name = "mining-drill-bit-mk2", amount = 1})
end

addingMiningdrillbits()

