data:extend({
	{
		type = "double-setting",
		name = "honk-sound-volume",
		setting_type = "startup",
		default_value = 1.5,
    minimum_value = 0,
    maximum_value = 10,
    order = "ac"
	},
	{
		type = "double-setting",
		name = "honk-sound-range",
		setting_type = "startup",
		default_value = 10,
    minimum_value = 1,
    maximum_value = 100,
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
  },
  {
    type = "string-setting",
    name = "honk-sound-manual",
    setting_type = "runtime-global",
    default_value = "auto",
    allowed_values = {"auto","honk-double", "honk-single", "none"},
    order = "be"
  },
  {
    type = "string-setting",
    name = "honk-sound-manual-alt",
    setting_type = "runtime-global",
    default_value = "honk-single",
    allowed_values = {"honk-double", "honk-single", "none"},
    order = "bf"
  }
})