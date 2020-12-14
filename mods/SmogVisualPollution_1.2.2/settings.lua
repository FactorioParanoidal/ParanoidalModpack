
data:extend({
	{
		type = "int-setting",
		name = "svp-min-pollution",
		setting_type = "runtime-global",
		minimum_value = 0,
		default_value = 20,
		maximum_value = 100
	},
	{
		type = "int-setting",
		name = "svp-max-pollution",
		setting_type = "runtime-global",
		minimum_value = 150,
		default_value = 1000,
		maximum_value = 12000
	},
  
	{
		type = "int-setting",
		name = "svp-chunks-per-tick",
		setting_type = "runtime-global",
		minimum_value = 1,
		default_value = 1, -- about 1 ms, UPS about 1000-2000
		maximum_value = 120
	}
})

