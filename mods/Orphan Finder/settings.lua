data:extend({
	{
		type = "int-setting",
		name = "orphan-finder-search-range",
		setting_type = "runtime-global",
		minimum_value = 1,
		default_value = 100,
    order = "a"
	},
  {
    type = "string-setting",
    name = "orphan-finder-underground-mode",
    setting_type = "runtime-global",
    default_value = "strict",
    allowed_values =  {"standard", "strict", "none"},
    order = "b"
  }
})