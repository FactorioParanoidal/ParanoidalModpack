local tech_util = require("__automated-utility-protocol__.util.technology-util")
local function reset_basic_technology_prerequisites_to_regular_tree(mode)
    tech_util.reset_prerequisites_for_technology("factory-architecture-t1",
        { "coal-stone-processing", "coal-ore-smelting", "automation-science-pack" }, mode)
    tech_util.reset_prerequisites_for_technology("basic-automation",
        { "factory-architecture-t1", "automation-science-pack" }, mode)
    tech_util.reset_prerequisites_for_technology("stone-wall",
        { "basic-automation", "military-0", "basic-metal-processing" }, mode)
    if mods["P-U-M-P-S"] then
        tech_util.reset_prerequisites_for_technology("water-pumpjack-1",
            { "basic-automation", "basic-metal-processing", "angels-copper-smelting-1", "electricity",
                "coal-ore-smelting" }, mode)
    end
    tech_util.reset_prerequisites_for_technology("basic-logistics", { "iron-storage", "basic-electronics" }, mode)
    tech_util.reset_prerequisites_for_technology("logistics-0",
        { "coal-ore-smelting", "basic-wood-production", "basic-metal-processing", "automation-science-pack" }, mode)
    tech_util.reset_prerequisites_for_technology("armor-absorb-1", { "basic-automation" }, mode)
    tech_util.reset_prerequisites_for_technology("bi-dart-turret",
        { "basic-automation", "basic-metal-processing", "basic-wood-production", "coal-ore-smelting",
            "automation-science-pack" }, mode)
    tech_util.reset_prerequisites_for_technology("electricity", { "basic-automation", "electricity-0" }, mode)
    tech_util.reset_prerequisites_for_technology("angels-zinc-smelting-1",
        _table.deepcopy(Utils.get_moded_object(data.raw["technology"]["zinc-processing"], mode).prerequisites), mode)
    --заменяем удалённые технологии
    tech_util.replace_all_occurs_prerequisite_to_another_in_active_technologies("zinc-processing",
        "angels-brass-smelting-1", mode)
    tech_util.replace_all_occurs_prerequisite_to_another_in_active_technologies("nitrogen-processing",
        "angels-nitrogen-processing-1", mode)
    tech_util.replace_all_occurs_prerequisite_to_another_in_active_technologies("radars-1", "radar", mode)
    tech_util.replace_all_occurs_prerequisite_to_another_in_active_technologies("bio-fermentation", "bio-farm-1", mode)
    tech_util.replace_all_occurs_prerequisite_to_another_in_active_technologies("k-angels-advanced-chemistry-5",
        "angels-advanced-chemistry-3", mode)
    -- конец заменяем удалённые технологии
    if mods["nixie-tubes"] then
        tech_util.reset_prerequisites_for_technology("cathodes", { "circuit-network" })
    end
end

