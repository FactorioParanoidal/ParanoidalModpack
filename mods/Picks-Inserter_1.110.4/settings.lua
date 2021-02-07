--[[ Copyright (c) 2019 - 2021 Picklock
 * Part of Picklocks Inserter
 * settings.lua
 * Version 1.110.4.52
 *
 * See LICENSE.MD in the project directory for license information.
--]]

data:extend(
{
	{
		--Temporary unlock locked slots in chests
		type = "bool-setting",
		name = "PI_temp_unlock",
		setting_type = "runtime-global",
		default_value = false,
		order = "a[common]-a"
	},
   {
		--Destroy items in hand when they not could be put back to source
        type = "bool-setting",
        name = "PI_clear_inserter",
        setting_type = "runtime-global",
        default_value = false,
		order = "a[common]-c"
    },
 	{
		--Clean selected inserters
		type = "bool-setting",
		name = "PI_target_selection",
		setting_type = "runtime-global",
		default_value = true,
		order = "b[select]-a"
	},
 	{
		--Keep selected inserters in database after clearing
		type = "bool-setting",
		name = "PI_keep_selected",
		setting_type = "runtime-global",
		default_value = false,
		order = "b[select]-b"
	},
 	{
		--Mark selected inserters
		type = "bool-setting",
		name = "PI_set_mark",
		setting_type = "runtime-global",
		default_value = true,
		order = "b[select]-c"
	},
	{
		--Maximum inserters cleand by tick
		type = "int-setting",
		name = "PI_clear_max",
		setting_type = "runtime-global",
		default_value = 10,
		minimum_value = 1,
		maximum_value = 120,
		order = "b[select]-d"
	},
 	{
		--Clean inserters around cargo-wagons
		type = "bool-setting",
		name = "PI_target_train_stop",
		setting_type = "runtime-global",
		default_value = true,
		order = "t[train]-a"
	},
	{
		--Lines to search for inserters around cargo-wagons
		type = "int-setting",
		name = "PI_lines_to_check",
		setting_type = "runtime-global",
		default_value = 1,
		allowed_values = {1, 2, 3},
		order = "t[train]-c"
	},
	{
		--Extended lenght to search for inserters around cargo-wagons
		type = "int-setting",
		name = "PI_extend_length",
		setting_type = "runtime-global",
		default_value = 0,
		allowed_values = {0, 1, 2, 3},
		order = "t[train]-e"
	}
}
)