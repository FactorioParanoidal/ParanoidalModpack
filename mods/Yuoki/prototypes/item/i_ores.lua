data:extend({
	{
		type = "item",
		name = "y-quantrinum",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/quantrinum_icon.png",
		group = "yuoki",
		stack_size = 25,
	},

	-- compressed dirt -> lachnan crystal
	{
		type = "item",
		name = "y-crystal-cnd",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/crystal_3.png",
		group = "yuoki",
		stack_size = 500,
	},

	{
		type = "item",
		name = "y-unicomp-a2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/unicomp_icon.png",
		subgroup = "y-raw-material",
		stack_size = 2500,
	},
	-- dust
	{
		type = "item",
		name = "y-crush-yres1",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/dust-blue.png",
		subgroup = "yuoki-archaeology",
		stack_size = 1000,
		weight = 1 * kg,
	},
	{
		type = "item",
		name = "y-crush-yres2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/dust-green.png",
		subgroup = "yuoki-archaeology",
		stack_size = 1000,
		weight = 1 * kg,
	},
	-- pellets
	{
		type = "item",
		name = "y-refined-yres1",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/n4pellets64_icon.png",
		subgroup = "y-raw-material",
		stack_size = 600,
		weight = 5 * kg,
	},
	{
		type = "item",
		name = "y-refined-yres2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/f7pellets64_icon.png",
		subgroup = "y-raw-material",
		stack_size = 600,
		weight = 5 * kg,
	},
	-- blaue Brocken
	{
		type = "item",
		name = "y-unicomp-raw",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/uni_komp_n4_icon.png",
		subgroup = "y-raw-material",
		stack_size = 500,
		weight = 2 * kg,
	},
	-- raw-fuelnium (shard)
	{
		type = "item",
		name = "y-raw-fuelnium",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/crystal_energy.png",
		subgroup = "y-raw-material",
		stack_size = 900,
	},
	-- fuelnium
	{
		type = "item",
		name = "y-fuel-reactor",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/reactor-fuel.png",
		subgroup = "y-fuel",
		stack_size = 335,
		fuel_category = "yfusion",
		fuel_value = "300MJ",
	},
	-- infused dry-mud
	{
		type = "item",
		name = "y-infused-mud",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/fuel_cell_d_icon.png",
		subgroup = "y-fuel",
		stack_size = 625,
		fuel_category = "chemical",
		fuel_value = "80MJ",
	},
})
