data:extend(
{
	{
		type = "item-group",
		name = "merged-chests",
		order = "wide-chests",
		icon = "__base__/graphics/item-group/logistics.png",
		icon_size = 64,
	},
	{
		type = "item-subgroup",
		name = "wide-chests",
		group = "merged-chests",
		order = "a",
	},
	{
		type = "item-subgroup",
		name = "high-chests",
		group = "merged-chests",
		order = "b",
	},
	{
		type = "item-subgroup",
		name = "warehouse",
		group = "merged-chests",
		order = "c",
	},
	{
		type = "item-subgroup",
		name = "trashdump",
		group = "merged-chests",
		order = "d",
	},
})