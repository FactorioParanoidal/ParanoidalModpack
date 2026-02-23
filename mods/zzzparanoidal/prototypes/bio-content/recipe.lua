data:extend({
	{
		type = "recipe-category",
		name = "biofarm-mod-farm-2",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-farm-3",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-greenhouse-2",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-greenhouse-3",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-bioreactor-2",
	},
	{
		type = "recipe-category",
		name = "biofarm-mod-bioreactor-3",
	},
})

data:extend({ -- Greenhouse
	{
		type = "recipe",
		name = "bi-bio-greenhouse-2",
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "concrete", amount = 10},
			{ type = "item", name = "deadlock-large-lamp", amount = 5},
			{
				"bi-bio-greenhouse",
				2,
			},
		},
		enabled = false,
		energy_required = 5,
		results = { { type = "item", name = "bi-bio-greenhouse-2", amount = 1 } },
		subgroup = "bio-bio-farm-fluid-entity",
		order = "aa[bi]",
	},
	{
		type = "recipe",
		name = "bi-bio-greenhouse-3",
		ingredients = {
			{ type = "item", name = "plastic-bar", amount = 10},
			{ type = "item", name = "refined-concrete", amount = 10},
			{ type = "item", name = "deadlock-large-lamp", amount = 5},
			{ type = "item", name = "bi-bio-greenhouse-2", amount = 2},
		},
		enabled = false,
		energy_required = 5,
		results = { { type = "item", name = "bi-bio-greenhouse-3", amount = 1 } },
		subgroup = "bio-bio-farm-fluid-entity",
		order = "aaa[bi]",
	}, -- BioFarm
	{
		type = "recipe",
		name = "bi-bio-farm-2",
		ingredients = {
			{ type = "item", name = "bi-bio-farm", amount = 2},
			{ type = "item", name = "bi-bio-greenhouse-2", amount = 4},
			{ type = "item", name = "concrete", amount = 40},
			{ type = "item", name = "wood", amount = 50},
			{ type = "item", name = "bob-steel-pipe", amount = 30},
		},
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-farm-2", amount=1}},
		subgroup = "bio-bio-farm-fluid-entity",
		order = "bb[bi]",
	},
	{
		type = "recipe",
		name = "bi-bio-farm-3",
		ingredients = {
			{ type = "item", name = "bi-bio-farm-2", amount = 2},
			{ type = "item", name = "bi-bio-greenhouse-3", amount = 4},
			{ type = "item", name = "refined-concrete", amount = 40},
			{ type = "item", name = "wood", amount = 100},
			{ type = "item", name = "bob-brass-pipe", amount = 30},
		},
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-farm-3", amount=1}},
		subgroup = "bio-bio-farm-fluid-entity",
		order = "bbb[bi]",
	}, -- BIOREACTOR
	{
		type = "recipe",
		name = "bi-bio-reactor-2",
		ingredients = { { type = "item", name = "bi-bio-reactor", amount = 2}, { type = "item", name = "bob-aluminium-plate", amount = 20}, { type = "item", name = "electronic-circuit", amount = 5} },
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-reactor-2", amount=1}},
		subgroup = "bio-bio-fuel-fluid",
		order = "aa",
	},
	{
		type = "recipe",
		name = "bi-bio-reactor-3",
		ingredients = { { type = "item", name = "bi-bio-reactor-2", amount = 2}, { type = "item", name = "plastic-bar", amount = 20}, { type = "item", name = "advanced-circuit", amount = 5} },
		enabled = false,
		energy_required = 5,
		results ={{type="item", name= "bi-bio-reactor-3", amount=1}},
		subgroup = "bio-bio-fuel-fluid",
		order = "aaa",
	},
})
