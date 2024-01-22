local techUtil = require("__automated-utility-protocol__.util.technology-util")
local function resetBasicTechnologyPrerequisitesToNormalTree(mode)
	local technologies = data.raw["technology"]
	techUtil.resetTechnologyPrerequisites(technologies["factory-architecture-t1"], { "basic-researching" }, mode)
	techUtil.resetTechnologyPrerequisites(
		technologies["basic-automation"],
		{ "factory-architecture-t1", "basic-researching" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["stone-wall"], { "military-0", "basic-automation" }, mode)
	techUtil.resetTechnologyPrerequisites(
		technologies["water-pumpjack-1"],
		{ "basic-automation", "basic-metal-processing", "angels-copper-smelting-1", "electricity", "coal-ore-smelting" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(
		technologies["basic-logistics"],
		{ "logistics-0", "basic-automation", "iron-storage" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["logistics-0"], {
		"basic-automation",
		"coal-ore-smelting",
		"basic-wood-production",
		"basic-metal-processing",
		"basic-researching",
	}, mode)
	techUtil.resetTechnologyPrerequisites(technologies["armor-absorb-1"], { "basic-automation" }, mode)
	techUtil.resetTechnologyPrerequisites(
		technologies["bi-dart-turret"],
		{ "basic-automation", "basic-metal-processing", "basic-wood-production" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["military"], { "basic-automation", "military-0" }, mode)
	techUtil.resetTechnologyPrerequisites(technologies["electricity"], { "basic-automation", "electricity-0" }, mode)
end

local function addPrerequisitesToTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.addPrerequisitesToTechnology(technologies["ore-crushing"], { "burner-ore-crushing" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["electric-mining"], { "burner-ore-mining" }, mode)
end

local function removeRecipeEffectsFromTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.removeRecipeEffectFromTechnologyEffects(technologies["sulfur-processing"], "sulfuric-acid-2", mode)
end
local function moveRecipesToNewTechnologies(mode)
	techUtil.moveRecipeEffectsToTechnology("resins", "resin-1", "solid-resin", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-1", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-2", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-3", "puffer-egg-3", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-4", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-5", mode)
	techUtil.moveRecipeEffectsToTechnology("w93-modular-turrets", "w93-modular-turrets2", "w93-hmg-turret2", mode)
	techUtil.moveRecipeEffectsToTechnology("rubber", "rubbers", "liquid-rubber-1", mode)
	techUtil.moveRecipeEffectsToTechnology(
		"phosphorus-processing-1",
		"phosphorus-processing-2",
		"solid-tetrasodium-pyrophosphate",
		mode
	)
	techUtil.moveRecipeEffectsToTechnology("basic-automation", "steam-power", "steam-inserter", mode)
end
local function removePrerequisitesFromTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.removePrerequisitesFromTechnology(technologies["modules-3"], { "advanced-electronics-3" }, mode)
	techUtil.removePrerequisitesFromTechnology(technologies["advanced-electronics"], { "offshore-pump-2" }, mode)
end

_table.each(GAME_MODES, function(mode)
	resetBasicTechnologyPrerequisitesToNormalTree(mode)
	addPrerequisitesToTechnologies(mode)
	removePrerequisitesFromTechnologies(mode)
	removeRecipeEffectsFromTechnologies(mode)
	moveRecipesToNewTechnologies(mode)
end)
