data:extend({
	{
		type = "int-setting",
		name = "min-fuel-amount",
		setting_type = "runtime-global",
		default_value = 20,
		minimum_value = 10
	},
	{
		type = "string-setting",
		name = "fuel-station-insert-order",
		setting_type = "runtime-global",
		default_value = "go-after",
        allowed_values = {"go-first", "go-after"}
	}
})
