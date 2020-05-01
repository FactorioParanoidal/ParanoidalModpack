data:extend({
	{
		name = "ltnt-show-button",
		setting_type = "runtime-per-user",
		type = "bool-setting",
		default_value = true,
	},
	{
		name = "ltnt-window-height",
		setting_type = "runtime-per-user",
		type = "int-setting",
		default_value = 750,
		minimum_value = 500,
		maximum_value = 2000,
	},
  {
		name = "ltnt-refresh-interval",
		setting_type = "runtime-per-user",
		type = "int-setting",
		default_value = 0,
		minimum_value = 0,
		maximum_value = 30,
	},
  {
		name = "ltnt-history-limit",
    setting_type = "runtime-global",
		type = "int-setting",
		default_value = 50,
		minimum_value = 5,
		maximum_value = 100,
	},
  {
		name = "ltnt-station-click-behavior",
    setting_type = "runtime-per-user",
		type = "string-setting",
    default_value = "2",
    allowed_values = {"1", "3", "2"}
	},
	{
		name = "ltnt-disable-underload-alert",
    setting_type = "runtime-global",
		type = "bool-setting",
    default_value = false,
	},
	{
		name = "ltnt-debug-level",
    setting_type = "runtime-global",
		type = "bool-setting",
    default_value = false,
	},
})
