recipe = data.raw["recipe"]["angels-warehouse"]
recipe.energy_required = 20
recipe.ingredients = {
	{"iron-plate", 500},
	{"stone-brick", 100},
	}

recipe = data.raw["recipe"]["angels-warehouse-passive-provider"]
recipe.energy_required = 20
recipe.ingredients = {
	{"steel-plate", 250},
	{"electronic-circuit", 100},
	{"advanced-circuit", 40},
	{"angels-warehouse", 1},
	}

recipe = data.raw["recipe"]["angels-warehouse-active-provider"]
recipe.energy_required = 20
recipe.ingredients = {
	{"steel-plate", 250},
	{"electronic-circuit", 100},
	{"advanced-circuit", 40},
	{"angels-warehouse", 1},
	}

recipe = data.raw["recipe"]["angels-warehouse-storage"]
recipe.energy_required = 20
recipe.ingredients = {
	{"steel-plate", 250},
	{"electronic-circuit", 100},
	{"advanced-circuit", 40},
	{"angels-warehouse", 1}
	}

recipe = data.raw["recipe"]["angels-warehouse-requester"]
recipe.energy_required = 20
recipe.ingredients = {
	{"steel-plate", 250},
	{"electronic-circuit", 100},
	{"advanced-circuit", 40},
	{"angels-warehouse", 1},
	}

	recipe = data.raw["recipe"]["angels-warehouse-buffer"]
	recipe.energy_required = 20
	recipe.ingredients = {
		{"steel-plate", 250},
		{"electronic-circuit", 100},
		{"advanced-circuit", 40},
		{"angels-warehouse", 1},
		}	

