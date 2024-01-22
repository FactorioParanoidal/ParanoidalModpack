data:extend(
{
	{
		type = 'item-group',
		name = MergingChests.item_group_names.merged_chests,
		order = 'wide-chests',
		icon = '__base__/graphics/item-group/logistics.png',
		icon_size = 64,
	},
	{
		type = 'item-subgroup',
		name = MergingChests.item_group_names.wide_chests,
		group = MergingChests.item_group_names.merged_chests,
		order = 'a',
	},
	{
		type = 'item-subgroup',
		name = MergingChests.item_group_names.high_chests,
		group = MergingChests.item_group_names.merged_chests,
		order = 'b',
	},
	{
		type = 'item-subgroup',
		name = MergingChests.item_group_names.warehouses,
		group = MergingChests.item_group_names.merged_chests,
		order = 'c',
	},
	{
		type = 'item-subgroup',
		name = MergingChests.item_group_names.trashdumps,
		group = MergingChests.item_group_names.merged_chests,
		order = 'd',
	}
})
