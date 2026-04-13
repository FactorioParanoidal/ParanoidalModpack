data:extend(
{
	----------------------------------------------------------------------------------
	{
		type = "recipe",
		name = "balloon-light",
		enabled = false,
		ingredients = {
			{type = "item", name ="electronic-circuit", amount = 2},
			{type = "item", name ="iron-stick", amount = 5},
			{type = "item", name ="iron-plate", amount = 2}
		},
		results = { 
			{type = "item",name = "balloon-light",amount = 1,} },
	},
	----------------------------------------------------------------------------------
	{
		type = "recipe",
		name = "short-balloon-light",
		enabled = false,
		ingredients = {
			{type = "item", name ="electronic-circuit", amount = 2},
			{type = "item", name ="iron-stick", amount = 2},
			{type = "item", name ="iron-plate", amount = 2}
		},
		results = { 
			{type = "item", name = "short-balloon-light", amount = 1,} },
	},
	----------------------------------------------------------------------------------
	{
		type = "recipe",
		name = "perfect-night-glasses",
		enabled = false,
		energy_required = 10,
		ingredients = {
			{type = "item", name ="advanced-circuit", amount = 10},
			{type = "item", name ="steel-plate", amount = 20}
		},
		results = {
               {type = "item", name = "perfect-night-glasses", amount = 1,} },
	},
	
}
)

table.insert( data.raw["technology"]["lamp"].effects, { type = "unlock-recipe", recipe = "balloon-light" } )
table.insert( data.raw["technology"]["lamp"].effects, { type = "unlock-recipe", recipe = "short-balloon-light" } )

table.insert( data.raw["technology"]["night-vision-equipment"].effects, { type = "unlock-recipe", recipe = "perfect-night-glasses" } )


