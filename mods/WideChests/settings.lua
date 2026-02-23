require('init')
require('setting_init')

MergingChests.create_mergeable_chest_setting(MergingChests.chest_names.wooden, { default_value = 'none', order = '1' })
MergingChests.create_mergeable_chest_setting(MergingChests.chest_names.iron, { default_value = 'none', order = '2' })
MergingChests.create_mergeable_chest_setting(MergingChests.chest_names.steel, { order = '3' })

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
		name = MergingChests.setting_names.mirror_whitelist,
		type = 'bool-setting',
		setting_type = 'startup',
		default_value = false,
		order = '06'
	},
	{
		name = MergingChests.setting_names.inventory_size_multiplier,
		type = 'double-setting',
		setting_type = 'startup',
		minimum_value = 0,
		default_value = 1.0,
		order = '07'
	},
	{
		name = MergingChests.setting_names.inventory_size_limit,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 1,
		maximum_value = 65535,
		default_value = 1000,
		order = '08'
	},
	{
		name = MergingChests.setting_names.inventory_type,
		type = 'string-setting',
		setting_type = 'startup',
		default_value = 'with_bar',
		allowed_values = {
			'normal',
			'with_bar',
			'with_filters_and_bar'
		},
		order = '09'
	},
	{
		name = MergingChests.setting_names.sprite_decal_chance,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 0,
		maximum_value = 100,
		default_value = 15,
		order = '10'
	},
	{
		name = MergingChests.setting_names.warehouse_threshold,
		type = 'int-setting',
		setting_type = 'startup',
		minimum_value = 2,
		default_value = 5,
		order = '11'
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
		order = '12'
	},
	{
		name = MergingChests.setting_names.allow_delete_items,
		type = 'bool-setting',
		setting_type = 'runtime-per-user',
		default_value = false,
		order = '13'
	},
	{
		name = MergingChests.setting_names.enable_upgrading_merged_chests,
		type = 'bool-setting',
		setting_type = 'startup',
		default_value = true,
		order = '14'
	}
})

if MergingChests.is_mod_active(MergingChests.override_size_settings_mod_name) then
	data.raw['int-setting'][MergingChests.setting_names.max_width].hidden = true
	data.raw['int-setting'][MergingChests.setting_names.max_height].hidden = true
	data.raw['int-setting'][MergingChests.setting_names.max_area].hidden = true
	data.raw['string-setting'][MergingChests.setting_names.whitelist].hidden = true
	data.raw['bool-setting'][MergingChests.setting_names.mirror_whitelist].hidden = true

end
if MergingChests.is_mod_active(MergingChests.override_inventory_settings_mod_name) then
	data.raw['double-setting'][MergingChests.setting_names.inventory_size_multiplier].hidden = true
	data.raw['int-setting'][MergingChests.setting_names.inventory_size_limit].hidden = true
end
