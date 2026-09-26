-- Beta 8 normal: доказанные RCU-потребители, без изменения механик/характеристик.
local patch = {
	["atomic-bomb"] = {
		ingredients = {
			{ type = "item", name = "rocket-control-unit", amount = 10 },
			{ type = "item", name = "explosives", amount = 10 },
			{ type = "item", name = "uranium-235", amount = 30 },
			{ type = "item", name = "angels-rocket-booster", amount = 1 },
		},
	},
	["rocket-part"] = {
		ingredients = {
			{ type = "item", name = "rocket-control-unit", amount = 10 },
			{ type = "item", name = "low-density-structure", amount = 10 },
			{ type = "item", name = "rocket-fuel", amount = 10 },
			{ type = "item", name = "bob-rocket-engine", amount = 10 },
			{ type = "item", name = "bob-heat-shield-tile", amount = 10 },
		},
	},
	satellite = {
		ingredients = {
			{ type = "item", name = "low-density-structure", amount = 100 },
			{ type = "item", name = "rocket-fuel", amount = 50 },
			{ type = "item", name = "rocket-control-unit", amount = 100 },
			{ type = "item", name = "bob-rtg", amount = 10 },
			{ type = "item", name = "bob-battery-3", amount = 50 },
			{ type = "item", name = "bob-radar-5", amount = 5 },
		},
	},
	["radioisotope-thermoelectric-generator"] = {
		ingredients = {
			{ type = "item", name = "bob-insulated-cable", amount = 500 },
			{ type = "item", name = "rocket-control-unit", amount = 100 },
			{ type = "item", name = "bob-titanium-plate", amount = 100 },
			{ type = "item", name = "uranium-fuel-cell", amount = 100 },
		},
	},
	["satellite-battery"] = {
		ingredients = {
			{ type = "item", name = "bob-insulated-cable", amount = 100 },
			{ type = "item", name = "bob-large-accumulator-3", amount = 150 },
			{ type = "item", name = "rocket-control-unit", amount = 10 },
			{ type = "item", name = "power-switch", amount = 1 },
		},
	},
	["satellite-communications"] = {
		ingredients = {
			{ type = "item", name = "electric-engine-unit", amount = 10 },
			{ type = "item", name = "low-density-structure", amount = 20 },
			{ type = "item", name = "rocket-control-unit", amount = 10 },
			{ type = "item", name = "bob-roboport-4", amount = 5 },
			{ type = "item", name = "bob-beacon-3", amount = 5 },
		},
	},
	["satellite-radar"] = {
		ingredients = {
			{ type = "item", name = "electric-engine-unit", amount = 10 },
			{ type = "item", name = "low-density-structure", amount = 20 },
			{ type = "item", name = "rocket-control-unit", amount = 30 },
			{ type = "item", name = "bob-radar-5", amount = 100 },
		},
	},
	["mirv-rocket"] = {
		ingredients = {
			{ type = "item", name = "atomic-bomb", amount = 20 },
			{ type = "item", name = "rocket-fuel", amount = 50 },
			{ type = "item", name = "rocket-control-unit", amount = 10 },
		},
	},
	["plutonium-atomic-bomb"] = {
		ingredients = {
			{ type = "item", name = "rocket-control-unit", amount = 20 },
			{ type = "item", name = "explosives", amount = 10 },
			{ type = "item", name = "bob-plutonium-239", amount = 10 },
		},
	},
	["thermonuclear-bomb"] = {
		ingredients = {
			{ name = "atomic-bomb", amount = 1, type = "item" },
			{ name = "bob-speed-module-5", amount = 3, type = "item" },
			{ name = "bob-productivity-module-5", amount = 3, type = "item" },
			{ name = "bob-efficiency-module-5", amount = 3, type = "item" },
			{ name = "bob-fission-reactor-equipment-2", amount = 1, type = "item" },
			{ name = "rocket-control-unit", amount = 200, type = "item" },
		},
	},
	["radioisotope-thermoelectric-generator-thorium"] = {
		ingredients = {
			{ type = "item", name = "bob-thorium-fuel-cell", amount = 100 },
			{ type = "item", name = "bob-insulated-cable", amount = 500 },
			{ type = "item", name = "rocket-control-unit", amount = 100 },
			{ type = "item", name = "bob-titanium-plate", amount = 100 },
		},
	},
}
for name, fields in pairs(patch) do
	local prototype = data.raw.recipe[name]
	if prototype then for field, value in pairs(fields) do prototype[field] = value end end
end
