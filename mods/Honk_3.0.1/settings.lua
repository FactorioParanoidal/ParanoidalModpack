data:extend({
	{
		type = "double-setting",
		name = "honk-cooldown",
		setting_type = "runtime-global",
		default_value = 2,
    minimum_value = 0,
    order = "ad"
	},
	{
		type = "int-setting",
		name = "honk-volume",
		setting_type = "runtime-global",
		default_value = 100,
    minimum_value = 0,
    maximum_value = 100,
    order = "ac"
	},
  {
    type = "bool-setting",
    name = "honk-advanced",
    setting_type = "runtime-global",
    default_value = true,
    order = "aa"
  },
	{
		type = "int-setting",
		name = "honk-range",
		setting_type = "runtime-global",
		default_value = 100,
    minimum_value = 0,
    order = "ab"
	},
  {
    type = "string-setting",
    name = "honk-sound-start",
    setting_type = "runtime-global",
    default_value = "honk-double",
    allowed_values = {"honk-double", "honk-single", "none"},
    order = "ba"
  },
  {
    type = "string-setting",
    name = "honk-sound-station",
    setting_type = "runtime-global",
    default_value = "honk-single",
    allowed_values = {"honk-double", "honk-single", "none"},
    order = "bb"
  },
  {
    type = "string-setting",
    name = "honk-sound-signal",
    setting_type = "runtime-global",
    default_value = "honk-single",
    allowed_values = {"honk-double", "honk-single", "none"},
    order = "bc"
  },
  {
    type = "string-setting",
    name = "honk-sound-lost",
    setting_type = "runtime-global",
    default_value = "none",
    allowed_values = {"honk-double", "honk-single", "none"},
    order = "bd"
  }
})