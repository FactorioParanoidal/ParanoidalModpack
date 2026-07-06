
local settings = { 	

	-- runtime global
   {
		type = "int-setting",
		name = "inventory-repair-interval",
		setting_type = "runtime-global",
		default_value = 30,
		minimum_value = 1,
		order = "a[mode]",
	},
	{
		type = "string-setting",
		name = "inventory-repair-order",
		setting_type = "runtime-global",
		allowed_values = {"low-first", "high-first"},
		default_value = "low-first",
		order = "a[mode]",
	},
}

for _,setting in pairs(settings) do
	setting.localised_description = {"mod-setting-description." .. setting.name, tostring(setting.default_value), tostring(setting.minimum_value), tostring(setting.maximum_value)}
end

data:extend(settings)