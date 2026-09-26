-- Beta 8 normal: оборудование/W93. Характеристики, категории и эффекты 2.0 не меняются.
-- ПР-043: модульная часть старших щитов/брони принята 2.0.
-- ПР-044/047: ERP снова использует отдельный RCU; провода/мотор исправлены ранее.
local patch = {
	["night-vision-equipment"] = {
		ingredients = {
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 10 },
		},
	},
	["belt-immunity-equipment"] = {
		ingredients = {
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 10 },
		},
	},
	["energy-shield-equipment"] = {
		ingredients = {
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 10 },
		},
	},
	["energy-shield-mk2-equipment"] = {
		ingredients = {
			{ type = "item", name = "energy-shield-equipment", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 5 },
		},
	},
	["personal-laser-defense-equipment"] = {
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "electronic-circuit", amount = 5 },
			{ type = "item", name = "battery", amount = 3 },
		},
	},
	["personal-roboport-mk2-equipment"] = {
		ingredients = {
			{ type = "item", name = "personal-roboport-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-2", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-2", amount = 2 },
			{ type = "item", name = "bob-roboport-door-2", amount = 1 },
			{ type = "item", name = "bob-aluminium-plate", amount = 5 },
		},
	},
	["w93-modular-turret-base"] = {
		ingredients = {
			{ type = "item", name = "stone-brick", amount = 50 },
			{ type = "item", name = "steel-plate", amount = 40 },
			{ type = "item", name = "engine-unit", amount = 5 },
			{ type = "item", name = "gun-turret", amount = 1 },
		},
	},
	["w93-modular-turret2-base"] = {
		ingredients = {
			{ type = "item", name = "concrete", amount = 75 },
			{ type = "item", name = "plastic-bar", amount = 80 },
			{ type = "item", name = "electric-engine-unit", amount = 10 },
			{ type = "item", name = "w93-modular-turret-base", amount = 1 },
			{ type = "item", name = "electronic-circuit", amount = 10 },
		},
	},
	["w93-modular-gun-lcannon"] = {
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 4 },
			{ type = "item", name = "advanced-circuit", amount = 1 },
			{ type = "item", name = "iron-gear-wheel", amount = 4 },
		},
	},
	["w93-modular-gun-plaser"] = {
		ingredients = {
			{ type = "item", name = "plastic-bar", amount = 10 },
			{ type = "item", name = "iron-stick", amount = 8 },
			{ type = "item", name = "electronic-circuit", amount = 5 },
			{ type = "item", name = "speed-module", amount = 1 },
			{ type = "item", name = "battery", amount = 10 },
		},
	},
	["w93-modular-gun-tlaser"] = {
		ingredients = {
			{ type = "item", name = "plastic-bar", amount = 8 },
			{ type = "item", name = "steel-plate", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 2 },
			{ type = "item", name = "battery", amount = 10 },
			{ type = "item", name = "efficiency-module", amount = 1 },
		},
	},
	["w93-modular-gun-beam"] = {
		ingredients = {
			{ type = "item", name = "uranium-fuel-cell", amount = 1 },
			{ type = "item", name = "small-lamp", amount = 1 },
			{ type = "item", name = "low-density-structure", amount = 1 },
			{ type = "item", name = "poison-capsule", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 2 },
			{ type = "item", name = "battery", amount = 8 },
		},
	},
	["bob-roboport-antenna-2"] = {
		ingredients = {
			{ type = "item", name = "advanced-circuit", amount = 15 },
			{ type = "item", name = "bob-aluminium-plate", amount = 3 },
			{ type = "item", name = "bob-tinned-copper-cable", amount = 6 },
		},
		results = {
			{ type = "item", name = "bob-roboport-antenna-2", amount = 3 },
		},
		energy_required = 0.6000000000000001,
	},
	["bob-roboport-antenna-3"] = {
		ingredients = {
			{ type = "item", name = "processing-unit", amount = 15 },
			{ type = "item", name = "bob-nickel-plate", amount = 3 },
			{ type = "item", name = "bob-insulated-cable", amount = 6 },
		},
		results = {
			{ type = "item", name = "bob-roboport-antenna-3", amount = 3 },
		},
		energy_required = 0.6000000000000001,
	},
	["bob-roboport-antenna-4"] = {
		ingredients = {
			{ type = "item", name = "bob-nickel-plate", amount = 3 },
			{ type = "item", name = "bob-gold-plate", amount = 3 },
			{ type = "item", name = "bob-gilded-copper-cable", amount = 6 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 15 },
		},
		results = {
			{ type = "item", name = "bob-roboport-antenna-4", amount = 3 },
		},
		energy_required = 0.6000000000000001,
	},
	["bob-roboport-chargepad-2"] = {
		ingredients = {
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "battery", amount = 2 },
			{ type = "item", name = "bob-invar-alloy", amount = 2 },
		},
	},
	["bob-roboport-door-2"] = {
		ingredients = {
			{ type = "item", name = "bob-invar-alloy", amount = 15 },
			{ type = "item", name = "bob-steel-bearing", amount = 20 },
			{ type = "item", name = "bob-brass-gear-wheel", amount = 20 },
		},
	},
	["bob-roboport-door-3"] = {
		ingredients = {
			{ type = "item", name = "bob-titanium-plate", amount = 15 },
			{ type = "item", name = "bob-titanium-bearing", amount = 20 },
			{ type = "item", name = "bob-titanium-gear-wheel", amount = 20 },
		},
	},
	["bob-roboport-door-4"] = {
		ingredients = {
			{ type = "item", name = "bob-nitinol-alloy", amount = 15 },
			{ type = "item", name = "bob-nitinol-bearing", amount = 20 },
			{ type = "item", name = "bob-nitinol-gear-wheel", amount = 20 },
		},
	},
	["bob-power-armor-mk3"] = {
		ingredients = {
			{ type = "item", name = "power-armor-mk2", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 50 },
			{ type = "item", name = "bob-invar-alloy", amount = 25 },
			{ type = "item", name = "bob-aluminium-plate", amount = 25 },
			{ type = "item", name = "efficiency-module-3", amount = 5 },
			{ type = "item", name = "speed-module-3", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-orange", amount = 25 },
			{ type = "item", name = "bob-alien-artifact-blue", amount = 25 },
			{ type = "item", name = "space-science-pack", amount = 100 },
		},
	},
	["bob-power-armor-mk4"] = {
		ingredients = {
			{ type = "item", name = "bob-power-armor-mk3", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 40 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 20 },
			{ type = "item", name = "bob-titanium-plate", amount = 25 },
			{ type = "item", name = "bob-silicon-nitride", amount = 25 },
			{ name = "bob-efficiency-module-4", amount = 5, type = "item" },
			{ name = "bob-speed-module-4", amount = 5, type = "item" },
			{ type = "item", name = "bob-alien-artifact-yellow", amount = 25 },
			{ type = "item", name = "bob-alien-artifact-purple", amount = 25 },
			{ type = "item", name = "planetary-data", amount = 1 },
		},
	},
	["bob-power-armor-mk5"] = {
		ingredients = {
			{ type = "item", name = "bob-power-armor-mk4", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 50 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 50 },
			{ type = "item", name = "bob-copper-tungsten-alloy", amount = 25 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 25 },
			{ name = "bob-efficiency-module-5", amount = 5, type = "item" },
			{ name = "bob-speed-module-5", amount = 5, type = "item" },
			{ type = "item", name = "bob-alien-artifact-red", amount = 25 },
			{ type = "item", name = "bob-alien-artifact-green", amount = 25 },
			{ type = "item", name = "station-science", amount = 1 },
		},
	},
	["bob-energy-shield-mk3-equipment"] = {
		ingredients = {
			{ type = "item", name = "energy-shield-mk2-equipment", amount = 2 },
			{ type = "item", name = "productivity-module-2", amount = 1 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ type = "item", name = "bob-alien-artifact", amount = 10 },
		},
	},
	["bob-energy-shield-mk4-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-energy-shield-mk3-equipment", amount = 2 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ type = "item", name = "productivity-module-3", amount = 1 },
			{ type = "item", name = "bob-alien-artifact-orange", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-blue", amount = 5 },
		},
	},
	["bob-energy-shield-mk5-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-energy-shield-mk4-equipment", amount = 2 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ name = "bob-productivity-module-4", amount = 1, type = "item" },
			{ type = "item", name = "bob-alien-artifact-yellow", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-purple", amount = 5 },
		},
	},
	["bob-energy-shield-mk6-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-energy-shield-mk5-equipment", amount = 2 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ name = "bob-productivity-module-5", amount = 1, type = "item" },
			{ type = "item", name = "bob-alien-artifact-red", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-green", amount = 5 },
		},
	},
	["bob-night-vision-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "night-vision-equipment", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 5 },
			{ type = "item", name = "bob-glass", amount = 2 },
		},
	},
	["bob-personal-laser-defense-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "personal-laser-defense-equipment", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "bob-sapphire-5", amount = 1 },
		},
	},
	["bob-personal-laser-defense-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-laser-defense-equipment-2", amount = 1 },
			{ type = "item", name = "bob-invar-alloy", amount = 5 },
			{ type = "item", name = "bob-battery-2", amount = 3 },
			{ type = "item", name = "bob-emerald-5", amount = 1 },
		},
	},
	["bob-personal-laser-defense-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-laser-defense-equipment-3", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 5 },
			{ type = "item", name = "bob-battery-2", amount = 3 },
			{ type = "item", name = "bob-titanium-plate", amount = 5 },
			{ type = "item", name = "bob-amethyst-5", amount = 1 },
		},
	},
	["bob-personal-laser-defense-equipment-5"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-laser-defense-equipment-4", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 5 },
			{ type = "item", name = "bob-battery-3", amount = 3 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 5 },
			{ type = "item", name = "bob-topaz-5", amount = 1 },
		},
	},
	["bob-personal-laser-defense-equipment-6"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-laser-defense-equipment-5", amount = 1 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ type = "item", name = "bob-battery-3", amount = 3 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 5 },
			{ type = "item", name = "bob-diamond-5", amount = 1 },
			{ type = "item", name = "bob-alien-artifact-red", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-green", amount = 5 },
		},
	},
	["bob-exoskeleton-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "exoskeleton-equipment", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 10 },
			{ type = "item", name = "bob-invar-alloy", amount = 20 },
			{ type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 30 },
			{ type = "item", name = "bob-cobalt-steel-bearing", amount = 30 },
		},
	},
	["bob-exoskeleton-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-exoskeleton-equipment-2", amount = 1 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 10 },
			{ type = "item", name = "bob-titanium-plate", amount = 20 },
			{ type = "item", name = "bob-titanium-gear-wheel", amount = 30 },
			{ type = "item", name = "bob-titanium-bearing", amount = 30 },
		},
	},
	["bob-personal-roboport-antenna-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-roboport-antenna-1", amount = 2 },
			{ type = "item", name = "bob-roboport-door-1", amount = 1 },
		},
	},
	["bob-personal-roboport-antenna-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-antenna-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-2", amount = 2 },
			{ type = "item", name = "bob-roboport-door-2", amount = 1 },
		},
	},
	["bob-personal-roboport-antenna-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-antenna-equipment-2", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-3", amount = 2 },
			{ type = "item", name = "bob-roboport-door-3", amount = 1 },
		},
	},
	["bob-personal-roboport-antenna-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-antenna-equipment-3", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-4", amount = 2 },
			{ type = "item", name = "bob-roboport-door-4", amount = 1 },
		},
	},
	["bob-personal-roboport-chargepad-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-roboport-chargepad-1", amount = 2 },
		},
	},
	["bob-personal-roboport-chargepad-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-chargepad-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-chargepad-2", amount = 2 },
		},
	},
	["bob-personal-roboport-chargepad-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-chargepad-equipment-2", amount = 1 },
			{ type = "item", name = "bob-roboport-chargepad-3", amount = 2 },
		},
	},
	["bob-personal-roboport-chargepad-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-chargepad-equipment-3", amount = 1 },
			{ type = "item", name = "bob-roboport-chargepad-4", amount = 2 },
		},
	},
	["bob-personal-roboport-robot-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 30 },
			{ type = "item", name = "bob-electronic-components", amount = 15 },
			{ type = "item", name = "bob-solder", amount = 2 },
			{ type = "item", name = "bob-module-case", amount = 1 },
		},
	},
	["bob-personal-roboport-robot-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-robot-equipment", amount = 1 },
			{ type = "item", name = "bob-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 15 },
			{ type = "item", name = "bob-electronic-components", amount = 30 },
			{ type = "item", name = "bob-solder", amount = 3 },
		},
	},
	["bob-personal-roboport-robot-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-robot-equipment-2", amount = 1 },
			{ type = "item", name = "bob-superior-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 10 },
			{ type = "item", name = "bob-electronic-components", amount = 20 },
			{ type = "item", name = "bob-integrated-electronics", amount = 10 },
			{ type = "item", name = "bob-solder", amount = 4 },
		},
	},
	["bob-personal-roboport-robot-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-robot-equipment-3", amount = 1 },
			{ type = "item", name = "bob-multi-layer-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 5 },
			{ type = "item", name = "bob-electronic-components", amount = 10 },
			{ type = "item", name = "bob-integrated-electronics", amount = 20 },
			{ type = "item", name = "bob-processing-electronics", amount = 8 },
			{ type = "item", name = "bob-solder", amount = 6 },
		},
	},
	["bob-personal-roboport-mk3-equipment"] = {
		ingredients = {
			{ type = "item", name = "personal-roboport-mk2-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-3", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-3", amount = 2 },
			{ type = "item", name = "bob-roboport-door-3", amount = 1 },
			{ type = "item", name = "bob-titanium-plate", amount = 5 },
		},
	},
	["bob-personal-roboport-mk4-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-personal-roboport-mk3-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-4", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-4", amount = 2 },
			{ type = "item", name = "bob-roboport-door-4", amount = 1 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 5 },
		},
	},
	["bob-vehicle-laser-defense-equipment-1"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "electronic-circuit", amount = 5 },
			{ type = "item", name = "battery", amount = 3 },
			{ type = "item", name = "bob-ruby-5", amount = 1 },
		},
	},
	["bob-vehicle-laser-defense-equipment-2"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-laser-defense-equipment-1", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "bob-sapphire-5", amount = 1 },
		},
	},
	["bob-vehicle-laser-defense-equipment-3"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-laser-defense-equipment-2", amount = 1 },
			{ type = "item", name = "bob-invar-alloy", amount = 5 },
			{ type = "item", name = "bob-battery-2", amount = 3 },
			{ type = "item", name = "bob-emerald-5", amount = 1 },
		},
	},
	["bob-vehicle-laser-defense-equipment-4"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-laser-defense-equipment-3", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 5 },
			{ type = "item", name = "bob-battery-2", amount = 3 },
			{ type = "item", name = "bob-titanium-plate", amount = 5 },
			{ type = "item", name = "bob-amethyst-5", amount = 1 },
		},
	},
	["bob-vehicle-laser-defense-equipment-5"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-laser-defense-equipment-4", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 5 },
			{ type = "item", name = "bob-battery-3", amount = 3 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 5 },
			{ type = "item", name = "bob-topaz-5", amount = 1 },
		},
	},
	["bob-vehicle-laser-defense-equipment-6"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-laser-defense-equipment-5", amount = 1 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ type = "item", name = "bob-battery-3", amount = 3 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 5 },
			{ type = "item", name = "bob-diamond-5", amount = 1 },
		},
	},
	["bob-vehicle-roboport-antenna-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-roboport-antenna-1", amount = 2 },
			{ type = "item", name = "bob-roboport-door-1", amount = 1 },
		},
	},
	["bob-vehicle-roboport-antenna-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-antenna-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-2", amount = 2 },
			{ type = "item", name = "bob-roboport-door-2", amount = 1 },
		},
	},
	["bob-vehicle-roboport-antenna-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-antenna-equipment-2", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-3", amount = 2 },
			{ type = "item", name = "bob-roboport-door-3", amount = 1 },
		},
	},
	["bob-vehicle-roboport-antenna-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-antenna-equipment-3", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-4", amount = 2 },
			{ type = "item", name = "bob-roboport-door-4", amount = 1 },
		},
	},
	["bob-vehicle-roboport-chargepad-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-roboport-chargepad-1", amount = 2 },
		},
	},
	["bob-vehicle-roboport-chargepad-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-chargepad-equipment", amount = 1 },
			{ type = "item", name = "bob-roboport-chargepad-2", amount = 2 },
		},
	},
	["bob-vehicle-roboport-chargepad-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-chargepad-equipment-2", amount = 1 },
			{ type = "item", name = "bob-roboport-chargepad-3", amount = 2 },
		},
	},
	["bob-vehicle-roboport-chargepad-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-chargepad-equipment-3", amount = 1 },
			{ type = "item", name = "bob-roboport-chargepad-4", amount = 2 },
		},
	},
	["bob-vehicle-roboport-robot-equipment"] = {
		ingredients = {
			{ type = "item", name = "bob-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 30 },
			{ type = "item", name = "bob-electronic-components", amount = 15 },
			{ type = "item", name = "bob-solder", amount = 2 },
			{ type = "item", name = "bob-module-case", amount = 1 },
		},
	},
	["bob-vehicle-roboport-robot-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-robot-equipment", amount = 1 },
			{ type = "item", name = "bob-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 15 },
			{ type = "item", name = "bob-electronic-components", amount = 30 },
			{ type = "item", name = "bob-solder", amount = 3 },
		},
	},
	["bob-vehicle-roboport-robot-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-robot-equipment-2", amount = 1 },
			{ type = "item", name = "bob-superior-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 10 },
			{ type = "item", name = "bob-electronic-components", amount = 20 },
			{ type = "item", name = "bob-integrated-electronics", amount = 10 },
			{ type = "item", name = "bob-solder", amount = 4 },
		},
	},
	["bob-vehicle-roboport-robot-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-robot-equipment-3", amount = 1 },
			{ type = "item", name = "bob-multi-layer-circuit-board", amount = 1 },
			{ type = "item", name = "bob-basic-electronic-components", amount = 5 },
			{ type = "item", name = "bob-electronic-components", amount = 10 },
			{ type = "item", name = "bob-integrated-electronics", amount = 20 },
			{ type = "item", name = "bob-processing-electronics", amount = 8 },
			{ type = "item", name = "bob-solder", amount = 6 },
		},
	},
	["bob-vehicle-roboport-equipment-1"] = {
		ingredients = {
			{ type = "item", name = "bob-roboport-antenna-1", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-1", amount = 2 },
			{ type = "item", name = "bob-roboport-door-1", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 5 },
		},
	},
	["bob-vehicle-roboport-equipment-2"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-equipment-1", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-2", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-2", amount = 2 },
			{ type = "item", name = "bob-roboport-door-2", amount = 1 },
			{ type = "item", name = "bob-aluminium-plate", amount = 5 },
		},
	},
	["bob-vehicle-roboport-equipment-3"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-equipment-2", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-3", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-3", amount = 2 },
			{ type = "item", name = "bob-roboport-door-3", amount = 1 },
			{ type = "item", name = "bob-titanium-plate", amount = 5 },
		},
	},
	["bob-vehicle-roboport-equipment-4"] = {
		ingredients = {
			{ type = "item", name = "bob-vehicle-roboport-equipment-3", amount = 1 },
			{ type = "item", name = "bob-roboport-antenna-4", amount = 2 },
			{ type = "item", name = "bob-roboport-chargepad-4", amount = 2 },
			{ type = "item", name = "bob-roboport-door-4", amount = 1 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 5 },
		},
	},
	["bob-vehicle-shield-equipment-1"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 10 },
		},
	},
	["bob-vehicle-shield-equipment-2"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-shield-equipment-1", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 5 },
		},
	},
	["bob-vehicle-shield-equipment-3"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-shield-equipment-2", amount = 2 },
			{ type = "item", name = "productivity-module-2", amount = 1 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ type = "item", name = "bob-alien-artifact", amount = 10 },
		},
	},
	["bob-vehicle-shield-equipment-4"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-shield-equipment-3", amount = 2 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ type = "item", name = "productivity-module-3", amount = 1 },
			{ type = "item", name = "bob-alien-artifact-orange", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-blue", amount = 5 },
		},
	},
	["bob-vehicle-shield-equipment-5"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-shield-equipment-4", amount = 2 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ name = "bob-productivity-module-4", amount = 1, type = "item" },
			{ type = "item", name = "bob-alien-artifact-yellow", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-purple", amount = 5 },
		},
	},
	["bob-vehicle-shield-equipment-6"] = {
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "bob-vehicle-shield-equipment-5", amount = 2 },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
			{ name = "bob-productivity-module-5", amount = 1, type = "item" },
			{ type = "item", name = "bob-alien-artifact-red", amount = 5 },
			{ type = "item", name = "bob-alien-artifact-green", amount = 5 },
		},
	},
}
for name, fields in pairs(patch) do
	local prototype = data.raw.recipe[name]
	if prototype then
		for field, value in pairs(fields) do prototype[field] = value end
	end
end
