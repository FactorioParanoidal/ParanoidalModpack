local techUtil = require("__automated-utility-protocol__.util.technology-util")
local function reset_basic_technology_prerequisites_to_regular_tree(mode)
	local technologies = data.raw["technology"]
	techUtil.reset_prerequisites_for_technology(
		technologies["factory-architecture-t1"],
		{ "coal-stone-processing", "coal-ore-smelting", "automation-science-pack" },
		mode
	)
	techUtil.reset_prerequisites_for_technology(
		technologies["basic-automation"],
		{ "factory-architecture-t1", "automation-science-pack" },
		mode
	)
	techUtil.reset_prerequisites_for_technology(technologies["stone-wall"], {
		"basic-automation",
		"military-0",
		"basic-metal-processing",
	}, mode)
	techUtil.reset_prerequisites_for_technology(
		technologies["water-pumpjack-1"],
		{ "basic-automation", "basic-metal-processing", "angels-copper-smelting-1", "electricity", "coal-ore-smelting" },
		mode
	)
	techUtil.reset_prerequisites_for_technology(technologies["basic-logistics"], {
		"iron-storage",
		"basic-electronics",
	}, mode)
	techUtil.reset_prerequisites_for_technology(technologies["logistics-0"], {
		"coal-ore-smelting",
		"basic-wood-production",
		"basic-metal-processing",
		"automation-science-pack",
	}, mode)
	techUtil.reset_prerequisites_for_technology(technologies["armor-absorb-1"], { "basic-automation" }, mode)
	techUtil.reset_prerequisites_for_technology(technologies["bi-dart-turret"], {
		"basic-automation",
		"basic-metal-processing",
		"basic-wood-production",
		"coal-ore-smelting",
		"automation-science-pack",
	}, mode)
	techUtil.reset_prerequisites_for_technology(
		technologies["electricity"],
		{ "basic-automation", "electricity-0" },
		mode
	)
	techUtil.reset_prerequisites_for_technology(
		technologies["angels-zinc-smelting-1"],
		_table.deepcopy(Utils.get_moded_object(technologies["zinc-processing"], mode).prerequisites),
		mode
	)
end

