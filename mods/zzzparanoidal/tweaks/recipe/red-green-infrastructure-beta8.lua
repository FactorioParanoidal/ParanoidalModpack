-- Beta 8 normal: цена и порядок изготовления связанной инфраструктуры.
-- Категории, продуктивность, характеристики и механики остаются 2.0.
-- Factory-2 сохраняет нынешний предмет пустого здания, не старую механику raw/occupied.
local definitions = {
	["concrete"] = {
		["ingredients"] = {
			{ type = "fluid", name = "angels-liquid-concrete", amount = 40 },
		},
	},
	["refined-concrete"] = {
		["ingredients"] = {
			{ type = "fluid", name = "angels-liquid-concrete", amount = 40 },
			{ type = "item", name = "steel-plate", amount = 4 },
			{ type = "item", name = "iron-stick", amount = 8 },
		},
	},
	["engine-unit"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 4 },
			{ type = "item", name = "iron-gear-wheel", amount = 4 },
			{ type = "item", name = "pipe", amount = 4 },
			{ type = "item", name = "motor", amount = 2 },
		},
	},
	["gate"] = {
		["ingredients"] = {
			{ type = "item", name = "stone-wall", amount = 2 },
			{ type = "item", name = "steel-plate", amount = 10 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 2 },
			{ type = "item", name = "motor", amount = 2 },
		},
	},
	["assembling-machine-3"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 9 },
			{ type = "item", name = "advanced-circuit", amount = 3 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 5 },
			{ type = "item", name = "electric-motor", amount = 10 },
			{ type = "item", name = "intermediate-structure-components", amount = 2 },
			{ type = "item", name = "assembling-machine-2", amount = 2 },
		},
		["energy_required"] = 15,
	},
	["modular-armor"] = {
		["ingredients"] = {
			{ type = "item", name = "advanced-circuit", amount = 30 },
			{ type = "item", name = "steel-plate", amount = 50 },
			{ type = "item", name = "heavy-armor", amount = 1 },
		},
	},
	["battery"] = {
		["ingredients"] = {
			{ type = "item", name = "bob-lead-plate", amount = 2 },
			{ type = "fluid", name = "sulfuric-acid", amount = 20 },
			{ type = "item", name = "plastic-bar", amount = 1 },
		},
	},
	["bob-storage-tank-all-corners-2"] = {
		["ingredients"] = {
			{ type = "item", name = "bob-invar-alloy", amount = 20 },
			{ type = "item", name = "bob-steel-pipe", amount = 4 },
			{ type = "item", name = "bob-storage-tank-all-corners", amount = 2 },
		},
	},
	["bob-storage-tank-2"] = {
		["ingredients"] = {
			{ type = "item", name = "bob-invar-alloy", amount = 20 },
			{ type = "item", name = "storage-tank", amount = 2 },
		},
	},
	["bob-cargo-wagon-2"] = {
		["ingredients"] = {
			{ type = "item", name = "cargo-wagon", amount = 1 },
			{ type = "item", name = "bob-invar-alloy", amount = 20 },
			{ type = "item", name = "bob-steel-bearing", amount = 8 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 12 },
		},
	},
	["bob-locomotive-2"] = {
		["ingredients"] = {
			{ type = "item", name = "locomotive", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "bob-invar-alloy", amount = 10 },
			{ type = "item", name = "bob-steel-bearing", amount = 16 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 20 },
		},
	},
	["bob-fluid-wagon-2"] = {
		["ingredients"] = {
			{ type = "item", name = "fluid-wagon", amount = 1 },
			{ type = "item", name = "bob-storage-tank-2", amount = 1 },
			{ type = "item", name = "bob-invar-alloy", amount = 16 },
			{ type = "item", name = "bob-steel-bearing", amount = 8 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 12 },
		},
	},
	["bob-logistic-zone-interface"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "bob-roboport-antenna-1", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 2 },
		},
	},
	["bob-roboport-antenna-1"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 45 },
			{ type = "item", name = "copper-cable", amount = 6 },
			{ type = "item", name = "advanced-circuit", amount = 15 },
			{ type = "item", name = "electric-motor", amount = 30 },
			{ type = "item", name = "electronic-circuit", amount = 75 },
		},
		["results"] = {
			{ type = "item", name = "bob-roboport-antenna-1", amount = 3 },
		},
		["energy_required"] = 0.6000000000000001,
	},
	["bob-roboport-chargepad-1"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 10 },
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "electric-motor", amount = 3 },
		},
	},
	["bob-roboport-door-1"] = {
		["ingredients"] = {
			{ type = "item", name = "steel-plate", amount = 30 },
			{ type = "item", name = "iron-gear-wheel", amount = 20 },
			{ type = "item", name = "electric-motor", amount = 30 },
			{ type = "item", name = "concrete", amount = 50 },
		},
	},
	["factory-2"] = {
		["ingredients"] = {
			{ type = "item", name = "stone-brick", amount = 1000 },
			{ type = "item", name = "steel-plate", amount = 250 },
			{ type = "item", name = "big-electric-pole", amount = 50 },
			{ type = "item", name = "basic-structure-components", amount = 50 },
		},
	},
	["bob-electronics-machine-2"] = {
		["ingredients"] = {
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "bob-steel-bearing", amount = 5 },
			{ type = "item", name = "bob-steel-gear-wheel", amount = 5 },
			{ type = "item", name = "intermediate-structure-components", amount = 3 },
			{ type = "item", name = "long-handed-inserter", amount = 4 },
			{ type = "item", name = "bob-electronics-machine-1", amount = 2 },
		},
		["energy_required"] = 10,
	},
	["bob-reinforced-wall"] = {
		["ingredients"] = {
			{ type = "item", name = "stone-brick", amount = 3 },
			{ type = "item", name = "steel-plate", amount = 3 },
		},
	},
}
for name, fields in pairs(definitions) do
	local prototype = data.raw.recipe[name]
	if prototype then
		for field, value in pairs(fields) do prototype[field] = value end
	end
end
if data.raw.recipe["refined-hazard-concrete"] then data.raw.recipe["refined-hazard-concrete"].order = nil end
if data.raw.recipe["refined-hazard-concrete"] then data.raw.recipe["refined-hazard-concrete"].subgroup = nil end
