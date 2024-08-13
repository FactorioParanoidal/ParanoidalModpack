data:extend{

-- ITEM SUBGROUP --
--
	{
		type = "item-subgroup",
		name = "realistic-reactors-energy",
		group = "production",
		order = "b-a",
	},


-- ITEMS --
--
	-- Nuclear Reactor
	{
		type = "item",
		name = "realistic-reactor",
		icon = "__UnrealisticReactors__/graphics/icons/nuclear-reactor.png",
		icon_size = 32,
		subgroup = "realistic-reactors-energy",
		order = "f[nuclear-energy]-b[a-realistic-reactor]-a[normal]",
		place_result = "realistic-reactor-normal",
		stack_size = 10,
	},
	-- Reactor Ruin
-- 	{ -- not needed
-- 		type = "item",
-- 		name = "reactor-ruin",
-- 		icon = "__UnrealisticReactors__/graphics/icons/nuclear-reactor.png",
-- 		icon_size = 32,
-- 		subgroup = "realistic-reactors-energy",
-- 		order = "f[nuclear-energy]-b[a-realistic-reactor]-z[ruin]",
-- 		place_result = "reactor-ruin",
-- 		stack_size = 10,
-- 	},
	-- Breeder Reactor
		{
		type = "item",
		name = "breeder-reactor",
		icon = "__UnrealisticReactors__/graphics/icons/breeder-reactor.png",
		icon_size = 32,
		subgroup = "realistic-reactors-energy",
		order = "f[nuclear-energy]-b[a-realistic-reactor]-b[breeder]",
		place_result = "realistic-reactor-breeder",
		stack_size = 10,
	},
	-- Cooling Tower
	{
		type = "item",
		name = "rr-cooling-tower",
		icon = "__UnrealisticReactors__/graphics/icons/cooling-tower.png",
		icon_size = 32,
		subgroup = "realistic-reactors-energy",
		order = "f[nuclear-energy]-d[cooling-tower]",
		place_result = "rr-cooling-tower",
		stack_size = 10,
	},
	-- Sarcophagus
	{
		type = "item",
		name = "reactor-sarcophagus",
		icon = "__UnrealisticReactors__/graphics/icons/sarcophagus2.png",
		icon_size = 32,
		subgroup = "realistic-reactors-energy",
		order = "f[nuclear-energy]-s[sarcophagus]",
		place_result = "reactor-sarcophagus",
		stack_size = 1,
	},
	-- Interface Blueprint Placables
	{
		type = "item",
		name = "realistic-reactor-interface",
		icon = "__UnrealisticReactors__/graphics/icons/nuclear-reactor-interface.png",
		icon_size = 32,
		flags = {"hidden","primary-place-result","only-in-cursor"},
		subgroup = "realistic-reactors-energy",
		order = "z[nuclear-energy]-i[interface]-a[reactor]-a[normal]",
		place_result = "realistic-reactor-interface",
		stack_size = 50,
	},
	{
		type = "item",
		name = "realistic-breeder-interface",
		icon = "__UnrealisticReactors__/graphics/icons/breeder-interface.png",
		icon_size = 32,
		flags = {"hidden","primary-place-result","only-in-cursor"},
		subgroup = "realistic-reactors-energy",
		order = "z[nuclear-energy]-i[interface]-a[reactor]-b[breeder]",
		place_result = "realistic-breeder-interface",
		stack_size = 50,
	},

	-- Dummy Fuel Cell for Reactor Core
	{
		type = "item",
		name = "rr-dummy-fuel-cell",
		flags = {"hidden","hide-from-bonus-gui","hide-from-fuel-tooltip"},
		icon = "__base__/graphics/icons/uranium-fuel-cell.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "r[uranium-processing]-a[uranium-fuel-cell]",
		fuel_category = "nuclear",
		burnt_result = "used-up-uranium-fuel-cell",
		fuel_value = "9223372035GJ",
		stack_size = 50,
	},

}
