local tech_util = require("__automated-utility-protocol__.util.technology-util")
local function update_factorissimo_mod(mode)
    if not mods["factorissimo-2-notnotmelon"] then
        return
    end
    local connection_chest_tech = "factory-connection-type-chest"
    tech_util.reset_prerequisites_for_technology(
        connection_chest_tech,
        { "factory-architecture-t1", "basic-logistics" },
        mode
    )
    local connection_fluid_tech = "factory-connection-type-fluid"
    tech_util.reset_prerequisites_for_technology(
        connection_fluid_tech,
        { "factory-architecture-t1", "basic-fluid-handling" },
        mode
    )
    local connection_circuit_tech = "factory-connection-type-circuit"
    tech_util.reset_prerequisites_for_technology(
        connection_circuit_tech,
        { "factory-architecture-t1", "circuit-network" },
        mode
    )
    local connection_lights_tech = "factory-interior-upgrade-lights"
    tech_util.reset_prerequisites_for_technology(connection_lights_tech, { "factory-architecture-t1", "optics" }, mode)
    local connection_display_tech = "factory-interior-upgrade-display"
    tech_util.reset_prerequisites_for_technology(
        connection_display_tech,
        { "factory-architecture-t1", "factory-connection-type-circuit" },
        mode
    )
    tech_util.remove_science_pack_from_technology_units(connection_chest_tech, "logistic-science-pack", mode)
    tech_util.remove_science_pack_from_technology_units(connection_circuit_tech, "logistic-science-pack", mode)
    tech_util.remove_science_pack_from_technology_units(connection_display_tech, "logistic-science-pack", mode)
    local archtecture_t2_tech = data.raw["technology"]["factory-architecture-t2"]
    local archtecture_t2_tech_untis = {
        ingredients = {
            { "automation-science-pack", 2 },
            { "logistic-science-pack",   3 },
        },
        count = 500,
        time = 60,
    }
    archtecture_t2_tech.normal.unit = archtecture_t2_tech_untis
    archtecture_t2_tech.expensive.unit = archtecture_t2_tech_untis
    tech_util.add_prerequisites_to_technology("military-science-pack", { "factory-architecture-t2" }, mode)
    tech_util.add_prerequisites_to_technology("chemical-science-pack", { "factory-architecture-t2" }, mode)
    tech_util.add_prerequisites_to_technology("production-science-pack", { "factory-recursion-t1" }, mode)
    tech_util.add_prerequisites_to_technology("factory-connection-type-heat", { "bob-heat-pipe-1" }, mode)
    local architecture_t3_tech = "factory-architecture-t3"
    tech_util.add_prerequisites_to_technology(architecture_t3_tech, { "utility-science-pack" }, mode)
    tech_util.remove_science_pack_from_technology_units(architecture_t3_tech, "production-science-pack", mode)
    tech_util.add_science_packs_to_technology_units(architecture_t3_tech, { { "utility-science-pack", 1 } }, mode)
    tech_util.add_prerequisites_to_technology("space-science-pack", { "factory-recursion-t2" }, mode)
end
_table.each(GAME_MODES, function(mode)
    update_factorissimo_mod(mode)
end)
