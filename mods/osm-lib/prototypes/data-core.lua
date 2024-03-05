------------------
---- data.lua ----
------------------

-- Host local variables
local icons_path = OSM.lib.graphics.."/icons/core/"

-- Make item group [removed items]
local item_group =
{
	type = "item-group",
	name = "OSM-removed",
	icon = icons_path.."OSM-removed.png",
	icon_size = 128,
	icon_mipmaps = 2,
	inventory_order = "zzzz-a",
	order = "zzzz-a",
	localised_name = {"", "Disabled prototypes"}
}	data:extend({item_group})

local item_subgroup =
{
	group = "OSM-removed",
	type = "item-subgroup",
	name = "OSM-removed",
	order = "a"
}	data:extend({item_subgroup})

local recipe_category =
{
    type = "recipe-category",
    name = "OSM-removed"
}	data:extend({recipe_category})

-- Make item group [placeholder items]
local item_group =
{
	type = "item-group",
	name = "OSM-placeholder",
	icon = icons_path.."LSD-25.png",
	icon_size = 128,
	icon_mipmaps = 2,
	inventory_order = "zzzz",
	order = "zzzz",
	localised_name = {"", "Placeholders"}
}	data:extend({item_group})

local item_subgroup =
{
	group = "OSM-placeholder",
	type = "item-subgroup",
	name = "OSM-placeholder",
	order = "a"
}	data:extend({item_subgroup})

-- Make voids
local OSM_void =
{
	type = "item",
	name = "OSM-hoffman-void-recipe",
	icon = icons_path.."albert-hofmann.png",
	icon_size = 64,
	subgroup = "OSM-placeholder",
	flags = {"hidden"},
	order = "*19/04/1943-C20H25N3O*",
	stack_size = 250
}	data:extend({OSM_void})

local OSM_crafting_void =
{
    type = "recipe-category",
    name = "OSM-crafting-void"
}	data:extend({OSM_crafting_void})

-- Make utility sprites
local OSM_red_mark =
{
    type = "sprite",
    name = "OSM-tooltip-red-warning",
    filename = icons_path.."OSM-tooltip-red-warning.png",
    priority = "extra-high-no-scale",
    width = 40,
    height = 40,
    flags = {"gui-icon"},
    mipmap_count = 2,
    scale = 0.5
}	data:extend({OSM_red_mark})

local OSM_orange_mark =
{
    type = "sprite",
    name = "OSM-tooltip-orange-warning",
    filename = icons_path.."OSM-tooltip-orange-warning.png",
    priority = "extra-high-no-scale",
    width = 40,
    height = 40,
    flags = {"gui-icon"},
    mipmap_count = 2,
    scale = 0.5
}	data:extend({OSM_orange_mark})

local OSM_yellow_mark =
{
    type = "sprite",
    name = "OSM-tooltip-yellow-warning",
    filename = icons_path.."OSM-tooltip-yellow-warning.png",
    priority = "extra-high-no-scale",
    width = 40,
    height = 40,
    flags = {"gui-icon"},
    mipmap_count = 2,
    scale = 0.5
}	data:extend({OSM_yellow_mark})

if OSM.debug_mode then
	
	local item_group =
	{
		type = "item-group",
		name = "OSM-warning",
		icon = icons_path.."OSM-warning.png",
		icon_size = 128,
		icon_mipmaps = 2,
		inventory_order = "zzzz-b",
		order = "zzzz-b",
		localised_name = {"", "Disabled prototypes"}
	}	data:extend({item_group})
	
	local item_subgroup =
	{
		group = "OSM-warning",
		type = "item-subgroup",
		name = "OSM-warning",
		order = "a"
	}	data:extend({item_subgroup})
end