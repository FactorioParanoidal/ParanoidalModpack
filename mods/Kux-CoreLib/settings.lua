-- data:extend({
-- 	{
-- 		setting_type = "runtime-global", --"runtime-user|startup"
-- 		name = "my-mod_test-setting",
-- 		type = "bool-setting",  -- string-setting|double-setting|int-setting|color-setting",
-- 		default_value = true,
-- 		forced_value = false, 	-- Only loaded if hidden = true. This forces the setting to be of this value. 
-- 		minimum_value = 0, 		-- "double,int"
-- 		maximum_value  = 0, 	-- "double,int"
-- 		allowed_values = {},	-- "double,int,string"
-- 		allow_blank = false,	-- "string"
-- 		auto_trim = false,		-- "string"
-- 		order = "",
-- 		hidden = false,
-- 	}
--   })
require("init")

data:extend({
	{
		setting_type = "runtime-global",
		name = "Kux-CoreLib_".."on_load_LogEvents_Summary",
		type = "bool-setting",
		default_value = false,
		order = ""
	}
})
