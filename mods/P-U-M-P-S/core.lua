------------------
---- data.lua ----
------------------

-- Settings host
local water_pumpjacks = OSM.lib.get_setting_boolean("osm-pumps-enable-ground-water-pumpjacks")

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
	icon = "__core__/graphics/empty.png",
    icon_size = 1,
	energy_required = 1,
	ingredients = {},
	results =
	{
		{type = "fluid", name = "water", amount = 300}
	},
	subgroup = "fluid-recipes",
	allow_decomposition = false
}	data:extend({water_offshore})

-- Water [recipe - pumpjack]
local water_ground =
{
	type = "recipe",
	name = "water-ground",
	category = "pump-water",
	hidden = true,
	hide_from_stats = false,	
	icon = "__core__/graphics/empty.png",
	icon_size = 1,
	energy_required = 1,
	ingredients = {},
	results =
	{
		{type = "fluid", name = "water", amount = 150}
	},
	subgroup = "fluid-recipes",
	allow_decomposition = false
}	data:extend({water_ground})

OSM.utils.make_collision_layer("offshore-pump", {"water-tile"}, "offshore-pump")