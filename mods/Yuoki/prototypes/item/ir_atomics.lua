data:extend({
	-- pure atomic constructs
	yi.lib.recipe.atomics.recipes_make_item("iron-ore", 64, 20, 1, "ore"),
	yi.lib.recipe.atomics.recipes_make_item("copper-ore", 64, 20, 1, "ore"),
	yi.lib.recipe.atomics.recipes_make_item("wood", 64, 20, 1, "ore"),
	yi.lib.recipe.atomics.recipes_make_item("stone", 64, 20, 1, "ore"),
	yi.lib.recipe.atomics.recipes_make_item("coal", 64, 20, 1, "ore"),
	yi.lib.recipe.atomics.recipes_make_item("uranium-ore", 64, 12, 1, "ore"),

	{
		type = "recipe",
		name = "y-ac-slag2uc",
		order = "a",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-slag", amount = 100 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		subgroup = "j-y-atomics-5",
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_down("y-slag"),
		auto_recycle = false,
		allow_quality = false,
	},

	{
		type = "recipe",
		name = "y-ac-crystal2uc",
		order = "d",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-crystal2", amount = 100 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		subgroup = "j-y-atomics-5",
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_down("y-crystal2"),
		auto_recycle = false,
		allow_quality = false,
	},

	-- toxic-dust-recycle
	{
		type = "recipe",
		name = "y-ac-toxic2uc",
		order = "b",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-toxic-dust", amount = 70 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		subgroup = "j-y-atomics-5",
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_down("y-toxic-dust"),
		auto_recycle = false,
		allow_quality = false,
	},

	-- mud-ball-recycle
	{
		type = "recipe",
		name = "y-ac-mud2uc",
		order = "c",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-dry_mud", amount = 30 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		subgroup = "j-y-atomics-5",
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_down("y-dry_mud"),
		auto_recycle = false,
		allow_quality = false,
	},

	-- reverse atomic transfers and ++


	{
		type = "recipe",
		name = "y-ac-uc2plastic",
		order = "a",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		results = {
			{ type = "item", name = "plastic-bar", amount = 8 },
		},
		main_product = "plastic-bar",
		subgroup = "j-y-atomics-16",
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_up("plastic-bar"),
		auto_recycle = false,
		allow_quality = false,
	},


	-- fluid transition
	{
		type = "recipe",
		name = "y-lightoil2uc",
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "light-oil", amount = 100 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		enabled = true,
		icons = yi.lib.recipe.atomics.fluid_down("light-oil"),
		order = "b",
		subgroup = "j-y-atomics-7",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	{
		type = "recipe",
		name = "y-heavyoil2uc",
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "heavy-oil", amount = 100 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		enabled = true,
		icons = yi.lib.recipe.atomics.fluid_down("heavy-oil"),
		order = "c",
		subgroup = "j-y-atomics-7",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	{
		type = "recipe",
		name = "y-lubricant2uc",
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "lubricant", amount = 95 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		enabled = true,
		icons = yi.lib.recipe.atomics.fluid_down("lubricant"),
		order = "e",
		subgroup = "j-y-atomics-7",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	{
		type = "recipe",
		name = "y-petroleum",
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "petroleum-gas", amount = 100 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		enabled = true,
		icons = yi.lib.recipe.atomics.fluid_down("petroleum-gas"),
		order = "d",
		subgroup = "j-y-atomics-7",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	-- only reverse to crude-oil
	{
		type = "recipe",
		name = "y-uc2crudeoil",
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		results = {
			{ type = "fluid", name = "crude-oil", amount = 80 },
		},
		main_product = "crude-oil",
		enabled = true,
		icons = yi.lib.recipe.atomics.fluid_up("crude-oil"),
		order = "a",
		subgroup = "j-y-atomics-14",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	-- full fluid transition
	{
		type = "recipe",
		name = "y-uc2liquid",
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "y-unicomp-a2", amount = 25 },
		},
		results = {
			{ type = "fluid", name = "y-liquid-uc2", amount = 5 },
		},
		main_product = "y-liquid-uc2",
		enabled = true,
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/liquid_a2.png",
		order = "a",
		subgroup = "j-y-atomics-1",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	-- and fluid reverse
	{
		type = "recipe",
		name = "y-liquid2uc",
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "y-liquid-uc2", amount = 5 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 25 },
		},
		main_product = "y-unicomp-a2",
		enabled = true,
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/unicomp_stack.png",
		order = "b",
		subgroup = "j-y-atomics-1",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},

	-- contaminated water to unicomp
	{
		type = "recipe",
		name = "j-cw2uc-recipe",
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "y-con_water", amount = 9100 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 1 },
		},
		main_product = "y-unicomp-a2",
		enabled = true,
		icons = yi.lib.recipe.atomics.fluid_down("y-con_water"),
		order = "a",
		subgroup = "j-y-atomics-7",
		category = "yuoki-atomics",
		auto_recycle = false,
		allow_quality = false,
	},
})
