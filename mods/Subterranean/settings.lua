data:extend({
	  {
		 type = "int-setting",
		 name = "subterrain-belt-cost-multiplier",
		 setting_type = "runtime-global",
		 default_value = 0,
		 order = "a",
	  },
	  {
		 type = "int-setting",
		 name = "subterrain-pipe-cost-multiplier",
		 setting_type = "runtime-global",
		 default_value = 0,
		 order = "b",
	  },
	  {
		 type = "bool-setting",
		 name = "subterrain-should-refund-belts",
		 setting_type = "runtime-global",
		 default_value = false,
		 order = "c",
	  },
	  {
		 type = "bool-setting",
		 name = "subterrain-should-refund-pipes",
		 setting_type = "runtime-global",
		 default_value = false,
		 order = "d",
	  },
	  
	  {
		 type = "double-setting",
		 name = "subterrain-belt-refund-multiplier",
		 setting_type = "runtime-global",
		 default_value = 1.0,
		 minimum_value = 0.1,
		 maximum_value = 1.0,
		 order = "e",
	  },
	  {
		 type = "double-setting",
		 name = "subterrain-pipe-refund-multiplier",
		 setting_type = "runtime-global",
		 default_value = 1.0,
		 minimum_value = 0.1,
		 maximum_value = 1.0,
		 order = "f",
	  }

	  
})
