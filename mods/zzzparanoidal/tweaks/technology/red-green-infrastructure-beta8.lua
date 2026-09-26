-- Beta 8 normal: конечная инфраструктура красной/зелёной науки.
-- Явно сопоставленные роли; эффекты, механики и бесконечные технологии не меняются.
-- После OV.execute и прежних science/early-electronics патчей.
local definitions = {
	["heavy-armor"] = {
		["unit"] = {
			["count"] = 30,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
	},
	["gun-turret"] = {
		["prerequisites"] = { "burner-mechanics", "military", "electricity" },
	},
	["advanced-material-processing"] = {
		["prerequisites"] = { "steel-processing", "logistic-science-pack", "burner-mechanics" },
	},
	["concrete"] = {
		["prerequisites"] = { "advanced-material-processing", "automation-2", "angels-stone-smelting-2" },
	},
	["engine"] = {
		["prerequisites"] = { "steel-processing", "logistic-science-pack", "burner-mechanics" },
	},
	["toolbelt"] = {
		["unit"] = {
			["count"] = 100,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "logistic-science-pack" },
	},
	["gate"] = {
		["prerequisites"] = { "stone-wall", "military-2" },
	},
	["automation-3"] = {
		["unit"] = {
			["count"] = 60,
			["ingredients"] = { { "automation-science-pack", 2 }, { "logistic-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "automation-2", "advanced-circuit" },
	},
	["laser"] = {
		["prerequisites"] = { "lamp", "battery" },
	},
	["modular-armor"] = {
		["prerequisites"] = { "heavy-armor", "advanced-circuit" },
	},
	["battery"] = {
		["prerequisites"] = { "angels-sulfur-processing-1", "plastics" },
	},
	["exoskeleton-equipment"] = {
		["prerequisites"] = { "electric-engine", "solar-panel-equipment" },
	},
	["warehouse-logistics-research-1"] = {
		["prerequisites"] = { "warehouse-research", "robotics", "construction-robotics", "logistic-robotics" },
	},
	["bob-fluid-handling-2"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "angels-invar-smelting-1", "angels-aluminium-smelting-1" },
	},
	["bob-railway-2"] = {
		["unit"] = {
			["count"] = 100,
			["ingredients"] = { { "automation-science-pack", 2 }, { "logistic-science-pack", 1 } },
			["time"] = 20,
		},
		["prerequisites"] = { "advanced-circuit", "automated-rail-transportation", "angels-invar-smelting-1" },
	},
	["bob-fluid-wagon-2"] = {
		["unit"] = {
			["count"] = 200,
			["time"] = 30,
			["ingredients"] = { { "automation-science-pack", 2 }, { "logistic-science-pack", 2 } },
		},
		["prerequisites"] = { "fluid-wagon", "bob-railway-2", "bob-fluid-handling-2" },
	},
	["bob-robo-modular-1"] = {
		["prerequisites"] = { "robotics", "advanced-circuit" },
	},
	["inserter-stack-size-bonus-1"] = {
		["unit"] = {
			["count"] = 1000,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 60,
		},
	},
	["bob-repair-pack-3"] = {
		["unit"] = {
			["count"] = 50,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "bob-repair-pack-2", "advanced-circuit", "bob-brass-processing", "angels-invar-smelting-1" },
	},
	["armor-absorb-5"] = {
		["prerequisites"] = { "armor-absorb-4", "logistic-science-pack" },
	},
	["radar"] = {
		["unit"] = {
			["count"] = 40,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 10,
		},
		["prerequisites"] = { "lamp" },
	},
	["factory-architecture-t2"] = {
		["prerequisites"] = { "factory-architecture-t1", "electric-energy-distribution-1" },
	},
	["factory-connection-type-circuit"] = {
		["prerequisites"] = { "factory-architecture-t2", "circuit-network" },
	},
	["factory-interior-upgrade-display"] = {
		["prerequisites"] = { "factory-architecture-t1", "lamp" },
	},
	["CW-air-filtering-1"] = {
		["prerequisites"] = { "steel-processing", "electronics", "automation-2" },
	},
	["nano-range-1"] = {
		["unit"] = {
			["count"] = 100,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "nanobots" },
	},
	["nano-range-2"] = {
		["unit"] = {
			["count"] = 100,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 60,
		},
		["prerequisites"] = { "engine", "nano-range-1" },
	},
	["nano-range-3"] = {
		["unit"] = {
			["count"] = 300,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 90,
		},
		["prerequisites"] = { "electric-engine", "nano-range-2" },
	},
	["nano-range-4"] = {
		["unit"] = {
			["count"] = 400,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 120,
		},
		["prerequisites"] = { "robotics", "nano-range-3" },
	},
	["nano-speed-1"] = {
		["unit"] = {
			["count"] = 100,
			["ingredients"] = { { "automation-science-pack", 1 } },
			["time"] = 30,
		},
		["prerequisites"] = { "nanobots" },
	},
	["nano-speed-2"] = {
		["unit"] = {
			["count"] = 100,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 60,
		},
		["prerequisites"] = { "engine", "nano-speed-1" },
	},
	["nano-speed-3"] = {
		["unit"] = {
			["count"] = 300,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 90,
		},
		["prerequisites"] = { "electric-engine", "nano-speed-2" },
	},
	["nano-speed-4"] = {
		["unit"] = {
			["count"] = 400,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			["time"] = 120,
		},
		["prerequisites"] = { "robotics", "nano-speed-3" },
	},
	["bob-electronics-machine-2"] = {
		["unit"] = {
			["count"] = 50,
			["time"] = 30,
			["ingredients"] = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
		},
		["prerequisites"] = { "bob-electronics-machine-1", "advanced-circuit", "fast-inserter" },
	},
	["bob-reinforced-wall"] = {
		["prerequisites"] = { "gate" },
	},
}
for name, fields in pairs(definitions) do
	local prototype = data.raw.technology[name]
	if prototype and prototype.max_level ~= "infinite" then
		for field, value in pairs(fields) do prototype[field] = value end
	end
end
