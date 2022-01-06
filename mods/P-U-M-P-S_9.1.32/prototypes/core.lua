------------------
---- data.lua ----
------------------

-- Water [recipe category]
local recipe_category =
{
	name = "pump-water",
	type = "recipe-category"
}	data:extend({recipe_category})

-- Water [recipe - offshore]
local water_offshore =
{
	type = "recipe",
	name = "water-offshore",
	category = "pump-water",
	hidden = true,
	hide_from_stats = false,	
	icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 64,
	icon_mipmaps = 4,
	energy_required = 1,
	ingredients = {},
	results =
	{
		{type = "fluid", name = "water", amount = 500}
	},
	subgroup = "fluid-recipes",
	allow_decomposition = false
}	data:extend({water_offshore})

-- Water [recipe - pumpjack]
--[[
local water_ground =
{
	type = "recipe",
	name = "water-ground",
	category = "pump-water",
	hidden = true,
	hide_from_stats = false,	
	icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 64,
	icon_mipmaps = 4,
	energy_required = 1,
	ingredients = {},
	results =
	{
		{type = "fluid", name = "water", amount = 150}
	},
	subgroup = "fluid-recipes",
	allow_decomposition = false
}	data:extend({water_ground})
]]--