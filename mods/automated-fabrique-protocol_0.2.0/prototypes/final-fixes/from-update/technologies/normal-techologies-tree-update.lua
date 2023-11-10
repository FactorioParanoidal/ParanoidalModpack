local function updateTechnologyNormalTree(mode)
	local technologies = data.raw["technology"]
	-- железнодорожные сигналы теперь зависят от простейшей автоматики, так же, как и железные дороги.
	if mods["JunkTrain3"] then
		techUtil.resetTechnologyPrerequisites(technologies["fluid-wagon"], { "JunkTrain_tech", "fluid-handling" }, mode)
		techUtil.addPrerequisitesToTechnology(technologies["rail-signals"], { "automated-scrap-rail-transportation" },
			mode)
		techUtil.addPrerequisitesToTechnology(technologies["railway"], { "automated-scrap-rail-transportation" }, mode)
	end

	if mods["factorissimo-2-notnotmelon"] then
		local connection_chest_tech = technologies["factory-connection-type-chest"]
		techUtil.resetTechnologyPrerequisites(connection_chest_tech, { "factory-architecture-t1", "basic-logistics" },
			mode)
		local connection_fluid_tech = technologies["factory-connection-type-fluid"]
		techUtil.resetTechnologyPrerequisites(connection_fluid_tech,
			{ "factory-architecture-t1", "basic-fluid-handling" }, mode)
		local connection_circuit_tech = technologies["factory-connection-type-circuit"]
		techUtil.resetTechnologyPrerequisites(connection_circuit_tech,
			{ "factory-architecture-t1", "circuit-network" }, mode)
		local connection_lights_tech = technologies["factory-interior-upgrade-lights"]
		techUtil.resetTechnologyPrerequisites(connection_lights_tech, { "factory-architecture-t1", "optics" }, mode)
		local connection_display_tech = technologies["factory-interior-upgrade-display"]
		techUtil.resetTechnologyPrerequisites(connection_display_tech,
			{ "factory-architecture-t1", "factory-connection-type-circuit" }, mode)
		techUtil.removeSciencePackFrom(connection_chest_tech, "logistic-science-pack", mode)
		techUtil.removeSciencePackFrom(connection_fluid_tech, "logistic-science-pack", mode)
		techUtil.removeSciencePackFrom(connection_circuit_tech, "logistic-science-pack", mode)
		techUtil.removeSciencePackFrom(connection_lights_tech, "logistic-science-pack", mode)
		techUtil.removeSciencePackFrom(connection_display_tech, "logistic-science-pack", mode)
		local archtecture_t2_tech = technologies["factory-architecture-t2"]
		archtecture_t2_tech.unit = {
			ingredients = {
				{ "automation-science-pack", 2 },
				{ "logistic-science-pack",   3 }
			},
			count = 500,
			time = 60
		}
		techUtil.addPrerequisitesToTechnology(technologies["military-science-pack"], { "factory-architecture-t2" }, mode)
		techUtil.addPrerequisitesToTechnology(technologies["chemical-science-pack"], { "factory-architecture-t2" }, mode)
		techUtil.addPrerequisitesToTechnology(technologies["production-science-pack"], { "factory-recursion-t1" }, mode)
		if mods["bobpower"] then
			techUtil.addPrerequisitesToTechnology(technologies["factory-connection-type-heat"], { "bob-heat-pipe-1" },
				mode)
		end
		--
		local architecture_t3_tech = technologies["factory-architecture-t3"]
		techUtil.addPrerequisitesToTechnology(architecture_t3_tech, { "utility-science-pack" }, mode)
		techUtil.removeSciencePackFrom(architecture_t3_tech, "production-science-pack", mode)
		techUtil.addSciencePacksToTechnologyUnits(architecture_t3_tech, { { "utility-science-pack", 1 } }, mode)
		techUtil.addPrerequisitesToTechnology(technologies["space-science-pack"], { "factory-recursion-t2" }, mode)

		--attp technologies
		techUtil.addPrerequisitesToTechnology(technologies[ATTP_1_TECHNOLOGY_NAME],
			{ "factory-architecture-t1", "factory-connection-type-chest", "factory-connection-type-fluid",
				"factory-connection-type-circuit", "factory-interior-upgrade-lights", "factory-interior-upgrade-display" },
			mode)
		techUtil.addPrerequisitesToTechnology(technologies[ATTP_2_TECHNOLOGY_NAME],
			{ "factory-architecture-t2" }, mode)
		techUtil.addPrerequisitesToTechnology(technologies[ATTP_3_TECHNOLOGY_NAME], { "factory-recursion-t1" }, mode)
		techUtil.addPrerequisitesToTechnology(technologies[ATTP_4_TECHNOLOGY_NAME], { "factory-recursion-t2" }, mode)
	end
end
updateTechnologyNormalTree("normal")
updateTechnologyNormalTree("expensive")
