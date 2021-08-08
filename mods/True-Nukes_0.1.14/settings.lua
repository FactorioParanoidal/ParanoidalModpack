data:extend({
	{
		type = "bool-setting",
		name = "crater-water-filling",
		setting_type = "runtime-global",
		default_value = true,
		order = "a0"
	},
	{
		type = "bool-setting",
		name = "nuke-random-fires",
		setting_type = "runtime-global",
		default_value = true,
		order = "a1"
	},
	{
		type = "bool-setting",
		name = "nuke-crater-noise",
		setting_type = "runtime-global",
		default_value = true,
		order = "a2"
	},
	{
		type = "bool-setting",
		name = "use-height-for-craters",
		setting_type = "runtime-global",
		default_value = true,
		order = "a3"
	},
	{
		type = "bool-setting",
		name = "destroy-resources-in-crater",
		setting_type = "runtime-global",
		default_value = true,
		order = "a4"
	},
	{
		type = "bool-setting",
		name = "nukes-cause-pollution",
		setting_type = "runtime-global",
		default_value = true,
		order = "a5"
	},
	{
		type = "double-setting",
		name = "large-nuke-fire-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 5,
		default_value = 1,
		order = "b0"
	},
	{
		type = "double-setting",
		name = "huge-nuke-fire-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 10,
		default_value = 2,
		order = "b1"
	},
	{
		type = "double-setting",
		name = "really-huge-nuke-fire-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 20,
		default_value = 5,
		order = "b2"
	},
	{
		type = "double-setting",
		name = "mega-nuke-fire-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 20,
		default_value = 5,
		order = "b3"
	},
	{
		type = "double-setting",
		name = "large-nuke-blast-range-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 2,
		default_value = 1.5,
		order = "c0"
	},
	{
		type = "double-setting",
		name = "really-huge-nuke-blast-range-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 2,
		default_value = 2,
		order = "c1"
	},
	{
		type = "double-setting",
		name = "mega-nuke-blast-range-scaledown",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 2,
		default_value = 2,
		order = "c2"
	},
	{
		type = "bool-setting",
		name = "use-efficient-thermal",
		setting_type = "runtime-global",
		default_value = false,
		order = "c3"
	},
	{
		type = "bool-setting",
		name = "use-californium",
		setting_type = "startup",
		default_value = true,
		order = "b0"
	},
	{
		type = "bool-setting",
		name = "enable-new-craters",
		setting_type = "startup",
		default_value = true,
		order = "d0"
	},
	
	{
		type = "bool-setting",
		name = "enable-menu-backgrounds",
		setting_type = "startup",
		default_value = true,
		order = "e0"
	},
	
	{
		type = "bool-setting",
		name = "enable-thermobaric-cannons",
		setting_type = "startup",
		default_value = true,
		order = "f0"
	},
	{
		type = "bool-setting",
		name = "enable-thermobaric-rockets",
		setting_type = "startup",
		default_value = true,
		order = "f1"
	},
	{
		type = "bool-setting",
		name = "enable-thermobaric-artillery",
		setting_type = "startup",
		default_value = true,
		order = "f2"
	},
	
	{
		type = "bool-setting",
		name = "enable-atomic-ammo",
		setting_type = "startup",
		default_value = true,
		order = "f3"
	},
	{
		type = "bool-setting",
		name = "enable-big-atomic-ammo",
		setting_type = "startup",
		default_value = true,
		order = "f4"
	},
	
	{
		type = "bool-setting",
		name = "enable-atomic-cannons",
		setting_type = "startup",
		default_value = true,
		order = "f5"
	},
	{
		type = "bool-setting",
		name = "enable-big-atomic-cannons",
		setting_type = "startup",
		default_value = true,
		order = "f6"
	},
	
	{
		type = "bool-setting",
		name = "enable-small-atomic-bomb",
		setting_type = "startup",
		default_value = true,
		order = "f7"
	},
	
	{
		type = "bool-setting",
		name = "enable-very-small-atomic-bomb",
		setting_type = "startup",
		default_value = true,
		order = "f8"
	},
	
	{
		type = "bool-setting",
		name = "enable-really-very-small-atomic-bomb",
		setting_type = "startup",
		default_value = true,
		order = "f9"
	},
	
	{
		type = "bool-setting",
		name = "enable-atomic-bomb",
		setting_type = "startup",
		default_value = true,
		order = "fa"
	},
	{
		type = "bool-setting",
		name = "enable-big-atomic-bomb",
		setting_type = "startup",
		default_value = true,
		order = "fb"
	},
	{
		type = "bool-setting",
		name = "enable-very-big-atomic-bomb",
		setting_type = "startup",
		default_value = true,
		order = "fc"
	},
	
	{
		type = "bool-setting",
		name = "enable-very-small-atomic-artillery",
		setting_type = "startup",
		default_value = true,
		order = "fd"
	},
	{
		type = "bool-setting",
		name = "enable-small-atomic-artillery",
		setting_type = "startup",
		default_value = true,
		order = "fe"
	},
	{
		type = "bool-setting",
		name = "enable-atomic-artillery",
		setting_type = "startup",
		default_value = true,
		order = "fh"
	},
	{
		type = "bool-setting",
		name = "enable-big-atomic-artillery",
		setting_type = "startup",
		default_value = true,
		order = "fi"
	},
	{
		type = "bool-setting",
		name = "enable-very-big-atomic-artillery",
		setting_type = "startup",
		default_value = true,
		order = "fj"
	},
	
	{
		type = "bool-setting",
		name = "enable-fusion-building",
		setting_type = "startup",
		default_value = true,
		order = "fk"
	},
	{
		type = "bool-setting",
		name = "enable-mega-fusion-building",
		setting_type = "startup",
		default_value = true,
		order = "fl"
	},
	
	{
		type = "bool-setting",
		name = "enable-fire-shield",
		setting_type = "startup",
		default_value = true,
		order = "fm"
	},
	
	{
		type = "bool-setting",
		name = "keep-atomic-research-without-weapons",
		setting_type = "startup",
		default_value = false,
		order = "fn"
	},
	{
		type = "bool-setting",
		name = "keep-atomic-bomb-without-changes",
		setting_type = "startup",
		default_value = false,
		order = "fo"
	},
	
	{
		type = "bool-setting",
		name = "TN-mushroom-cloud-style-nuclear-flash",
		setting_type = "runtime-per-user",
		default_value = true,
		order = "a0",
	}
})
