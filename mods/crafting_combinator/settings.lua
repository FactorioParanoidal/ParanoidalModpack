local config = require "config"


data:extend{
	{
		type = "int-setting",
		name = config.REFRESH_RATE_CC_NAME,
		setting_type = "runtime-global",
		default_value = config.REFRESH_RATE_CC,
		minimum_value = 0,
	},
	{
		type = "int-setting",
		name = config.REFRESH_RATE_RC_NAME,
		setting_type = "runtime-global",
		default_value = config.REFRESH_RATE_RC,
		minimum_value = 0,
	},
}