local function add_prerequisites_to_technologies_in_regular_tree(mode)
    --для бойлеров
    if settings.startup["bobmods-power-heatsources"].value == true then
        tech_util.add_prerequisites_to_technology("burner-reactor-1", { "nuclear-power" }, mode)
    end
    tech_util.add_prerequisites_to_technology("bi-tech-bio-boiler", { "bio-processing-alien-3" }, mode)
    -- конец для бойлеров
    --остальное
    tech_util.add_prerequisites_to_technology("physical-projectile-damage-2", { "logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("physical-projectile-damage-3", { "military-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("physical-projectile-damage-6", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("stronger-explosives-4", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("refined-flammables-4", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("energy-weapons-damage-4", { "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("energy-weapons-damage-5", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("laser-shooting-speed-5", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("follower-robot-count-5", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("inserter-capacity-bonus-5", { "advanced-logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("inserter-capacity-bonus-7", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("electronics", { "bi-tech-timber", "angels-solder-smelting-basic" }, mode)
    tech_util.add_prerequisites_to_technology("logistic-science-pack", { "logistics" }, mode)
    tech_util.add_prerequisites_to_technology("steel-processing", { "electric-mining" }, mode)
    tech_util.add_prerequisites_to_technology("logistics", { "electronics" }, mode)
    tech_util.add_prerequisites_to_technology("chemical-science-pack", { "engine" }, mode)
    tech_util.add_prerequisites_to_technology("military-science-pack", { "gun-turret" }, mode)
    tech_util.add_prerequisites_to_technology("production-science-pack",
        { "productivity-module", "effectivity-module", "speed-module", "electric-engine" },
        mode)
    tech_util.add_prerequisites_to_technology("utility-science-pack", { "logistics-3", "nuclear-power" }, mode)
    tech_util.add_prerequisites_to_technology("atomic-bomb",
        { "nuclear-fuel-reprocessing", "bob-rocket", "land-mine", "Schall-tank-H-0", "Schall-tank-SH-0" },
        mode)

    if settings.startup["artillery-shells"].value then
        tech_util.add_prerequisites_to_technology("atomic-bomb", { "artillery" }, mode)
    end

    tech_util.add_prerequisites_to_technology("flamethrower", { "engine" }, mode)
    --alien-artifact удалён, с переносом рецепта в alien-research
    tech_util.add_prerequisites_to_technology("advanced-electronics", { "angels-sulfur-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("braking-force-3", { "advanced-logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("braking-force-6", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("logistics-3", { "titanium-processing" }, mode)
    tech_util.add_prerequisites_to_technology("rocket-silo", { "bob-area-drills-3" }, mode)
    tech_util.add_prerequisites_to_technology("research-speed-5", { "production-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("research-speed-6", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("electric-energy-distribution-2", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("effect-transmission", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("electric-engine", { "engine", "steam-power", "automation-2" }, mode)
    tech_util.add_prerequisites_to_technology("worker-robots-speed-3", { "advanced-logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("worker-robots-speed-5", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("worker-robots-storage-2", { "advanced-logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("worker-robots-storage-3", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("energy-shield-equipment", { "electric-engine" }, mode)
    tech_util.add_prerequisites_to_technology("battery-equipment", { "electric-engine" }, mode)
    tech_util.add_prerequisites_to_technology("fusion-reactor-equipment", { "solar-panel-equipment-4" }, mode)
    tech_util.add_prerequisites_to_technology("personal-roboport-equipment",
        { "advanced-electronics-2", "defender", "nanobots", "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("modules", { "angels-gold-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("mining-productivity-3",
        { "production-science-pack", "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("artillery", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bet-tech", { "battery" }, mode)
    tech_util.add_prerequisites_to_technology("bet-fuel-recycling", { "bet-fuel-4" }, mode)
    tech_util.add_prerequisites_to_technology("extremely-advanced-material-processing",
        { "bob-electric-energy-accumulators-3", "bob-robo-modular-4", "effect-transmission-3", "bob-solar-energy-3",
            "vehicle-motor-equipment", "bob-nuclear-power-2" }, mode)
    tech_util.add_prerequisites_to_technology("extremely-advanced-rocket-payloads", { "space-lab", "space-telescope" },
        mode)
    tech_util.add_prerequisites_to_technology("advanced-machining", { "automation-6", "stack-inserter-4" }, mode)
    tech_util.add_prerequisites_to_technology("autonomous-space-mining-drones", { "bob-drills-4" }, mode)
    tech_util.add_prerequisites_to_technology("shuttle-repurposing", { "asteroid-mining" }, mode)
    tech_util.add_prerequisites_to_technology("orbital-autonomous-fabricators",
        { "advanced-material-processing-4", "centrifuging-2" }, mode)
    tech_util.add_prerequisites_to_technology("ober-nuclear-processing",
        { "phosphorus-processing-2", "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("qol-crafting-speed-1-1", { "automation-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("qol-inventory-size-1-1", { "automation-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("qol-mining-speed-1-1", { "automation-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("qol-movement-speed-1-1", { "automation-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("qol-player-reach-1-1", { "automation-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("robot-attrition-explosion-safety", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets", { "fast-inserter" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets2", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets-gatling", { "w93-modular-turrets2" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets-rocket", { "w93-modular-turrets2" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets-plaser", { "w93-modular-turrets2" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets-lcannon", { "w93-modular-turrets2" }, mode)
    tech_util.add_prerequisites_to_technology("w93-modular-turrets-dcannon", { "angels-explosives-1" }, mode)
    tech_util.add_prerequisites_to_technology("Schall-pickup-tower-1", { "radar" }, mode)
    tech_util.add_prerequisites_to_technology("Schall-tank-SH-1", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("warehouse-logistics-research-2", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("alloy-processing", { "angels-nickel-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("grinding", { "geode-crystallization-2" }, mode)
    tech_util.add_prerequisites_to_technology("nitinol-processing", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("tungsten-alloy-processing",
        { "titanium-processing", "ceramics", "nitinol-processing" }, mode)
    tech_util.add_prerequisites_to_technology("deuterium-fuel-cell-2", { "deuterium-fuel-reprocessing" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-research", { "electric-lab" }, mode)
    tech_util.add_prerequisites_to_technology("nanobots", { "repair-pack" }, mode)
    tech_util.add_prerequisites_to_technology("roboport-interface", { "radar", "bob-robo-modular-1" }, mode)
    tech_util.add_prerequisites_to_technology("electronics-machine-1", { "logistics" }, mode)
    tech_util.add_prerequisites_to_technology("electronics-machine-2", { "fast-inserter" }, mode)
    tech_util.add_prerequisites_to_technology("electronics-machine-3", { "turbo-inserter" }, mode)
    tech_util.add_prerequisites_to_technology("bob-fluid-wagon-2", { "bob-fluid-handling-2" }, mode)
    tech_util.add_prerequisites_to_technology("bob-robo-modular-1", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bob-robo-modular-4", { "tungsten-alloy-processing" }, mode)
    tech_util.add_prerequisites_to_technology("logistic-system-2", { "construction-robotics" }, mode)
    tech_util.add_prerequisites_to_technology("toolbelt-3", { "advanced-logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("toolbelt-4", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("inserter-stack-size-bonus-3", { "advanced-logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("inserter-stack-size-bonus-4", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("bob-area-drills-2", { "bob-drills-2" }, mode)
    tech_util.add_prerequisites_to_technology("bob-area-drills-3", { "bob-drills-3" }, mode)
    tech_util.add_prerequisites_to_technology("bob-area-drills-4", { "bob-drills-4" }, mode)
    tech_util.add_prerequisites_to_technology("bob-pumpjacks-4", { "tungsten-alloy-processing" }, mode)
    tech_util.add_prerequisites_to_technology("electric-pole-3", { "rubber" }, mode)
    tech_util.add_prerequisites_to_technology("bob-steam-turbine-3", { "tungsten-alloy-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bob-nuclear-power-2", { "centrifuging-2" }, mode)
    tech_util.add_prerequisites_to_technology("bob-nuclear-power-3",
        { "bob-nuclear-power-2", "thorium-fuel-reprocessing" }, mode)
    tech_util.add_prerequisites_to_technology("bob-shotgun-shells", { "military-4" }, mode)
    tech_util.add_prerequisites_to_technology("bob-plasma-rocket", { "bob-rocket" }, mode)
    tech_util.add_prerequisites_to_technology("bob-power-armor-3", { "space-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("bob-power-armor-4", { "bob-armor-making-3", "space-telescope" }, mode)
    tech_util.add_prerequisites_to_technology("bob-power-armor-5", { "bob-armor-making-4", "space-shuttle" }, mode)
    tech_util.add_prerequisites_to_technology("bob-plasma-turrets-1", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("bob-plasma-turrets-2", { "bob-laser-turrets-2" }, mode)
    tech_util.add_prerequisites_to_technology("bob-plasma-turrets-3", { "bob-laser-turrets-3" }, mode)
    tech_util.add_prerequisites_to_technology("bob-plasma-turrets-4", { "bob-laser-turrets-4" }, mode)
    tech_util.add_prerequisites_to_technology("bob-plasma-turrets-5", { "bob-laser-turrets-5" }, mode)
    tech_util.add_prerequisites_to_technology("memory-unit", { "warehouse-research" }, mode)
    tech_util.add_prerequisites_to_technology("Ducts", { "angels-metallurgy-3", "bob-fluid-handling-2" }, mode)
    tech_util.add_prerequisites_to_technology("effect-transmission-3",
        { "advanced-electronics-3", "bio-processing-crystal-full" }, mode)
    tech_util.add_prerequisites_to_technology("speed-module-7", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("effectivity-module-7", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("productivity-module-7", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("pollution-clean-module-7", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("pollution-create-module-7", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("module-merging", { "angels-gunmetal-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("vehicle-roboport-equipment", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("miniloader", { "angels-steel-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("fast-miniloader", { "fast-inserter" }, mode)
    tech_util.add_prerequisites_to_technology("express-miniloader", { "express-inserters" }, mode)
    tech_util.add_prerequisites_to_technology("turbo-miniloader", { "turbo-inserter" }, mode)
    tech_util.add_prerequisites_to_technology("ultimate-miniloader", { "ultimate-inserter" }, mode)
    tech_util.add_prerequisites_to_technology("armor-absorb-10", { "military-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("armor-absorb-15", { "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("armor-absorb-20", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("cargo-planes", { "military" }, mode)
    tech_util.add_prerequisites_to_technology("napalm", { "flamethrower" }, mode)
    tech_util.add_prerequisites_to_technology("aircraft-energy-shield", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("ore-crushing", { "burner-ore-crushing", "water-aggregate-states" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-ore-refining-1", { "angels-stone-smelting-1", "engine" }, mode)
    tech_util.add_prerequisites_to_technology("slag-processing-1", { "angels-stone-smelting-1", "bi-tech-ash" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-ore-refining-2",
        { "concrete", "angels-metallurgy-3", "electric-engine" }, mode)
    tech_util.add_prerequisites_to_technology("slag-processing-2", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("ore-leaching", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-ore-refining-3", { "titanium-processing" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-ore-refining-4", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("water-treatment", { "angels-metallurgy-1" }, mode)
    tech_util.add_prerequisites_to_technology("water-treatment-2",
        { "angels-stone-smelting-1", "bi-tech-coal-processing-1" }, mode)
    tech_util.add_prerequisites_to_technology("water-treatment-3", { "concrete", "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("water-treatment-4",
        { "advanced-electronics-2", "nuclear-fuel-reprocessing-2" }, mode)
    tech_util.add_prerequisites_to_technology("water-washing-1", { "electric-mining", "fluid-barrel-processing" }, mode)
    tech_util.add_prerequisites_to_technology("water-washing-2", { "angels-stone-smelting-1", "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("automation-8", { "advanced-magnesium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("automation-9", { "advanced-depleted-uranium-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("electronics-machine-5", { "advanced-magnesium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("space-casings", { "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("space-thrusters", { "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("fuel-cells", { "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("habitation", { "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("life-support-systems",
        { "productivity-module-8", "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("spaceship-command",
        { "productivity-module-8", "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("astrometrics", { "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("ftl-propulsion", { "advanced-osmium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("angels-coal-processing", { "water-aggregate-states" }, mode)
    tech_util.add_prerequisites_to_technology("angels-coal-processing-2", { "chlorine-processing-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-nitrogen-processing-2", { "bio-nutrient-paste" }, mode)
    tech_util.add_prerequisites_to_technology("angels-nitrogen-processing-4",
        { "angels-copper-tungsten-smelting-1", "tungsten-alloy-processing" }, mode)
    tech_util.add_prerequisites_to_technology("chlorine-processing-2",
        { "angels-oil-processing", "angels-advanced-chemistry-3" }, mode)
    tech_util.add_prerequisites_to_technology("oil-gas-extraction", { "angels-stone-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-gas-processing", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-chemistry-1", { "angels-stone-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-chemistry-2",
        { "concrete", "angels-nitrogen-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-chemistry-3", { "mercury-processing-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-chemistry-4", { "titanium-processing", "ore-refining" },
        mode)
    tech_util.add_prerequisites_to_technology("gas-steam-cracking-1", { "angels-advanced-chemistry-1" }, mode)
    tech_util.add_prerequisites_to_technology("rubbers", { "angels-advanced-chemistry-2" }, mode)
    tech_util.add_prerequisites_to_technology("rubber", { "chlorine-processing-2", "angels-coolant-1" }, mode)
    tech_util.add_prerequisites_to_technology("better-cargo-planes",
        { "low-density-structure", "production-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("mixed-oxide-fuel", { "nuclear-fuel-reprocessing" }, mode)
    tech_util.add_prerequisites_to_technology("CW-air-filtering-5", { "nitinol-processing" }, mode)
    tech_util.add_prerequisites_to_technology("CW-air-filtering-6",
        { "angels-copper-tungsten-smelting-1", "space-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("petroleum-generator",
        { "bob-steam-engine-3", "angels-metallurgy-3", "flammables", "slag-processing-1" }, mode)
    if mods["P-U-M-P-S"] then
        tech_util.add_prerequisites_to_technology("offshore-pump-3", { "titanium-processing" }, mode)

        tech_util.add_prerequisites_to_technology("offshore-pump-4",
            { "nitinol-processing", "advanced-logistic-science-pack" }, mode)
    end
    tech_util.add_prerequisites_to_technology("angels-steel-smelting-2", { "angels-manganese-smelting-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-steel-smelting-3",
        { "angels-chrome-smelting-2", "angels-tungsten-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-aluminium-smelting-1", { "angels-sulfur-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-aluminium-smelting-2", { "advanced-magnesium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("angels-aluminium-smelting-3", { "angels-zinc-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-iron-smelting-3", { "advanced-magnesium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("angels-metallurgy-2", { "angels-stone-smelting-1", "ore-floatation" },
        mode)
    tech_util.add_prerequisites_to_technology("angels-metallurgy-3", { "concrete", "ore-leaching" }, mode)
    tech_util.add_prerequisites_to_technology("ore-processing-2", { "angels-metallurgy-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-copper-smelting-3", { "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-lead-smelting-3", { "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-nickel-smelting-2", { "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-silicon-smelting-2",
        { "chlorine-processing-1", "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-silver-smelting-2", { "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-metallurgy-4", { "advanced-electronics-2", "titanium-processing" },
        mode)
    tech_util.add_prerequisites_to_technology("angels-metallurgy-5", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("ore-processing-2",
        { "angels-aluminium-smelting-1", "concrete", "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("ore-processing-5",
        { "angels-tungsten-carbide-smelting-1", "nitinol-processing" }, mode)
    tech_util.add_prerequisites_to_technology("angels-cooling", { "angels-stone-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-titanium-smelting-3", { "advanced-magnesium-smelting" }, mode)
    tech_util.add_prerequisites_to_technology("angels-tungsten-smelting-3",
        { "angels-coolant-1", "sodium-processing-2", "angels-manganese-smelting-3", "angels-zinc-smelting-2",
            "phosphorus-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-zinc-smelting-1", { "ore-floatation", "angels-lead-smelting-1" },
        mode)
    tech_util.add_prerequisites_to_technology("bi-tech-coal-processing-2", { "gas-synthesis" }, mode)
    tech_util.add_prerequisites_to_technology("bi-tech-fertilizer", { "sodium-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bi-tech-depollution-1", { "bi-tech-fertilizer" }, mode)
    tech_util.add_prerequisites_to_technology("angels-alloys-smelting-2",
        { "angels-invar-smelting-1", "angels-cobalt-steel-smelting-1", "angels-gunmetal-smelting-1", "strand-casting-1" },
        mode)
    tech_util.add_prerequisites_to_technology("angels-alloys-smelting-3",
        { "angels-coolant-1", "angels-nitinol-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-ironworks-2",
        { "angels-cobalt-steel-smelting-1", "angels-steel-smelting-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-ironworks-3", { "angels-zinc-smelting-3" }, mode)
    tech_util.add_prerequisites_to_technology("bio-processing-green",
        { "angels-steel-smelting-1", "angels-stone-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-processing-blue", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bio-processing-paste",
        { "angels-cobalt-smelting-1", "angels-copper-smelting-2", "angels-gold-smelting-2", "angels-iron-smelting-2",
            "angels-titanium-smelting-2", "angels-tungsten-smelting-1", "angels-zinc-smelting-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-processing-alien-2", { "slag-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-processing-alien-3", { "bio-processing-paste" }, mode)
    tech_util.add_prerequisites_to_technology("gardens-3", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bio-arboretum-1", { "bio-nutrient-paste", "bio-temperate-farming-1" },
        mode)

    tech_util.add_prerequisites_to_technology("bio-farm-2", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bio-temperate-farming-2",
        { "angels-titanium-smelting-1", "advanced-electronics-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-desert-farming-2",
        { "angels-titanium-smelting-1", "advanced-electronics-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-swamp-farming-2",
        { "angels-titanium-smelting-1", "advanced-electronics-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-nutrient-paste",
        { "bio-temperate-farming-1", "bio-desert-farming-1", "bio-swamp-farming-1", "bio-wood-processing",
            "chlorine-processing-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-pressing-1", { "bio-swamp-farming-1", "bio-desert-farming-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-pressing-2",
        { "angels-titanium-smelting-1", "advanced-electronics-2", "titanium-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bio-farm-2", { "bio-temperate-farming-1", "bio-desert-farming-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-swamp-farming-1",
        { "bio-temperate-farming-1", "bio-desert-farming-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-fish-2", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-hatchery", { "concrete" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-puffer-2",
        { "bio-temperate-farming-2", "bio-desert-farming-2", "bio-swamp-farming-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-puffer-3",
        { "angels-tungsten-smelting-1", "advanced-electronics-3", "tungsten-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-biter-3",
        { "bio-refugium-puffer-2", "angels-copper-tungsten-smelting-1", "tungsten-alloy-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bio-processing-crystal-full",
        { "production-science-pack", "ore-powderizer" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-biter-2",
        { "angels-tungsten-smelting-1", "advanced-electronics-3", "tungsten-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-biter-3", { "bio-processing-alien-2" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-butchery-2", { "bio-refugium-puffer-1" }, mode)
    tech_util.add_prerequisites_to_technology("factory-preview", { "logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("garden-mutation", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-magnesium-smelting", { "water-treatment-4" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-depleted-uranium-smelting-1", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-osmium-smelting", { "asteroid-mining" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-uranium-processing-1", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("mercury-processing-1",
        { "automation-science-pack", "logistic-science-pack", "chemical-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("centrifuging-2",
        { "advanced-electronics-3", "angels-copper-tungsten-smelting-1", "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("phosphorus-processing-1", { "angels-nitrogen-processing-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-nitrogen-processing-1", { "basic-chemistry-2" }, mode)
    tech_util.add_prerequisites_to_technology("phosphorus-processing-2", { "sodium-processing" }, mode)
    tech_util.add_prerequisites_to_technology("plastic-pc", { "angels-advanced-chemistry-5" }, mode)
    tech_util.add_prerequisites_to_technology("remelting-alloy-mixer-4",
        { "advanced-electronics-2", "titanium-processing", "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("nuclear-fuel-1", { "centrifuging-1" }, mode)
    tech_util.add_prerequisites_to_technology("nuclear-fuel-2", { "nuclear-fuel-reprocessing-2" }, mode)
    tech_util.add_prerequisites_to_technology("nuclear-fuel-3", { "thorium-nuclear-fuel-reprocessing-2" }, mode)
    tech_util.add_prerequisites_to_technology("radiothermal-fuel-1", { "nuclear-fuel-reprocessing" }, mode)
    tech_util.add_prerequisites_to_technology("radiothermal-fuel-2", { "water-treatment-4" }, mode)
    tech_util.add_prerequisites_to_technology("thorium-nuclear-fuel-reprocessing-2", { "thorium-plutonium-fuel-cell" },
        mode)
    tech_util.add_prerequisites_to_technology("thorium-ore-processing", { "slag-processing-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-gas-processing-2",
        { "angels-copper-tungsten-smelting-1", "advanced-electronics-3", "tungsten-alloy-processing",
            "angels-advanced-chemistry-5" }, mode)
    tech_util.add_prerequisites_to_technology("sodium-processing-2",
        { "angels-lead-smelting-3", "production-science-pack", "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-copper-tungsten-smelting-2", { "utility-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-bio-processing", { "advanced-electronics-3" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-butchery-3", { "titanium-processing" }, mode)
    tech_util.add_prerequisites_to_technology("bio-farm-advanced-upgrade",
        { "angels-tungsten-smelting-1", "advanced-electronics-3", "tungsten-processing" },
        mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-hatchery-2",
        { "angels-titanium-smelting-1", "advanced-electronics-3", "angels-tungsten-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-nutrient-paste-2",
        { "concrete", "angels-titanium-smelting-1", "advanced-electronics-2", "titanium-processing",
            "bio-temperate-farming-2", "bio-desert-farming-2", "bio-swamp-farming-2" }, mode)
    tech_util.add_prerequisites_to_technology("water-washing-3", { "bob-drills-2" }, mode)
    tech_util.add_prerequisites_to_technology("water-washing-4", { "advanced-electronics-2", "utility-science-pack" },
        mode)
    tech_util.add_prerequisites_to_technology("advanced-ore-refining-5",
        { "angels-copper-tungsten-smelting-1", "tungsten-alloy-processing" }, mode)
    if mods["Warheads"] then
        tech_util.add_prerequisites_to_technology("basic-atomic-weapons",
            { "nuclear-fuel-reprocessing", "electric-energy-accumulators" }, mode)
        tech_util.add_prerequisites_to_technology("artillery-atomics", { "full-fission-atomics" }, mode)
        tech_util.add_prerequisites_to_technology("californium-weapons",
            { "bob-shotgun-shells", "bob-bullets", "Schall-sniper-rifle" }, mode)
        tech_util.add_prerequisites_to_technology("fusion-weapons", { "space-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("thermobaric-weaponry",
            { "angels-explosives-1", "tank", "bob-rocket", "rocket-control-unit", "land-mine", "Schall-tank-H-0",
                "Schall-tank-SH-0", "artillery" }, mode)
    end
    tech_util.add_prerequisites_to_technology("artillery-prototype", { "engine", "concrete", "military-science-pack" },
        mode)
    tech_util.add_prerequisites_to_technology("hiend_train", { "bob-railway-3", "bob-fluid-wagon-3", "bet-charger-3" },
        mode)
    tech_util.add_prerequisites_to_technology("geode-processing-3", { "geode-crystallization-2" }, mode)
    tech_util.add_prerequisites_to_technology("geode-crystallization-1", { "slag-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-brass-smelting-1",
        { "angels-zinc-smelting-1", "logistic-science-pack" }, mode)
    tech_util.add_prerequisites_to_technology("angels-brass-smelting-3", { "angels-coolant-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-bronze-smelting-3", { "angels-coolant-1" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-electronics-3", { "modules-2" }, mode)
    if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
        tech_util.add_prerequisites_to_technology("coal-ore-crushing",
            { "angels-ore1-detected-resource-technology", "angels-ore3-detected-resource-technology" }, mode)
    end
    tech_util.add_prerequisites_to_technology("basic-wood-production", { "basic-metal-processing" }, mode)
    tech_util.add_prerequisites_to_technology("water-aggregate-states", { "coal-wooden-fluid-handling" }, mode)
    if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
        tech_util.add_prerequisites_to_technology("burner-ore-crushing",
            { "angels-ore5-detected-resource-technology", "angels-ore6-detected-resource-technology" }, mode)
        tech_util.add_prerequisites_to_technology("angels-ore1-detected-resource-technology",
            { "water-detected-resource-technology" }, mode)
        tech_util.add_prerequisites_to_technology("angels-ore3-detected-resource-technology",
            { "water-detected-resource-technology" }, mode)
        tech_util.add_prerequisites_to_technology("angels-ore5-detected-resource-technology",
            { "water-aggregate-states" }, mode)
        tech_util.add_prerequisites_to_technology("angels-ore6-detected-resource-technology",
            { "water-aggregate-states" }, mode)

        tech_util.add_prerequisites_to_technology("angels-ore2-detected-resource-technology",
            { "water-aggregate-states" }, mode)
        tech_util.add_prerequisites_to_technology("angels-ore4-detected-resource-technology",
            { "water-aggregate-states" }, mode)
    end
    if settings.startup["bobs-military-simplify"].value == false then
        tech_util.add_prerequisites_to_technology("uranium-ammo",
            { "Schall-sniper-rifle", "advanced-depleted-uranium-smelting-1", "Schall-tank-H-0", "Schall-tank-SH-0",
                "w93-modular-turrets-lcannon", "w93-modular-turrets-hcannon" }, mode)
    end
    tech_util.add_prerequisites_to_technology("Schall-pickup-tower-4",
        { "advanced-electronics-2", "utility-science-pack" }, mode)
    -- после проверки на достижимость автоматизации производства рецепта
    tech_util.add_prerequisites_to_technology("military-3", { "automation-2" }, mode)
    tech_util.add_prerequisites_to_technology("plastics", { "automation-2" }, mode)
    tech_util.add_prerequisites_to_technology("battery-3", { "powder-metallurgy-5" }, mode)
    tech_util.add_prerequisites_to_technology("bob-shotgun-plasma-shells", { "automation-3" }, mode)
    tech_util.add_prerequisites_to_technology("ore-electro-whinning-cell", { "slag-processing-3" }, mode)
    tech_util.add_prerequisites_to_technology("water-treatment-2", { "angels-advanced-chemistry-1" }, mode)
    tech_util.add_prerequisites_to_technology("water-chemistry-2", { "angels-advanced-chemistry-3" }, mode)
    tech_util.add_prerequisites_to_technology("ore-powderizer", { "automation-2" }, mode)
    tech_util.add_prerequisites_to_technology("rubber", { "strand-casting-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-solder-smelting-1", { "remelting-alloy-mixer-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-solder-smelting-basic", { "ore-crushing" }, mode)
    tech_util.add_prerequisites_to_technology("angels-steel-smelting-1", { "remelting-alloy-mixer-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-chrome-smelting-1", { "angels-metallurgy-4" }, mode)
    tech_util.add_prerequisites_to_technology("angels-chrome-smelting-2", { "ore-processing-4" }, mode)
    tech_util.add_prerequisites_to_technology("angels-chrome-smelting-3", { "ore-processing-5" }, mode)
    tech_util.add_prerequisites_to_technology("angels-cobalt-smelting-1", { "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-cobalt-casting-2", { "strand-casting-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-cobalt-casting-3", { "strand-casting-4" }, mode)
    tech_util.add_prerequisites_to_technology("angels-copper-smelting-3", { "ore-processing-4" }, mode)
    tech_util.add_prerequisites_to_technology("angels-glass-smelting-2", { "strand-casting-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-glass-smelting-3", { "strand-casting-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-lead-casting-2", { "angels-lead-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-lead-smelting-3", { "ore-processing-4" }, mode)
    tech_util.add_prerequisites_to_technology("angels-nickel-smelting-2", { "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-silicon-smelting-2", { "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-silver-smelting-2", { "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-stone-smelting-2", { "automation-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-tin-smelting-3", { "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-zinc-smelting-1", { "angels-metallurgy-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-brass-smelting-1", { "angels-metallurgy-1" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-electronics", { "angels-brass-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-zinc-smelting-2", { "angels-metallurgy-3" }, mode)
    tech_util.add_prerequisites_to_technology("angels-ironworks-2", { "powder-metallurgy-1" }, mode)
    tech_util.add_prerequisites_to_technology("powder-metallurgy-1",
        { "angels-steel-smelting-1", "angels-stone-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("bio-wood-processing", { "bio-farm-1" }, mode)
    tech_util.add_prerequisites_to_technology("Rubber-Processing", { "ore-processing-2" }, mode)
    tech_util.add_prerequisites_to_technology("angels-brass-smelting-2", { "strand-casting-1" }, mode)
    tech_util.add_prerequisites_to_technology("logistic-science-pack", { "angels-metallurgy-1" }, mode)
    tech_util.add_prerequisites_to_technology("bob-fluid-handling-2", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("thermal-water-extraction", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("water-washing-2", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-nitrogen-processing-2", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-advanced-chemistry-1", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("strand-casting-1", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-cooling", { "angels-bronze-smelting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-bronze-smelting-1", { "remelting-alloy-mixer-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-bronze-smelting-2", { "strand-casting-1" }, mode)
    tech_util.add_prerequisites_to_technology("angels-gunmetal-smelting-1", { "angels-tin-smelting-1" }, mode)
    -- применимость всех результатов рецептов
    tech_util.add_prerequisites_to_technology("bob-rocket", { "rocket-silo" }, mode)
    tech_util.add_prerequisites_to_technology("bob-boiler-3", { "angels-coal-cracking" }, mode)
    tech_util.add_prerequisites_to_technology("bob-boiler-3", { "Fuel-Additive" }, mode)
    tech_util.add_prerequisites_to_technology("bob-nuclear-power-3", { "nuclear-fuel-3", "radiothermal-fuel-3" }, mode)
    tech_util.add_prerequisites_to_technology("bob-nuclear-power-2", { "nuclear-fuel-2", "radiothermal-fuel-2" }, mode)
    if mods["UnrealisticReactors"] then
        tech_util.add_prerequisites_to_technology("thermonuclear-bomb",
            { "productivity-module-6", "fusion-reactor-equipment-2" }, mode)
    end
    -- добавление после начала игры и использование "когнитивной составляющей"
    tech_util.add_prerequisites_to_technology("bio-arboretum-temperate-1", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("bio-arboretum-swamp-1", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("gardens-2", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("bio-farm-2", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("bio-temperate-farming-1", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("bio-temperate-farm", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("bio-desert-farming-1", { "gardens" }, mode)

    --
    if mods["Electric_Transformators"] then
        tech_util.add_prerequisites_to_technology("trafo-s", { "angels-steel-smelting-1" }, mode)
        tech_util.add_prerequisites_to_technology("trafo-l", { "chemical-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("trafo-xl", { "production-science-pack" }, mode)
    end
    if mods["RampantMaintenance"] then
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-failure-3", { "chemical-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-failure-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-failure-7", { "utility-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-failure-9", { "space-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-3", { "chemical-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-7", { "utility-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-9", { "space-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-failure-3",
            { "chemical-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-failure-5",
            { "production-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-failure-7",
            { "utility-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-damage-failure-9", { "space-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-downtime-3", { "chemical-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-downtime-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-downtime-7", { "utility-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-downtime-9", { "space-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-checks-3", { "chemical-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-checks-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-checks-7", { "utility-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-checks-9", { "space-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-energy-3", { "chemical-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-energy-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-energy-7", { "utility-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-energy-9", { "space-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-tile-3", { "chemical-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-tile-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-tile-7", { "utility-science-pack" }, mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-tile-9", { "space-science-pack" }, mode)

        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-pollution-3", { "chemical-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-pollution-5", { "production-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-pollution-7", { "utility-science-pack" },
            mode)
        tech_util.add_prerequisites_to_technology("rampant-maintenance-reduce-pollution-9", { "space-science-pack" },
            mode)
    end

    tech_util.add_prerequisites_to_technology("bob-energy-shield-equipment-3", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("bob-battery-equipment-4", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("fusion-reactor-equipment-2", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("night-vision-equipment-3", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("solar-panel-equipment-4", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("personal-laser-defense-equipment-6", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("advanced-electronics-3", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-blue-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-orange-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-purple-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-yellow-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-green-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-red-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("alien-research", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("vehicle-fusion-reactor-equipment-2", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("vehicle-fusion-cell-equipment-2", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("vehicle-big-turret-equipment-1", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("bi-tech-advanced-biotechnology", { "alien-artifact" }, mode)
    tech_util.add_prerequisites_to_technology("bio-refugium-hatchery", { "gardens" }, mode)
    tech_util.add_prerequisites_to_technology("alien-artifact", { "automation-science-pack" }, mode)
end

local function remove_prerequisites_from_technologies_in_regular_tree(mode)
    -- удаление скрытых технологий
    tech_util.remove_prerequisites_from_technology("water-chemistry-2", { "angels-electric-boiler-2" }, mode)
    -- конец удаление скрытых технологий
    -- удаление остальных
    tech_util.remove_prerequisites_from_technology("silicon-processing", { "chlorine-processing-2" }, mode)
    tech_util.remove_prerequisites_from_technology("mercury-processing-1", { "angels-advanced-chemistry-3" }, mode)
    tech_util.remove_prerequisites_from_technology("ore-processing-2", { "angels-metallurgy-3" }, mode)
    tech_util.remove_prerequisites_from_technology("bio-processing-alien-1", { "bio-processing-paste" }, mode)
    tech_util.remove_prerequisites_from_technology("bio-refugium-biter-3", { "bio-refugium-puffer-4" }, mode)
    tech_util.remove_prerequisites_from_technology("angels-zinc-smelting-1", { "angels-brass-smelting-1" }, mode)
    --
    tech_util.remove_prerequisites_from_technology("water-washing-1", { "gas-canisters" }, mode)
    tech_util.remove_prerequisites_from_technology("electronics", { "angels-solder-smelting-1" }, mode)
    tech_util.remove_prerequisites_from_technology("angels-metallurgy-2", { "angels-brass-smelting-1" }, mode)
    tech_util.remove_prerequisites_from_technology("logistic-science-pack", { "angels-bronze-smelting-1" }, mode)
    -- конец удаление остальных
    -- удаление после начала игры и использование "когнитивной составляющей"
    tech_util.remove_prerequisites_from_technology("bio-farm-1", { "gardens" }, mode)
    tech_util.remove_prerequisites_from_technology("alien-artifact", { "gardens" }, mode)
end

local function remove_recipes_from_technology_effects_in_regular_tree(mode)
    -- скрытые рецепты или несуществующие
    tech_util.remove_recipe_effect_from_technology("ober-nuclear-processing", "nuclear-smelting-copper-plate", mode)
    tech_util.remove_recipe_effect_from_technology("ober-nuclear-processing", "nuclear-smelting-iron-plate", mode)
    tech_util.remove_recipe_effect_from_technology("ober-nuclear-processing", "nuclear-smelting-lead-plate", mode)
    tech_util.remove_recipe_effect_from_technology("ober-nuclear-processing", "nuclear-smelting-silver-plate", mode)
    tech_util.remove_recipe_effect_from_technology("ober-nuclear-processing", "nuclear-smelting-tin-plate", mode)
    tech_util.remove_recipe_effect_from_technology("ober-nuclear-processing",
        "nuclear-smelting-angels-solder-mixture-smelting", mode)
    tech_util.remove_recipe_effect_from_technology("basic-fluid-handling", "bob-valve", mode)
    tech_util.remove_recipe_effect_from_technology("angels-stone-smelting-2", "angels-concrete-brick", mode)
    tech_util.remove_recipe_effect_from_technology("angels-stone-smelting-3", "angels-reinforced-concrete-brick", mode)
    tech_util.remove_recipe_effect_from_technology("rocket-silo", "rocket-part", mode)
    -- конец скрытые рецепты или несуществующие
    --остальные
    tech_util.remove_recipe_effect_from_technology("bio-fermentation", "fermentation-corn", mode)
    tech_util.remove_recipe_effect_from_technology("bio-fermentation", "fermentation-fruit", mode)
    tech_util.remove_recipe_effect_from_technology("bio-fermentation", "anaerobic-fermentation", mode)
    tech_util.remove_recipe_effect_from_technology("bio-fermentation", "aerobic-fermentation", mode)

    tech_util.remove_recipe_effect_from_technology("bio-farm-1", "solid-soil", mode)
    --конец остальные
    --после проверки на достижимость автоматизации производства рецепта
    tech_util.remove_recipe_effect_from_technology("slag-processing-1", "slag-processing-5", mode)
    tech_util.remove_recipe_effect_from_technology("slag-processing-1", "slag-processing-6", mode)
    tech_util.remove_recipe_effect_from_technology("bio-farm-1", "crop-farm", mode)
    -- применимость всех результатов рецептов
    tech_util.remove_recipe_effect_from_technology("robotics", "robot-drone-frame-large", mode)
end

local function move_recipes_to_another_technologies(mode)
    --basic
    tech_util.move_recipe_effects_to_another_technology("electricity", "repair-pack", "repair-pack", mode)
    tech_util.move_recipe_effects_to_another_technology("electricity", "basic-logistics", "burner-filter-inserter", mode)
    tech_util.move_recipe_effects_to_another_technology("basic-automation", "basic-logistics", "burner-inserter", mode)
    tech_util.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "condensator", mode)
    tech_util.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "wooden-board", mode)
    tech_util.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "basic-circuit-board", mode)
    tech_util.move_recipe_effects_to_another_technology("electricity", "logistics", "inserter", mode)
    tech_util.move_recipe_effects_to_another_technology("electronics", "logistics", "yellow-filter-inserter", mode)
    tech_util.move_recipe_effects_to_another_technology("steam-power", "water-aggregate-states", "boiler", mode)
    --end basic
    -- перенос из удалённых технологий
    tech_util.move_recipe_effects_to_another_technology("zinc-processing", "angels-brass-smelting-1", "brass-pipe", mode)
    tech_util.move_recipe_effects_to_another_technology("zinc-processing", "angels-brass-smelting-1",
        "brass-pipe-to-ground", mode)
    tech_util.move_recipe_effects_to_another_technology("zinc-processing", "angels-brass-smelting-1", "brass-chest", mode)
    tech_util.move_recipe_effects_to_another_technology("zinc-processing", "angels-brass-smelting-1", "brass-gear-wheel",
        mode)
    -- конец перенос из удалённых технологий
    --another
    tech_util.move_recipe_effects_to_another_technology("w93-modular-turrets", "w93-modular-turrets2", "w93-hmg-turret2",
        mode)
    tech_util.move_recipe_effects_to_another_technology("tungsten-processing", "tungsten-alloy-processing",
        "anotherworld-structure-components", mode)
    tech_util.move_recipe_effects_to_another_technology("basic-automation", "steam-power", "steam-inserter", mode)
    tech_util.move_recipe_effects_to_another_technology("water-treatment", "water-treatment-2",
        "bi-mineralized-sulfuric-waste", mode)
    tech_util.move_recipe_effects_to_another_technology("water-chemistry-2", "deuterium-processing",
        "deuterium-fuel-cell", mode)
    tech_util.move_recipe_effects_to_another_technology("angels-advanced-chemistry-2", "angels-advanced-chemistry-3",
        "acetylene-diomerisation", mode)
    tech_util.move_recipe_effects_to_another_technology("k-angels-advanced-chemistry-5", "angels-advanced-chemistry-3",
        "nitrous-oxide-synthesis-1", mode)
    tech_util.move_recipe_effects_to_another_technology("k-angels-advanced-chemistry-5", "angels-advanced-chemistry-3",
        "nitrous-oxide-synthesis-2", mode)
    tech_util.move_recipe_effects_to_another_technology("k-angels-advanced-chemistry-5", "angels-advanced-chemistry-3",
        "sodium-nitrate-synthesis", mode)
    tech_util.move_recipe_effects_to_another_technology("k-angels-advanced-chemistry-5", "angels-advanced-chemistry-3",
        "acrylonitrile-synthesis", mode)
    tech_util.move_recipe_effects_to_another_technology("k-angels-advanced-chemistry-5", "angels-advanced-chemistry-3",
        "catalyst-metal-cyan", mode)
    tech_util.move_recipe_effects_to_another_technology("resins", "resin-1", "solid-resin", mode)
    tech_util.move_recipe_effects_to_another_technology("rubber", "rubbers", "liquid-rubber-1", mode)
    tech_util.move_recipe_effects_to_another_technology("bio-processing-paste", "bio-nutrient-paste", "paste-cellulose",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-nutrient-paste", "bio-nutrient-paste-2",
        "solid-fruit-nutrients", mode)
    tech_util.move_recipe_effects_to_another_technology("bio-farm-1", "bio-temperate-farming-1",
        "temperate-garden-generation", mode)
    tech_util.move_recipe_effects_to_another_technology("bio-farm-1", "bio-swamp-farming-1", "swamp-garden-generation",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-farm-1", "bio-swamp-farming-1", "desert-garden-generation",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-1",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-2",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-refugium-hatchery", "bio-refugium-puffer-3", "puffer-egg-3",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-4",
        mode)
    tech_util.move_recipe_effects_to_another_technology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-5",
        mode)
    tech_util.move_recipe_effects_to_another_technology("angels-nitrogen-processing-2", "angels-nitrogen-processing-1",
        "gas-ammonia", mode)
    tech_util.move_recipe_effects_to_another_technology("phosphorus-processing-1", "phosphorus-processing-2",
        "solid-tetrasodium-pyrophosphate", mode)
    tech_util.move_recipe_effects_to_another_technology("geode-processing-2", "geode-processing-3", "ober-liquify-ruby",
        mode)
    tech_util.move_recipe_effects_to_another_technology("geode-processing-2", "geode-processing-3",
        "ober-liquify-sapphire", mode)
    tech_util.move_recipe_effects_to_another_technology("geode-processing-2", "geode-processing-3",
        "ober-liquify-emerald", mode)
    tech_util.move_recipe_effects_to_another_technology("geode-processing-2", "geode-processing-3",
        "ober-liquify-amethyst", mode)
    tech_util.move_recipe_effects_to_another_technology("geode-processing-2", "geode-processing-3", "ober-liquify-topaz",
        mode)
    tech_util.move_recipe_effects_to_another_technology("geode-processing-2", "geode-processing-3",
        "ober-liquify-diamond", mode)
    if mods["holographic_signs"] then
        tech_util.move_recipe_effects_to_another_technology("optics", "electronics", "hs_holo_sign", mode)
    end
    -- сдвиги после проверки на достижимость машин для производства рецептов автоматически
    tech_util.move_recipe_effects_to_another_technology("angels-sulfur-processing-1", "angels-sulfur-processing-2",
        "condensator2", mode)
    -- после начала игры и прохождения технологического стэка
    tech_util.move_recipe_effects_to_another_technology("advanced-electronics", "alien-research", "sci-component-o", mode)
    --end another
end

local function add_recipe_to_technology_effects(mode)
    --#region basic tech recipes

    tech_util.add_recipe_effect_to_technology("salvaged-automation-tech", "salvaged-mining-drill-bit-mk0", mode)
    tech_util.add_recipe_effect_to_technology("coal-wooden-fluid-handling", "bi-wood-pipe", mode)
    tech_util.add_recipe_effect_to_technology("coal-wooden-fluid-handling", "salvaged-offshore-pump-0", mode)
    tech_util.add_recipe_effect_to_technology("coal-wooden-fluid-handling", "bi-wood-pipe-to-ground", mode)
    tech_util.add_recipe_effect_to_technology("coal-ore-crushing", "salvaged-ore-crusher", mode)
    tech_util.add_recipe_effect_to_technology("coal-ore-crushing", "angelsore1-crushed", mode)
    tech_util.add_recipe_effect_to_technology("coal-ore-crushing", "angelsore3-crushed", mode)
    tech_util.add_recipe_effect_to_technology("coal-stone-processing", "stone-crushed", mode)
    tech_util.add_recipe_effect_to_technology("coal-ore-smelting", "angelsore1-crushed-smelting", mode)
    tech_util.add_recipe_effect_to_technology("coal-ore-smelting", "angelsore3-crushed-smelting", mode)
    tech_util.add_recipe_effect_to_technology("coal-lighting", "deadlock-copper-lamp", mode)
    tech_util.add_recipe_effect_to_technology("basic-wood-production", "coal-bi-bio-farm", mode)
    tech_util.add_recipe_effect_to_technology("basic-wood-production", "coal-bi-bio-greenhouse", mode)
    tech_util.add_recipe_effect_to_technology("basic-wood-production", "basic-coal-production-wood", mode)
    tech_util.add_recipe_effect_to_technology("basic-wood-production", "basic-coal-production-seedling", mode)
    tech_util.add_recipe_effect_to_technology("basic-electronics", "motor", mode)
    tech_util.add_recipe_effect_to_technology("basic-electronics", "electric-motor", mode)
    tech_util.add_recipe_effect_to_technology("military-0", "pistol-rearm-ammo", mode)
    tech_util.add_recipe_effect_to_technology("military-0", "bi-wooden-fence", mode)
    tech_util.add_recipe_effect_to_technology("military-0", "respirator", mode)
    if settings.startup["bobmods-power-heatsources"].value == true then
        tech_util.add_recipe_effect_to_technology("electricity-0", "bob-burner-generator", mode)
    end
    tech_util.add_recipe_effect_to_technology("burner-ore-mining", "mining-drill-bit-mk0", mode)
    tech_util.add_recipe_effect_to_technology("burner-ore-mining", "burner-mining-drill", mode)
    tech_util.add_recipe_effect_to_technology("burner-ore-crushing", "burner-ore-crusher", mode)
    tech_util.add_recipe_effect_to_technology("burner-ore-crushing", "angelsore5-crushed", mode)
    tech_util.add_recipe_effect_to_technology("burner-ore-crushing", "angelsore6-crushed", mode)
    tech_util.add_recipe_effect_to_technology("burner-ore-crushing", "angelsore5-crushed-smelting", mode)
    tech_util.add_recipe_effect_to_technology("burner-ore-crushing", "angelsore6-crushed-smelting", mode)
    tech_util.add_recipe_effect_to_technology("automation-science-pack", "burner-lab", mode)
    tech_util.add_recipe_effect_to_technology("automation-science-pack", "sci-component-1", mode)
    tech_util.add_recipe_effect_to_technology("logistics-0", "basic-transport-belt", mode)
    tech_util.add_recipe_effect_to_technology("logistics", "transport-belt", mode)
    if settings.startup["bobmods-mining-steamminingdrills"].value == true then
        tech_util.add_recipe_effect_to_technology("steam-power", "steam-mining-drill", mode)
    end
    tech_util.add_recipe_effect_to_technology("electricity", "burner-turbine", mode)
    if mods["P-U-M-P-S"] then
        tech_util.add_recipe_effect_to_technology("basic-fluid-handling", "offshore-pump-0", mode)
    end
    tech_util.add_recipe_effect_to_technology("ore-crushing", "iron-plate", mode)
    tech_util.add_recipe_effect_to_technology("ore-crushing", "copper-plate", mode)
    tech_util.add_recipe_effect_to_technology("ore-crushing", "lead-plate", mode)
    tech_util.add_recipe_effect_to_technology("ore-crushing", "tin-plate", mode)
    tech_util.add_recipe_effect_to_technology("ore-crushing", "glass-from-ore4", mode)
    if settings.startup["miniloader-enable-chute"].value == true then
        tech_util.add_recipe_effect_to_technology("basic-miniloader", "chute-miniloader", mode)
    end
    tech_util.add_recipe_effect_to_technology("military", "copper-nickel-firearm-magazine", mode)
    --#end region basic tech recipes
    -- остальные
    tech_util.add_recipe_effect_to_technology("nuclear-power", "used-up-RITEG-1", mode)

    if settings.startup["bobs-military-simplify"].value == true then
        tech_util.add_recipe_effect_to_technology("bob-bullets", "bullet-casing", mode)
        tech_util.add_recipe_effect_to_technology("bob-bullets", "magazine", mode)
        tech_util.add_recipe_effect_to_technology("bob-shotgun-shells", "shotgun-shell-casing", mode)
    end
    tech_util.add_recipe_effect_to_technology("CW-air-filtering-1", "CW-filter-air", mode)
    tech_util.add_recipe_effect_to_technology("angels-chrome-smelting-2", "angels-plate-chrome", mode)
    tech_util.add_recipe_effect_to_technology("angels-manganese-smelting-2", "angels-plate-manganese", mode)

    -- разнесение ферментации в отдельные ветки, для которых она нужна
    tech_util.add_recipe_effect_to_technology("bio-temperate-farming-1", "fermentation-corn", mode)
    tech_util.add_recipe_effect_to_technology("bio-desert-farming-1", "fermentation-corn", mode)

    tech_util.add_recipe_effect_to_technology("bio-temperate-farming-2", "fermentation-fruit", mode)
    tech_util.add_recipe_effect_to_technology("bio-desert-farming-2", "fermentation-fruit", mode)
    tech_util.add_recipe_effect_to_technology("bio-swamp-farming-2", "fermentation-fruit", mode)

    tech_util.add_recipe_effect_to_technology("bio-temperate-farming-1", "solid-soil", mode)
    tech_util.add_recipe_effect_to_technology("bio-desert-farming-1", "solid-soil", mode)
    tech_util.add_recipe_effect_to_technology("bio-swamp-farming-1", "solid-soil", mode)

    tech_util.add_recipe_effect_to_technology("bio-temperate-farming-1", "crop-farm", mode)
    tech_util.add_recipe_effect_to_technology("bio-desert-farming-1", "crop-farm", mode)
    tech_util.add_recipe_effect_to_technology("bio-swamp-farming-1", "crop-farm", mode)

    tech_util.add_recipe_effect_to_technology("bio-temperate-farming-1", "anaerobic-fermentation", mode)
    tech_util.add_recipe_effect_to_technology("bio-desert-farming-1", "anaerobic-fermentation", mode)
    tech_util.add_recipe_effect_to_technology("bio-temperate-farming-1", "aerobic-fermentation", mode)
    tech_util.add_recipe_effect_to_technology("bio-desert-farming-1", "aerobic-fermentation", mode)
    -- конец разнесение ферментации в отдельные ветки, для которых она нужна
    tech_util.add_recipe_effect_to_technology("angels-solder-smelting-basic", "angels-solder-mixture", mode)
    tech_util.add_recipe_effect_to_technology("angels-solder-smelting-basic", "angels-solder-mixture-smelting", mode)
    tech_util.add_recipe_effect_to_technology("powder-metallurgy-1", "sintering-oven", mode)
    -- дешёвыё вариант плавки бронзы необходим, иначе нет достижимости производства бронзы, сразу в металлургию 1
    tech_util.add_recipe_effect_to_technology("angels-metallurgy-1", "bronze-alloy", mode)
    -- конец остальные
end
local function hide_recipes(mode)
    local recipes = data.raw["recipe"]
    -- скрыть бесполезный факел
    tech_util.hide_recipe("torch", mode)
    -- конец скрыть бесполезный факел
    -- отключить ручной крафт руд
    tech_util.hide_recipe("angelsore1-crushed-hand", mode)
    tech_util.hide_recipe("angelsore3-crushed-hand", mode)
    -- конец отключить ручной крафт руд
end
local function hide_technologies(mode)
    --отключить электробойлеры, реализованные как сборочные автоматы
    tech_util.hide_technology("angels-electric-boiler", mode)
    tech_util.hide_technology("angels-electric-boiler-2", mode)
    tech_util.hide_technology("angels-electric-boiler-3", mode)
    --конец отключить электробойлеры, реализованные как сборочные автоматы
    --отключить электробойлер и бойлер на солнечных батареях
    tech_util.hide_technology("bi-tech-steamsolar-combination", mode)
    -- конец отключить электробойлер и бойлер на солнечных батареях

    --остальное
    tech_util.hide_technology("zinc-processing", mode)
    tech_util.hide_technology("k-angels-advanced-chemistry-5", mode)
    tech_util.hide_technology("bio-fermentation", mode)
    tech_util.hide_technology("nitrogen-processing", mode)
    -- конец остальное
    -- после выяснения используемых реально рецептов
    tech_util.hide_technology("mirv-technology", mode)
    if data.raw["technology"]["angels-nuclear-fuel"] then
        tech_util.hide_technology("angels-nuclear-fuel", mode)
    end
    if data.raw["technology"]["nuclear-fuel"] then
        tech_util.hide_technology("nuclear-fuel", mode)
    end
end
local function show_technologies(mode)
    tech_util.show_technology("angels-solder-smelting-basic", mode)
    tech_util.show_technology("powder-metallurgy-1", mode)
end
local function show_recipes(mode)
    local recipes = data.raw["recipe"]
    tech_util.show_recipe("magazine", mode)

    if settings.startup["bobs-military-simplify"].value == true then
        tech_util.show_recipe("shotgun-shell-casing", mode)
        tech_util.show_recipe("bullet-casing", mode)
    end

    tech_util.show_recipe("CW-filter-air", mode)
    tech_util.show_recipe("angels-plate-chrome", mode)
    tech_util.show_recipe("angels-plate-manganese", mode)
    tech_util.show_recipe("angels-solder-mixture", mode)
    tech_util.show_recipe("angels-solder-mixture-smelting", mode)
    tech_util.show_recipe("angels-stone-pipe-casting", mode)
    tech_util.show_recipe("angels-stone-pipe-to-ground-casting", mode)
    tech_util.show_recipe("sintering-oven", mode)
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
end
)
