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

local entity_void =
{
	type = "simple-entity-with-force",
	name = "OSM-offshore-pump-collision-layer",
	subgroup = "OSM-placeholder",
	collision_mask = {"water-tile"},
	icon = "__osm-lib__/graphics/icons/utils/collision-layer.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {"not-repairable", "not-on-map", "not-blueprintable", "not-deconstructable", "hidden"},
	order = "offshore-pump-collision-placeholder",
	max_health = 100,
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{0, 0}, {0, 0}},
	tile_width = 1,
	tile_height = 1,
	picture = require("utils.animation").animation_void(),
	selectable_in_game =  false,
	squeak_behaviour = false
}	data:extend({entity_void})