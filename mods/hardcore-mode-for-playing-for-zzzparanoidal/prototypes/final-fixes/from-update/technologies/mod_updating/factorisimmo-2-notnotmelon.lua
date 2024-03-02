local techUtil = require("__automated-utility-protocol__.util.technology-util")
local function update_factorissimo_mod(mode)
	if not mods["factorissimo-2-notnotmelon"] then
		return
	end
	local technologies = data.raw["technology"]
	local connection_chest_tech = technologies["factory-connection-type-chest"]
	techUtil.reset_prerequisites_for_technology(
		connection_chest_tech,
		{ "factory-architecture-t1", "basic-logistics" },
		mode
	)
	local connection_fluid_tech = technologies["factory-connection-type-fluid"]
	techUtil.reset_prerequisites_for_technology(
		connection_fluid_tech,
		{ "factory-architecture-t1", "basic-fluid-handling" },
		mode
	)
	local connection_circuit_tech = technologies["factory-connection-type-circuit"]
	techUtil.reset_prerequisites_for_technology(
		connection_circuit_tech,
		{ "factory-architecture-t1", "circuit-network" },
		mode
	)
	local connection_lights_tech = technologies["factory-interior-upgrade-lights"]
	techUtil.reset_prerequisites_for_technology(connection_lights_tech, { "factory-architecture-t1", "optics" }, mode)
	local connection_display_tech = technologies["factory-interior-upgrade-display"]
	techUtil.reset_prerequisites_for_technology(
		connection_display_tech,
		{ "factory-architecture-t1", "factory-connection-type-circuit" },
		mode
	)
	techUtil.remove_science_pack_from_technology_units(connection_chest_tech, "logistic-science-pack", mode)
	techUtil.remove_science_pack_from_technology_units(connection_circuit_tech, "logistic-science-pack", mode)
	techUtil.remove_science_pack_from_technology_units(connection_display_tech, "logistic-science-pack", mode)
	local archtecture_t2_tech = technologies["factory-architecture-t2"]
	archtecture_t2_tech.unit = {
		ingredients = {
			{ "automation-science-pack", 2 },
			{ "logistic-science-pack", 3 },
		},
		count = 500,
		time = 60,
	}
	techUtil.add_prerequisites_to_technology(technologies["military-science-pack"], { "factory-architecture-t2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["chemical-science-pack"], { "factory-architecture-t2" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["production-science-pack"], { "factory-recursion-t1" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["factory-connection-type-heat"], { "bob-heat-pipe-1" }, mode)
	local architecture_t3_tech = technologies["factory-architecture-t3"]
	techUtil.add_prerequisites_to_technology(architecture_t3_tech, { "utility-science-pack" }, mode)
	techUtil.remove_science_pack_from_technology_units(architecture_t3_tech, "production-science-pack", mode)
	techUtil.add_science_packs_to_technology_units(architecture_t3_tech, { { "utility-science-pack", 1 } }, mode)
	techUtil.add_prerequisites_to_technology(technologies["space-science-pack"], { "factory-recursion-t2" }, mode)
end
_table.each(GAME_MODES, function(mode)
	update_factorissimo_mod(mode)
end)
