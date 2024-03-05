if not mods['deep-storage-unit'] then
	data:extend{{
		type = 'string-setting',
		name = 'memory-unit-power-usage',
		setting_type = 'runtime-global',
		default_value = '300kW',
		allowed_values = {'0W', '60kW', '180kW', '300kW', '480kW', '600kW', '1.2MW', '2.4MW'}
	}}
end
