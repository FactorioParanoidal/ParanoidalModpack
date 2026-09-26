-- Beta 8 normal: оборудование/W93. Характеристики, категории и эффекты 2.0 не меняются.
-- Старшие щиты/броня: модульная часть 2.0 сохранена до отдельного решения.
-- ERP: исправлены только провода/мотор; замена RCU ещё не согласована.
local patch = {
	["energy-shield-mk2-equipment"] = {
		prerequisites = { "energy-shield-equipment", "military-3", "power-armor" },
	},
	["personal-laser-defense-equipment"] = {
		prerequisites = { "laser-turret", "military-3", "power-armor", "solar-panel-equipment" },
		unit = {
			count = 100,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 30,
		},
	},
	["discharge-defense-equipment"] = {
		prerequisites = { "laser-turret", "military-3", "power-armor", "solar-panel-equipment" },
	},
	["personal-roboport-mk2-equipment"] = {
		prerequisites = { "personal-roboport-equipment", "bob-brass-processing", "angels-aluminium-smelting-1", "angels-invar-smelting-1", "chemical-science-pack" },
	},
	["w93-modular-turrets"] = {
		prerequisites = { "military-science-pack", "gun-turret", "engine" },
	},
	["w93-modular-turrets-gatling"] = {
		unit = {
			count = 200,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 60,
		},
	},
	["w93-modular-turrets-lcannon"] = {
		prerequisites = { "w93-modular-turrets", "advanced-circuit", "w93-modular-turrets2", "explosives" },
	},
	["w93-modular-turrets-dcannon"] = {
		unit = {
			count = 100,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 60,
		},
	},
	["w93-modular-turrets-hcannon"] = {
		unit = {
			count = 200,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
	},
	["w93-modular-turrets-rocket"] = {
		prerequisites = { "w93-modular-turrets", "explosive-rocketry", "w93-modular-turrets2" },
		unit = {
			count = 150,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 60,
		},
	},
	["w93-modular-turrets-beam"] = {
		prerequisites = { "w93-modular-turrets-tlaser", "space-science-pack" },
		unit = {
			count = 300,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "utility-science-pack", 1 },
				{ "space-science-pack", 1 },
			},
			time = 60,
		},
	},
	["w93-modular-turrets-tlaser"] = {
		prerequisites = { "w93-modular-turrets-plaser", "military-4", "efficiency-module" },
		unit = {
			count = 250,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
	},
	["bob-robo-modular-2"] = {
		prerequisites = { "bob-robo-modular-1", "chemical-science-pack", "angels-aluminium-smelting-1", "angels-invar-smelting-1", "bob-brass-processing" },
	},
	["bob-robo-modular-3"] = {
		prerequisites = { "bob-robo-modular-2", "bob-battery-2", "bob-titanium-processing", "bob-advanced-logistic-science-pack", "processing-unit" },
	},
	["bob-robo-modular-4"] = {
		prerequisites = { "bob-robo-modular-3", "bob-advanced-processing-unit", "bob-battery-3", "bob-nitinol-processing" },
	},
	["bob-power-armor-3"] = {
		prerequisites = { "power-armor-mk2", "angels-invar-smelting-1", "bob-alien-research", "space-science-pack", "speed-module-3", "efficiency-module-3" },
	},
	["bob-power-armor-4"] = {
		prerequisites = { "bob-power-armor-3", "efficiency-module-3", "speed-module-3", "bob-speed-module-4", "bob-efficiency-module-4" },
	},
	["bob-power-armor-5"] = {
		unit = {
			count = 300,
			ingredients = {
				{ "bob-science-pack-gold", 1 },
				{ "bob-alien-science-pack", 1 },
				{ "bob-alien-science-pack-green", 1 },
				{ "bob-alien-science-pack-red", 1 },
			},
			time = 30,
		},
	},
	["bob-energy-shield-equipment-3"] = {
		prerequisites = { "energy-shield-mk2-equipment", "productivity-module-2", "bob-advanced-processing-unit" },
	},
	["bob-energy-shield-equipment-4"] = {
		prerequisites = { "bob-energy-shield-equipment-3", "bob-alien-research", "productivity-module-3" },
	},
	["bob-energy-shield-equipment-6"] = {
		prerequisites = { "bob-energy-shield-equipment-5", "bob-productivity-module-5" },
		unit = {
			count = 400,
			time = 45,
			ingredients = {
				{ "bob-science-pack-gold", 1 },
				{ "bob-alien-science-pack", 1 },
				{ "bob-alien-science-pack-green", 1 },
				{ "bob-alien-science-pack-red", 1 },
			},
		},
	},
	["bob-night-vision-equipment-2"] = {
		prerequisites = { "night-vision-equipment", "processing-unit" },
	},
	["bob-night-vision-equipment-3"] = {
		prerequisites = { "bob-night-vision-equipment-2", "bob-advanced-processing-unit", "bob-gem-processing-3" },
	},
	["bob-personal-laser-defense-equipment-2"] = {
		prerequisites = { "personal-laser-defense-equipment", "bob-gem-processing-3" },
		unit = {
			count = 150,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
		},
	},
	["bob-personal-laser-defense-equipment-3"] = {
		prerequisites = { "bob-personal-laser-defense-equipment-2", "production-science-pack", "angels-invar-smelting-1", "bob-battery-2" },
		unit = {
			count = 250,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
		},
	},
	["bob-personal-laser-defense-equipment-4"] = {
		prerequisites = { "bob-personal-laser-defense-equipment-3", "bob-titanium-processing" },
		unit = {
			count = 300,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
		},
	},
	["bob-personal-laser-defense-equipment-6"] = {
		prerequisites = { "bob-personal-laser-defense-equipment-5", "bob-advanced-processing-unit" },
		unit = {
			count = 350,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
		},
	},
	["bob-exoskeleton-equipment-2"] = {
		prerequisites = { "exoskeleton-equipment", "processing-unit", "angels-invar-smelting-1", "bob-cobalt-processing" },
	},
	["bob-exoskeleton-equipment-3"] = {
		prerequisites = { "bob-exoskeleton-equipment-2", "bob-advanced-processing-unit", "bob-titanium-processing" },
	},
	["bob-personal-roboport-modular-equipment-1"] = {
		prerequisites = { "personal-roboport-equipment", "modules" },
	},
	["bob-personal-roboport-modular-equipment-2"] = {
		prerequisites = { "bob-personal-roboport-modular-equipment-1", "personal-roboport-mk2-equipment" },
	},
	["bob-personal-roboport-modular-equipment-3"] = {
		prerequisites = { "bob-personal-roboport-modular-equipment-2", "bob-personal-roboport-mk3-equipment" },
	},
	["bob-personal-roboport-mk3-equipment"] = {
		prerequisites = { "personal-roboport-mk2-equipment", "processing-unit", "bob-battery-2", "bob-titanium-processing", "bob-advanced-logistic-science-pack" },
	},
	["bob-personal-roboport-mk4-equipment"] = {
		prerequisites = { "bob-personal-roboport-mk3-equipment", "bob-advanced-processing-unit", "bob-battery-3", "bob-nitinol-processing" },
	},
	["bob-vehicle-laser-defense-equipment-1"] = {
		prerequisites = { "bob-vehicle-solar-panel-equipment-1", "laser-turret", "military-3", "bob-gem-processing-3" },
		unit = {
			count = 100,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 30,
		},
	},
	["bob-vehicle-laser-defense-equipment-2"] = {
		prerequisites = { "bob-vehicle-laser-defense-equipment-1" },
		unit = {
			count = 150,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
		},
	},
	["bob-vehicle-laser-defense-equipment-3"] = {
		prerequisites = { "bob-vehicle-laser-defense-equipment-2", "production-science-pack", "angels-invar-smelting-1", "bob-battery-2" },
		unit = {
			count = 250,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
		},
	},
	["bob-vehicle-laser-defense-equipment-4"] = {
		prerequisites = { "bob-vehicle-laser-defense-equipment-3", "processing-unit", "bob-titanium-processing" },
		unit = {
			count = 300,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
		},
	},
	["bob-vehicle-laser-defense-equipment-6"] = {
		prerequisites = { "bob-vehicle-laser-defense-equipment-5", "bob-advanced-processing-unit" },
		unit = {
			count = 350,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
		},
	},
	["bob-vehicle-roboport-modular-equipment-1"] = {
		prerequisites = { "bob-vehicle-roboport-equipment-1", "modules" },
	},
	["bob-vehicle-roboport-modular-equipment-2"] = {
		prerequisites = { "bob-vehicle-roboport-modular-equipment-1", "bob-vehicle-roboport-equipment-2" },
	},
	["bob-vehicle-roboport-modular-equipment-3"] = {
		prerequisites = { "bob-vehicle-roboport-modular-equipment-2", "bob-vehicle-roboport-equipment-3" },
	},
	["bob-vehicle-roboport-equipment-2"] = {
		prerequisites = { "bob-vehicle-roboport-equipment-1", "chemical-science-pack", "bob-brass-processing", "angels-aluminium-smelting-1", "angels-invar-smelting-1" },
	},
	["bob-vehicle-roboport-equipment-3"] = {
		prerequisites = { "bob-vehicle-roboport-equipment-2", "processing-unit", "bob-advanced-logistic-science-pack", "bob-battery-2", "bob-titanium-processing" },
	},
	["bob-vehicle-roboport-equipment-4"] = {
		prerequisites = { "bob-vehicle-roboport-equipment-3", "bob-advanced-processing-unit", "bob-battery-3", "bob-nitinol-processing" },
	},
	["bob-vehicle-shield-equipment-1"] = {
		prerequisites = { "bob-vehicle-solar-panel-equipment-1", "military-science-pack", "advanced-circuit" },
	},
	["bob-vehicle-shield-equipment-2"] = {
		prerequisites = { "bob-vehicle-shield-equipment-1", "processing-unit", "military-3" },
		unit = {
			count = 200,
			time = 30,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
		},
	},
	["bob-vehicle-shield-equipment-3"] = {
		prerequisites = { "bob-vehicle-shield-equipment-2", "productivity-module-2", "bob-advanced-processing-unit" },
	},
	["bob-vehicle-shield-equipment-4"] = {
		prerequisites = { "bob-vehicle-shield-equipment-3", "bob-alien-research", "productivity-module-3" },
	},
	["bob-vehicle-shield-equipment-6"] = {
		prerequisites = { "bob-vehicle-shield-equipment-5", "bob-productivity-module-5" },
		unit = {
			count = 400,
			time = 45,
			ingredients = {
				{ "bob-science-pack-gold", 1 },
				{ "bob-alien-science-pack", 1 },
				{ "bob-alien-science-pack-green", 1 },
				{ "bob-alien-science-pack-red", 1 },
			},
		},
	},
	["bob-vehicle-engine-equipment"] = {
		prerequisites = { "bob-vehicle-motor-equipment", "bob-advanced-processing-unit", "bob-nitinol-processing" },
	},
}
for name, fields in pairs(patch) do
	local prototype = data.raw.technology[name]
	if prototype then
		for field, value in pairs(fields) do prototype[field] = value end
	end
end
