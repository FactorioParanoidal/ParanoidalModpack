-- Paranoidal fork: Yuoki agronomy as a near-end-game "bio-economy that feeds transmutation" (user decision
-- 2026-10-24, AGRONOMY.md): biomaterials stay the only source for Yuoki energy parts; exports pay in Yuoki currency
-- instead of vanilla science packs; Angels waste feeds the farms; the entry costs production science; Yuoki corn
-- and Angels corn are exchangeable. Smoker, extra fish, extra cans and packages were removed (removed-names.lua).
local P = require("prototypes.paranoidal.lib")

-- expensive entry: the first seeds come from Angels crops, the first DNA from production science or trade
P.ingredients("ye-seed_a1", { { "angels-solid-corn", 20 }, { "angels-solid-fertilizer", 10 },
	{ "production-science-pack", 1 } })
P.set("ye-seed_a1", { energy_required = 10 })
P.ingredients("ye_seed_b", { { "ye_corn_a", 20 }, { "angels-solid-fertilizer", 10 }, { "production-science-pack", 1 } })
P.results("ye_seed_b", { { "ye_seed_b", 1 }, { "y_greensign", 5 } }, "ye_seed_b")
P.ingredients("ye_dna_animal0", { { "production-science-pack", 20 }, { "chemical-science-pack", 10 } })

-- forage B without vanilla fish (the fish breeding recipe was removed): Krutags instead
P.ingredients("ye_futtermittel_c", { { "ye_celluose", 1 }, { "ye_fish2", 4 }, { "ye_sugar", 8 } })

-- the DNA splicer is assembled normally (it was an Atomic Quantum Composer recipe, i.e. after the alien tier)
P.set("ye_dnasplicer", { category = "crafting" })

-- exports pay in Yuoki currency instead of vanilla science packs
P.results("ye_buechse_gelb_export", { { "ypfw_trader_sign", 400 }, { "y-unicomp-a2", 1 } }, "ypfw_trader_sign")
P.results("ye_buechse_weiss_export", { { "ypfw_trader_sign", 800 }, { "y-unicomp-a2", 4 } }, "ypfw_trader_sign")

data:extend({
	-- DNA can also be bought through the Laika-Gate / Trade Node
	{
		type = "recipe",
		name = "ye_dna_import",
		category = "yuoki-stargate",
		energy_required = 10,
		enabled = false,
		ingredients = { { type = "item", name = "ypfw_trader_sign", amount = 2000 } },
		results = { { type = "item", name = "ye_dna", amount = 1 } },
		main_product = "ye_dna",
		subgroup = "y-stargate-4",
		order = "d-dna",
	},
	-- Yuoki corn <-> Angels corn (from JATMN Fixes; lossy both ways)
	{
		type = "recipe",
		name = "ye-corn-to-angels",
		energy_required = 4,
		enabled = false,
		ingredients = { { type = "item", name = "ye_corn_a", amount = 10 } },
		results = { { type = "item", name = "angels-solid-corn", amount = 4 } },
		main_product = "angels-solid-corn",
		subgroup = "yie_agroproducts",
		order = "a-corn-1",
	},
	{
		type = "recipe",
		name = "ye-corn-from-angels",
		energy_required = 4,
		enabled = false,
		ingredients = { { type = "item", name = "angels-solid-corn", amount = 4 } },
		results = { { type = "item", name = "ye_corn_a", amount = 8 } },
		main_product = "ye_corn_a",
		subgroup = "yie_agroproducts",
		order = "a-corn-2",
	},
	-- Angels waste water feeds the farm (substratin) and gives contaminated water for UC-A2
	{
		type = "recipe",
		name = "ye_grow_plant1_waste",
		category = "yrcat-farm",
		energy_required = 450,
		enabled = false,
		ingredients = {
			{ type = "item", name = "ye_base_green", amount = 1 },
			{ type = "fluid", name = "angels-water-yellow-waste", amount = 80 },
		},
		results = {
			{ type = "item", name = "ye_substrat", amount = 80 },
			{ type = "item", name = "ye_zells", amount = 3 },
		},
		main_product = "ye_substrat",
		subgroup = "yie_agroproducts",
		order = "s-substratin-2",
	},
	{
		type = "recipe",
		name = "y-yellow-waste-purification",
		category = "angels-water-treatment",
		energy_required = 1,
		enabled = false,
		ingredients = { { type = "fluid", name = "angels-water-yellow-waste", amount = 100 } },
		results = {
			{ type = "fluid", name = "y-con_water", amount = 20 },
			{ type = "fluid", name = "angels-water-purified", amount = 70 },
			{ type = "item", name = "sulfur", amount = 1 },
		},
		main_product = "y-con_water",
		subgroup = "yie_agroproducts",
		order = "w-waste",
	},
})

-- Merchant Signs are earned by selling Yuoki goods through the Laika-Gate / Trade Node (their by-product sources in
-- machines, robots and ammunition were removed); starting rates
local function export(name, item, amount, signs, order)
	data:extend({
		{
			type = "recipe",
			name = name,
			category = "yuoki-stargate",
			energy_required = 5,
			enabled = false,
			ingredients = { { type = "item", name = item, amount = amount } },
			results = { { type = "item", name = "ypfw_trader_sign", amount = signs } },
			main_product = "ypfw_trader_sign",
			icons = {
				{ icon = data.raw.item[item].icon, icon_size = data.raw.item[item].icon_size or 64 },
				{ icon = "__Yuoki__/graphics/icons/atomics/atomics-up-arrow.png", icon_size = 128, scale = 0.25 },
			},
			subgroup = "y-stargate-4",
			order = order,
		},
	})
end
export("y-export-krakon", "y-orange-stuff", 20, 40, "a-export-1")
export("y-export-chips", "y-chip-2", 10, 120, "a-export-2")
export("y-export-fuel-cells", "y-fuel-reactor", 5, 60, "a-export-3")
