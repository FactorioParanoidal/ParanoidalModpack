-- recipes.lua

data:extend {
	
{
	type = "recipe",
	name = "ret-electric-locomotive",
	result = "ret-electric-locomotive",
	ingredients = {
		{"steel-plate", 40}, 
		{"electric-engine-unit", 30},
		{"advanced-circuit", 20},
		{"iron-gear-wheel", 20}
	},
	energy_required = 8,
	enabled = false
},

{
	type = "recipe",
	name = "ret-power-pole",
	result = "ret-pole-placer",
	ingredients = {
		{"steel-plate", 4},
		{"iron-stick", 2},
		{"copper-plate", 4}
	},
	energy_required = 1,
	enabled = false
},

{
	type = "recipe",
	name = "ret-signal-pole",
	result = "ret-signal-pole-placer",
	ingredients = {
		{"ret-pole-placer", 1},
		{"rail-signal", 1}
	},
	energy_required = 1,
	enabled = false
},

{
	type = "recipe",
	name = "ret-chain-pole",
	result = "ret-chain-pole-placer",
	ingredients = {
		{"ret-pole-placer", 1},
		{"rail-chain-signal", 1}
	},
	energy_required = 1,
	enabled = false
},

{
	type = "recipe",
	name = "ret-pole-debugger",
	result = "ret-pole-debugger",
	ingredients = {
		{"electronic-circuit", 3}
	},
	enabled = false
},

{
	type = "recipe",
	name = "ret-electric-locomotive-mk2",
	result = "ret-electric-locomotive-mk2",
	ingredients = {
		{"ret-electric-locomotive", 1}, 
		{"electric-engine-unit", 20},
		{"advanced-circuit", 20},
		{"processing-unit", 5}
	},
	energy_required = 16,
	enabled = false
},

{
	type = "recipe",
	name = "ret-modular-locomotive",
	result = "ret-modular-locomotive",
	ingredients = {
		{"ret-electric-locomotive-mk2", 1},
		{"electric-engine-unit", 20},
		{"processing-unit", 20},
		{"low-density-structure", 30}
	},
	energy_required = 32,
	enabled = false
},

{
	type = "recipe",
	name = "ret-train-speed-module",
	result = "ret-train-speed-module",
	ingredients = {
		{"speed-module-3", 3},
		{"processing-unit", 2},
		{"low-density-structure", 5}
	},
	energy_required = 30,
	enabled = false
},

{
	type = "recipe",
	name = "ret-train-productivity-module",
	result = "ret-train-productivity-module",
	ingredients = {
		{"productivity-module-3", 3},
		{"processing-unit", 2},
		{"low-density-structure", 5}
	},
	energy_required = 30,
	enabled = false
},

{
	type = "recipe",
	name = "ret-train-efficiency-module",
	result = "ret-train-efficiency-module",
	ingredients = {
		{"effectivity-module-3", 3},
		{"processing-unit", 2},
		{"low-density-structure", 5}
	},
	energy_required = 30,
	enabled = false
},

{
	type = "recipe",
	name = "ret-train-battery-module",
	result = "ret-train-battery-module",
	ingredients = {
		{"battery", 30},
		{"processing-unit", 2},
		{"low-density-structure", 5}
	},
	energy_required = 30,
	enabled = false
}

}