data:extend(
{
	
	{
	type = "recipe",
	name = "warehouse-mk2",
	energy_required = 20,
	enabled = "false",
	ingredients ={
	{"angels-warehouse", 1},
	{"invar-alloy", 400},
	{"brass-gear-wheel", 150},
	{"steel-bearing", 100},
	},
	result= "warehouse-mk2",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse.png",
	icon_size = 32,
	subgroup = "angels-warehouses-2",
	order = "a"
	},

	{
    type = "recipe",
    name = "warehouse-passive-provider-mk2",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"angels-warehouse-passive-provider", 1},
	{"invar-alloy", 400},
	{"brass-gear-wheel", 150},
	{"steel-bearing", 100},
	},
    result= "warehouse-passive-provider-mk2",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-passive-provider.png",
	icon_size = 32,
    subgroup = "angels-warehouses-2",
	order = "b"
    },
	
	{
    type = "recipe",
    name = "warehouse-active-provider-mk2",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"invar-alloy", 400},
	{"brass-gear-wheel", 150},
	{"steel-bearing", 100},
	{"angels-warehouse-active-provider", 1},
	},
    result= "warehouse-active-provider-mk2",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-active-provider.png",
	icon_size = 32,
    subgroup = "angels-warehouses-2",
	order = "c"
    },
	
	{
    type = "recipe",
    name = "warehouse-storage-mk2",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"invar-alloy", 400},
	{"brass-gear-wheel", 150},
	{"steel-bearing", 100},
	{"angels-warehouse-storage", 1},
	},
    result= "warehouse-storage-mk2",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-storage.png",
	icon_size = 32,
    subgroup = "angels-warehouses-2",
	order = "d"
    },
	
	{
    type = "recipe",
    name = "warehouse-requester-mk2",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"invar-alloy", 400},
	{"brass-gear-wheel", 150},
	{"steel-bearing", 100},
	{"angels-warehouse-requester", 1},
	},
    result= "warehouse-requester-mk2",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-requester.png",
	icon_size = 32,
    subgroup = "angels-warehouses-2",
	order = "f"
	},
	
	{
	type = "recipe",
	name = "warehouse-buffer-mk2",
	energy_required = 20,
	enabled = "false",
	ingredients ={
	{"invar-alloy", 400},
	{"brass-gear-wheel", 150},
	{"steel-bearing", 100},
	{"angels-warehouse-buffer", 1},
	},
	result= "warehouse-buffer-mk2",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-buffer.png",
	icon_size = 32,
	subgroup = "angels-warehouses-2",
	order = "e"
	},
	
	{
	type = "recipe",
	name = "warehouse-mk3",
	energy_required = 20,
	enabled = "false",
	ingredients ={
	{"warehouse-mk2", 1},
	{"titanium-plate", 800},
	{"ceramic-bearing", 200},
	},
	result= "warehouse-mk3",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse.png",
	icon_size = 32,
	subgroup = "angels-warehouses-3",
	order = "a"
	},

	{
    type = "recipe",
    name = "warehouse-passive-provider-mk3",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"titanium-plate", 800},
	{"ceramic-bearing", 200},
	{"processing-unit", 200},
	{"warehouse-passive-provider-mk2", 1}
	},
    result= "warehouse-passive-provider-mk3",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-passive-provider.png",
	icon_size = 32,
    subgroup = "angels-warehouses-3",
	order = "b"
    },
	
	{
    type = "recipe",
    name = "warehouse-active-provider-mk3",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"titanium-plate", 800},
	{"ceramic-bearing", 200},
	{"processing-unit", 200},
	{"warehouse-active-provider-mk2", 1},
	},
    result= "warehouse-active-provider-mk3",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-active-provider.png",
	icon_size = 32,
    subgroup = "angels-warehouses-3",
	order = "c"
    },
	
	{
    type = "recipe",
    name = "warehouse-storage-mk3",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"titanium-plate", 800},
	{"ceramic-bearing", 200},
	{"processing-unit", 200},
	{"warehouse-storage-mk2", 1}
	},
    result= "warehouse-storage-mk3",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-storage.png",
	icon_size = 32,
    subgroup = "angels-warehouses-3",
	order = "d"
    },
	
	{
    type = "recipe",
    name = "warehouse-requester-mk3",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"titanium-plate", 800},
	{"ceramic-bearing", 200},
	{"processing-unit", 200},
	{"warehouse-requester-mk2", 1}
	},
    result= "warehouse-requester-mk3",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-requester.png",
	icon_size = 32,
    subgroup = "angels-warehouses-3",
	order = "f"
    },
	
	{
	type = "recipe",
	name = "warehouse-buffer-mk3",
	energy_required = 20,
	enabled = "false",
	ingredients ={
	{"titanium-plate", 800},
	{"ceramic-bearing", 200},
	{"processing-unit", 200},
	{"warehouse-buffer-mk2", 1}
	},
	result= "warehouse-buffer-mk3",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-buffer.png",
	icon_size = 32,
	subgroup = "angels-warehouses-3",
	order = "e"
	},

	{
	type = "recipe",
	name = "warehouse-mk4",
	energy_required = 20,
	enabled = "false",
	ingredients ={
	{"warehouse-mk3", 1},
	{"tungsten-plate", 1000},
	{"nitinol-bearing", 250},
	},
	result= "warehouse-mk4",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse.png",
	icon_size = 32,
	subgroup = "angels-warehouses-4",
	order = "a"
	},

	{
    type = "recipe",
    name = "warehouse-passive-provider-mk4",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"tungsten-plate", 1000},
	{"nitinol-bearing", 250},
	{"advanced-processing-unit", 200},
	{"warehouse-passive-provider-mk3", 1}
	},
    result= "warehouse-passive-provider-mk4",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-passive-provider.png",
	icon_size = 32,
    subgroup = "angels-warehouses-4",
	order = "b"
    },
	
	{
    type = "recipe",
    name = "warehouse-active-provider-mk4",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"tungsten-plate", 1000},
	{"nitinol-bearing", 250},
	{"advanced-processing-unit", 200},
	{"warehouse-active-provider-mk3", 1}
	},
    result= "warehouse-active-provider-mk4",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-active-provider.png",
	icon_size = 32,
    subgroup = "angels-warehouses-4",
	order = "c"
    },

	{
    type = "recipe",
    name = "warehouse-storage-mk4",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"tungsten-plate", 1000},
	{"nitinol-bearing", 250},
	{"advanced-processing-unit", 200},
	{"warehouse-storage-mk3", 1}
	},
    result= "warehouse-storage-mk4",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-storage.png",
	icon_size = 32,
    subgroup = "angels-warehouses-4",
	order = "d"
    },
	
	{
    type = "recipe",
    name = "warehouse-requester-mk4",
    energy_required = 20,
	enabled = "false",
    ingredients ={
	{"tungsten-plate", 1000},
	{"nitinol-bearing", 250},
	{"advanced-processing-unit", 200},
	{"warehouse-requester-mk3", 1}
	},
    result= "warehouse-requester-mk4",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-requester.png",
	icon_size = 32,
    subgroup = "angels-warehouses-4",
	order = "f"
	},
	
	{
	type = "recipe",
	name = "warehouse-buffer-mk4",
	energy_required = 20,
	enabled = "false",
	ingredients ={
	{"tungsten-plate", 1000},
	{"nitinol-bearing", 250},
	{"advanced-processing-unit", 200},
	{"warehouse-buffer-mk3", 1}
	},
	result= "warehouse-buffer-mk4",
	icon = "__angelsaddons-warehouses__/graphics/icons/warehouse-buffer.png",
	icon_size = 32,
	subgroup = "angels-warehouses-4",
	order = "e"
	},
	
})