local function add_prerequisites_to_technologies_in_regular_tree(mode)
	local technologies = data.raw["technology"]
	--для бойлеров
	if settings.startup["bobmods-power-heatsources"].value == true then
		techUtil.add_prerequisites_to_technology(technologies["burner-reactor-1"], { "nuclear-power" }, mode)
	end
	techUtil.add_prerequisites_to_technology(technologies["bi-tech-bio-boiler"], { "bio-processing-alien-3" }, mode)
	-- конец для бойлеров
	--заменяем удалённые технологии
	techUtil.replace_all_occurs_prerequisite_to_another_in_active_technologies(
		"zinc-processing",
		"angels-brass-smelting-1",
		mode
	)
	techUtil.replace_all_occurs_prerequisite_to_another_in_active_technologies(
		"nitrogen-processing",
		"angels-nitrogen-processing-1",
		mode
	)
	techUtil.replace_all_occurs_prerequisite_to_another_in_active_technologies("radars-1", "radar", mode)
	techUtil.replace_all_occurs_prerequisite_to_another_in_active_technologies("bio-fermentation", "bio-farm-1", mode)
	techUtil.replace_all_occurs_prerequisite_to_another_in_active_technologies(
		"k-angels-advanced-chemistry-5",
		"angels-advanced-chemistry-3",
		mode
	)
	-- конец заменяем удалённые технологии
	--остальное
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-2"],
		{ "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-3"],
		{ "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["physical-projectile-damage-6"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-4"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["refined-flammables-4"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["energy-weapons-damage-4"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["energy-weapons-damage-5"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["laser-shooting-speed-5"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["follower-robot-count-5"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-5"],
		{ "advanced-logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["inserter-capacity-bonus-7"], {
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["electronics"], {
		"bi-tech-timber",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistic-science-pack"], { "logistics" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["steel-processing"], { "electric-mining" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistics"], { "electronics" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["chemical-science-pack"], {
		"engine",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["military-science-pack"], { "gun-turret" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["production-science-pack"],
		{ "productivity-module", "effectivity-module", "speed-module", "electric-engine" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["utility-science-pack"],
		{ "logistics-3", "nuclear-power" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["atomic-bomb"],
		{ "nuclear-fuel-reprocessing", "bob-rocket", "land-mine", "Schall-tank-H-0", "Schall-tank-SH-0" },
		mode
	)

	if settings.startup["artillery-shells"].value then
		techUtil.add_prerequisites_to_technology(technologies["atomic-bomb"], { "artillery" }, mode)
	end

	techUtil.add_prerequisites_to_technology(technologies["flamethrower"], { "engine" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["advanced-electronics"], {
		"angels-sulfur-processing-1",
		"alien-artifact",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["braking-force-3"],
		{ "advanced-logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["braking-force-6"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistics-3"], { "titanium-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["rocket-silo"], { "bob-area-drills-3" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-5"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-6"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electric-energy-distribution-2"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["effect-transmission"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electric-engine"], { "engine", "steam-power" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["worker-robots-speed-3"],
		{ "advanced-logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["worker-robots-speed-5"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["worker-robots-storage-2"],
		{ "advanced-logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["worker-robots-storage-3"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["energy-shield-equipment"], { "electric-engine" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["battery-equipment"], { "electric-engine" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["fusion-reactor-equipment"],
		{ "solar-panel-equipment-4" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["personal-roboport-equipment"],
		{ "advanced-electronics-2", "defender", "nanobots", "concrete" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["modules"], { "angels-gold-smelting-1" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["mining-productivity-3"],
		{ "production-science-pack", "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["artillery"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bet-tech"], { "battery" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bet-fuel-recycling"], { "bet-fuel-4" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["extremely-advanced-material-processing"], {
		"bob-electric-energy-accumulators-3",
		"bob-robo-modular-4",
		"effect-transmission-3",
		"bob-solar-energy-3",
		"vehicle-motor-equipment",
		"bob-nuclear-power-2",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["extremely-advanced-rocket-payloads"],
		{ "space-lab", "space-telescope" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-machining"],
		{ "automation-6", "stack-inserter-4" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["autonomous-space-mining-drones"], { "bob-drills-4" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["shuttle-repurposing"], { "asteroid-mining" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["orbital-autonomous-fabricators"],
		{ "advanced-material-processing-4", "centrifuging-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["ober-nuclear-processing"],
		{ "phosphorus-processing-2", "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["qol-crafting-speed-1-1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["qol-inventory-size-1-1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["qol-mining-speed-1-1"], { "automation-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["qol-movement-speed-1-1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["qol-player-reach-1-1"], { "automation-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["robot-attrition-explosion-safety"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["w93-modular-turrets"], { "fast-inserter" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["w93-modular-turrets2"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["w93-modular-turrets-gatling"],
		{ "w93-modular-turrets2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["w93-modular-turrets-rocket"],
		{ "w93-modular-turrets2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["w93-modular-turrets-plaser"],
		{ "w93-modular-turrets2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["w93-modular-turrets-lcannon"],
		{ "w93-modular-turrets2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["w93-modular-turrets-dcannon"],
		{ "angels-explosives-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["Schall-pickup-tower-1"], { "radar" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["Schall-tank-SH-1"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["warehouse-logistics-research-2"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["alloy-processing"], { "angels-nickel-smelting-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["grinding"], { "geode-crystallization-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["nitinol-processing"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["tungsten-alloy-processing"],
		{ "titanium-processing", "ceramics", "nitinol-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["deuterium-fuel-cell-2"],
		{ "deuterium-fuel-reprocessing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["advanced-research"], { "electric-lab" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["nanobots"], { "repair-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["roboport-interface"],
		{ "radar", "bob-robo-modular-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["electronics-machine-1"], { "logistics" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electronics-machine-2"], { "fast-inserter" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electronics-machine-3"], { "turbo-inserter" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-fluid-wagon-2"], { "bob-fluid-handling-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-robo-modular-1"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-robo-modular-4"], { "tungsten-alloy-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistic-system-2"], { "construction-robotics" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["toolbelt-3"], { "advanced-logistic-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["toolbelt-4"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-stack-size-bonus-3"],
		{ "advanced-logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-stack-size-bonus-4"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bob-area-drills-2"], { "bob-drills-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-area-drills-3"], { "bob-drills-3" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-area-drills-4"], { "bob-drills-4" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-pumpjacks-4"], { "tungsten-alloy-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electric-pole-3"], { "rubber" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-steam-turbine-3"], { "tungsten-alloy-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-nuclear-power-2"], { "centrifuging-2" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bob-nuclear-power-3"],
		{ "bob-nuclear-power-2", "thorium-fuel-reprocessing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bob-shotgun-shells"], { "military-4" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-plasma-rocket"], { "bob-rocket" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-power-armor-3"], { "space-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bob-power-armor-4"],
		{ "bob-armor-making-3", "space-telescope" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bob-power-armor-5"],
		{ "bob-armor-making-4", "space-shuttle" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bob-plasma-turrets-1"], { "alien-artifact" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-plasma-turrets-2"], { "bob-laser-turrets-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-plasma-turrets-3"], { "bob-laser-turrets-3" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-plasma-turrets-4"], { "bob-laser-turrets-4" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bob-plasma-turrets-5"], { "bob-laser-turrets-5" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["memory-unit"], { "warehouse-research" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["Ducts"],
		{ "angels-metallurgy-3", "bob-fluid-handling-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["effect-transmission-3"],
		{ "advanced-electronics-3", "bio-processing-crystal-full" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["speed-module-7"], { "advanced-electronics-3" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["effectivity-module-7"], { "advanced-electronics-3" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["productivity-module-7"], { "advanced-electronics-3" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["pollution-clean-module-7"],
		{ "advanced-electronics-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["pollution-create-module-7"],
		{ "advanced-electronics-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["module-merging"], { "angels-gunmetal-smelting-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["vehicle-roboport-equipment"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["miniloader"], { "angels-steel-smelting-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["fast-miniloader"], { "fast-inserter" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["express-miniloader"], { "express-inserters" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["turbo-miniloader"], { "turbo-inserter" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["ultimate-miniloader"], { "ultimate-inserter" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["armor-absorb-10"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["armor-absorb-15"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["armor-absorb-20"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["cargo-planes"], { "military" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["napalm"], { "flamethrower" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["aircraft-energy-shield"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["ore-crushing"],
		{ "burner-ore-crushing", "water-aggregate-states" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-ore-refining-1"],
		{ "angels-stone-smelting-1", "engine" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["slag-processing-1"],
		{ "angels-stone-smelting-1", "bi-tech-ash" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-ore-refining-2"],
		{ "concrete", "angels-metallurgy-3", "electric-engine" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["slag-processing-2"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["ore-leaching"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["advanced-ore-refining-3"], { "titanium-processing" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-ore-refining-4"],
		{ "advanced-electronics-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["water-treatment"], { "angels-metallurgy-1" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["water-treatment-2"],
		{ "angels-stone-smelting-1", "bi-tech-coal-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["water-treatment-3"],
		{ "concrete", "angels-metallurgy-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["water-treatment-4"],
		{ "advanced-electronics-2", "nuclear-fuel-reprocessing-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["water-washing-1"], { "electric-mining" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["water-washing-2"],
		{ "angels-stone-smelting-1", "concrete" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["automation-8"], { "advanced-magnesium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["automation-9"],
		{ "advanced-depleted-uranium-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["electronics-machine-5"],
		{ "advanced-magnesium-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["space-casings"], { "advanced-osmium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["space-thrusters"], { "advanced-osmium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["fuel-cells"], { "advanced-osmium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["habitation"], { "advanced-osmium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["life-support-systems"],
		{ "productivity-module-8", "advanced-osmium-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["spaceship-command"],
		{ "productivity-module-8", "advanced-osmium-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["astrometrics"], { "advanced-osmium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["ftl-propulsion"], { "advanced-osmium-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["angels-coal-processing"], { "water-aggregate-states" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-coal-processing-2"],
		{ "chlorine-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-nitrogen-processing-2"],
		{ "bio-nutrient-paste" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-nitrogen-processing-4"],
		{ "angels-copper-tungsten-smelting-1", "tungsten-alloy-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["chlorine-processing-2"],
		{ "angels-oil-processing", "angels-advanced-chemistry-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["oil-gas-extraction"], { "angels-stone-smelting-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["angels-advanced-gas-processing"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["angels-advanced-chemistry-1"], {
		"angels-stone-smelting-1",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-advanced-chemistry-2"],
		{ "concrete", "angels-nitrogen-processing-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-advanced-chemistry-3"],
		{ "mercury-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-advanced-chemistry-4"],
		{ "titanium-processing", "ore-refining" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["gas-steam-cracking-1"],
		{ "angels-advanced-chemistry-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["rubbers"], { "angels-advanced-chemistry-2" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["rubber"],
		{ "chlorine-processing-2", "angels-coolant-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["better-cargo-planes"],
		{ "low-density-structure", "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["mixed-oxide-fuel"], { "nuclear-fuel-reprocessing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["CW-air-filtering-5"], { "nitinol-processing" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["CW-air-filtering-6"],
		{ "angels-copper-tungsten-smelting-1", "space-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["petroleum-generator"],
		{ "bob-steam-engine-3", "angels-metallurgy-3", "flammables", "slag-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["offshore-pump-3"], { "titanium-processing" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["offshore-pump-4"],
		{ "nitinol-processing", "advanced-logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-steel-smelting-2"],
		{ "angels-manganese-smelting-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-steel-smelting-3"],
		{ "angels-chrome-smelting-2", "angels-tungsten-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-aluminium-smelting-1"],
		{ "angels-sulfur-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-aluminium-smelting-2"],
		{ "advanced-magnesium-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-aluminium-smelting-3"],
		{ "angels-zinc-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-iron-smelting-3"],
		{ "advanced-magnesium-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-metallurgy-2"], {
		"angels-stone-smelting-1",
		"ore-floatation",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-metallurgy-3"],
		{ "concrete", "ore-leaching", "angels-alloys-smelting-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["ore-processing-2"], { "angels-metallurgy-2" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-copper-smelting-3"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-lead-smelting-3"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-nickel-smelting-2"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-silicon-smelting-2"],
		{ "chlorine-processing-1", "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-silver-smelting-2"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-metallurgy-4"],
		{ "advanced-electronics-2", "titanium-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-metallurgy-5"], { "advanced-electronics-3" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["ore-processing-2"],
		{ "angels-aluminium-smelting-1", "concrete", "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["ore-processing-5"],
		{ "angels-tungsten-carbide-smelting-1", "nitinol-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-cooling"], { "angels-stone-smelting-1" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-titanium-smelting-3"],
		{ "advanced-magnesium-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-tungsten-smelting-3"], {
		"angels-coolant-1",
		"sodium-processing-2",
		"angels-manganese-smelting-3",
		"angels-zinc-smelting-2",
		"phosphorus-processing-2",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["angels-zinc-smelting-1"], { "ore-floatation" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bi-tech-coal-processing-2"], { "gas-synthesis" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bi-tech-fertilizer"], { "sodium-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bi-tech-depollution-1"], { "bi-tech-fertilizer" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-alloys-smelting-2"],
		{ "angels-invar-smelting-1", "angels-cobalt-steel-smelting-1", "angels-gunmetal-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-alloys-smelting-3"],
		{ "angels-coolant-1", "angels-nitinol-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-ironworks-2"],
		{ "angels-cobalt-steel-smelting-1", "angels-steel-smelting-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-ironworks-3"], { "angels-zinc-smelting-3" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-processing-green"],
		{ "angels-steel-smelting-1", "angels-stone-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bio-processing-blue"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bio-processing-paste"], {
		"angels-cobalt-smelting-1",
		"angels-copper-smelting-2",
		"angels-gold-smelting-2",
		"angels-iron-smelting-2",
		"angels-titanium-smelting-2",
		"angels-tungsten-smelting-1",
		"angels-zinc-smelting-2",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["bio-processing-alien-2"], { "slag-processing-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bio-processing-alien-3"], { "bio-processing-paste" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["gardens-3"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-arboretum-1"],
		{ "bio-nutrient-paste", "bio-temperate-farming-1" },
		mode
	)

	techUtil.add_prerequisites_to_technology(technologies["bio-farm-2"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-temperate-farming-2"],
		{ "angels-titanium-smelting-1", "advanced-electronics-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-desert-farming-2"],
		{ "angels-titanium-smelting-1", "advanced-electronics-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-swamp-farming-2"],
		{ "angels-titanium-smelting-1", "advanced-electronics-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bio-nutrient-paste"], {
		"bio-temperate-farming-1",
		"bio-desert-farming-1",
		"bio-swamp-farming-1",
		"bio-wood-processing",
		"chlorine-processing-1",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-pressing-1"],
		{ "bio-swamp-farming-1", "bio-desert-farming-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-pressing-2"],
		{ "angels-titanium-smelting-1", "advanced-electronics-2", "titanium-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-farm-2"],
		{ "bio-temperate-farming-1", "bio-desert-farming-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-swamp-farming-1"],
		{ "bio-temperate-farming-1", "bio-desert-farming-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bio-refugium-fish-2"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bio-refugium-hatchery"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bio-refugium-puffer-2"], {
		"bio-temperate-farming-2",
		"bio-desert-farming-2",
		"bio-swamp-farming-2",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-refugium-puffer-3"],
		{ "angels-tungsten-smelting-1", "advanced-electronics-3", "tungsten-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-refugium-biter-3"],
		{ "bio-refugium-puffer-2", "angels-copper-tungsten-smelting-1", "tungsten-alloy-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-processing-crystal-full"],
		{ "production-science-pack", "ore-powderizer" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-refugium-biter-2"],
		{ "angels-tungsten-smelting-1", "advanced-electronics-3", "tungsten-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bio-refugium-biter-3"], { "bio-processing-alien-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bio-refugium-butchery-2"], { "bio-refugium-puffer-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["factory-preview"], { "logistic-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["garden-mutation"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["advanced-magnesium-smelting"], { "water-treatment-4" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-depleted-uranium-smelting-1"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["advanced-osmium-smelting"], { "asteroid-mining" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-uranium-processing-1"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["mercury-processing-1"],
		{ "automation-science-pack", "logistic-science-pack", "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["centrifuging-2"],
		{ "advanced-electronics-3", "angels-copper-tungsten-smelting-1", "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["phosphorus-processing-1"],
		{ "angels-nitrogen-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-nitrogen-processing-1"],
		{ "basic-chemistry-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["phosphorus-processing-2"], { "sodium-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["plastic-pc"], { "angels-advanced-chemistry-5" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["remelting-alloy-mixer-1"],
		{ "angels-steel-smelting-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["remelting-alloy-mixer-4"],
		{ "advanced-electronics-2", "titanium-processing", "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["nuclear-fuel-1"], { "centrifuging-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["nuclear-fuel-2"], { "nuclear-fuel-reprocessing-2" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["nuclear-fuel-3"],
		{ "thorium-nuclear-fuel-reprocessing-2" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["radiothermal-fuel-1"], { "nuclear-fuel-reprocessing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["radiothermal-fuel-2"], { "water-treatment-4" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["thorium-nuclear-fuel-reprocessing-2"],
		{ "thorium-plutonium-fuel-cell" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["thorium-ore-processing"], { "slag-processing-3" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["angels-advanced-gas-processing-2"], {
		"angels-copper-tungsten-smelting-1",
		"advanced-electronics-3",
		"tungsten-alloy-processing",
		"angels-advanced-chemistry-5",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["sodium-processing-2"],
		{ "angels-lead-smelting-3", "production-science-pack", "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-copper-tungsten-smelting-2"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-advanced-bio-processing"],
		{ "advanced-electronics-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bio-refugium-butchery-3"], { "titanium-processing" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-farm-advanced-upgrade"],
		{ "angels-tungsten-smelting-1", "advanced-electronics-3", "tungsten-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bio-refugium-hatchery-2"],
		{ "angels-titanium-smelting-1", "advanced-electronics-3", "angels-tungsten-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["bio-nutrient-paste-2"], {
		"concrete",
		"angels-titanium-smelting-1",
		"advanced-electronics-2",
		"titanium-processing",
		"bio-temperate-farming-2",
		"bio-desert-farming-2",
		"bio-swamp-farming-2",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["water-washing-3"], { "bob-drills-2" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["water-washing-4"],
		{ "advanced-electronics-2", "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["advanced-ore-refining-5"],
		{ "angels-copper-tungsten-smelting-1", "tungsten-alloy-processing" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["basic-atomic-weapons"],
		{ "nuclear-fuel-reprocessing", "electric-energy-accumulators" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["artillery-atomics"], { "full-fission-atomics" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["californium-weapons"],
		{ "bob-shotgun-shells", "bob-bullets", "Schall-sniper-rifle" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["fusion-weapons"], { "space-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["thermobaric-weaponry"], {
		"angels-explosives-1",
		"tank",
		"bob-rocket",
		"rocket-control-unit",
		"land-mine",
		"Schall-tank-H-0",
		"Schall-tank-SH-0",
		"artillery",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["artillery-prototype"],
		{ "engine", "concrete", "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["hiend_train"],
		{ "bob-railway-3", "bob-fluid-wagon-3", "bet-charger-3" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["geode-processing-3"], { "geode-crystallization-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["geode-crystallization-1"], { "slag-processing-2" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-brass-smelting-1"],
		{ "angels-zinc-smelting-1", "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-brass-smelting-3"], { "angels-coolant-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["angels-bronze-smelting-3"], { "angels-coolant-1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["advanced-electronics-3"], { "modules-2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["coal-ore-crushing"], {
		"angels-ore1-detected-resource-technology",
		"angels-ore3-detected-resource-technology",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["basic-wood-production"], {
		"basic-metal-processing",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["water-aggregate-states"],
		{ "coal-wooden-fluid-handling" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["burner-ore-crushing"], {
		"angels-ore5-detected-resource-technology",
		"angels-ore6-detected-resource-technology",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-ore1-detected-resource-technology"],
		{ "water-detected-resource-technology" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-ore3-detected-resource-technology"],
		{ "water-detected-resource-technology" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-ore5-detected-resource-technology"],
		{ "water-aggregate-states" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-ore6-detected-resource-technology"],
		{ "water-aggregate-states" },
		mode
	)

	techUtil.add_prerequisites_to_technology(
		technologies["angels-ore2-detected-resource-technology"],
		{ "water-aggregate-states" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["angels-ore4-detected-resource-technology"],
		{ "water-aggregate-states" },
		mode
	)
	if settings.startup["bobs-military-simplify"].value == false then
		techUtil.add_prerequisites_to_technology(technologies["uranium-ammo"], {
			"Schall-sniper-rifle",
			"advanced-depleted-uranium-smelting-1",
			"Schall-tank-H-0",
			"Schall-tank-SH-0",
			"w93-modular-turrets-lcannon",
			"w93-modular-turrets-hcannon",
		}, mode)
	end
	techUtil.add_prerequisites_to_technology(
		technologies["Schall-pickup-tower-4"],
		{ "advanced-electronics-2", "utility-science-pack" },
		mode
	)
end

local function remove_prerequisites_from_technologies_in_regular_tree(mode)
	local technologies = data.raw["technology"]
	-- удаление скрытых технологий
	techUtil.remove_prerequisites_from_technology(
		technologies["water-chemistry-2"],
		{ "angels-electric-boiler-2" },
		mode
	)
	-- конец удаление скрытых технологий
	-- удаление остальных
	techUtil.remove_prerequisites_from_technology(technologies["silicon-processing"], { "chlorine-processing-2" }, mode)
	techUtil.remove_prerequisites_from_technology(
		technologies["mercury-processing-1"],
		{ "angels-advanced-chemistry-3" },
		mode
	)
	techUtil.remove_prerequisites_from_technology(technologies["ore-processing-2"], { "angels-metallurgy-3" }, mode)
	techUtil.remove_prerequisites_from_technology(
		technologies["bio-processing-alien-1"],
		{ "bio-processing-paste" },
		mode
	)
	techUtil.remove_prerequisites_from_technology(
		technologies["bio-refugium-biter-3"],
		{ "bio-refugium-puffer-4" },
		mode
	)
	techUtil.remove_prerequisites_from_technology(
		technologies["angels-zinc-smelting-1"],
		{ "angels-brass-smelting-1" },
		mode
	)
	-- конец удаление остальных
end

local function remove_recipes_from_technology_effects_in_regular_tree(mode)
	local technologies = data.raw["technology"]
	-- скрытые рецепты или несуществующие
	techUtil.remove_recipe_effect_from_technology(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-copper-plate",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-iron-plate",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-lead-plate",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-silver-plate",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-tin-plate",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-angels-solder-mixture-smelting",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(technologies["basic-fluid-handling"], "bob-valve", mode)
	techUtil.remove_recipe_effect_from_technology(
		technologies["angels-stone-smelting-2"],
		"angels-concrete-brick",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(
		technologies["angels-stone-smelting-3"],
		"angels-reinforced-concrete-brick",
		mode
	)
	techUtil.remove_recipe_effect_from_technology(technologies["rocket-silo"], "rocket-part", mode)
	-- конец скрытые рецепты или несуществующие
	--остальные
	techUtil.remove_recipe_effect_from_technology(technologies["bio-fermentation"], "fermentation-corn", mode)
	techUtil.remove_recipe_effect_from_technology(technologies["bio-fermentation"], "fermentation-fruit", mode)
	techUtil.remove_recipe_effect_from_technology(technologies["bio-fermentation"], "anaerobic-fermentation", mode)
	techUtil.remove_recipe_effect_from_technology(technologies["bio-fermentation"], "aerobic-fermentation", mode)

	techUtil.remove_recipe_effect_from_technology(technologies["bio-farm-1"], "solid-soil", mode)

	--конец остальные
end

local function move_recipes_to_another_technologies(mode)
	--basic
	techUtil.move_recipe_effects_to_another_technology("electricity", "repair-pack", "repair-pack", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-logistics", "burner-filter-inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("basic-automation", "basic-logistics", "burner-inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "condensator", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "wooden-board", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "basic-circuit-board", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "logistics", "inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("electronics", "logistics", "yellow-filter-inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("steam-power", "water-aggregate-states", "boiler", mode)
	--end basic
	-- перенос из удалённых технологий
	techUtil.move_recipe_effects_to_another_technology("zinc-processing", "angels-brass-smelting-1", "brass-pipe", mode)
	techUtil.move_recipe_effects_to_another_technology(
		"zinc-processing",
		"angels-brass-smelting-1",
		"brass-pipe-to-ground",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"zinc-processing",
		"angels-brass-smelting-1",
		"brass-chest",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"zinc-processing",
		"angels-brass-smelting-1",
		"brass-gear-wheel",
		mode
	)
	-- конец перенос из удалённых технологий
	--another
	techUtil.move_recipe_effects_to_another_technology(
		"w93-modular-turrets",
		"w93-modular-turrets2",
		"w93-hmg-turret2",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"tungsten-processing",
		"tungsten-alloy-processing",
		"anotherworld-structure-components",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology("basic-automation", "steam-power", "steam-inserter", mode)
	techUtil.move_recipe_effects_to_another_technology(
		"water-treatment",
		"water-treatment-2",
		"bi-mineralized-sulfuric-waste",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"water-chemistry-2",
		"deuterium-processing",
		"deuterium-fuel-cell",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"angels-advanced-chemistry-2",
		"angels-advanced-chemistry-3",
		"acetylene-diomerisation",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"k-angels-advanced-chemistry-5",
		"angels-advanced-chemistry-3",
		"nitrous-oxide-synthesis-1",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"k-angels-advanced-chemistry-5",
		"angels-advanced-chemistry-3",
		"nitrous-oxide-synthesis-2",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"k-angels-advanced-chemistry-5",
		"angels-advanced-chemistry-3",
		"sodium-nitrate-synthesis",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"k-angels-advanced-chemistry-5",
		"angels-advanced-chemistry-3",
		"acrylonitrile-synthesis",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"k-angels-advanced-chemistry-5",
		"angels-advanced-chemistry-3",
		"catalyst-metal-cyan",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology("resins", "resin-1", "solid-resin", mode)
	techUtil.move_recipe_effects_to_another_technology("rubber", "rubbers", "liquid-rubber-1", mode)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-processing-paste",
		"bio-nutrient-paste",
		"paste-cellulose",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-nutrient-paste",
		"bio-nutrient-paste-2",
		"solid-fruit-nutrients",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-farm-1",
		"bio-temperate-farming-1",
		"temperate-garden-generation",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-farm-1",
		"bio-swamp-farming-1",
		"swamp-garden-generation",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology("bio-farm-1", "bio-farm-2", "crop-farm", mode)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-refugium-hatchery",
		"bio-refugium-puffer-2",
		"puffer-egg-1",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-refugium-hatchery",
		"bio-refugium-puffer-2",
		"puffer-egg-2",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-refugium-hatchery",
		"bio-refugium-puffer-3",
		"puffer-egg-3",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-refugium-hatchery",
		"bio-refugium-puffer-4",
		"puffer-egg-4",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"bio-refugium-hatchery",
		"bio-refugium-puffer-4",
		"puffer-egg-5",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"angels-nitrogen-processing-2",
		"angels-nitrogen-processing-1",
		"gas-ammonia",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"phosphorus-processing-1",
		"phosphorus-processing-2",
		"solid-tetrasodium-pyrophosphate",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"geode-processing-2",
		"geode-processing-3",
		"ober-liquify-ruby",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"geode-processing-2",
		"geode-processing-3",
		"ober-liquify-sapphire",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"geode-processing-2",
		"geode-processing-3",
		"ober-liquify-emerald",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"geode-processing-2",
		"geode-processing-3",
		"ober-liquify-amethyst",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"geode-processing-2",
		"geode-processing-3",
		"ober-liquify-topaz",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology(
		"geode-processing-2",
		"geode-processing-3",
		"ober-liquify-diamond",
		mode
	)
	--end another
end

local function add_recipe_to_technology_effects(mode)
	--#region basic tech recipes
	local technologies = data.raw["technology"]
	techUtil.add_recipe_effect_to_technology(
		technologies["salvaged-automation-tech"],
		"salvaged-mining-drill-bit-mk0",
		mode
	)
	techUtil.add_recipe_effect_to_technology(technologies["coal-wooden-fluid-handling"], "bi-wood-pipe", mode)
	techUtil.add_recipe_effect_to_technology(
		technologies["coal-wooden-fluid-handling"],
		"salvaged-offshore-pump-0",
		mode
	)
	techUtil.add_recipe_effect_to_technology(technologies["coal-wooden-fluid-handling"], "bi-wood-pipe-to-ground", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-crushing"], "salvaged-ore-crusher", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-crushing"], "angelsore1-crushed", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-crushing"], "angelsore3-crushed", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-stone-processing"], "stone-crushed", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-smelting"], "angelsore1-crushed-smelting", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-smelting"], "angelsore3-crushed-smelting", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-lighting"], "deadlock-copper-lamp", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-wood-production"], "coal-bi-bio-farm", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-wood-production"], "coal-bi-bio-greenhouse", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-wood-production"], "basic-coal-production-wood", mode)
	techUtil.add_recipe_effect_to_technology(
		technologies["basic-wood-production"],
		"basic-coal-production-seedling",
		mode
	)
	techUtil.add_recipe_effect_to_technology(technologies["basic-electronics"], "motor", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-electronics"], "electric-motor", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military-0"], "pistol-rearm-ammo", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military-0"], "bi-wooden-fence", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military-0"], "respirator", mode)
	if settings.startup["bobmods-power-heatsources"].value == true then
		techUtil.add_recipe_effect_to_technology(technologies["electricity-0"], "bob-burner-generator", mode)
	end
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-mining"], "mining-drill-bit-mk0", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-mining"], "burner-mining-drill", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-crushing"], "burner-ore-crusher", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-crushing"], "angelsore5-crushed", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-crushing"], "angelsore6-crushed", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-crushing"], "angelsore5-crushed-smelting", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-crushing"], "angelsore6-crushed-smelting", mode)
	techUtil.add_recipe_effect_to_technology(technologies["automation-science-pack"], "burner-lab", mode)
	techUtil.add_recipe_effect_to_technology(technologies["automation-science-pack"], "sci-component-1", mode)
	techUtil.add_recipe_effect_to_technology(technologies["logistics-0"], "basic-transport-belt", mode)
	techUtil.add_recipe_effect_to_technology(technologies["logistics"], "transport-belt", mode)
	if settings.startup["bobmods-mining-steamminingdrills"].value == true then
		techUtil.add_recipe_effect_to_technology(technologies["steam-power"], "steam-mining-drill", mode)
	end
	techUtil.add_recipe_effect_to_technology(technologies["electricity"], "burner-turbine", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-fluid-handling"], "offshore-pump-0", mode)
	techUtil.add_recipe_effect_to_technology(technologies["ore-crushing"], "iron-plate", mode)
	techUtil.add_recipe_effect_to_technology(technologies["ore-crushing"], "copper-plate", mode)
	techUtil.add_recipe_effect_to_technology(technologies["ore-crushing"], "lead-plate", mode)
	techUtil.add_recipe_effect_to_technology(technologies["ore-crushing"], "tin-plate", mode)
	techUtil.add_recipe_effect_to_technology(technologies["ore-crushing"], "glass-from-ore4", mode)
	if settings.startup["miniloader-enable-chute"].value == true then
		techUtil.add_recipe_effect_to_technology(technologies["basic-miniloader"], "chute-miniloader", mode)
	end
	techUtil.add_recipe_effect_to_technology(technologies["military"], "copper-nickel-firearm-magazine", mode)
	--#end region basic tech recipes
	-- остальные
	techUtil.add_recipe_effect_to_technology(technologies["nuclear-power"], "used-up-RITEG-1", mode)

	if settings.startup["bobs-military-simplify"].value == true then
		techUtil.add_recipe_effect_to_technology(technologies["bob-bullets"], "bullet-casing", mode)
		techUtil.add_recipe_effect_to_technology(technologies["bob-bullets"], "magazine", mode)
		techUtil.add_recipe_effect_to_technology(technologies["bob-shotgun-shells"], "shotgun-shell-casing", mode)
	end
	techUtil.add_recipe_effect_to_technology(technologies["CW-air-filtering-1"], "CW-filter-air", mode)
	techUtil.add_recipe_effect_to_technology(technologies["angels-chrome-smelting-2"], "angels-plate-chrome", mode)
	techUtil.add_recipe_effect_to_technology(
		technologies["angels-manganese-smelting-2"],
		"angels-plate-manganese",
		mode
	)

	-- разнесение ферментации в отдельные ветки, для которых она нужна
	techUtil.add_recipe_effect_to_technology(technologies["bio-temperate-farming-1"], "fermentation-corn", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-desert-farming-1"], "fermentation-corn", mode)

	techUtil.add_recipe_effect_to_technology(technologies["bio-temperate-farming-2"], "fermentation-fruit", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-desert-farming-2"], "fermentation-fruit", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-swamp-farming-2"], "fermentation-fruit", mode)

	techUtil.add_recipe_effect_to_technology(technologies["bio-temperate-farming-1"], "solid-soil", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-desert-farming-1"], "solid-soil", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-swamp-farming-1"], "solid-soil", mode)

	techUtil.add_recipe_effect_to_technology(technologies["bio-temperate-farming-1"], "anaerobic-fermentation", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-desert-farming-1"], "anaerobic-fermentation", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-temperate-farming-1"], "aerobic-fermentation", mode)
	techUtil.add_recipe_effect_to_technology(technologies["bio-desert-farming-1"], "aerobic-fermentation", mode)
	-- конец разнесение ферментации в отдельные ветки, для которых она нужна
	-- конец остальные
end
local function hide_recipes(mode)
	local recipes = data.raw["recipe"]
	-- скрыть бесполезный факел
	techUtil.hide_recipe(recipes["torch"], mode)
	-- конец скрыть бесполезный факел
	-- отключить ручной крафт руд
	techUtil.hide_recipe(recipes["angelsore1-crushed-hand"], mode)
	techUtil.hide_recipe(recipes["angelsore3-crushed-hand"], mode)
	-- конец отключить ручной крафт руд
end
local function hide_technologies(mode)
	local technologies = data.raw["technology"]
	--отключить электробойлеры, реализованные как сборочные автоматы
	techUtil.hide_technology(technologies["angels-electric-boiler"], mode)
	techUtil.hide_technology(technologies["angels-electric-boiler-2"], mode)
	techUtil.hide_technology(technologies["angels-electric-boiler-3"], mode)
	--конец отключить электробойлеры, реализованные как сборочные автоматы
	--отключить электробойлер и бойлер на солнечных батареях
	techUtil.hide_technology(technologies["bi-tech-steamsolar-combination"], mode)
	-- конец отключить электробойлер и бойлер на солнечных батареях

	--остальное
	techUtil.hide_technology(technologies["zinc-processing"], mode)
	techUtil.hide_technology(technologies["k-angels-advanced-chemistry-5"], mode)
	techUtil.hide_technology(technologies["bio-fermentation"], mode)
	techUtil.hide_technology(technologies["nitrogen-processing"], mode)
	-- конец остальное
end
local function show_technologies(mode)
	local technologies = data.raw["technology"]
end
local function show_recipes(mode)
	local recipes = data.raw["recipe"]
	techUtil.show_recipe(recipes["magazine"], mode)

	if settings.startup["bobs-military-simplify"].value == true then
		techUtil.show_recipe(recipes["shotgun-shell-casing"], mode)
		techUtil.show_recipe(recipes["bullet-casing"], mode)
	end

	techUtil.show_recipe(recipes["CW-filter-air"], mode)
	techUtil.show_recipe(recipes["angels-plate-chrome"], mode)
	techUtil.show_recipe(recipes["angels-plate-manganese"], mode)
end

_table.each(GAME_MODES, function(mode)
	show_technologies(mode)

	reset_basic_technology_prerequisites_to_regular_tree(mode)
	remove_prerequisites_from_technologies_in_regular_tree(mode)
	add_prerequisites_to_technologies_in_regular_tree(mode)
	remove_recipes_from_technology_effects_in_regular_tree(mode)

	hide_technologies(mode)

	show_recipes(mode)

	add_recipe_to_technology_effects(mode)
	move_recipes_to_another_technologies(mode)

	hide_recipes(mode)
end)
