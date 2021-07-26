data:extend{{
	type = 'string-setting',
	name = 'memory-unit-power-usage',
	setting_type = 'runtime-global',
	default_value = '480kW',
	allowed_values = {'0W', '60kW', '180kW', '300kW', '480kW', '600kW', '1.2MW', '2.4MW'}
}}

if mods['Krastorio2'] then
	data:extend{{
		type = 'bool-setting',
		name = 'remove-krastorio-warehouses',
		setting_type = 'startup',
		default_value = true
	}}
end