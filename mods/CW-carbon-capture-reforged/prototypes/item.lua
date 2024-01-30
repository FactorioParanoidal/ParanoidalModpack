data:extend({
	{
		type = "item",
		name = "CW-air-filter-machine-1",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-1.png",
		icon_size = 64,
		flags = {},
		subgroup = "production-machine",
		order = "e[air-filter-machine-1]",
		place_result = "CW-air-filter-machine-1",
		stack_size = 10
	},
	{
		type = "item",
		name = "CW-air-filter-machine-2",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-2.png",
		icon_size = 64,
		flags = {},
		subgroup = "production-machine",
		order = "e[air-filter-machine-2]",
		place_result = "CW-air-filter-machine-2",
		stack_size = 10
	},
	{
		type = "item",
		name = "CW-air-filter-machine-3",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-3.png",
		icon_size = 64,
		flags = {},
		subgroup = "production-machine",
		order = "e[air-filter-machine-3]",
		place_result = "CW-air-filter-machine-3",
		stack_size = 10
	},
	{
		type = "item",
		name = "CW-air-filter-machine-4",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-4.png",
		icon_size = 64,
		flags = {},
		subgroup = "production-machine",
		order = "e[air-filter-machine-4]",
		place_result = "CW-air-filter-machine-4",
		stack_size = 10
	},
	{
		type = "item",
		name = "CW-air-filter-machine-5",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-5.png",
		icon_size = 64,
		flags = {},
		subgroup = "production-machine",
		order = "e[air-filter-machine-5]",
		place_result = "CW-air-filter-machine-5",
		stack_size = 10
	},
	{
		type = "item",
		name = "CW-air-filter-machine-6",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter-machine-6.png",
		icon_size = 64,
		flags = {},
		subgroup = "production-machine",
		order = "e[air-filter-machine-6]",
		place_result = "CW-air-filter-machine-6",
		stack_size = 10
	},
	{
		type = "item",
		name = "CW-empty-air-filter",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/empty-air-filter.png",
		icon_size = 64,
		icon_mipmaps = 4,
		flags = {},
		subgroup = "raw-material",
		order = "g[plastic-bar]-h[air-filter]", "h[air-filter]-i[empty-air-filter]",
		--order = "f[air-filter]",
		stack_size = 200
	},
	{
		type = "item",
		name = "CW-air-filter",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/air-filter.png",
		icon_size = 64,
		icon_mipmaps = 4,
		flags = {},
		subgroup = "raw-material",
		order = "g[plastic-bar]-h[air-filter]", "h[air-filter]-i[used-air-filter]",
		stack_size = 200
	},
	{
		type = "item",
		name = "CW-used-air-filter",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/used-air-filter.png",
		icon_size = 64,
		icon_mipmaps = 4,
		flags = {},
		subgroup = "raw-material",
		order = "h[air-filter]-i[used-air-filter]",
		stack_size = 200
	},
})
--[[
	{
		type = "fluid",
		name = "CW-polution-sludge",
		default_temperature = 25,
		max_temperature = 100,
		gas_temperature = 100,
		
		icon = "__CW-carbon-capture-reforged__/graphics/icons/sludge.png",
		icon_size = 32,
			
		heat_capacity = "0.1KJ",
		base_color = {r=0.2, g=0.2, b=0.2},
		flow_color = {r=0.6, g=0, b=0},
		
		order = "h[sludge]",
		auto_barrel = true,
	},
	{
		type = "fluid",
		name = "CW-methanol",
		default_temperature = 25,
		max_temperature = 100,
		gas_temperature = 100,
		
		fuel_value = "1MJ",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/methanol.png",
		icon_size = 32,
			
		heat_capacity = "0.1KJ",
		base_color = {r=0.9, g=0.9, b=0.9},
		flow_color = {r=0.3, g=0.3, b=0.3},
		
		order = "h[methanol]",
		auto_barrel = true,
	},

	{
		type = "fluid",
		name = "CW-carbon-dioxide",
		default_temperature = 25,
		max_temperature = 100,
		gas_temperature = 100,
		
		icon = "__CW-carbon-capture-reforged__/graphics/icons/carbon-dioxide.png",
		icon_size = 32,
			
		heat_capacity = "0.1KJ",
		base_color = {r=0.1, g=0.1, b=0.1},
		flow_color = {r=0.5, g=0.5, b=0.5},
		
		order = "h[carbon]",
		auto_barrel = true,
	},
	
	{
		type = "item",
		name = "CW-dry-ice",
		icon = "__CW-carbon-capture-reforged__/graphics/icons/pellets.png",
		icon_size = 32,
		flags = {},
		subgroup = "raw-material",
		order = "f[air-filter]",
		stack_size = 200
	},
]]--