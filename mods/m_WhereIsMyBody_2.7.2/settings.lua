
local settings = {
	{type = "int-setting", name = "WHMB_update_tick", setting_type = "runtime-global", default_value = 120, minimum_value = 1, maximum_value = 8e4},
	{type = "bool-setting", name = "WHMB_delete_empty_bodies", setting_type = "runtime-global", default_value = false},
	{type = "int-setting", name = "WHMB_ignore_if_less_n_items", setting_type = "runtime-per-user", default_value = 6, minimum_value = 0, maximum_value = 100},
	{type = "double-setting", name = "WHMB_line_width", setting_type = "runtime-per-user", default_value = 0.2, minimum_value = 0.1, maximum_value = 20},
	{type = "bool-setting", name = "WHMB_create_lines", setting_type = "runtime-per-user", default_value = true},
	{type = "bool-setting", name = "WHMB_create_chart_tags_after_death", setting_type = "runtime-per-user", default_value = true}
}

if ZKSettings then
	for _, setting in pairs(settings) do
		ZKSettings.create_setting(setting.name, setting.type, setting.setting_type, setting.default_value, setting) -- welp it looks awful
	end
else
	data:extend(settings)
end
