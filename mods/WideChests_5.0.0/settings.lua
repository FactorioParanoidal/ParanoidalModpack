require('init')
require('setting_init')

MergingChests.create_mergeable_chest_setting('wooden-chest', { default_value = 'none', order = '1' })
MergingChests.create_mergeable_chest_setting('iron-chest', { default_value = 'none', order = '2' })
MergingChests.create_mergeable_chest_setting('steel-chest', { order = '3' })

data:extend(
{
	{
		name = MergingChests.setting_names.max_width,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 2,
		default_value = 10,
		order = '02'
	},
	{
		name = MergingChests.setting_names.max_height,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 2,
		default_value = 10,
		order = '03'
	},
	{
		name = MergingChests.setting_names.max_area,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 2,
		default_value = 100,
		order = '04'
	},
	{
		name = MergingChests.setting_names.whitelist,
		type = 'string-setting',
		setting_type = 'startup',
		default_value = 'NxN',
		allow_blank = true,
		order = '05'
	},
	{
		name = MergingChests.setting_names.inventory_size_multiplier,
		type = 'double-setting',
		setting_type = 'startup',
		minimum_value = 0,
		default_value = 1.0,
		order = '06'
	},
	{
		name = MergingChests.setting_names.inventory_size_limit,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 1,
		maximum_value = 65535,
		default_value = 1000,
		order = '07'
	},
	{
		name = MergingChests.setting_names.sprite_decal_chance,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 0,
		maximum_value = 100,
		default_value = 15,
		order = '08'
	},
	{
		name = MergingChests.setting_names.warehouse_threshold,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 2,
		default_value = 5,
		order = '09'
	},
	{
		name = MergingChests.setting_names.circuit_connector_position,
		type = 'string-setting',
		setting_type = 'startup',
		default_value = 'center-center',
		allowed_values = {
			'center-center',
			'right-top',
			'right-middle',
			'right-bottom',
			'left-top',
			'left-middle',
			'left-bottom',
			'bottom-right',
			'bottom-middle',
			'bottom-left'
		},
		order = '10'
	},
	{
		name = MergingChests.setting_names.allow_delete_items,
		type = 'bool-setting',
		setting_type = 'runtime-per-user',
		default_value = false,
		order = '11'
	}
})
