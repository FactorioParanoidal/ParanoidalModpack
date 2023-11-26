local function checkTechnologyCandidate(technology_candidate)
	if not technology_candidate then
		error("technology not specifed")
	end
	if type(technology_candidate) ~= "table" then
		error("technology must be a table but got " .. type(technology_candidate))
	end
	return technology_candidate
end
local function addPrerequisitesToTechnologyWithoutMode(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	if technology.prerequisites then
		_table.insert_all_if_not_exists(technology.prerequisites, prerequisites)
	else
		technology.prerequisites = prerequisites
	end
end

local function removePrerequisitesFromTechnologyWithoutMode(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	if not technology.prerequisites then
		error("try to remove from not exists prerequisistes")
	end
	_table.each(prerequisites, function(prerequisite)
		_table.remove_item(technology.prerequisites, prerequisite)
	end)
end

local function resetTechnologyPrerequisitesWithoutMode(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	if technology.prerequisites then
		technology.prerequisites = nil
	end
	addPrerequisitesToTechnologyWithoutMode(technology_candidate, prerequisites)
end

local function resetBasicTechnologyPrerequisitesToNormalTree()()
	local technologies = data.raw["technology"]
	resetTechnologyPrerequisitesWithoutMode(technologies["factory-architecture-t1"], { "basic-researching" })
	resetTechnologyPrerequisitesWithoutMode(
		technologies["basic-automation"],
		{ "factory-architecture-t1", "basic-researching" }
	)
	resetTechnologyPrerequisitesWithoutMode(technologies["stone-wall"], { "military-0", "basic-automation" })
	resetTechnologyPrerequisitesWithoutMode(
		technologies["water-pumpjack-1"],
		{ "basic-automation", "basic-metal-processing", "angels-copper-smelting-1", "electricity", "coal-ore-smelting" }
	)
	resetTechnologyPrerequisitesWithoutMode(
		technologies["basic-logistics"],
		{ "logistics-0", "basic-automation", "iron-storage" }
	)
	resetTechnologyPrerequisitesWithoutMode(technologies["logistics-0"], {
		"basic-automation",
		"coal-ore-smelting",
		"basic-wood-production",
		"basic-metal-processing",
		"basic-researching",
	})
	resetTechnologyPrerequisitesWithoutMode(technologies["armor-absorb-1"], { "basic-automation" })
	resetTechnologyPrerequisitesWithoutMode(
		technologies["bi-dart-turret"],
		{ "basic-automation", "basic-metal-processing", "basic-wood-production" }
	)
	resetTechnologyPrerequisitesWithoutMode(technologies["military"], { "basic-automation", "military-0" })
	resetTechnologyPrerequisitesWithoutMode(technologies["electricity"], { "basic-automation", "electricity-0" })
	-- открываем технологию радара вновь, потому что она используется в нескольких других технлогиях явно, про которые забыли
	technologies["radars-1"].hidden = false
	-- технология powder-metallurgy-1 - почему-то отключает ангел-боб, включаем, используется в нескольких местах! ОТКЛЮЧАТЬ ТОЛЬКО ЯВНО, ВО ВСЕХ ТЕХНОЛОГИЯХ ГДЕ ИСПОЛЬЗУЮТСЯ ЗАВИСИМОСТИ!!!
	technologies["powder-metallurgy-1"].hidden = false
	-- вооружение боба, скрытые технологии и рецепты
	technologies["bob-bullets"].hidden = false
	data.raw.recipe["bullet-casing"].hidden = false
	data.raw.recipe["magazine"].hidden = false
	data.raw.recipe["bullet-projectile"].hidden = false
	data.raw.recipe["bullet"].hidden = false
	data.raw.recipe["uranium-bullet-projectile"].hidden = false
	data.raw.recipe["uranium-bullet"].hidden = false
	data.raw.recipe["shotgun-shell-casing"].hidden = false
	-- технология серной кислоты, открываем для газов из мода
	technologies["sulfur-processing"].hidden = false
	technologies["oil-processing"].hidden = false
end
local function hideTechnologies()
	_table.each(technologies, function(technology)
		if string.find(technology.name, "qol-", 1, true) then
			technology.hidden = true
		end
	end)
	
end
local function addRecipeEffectToTechnologyEffectsWithoutMode(technology_candidate, recipe_name)
	local technology = checkTechnologyCandidate(technology_candidate)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		technology.effects = {}
	end
	table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
	local recipe = data.raw.recipe[recipe_name]
	if not recipe then
		error("recipe with name " .. recipe_name .. " not found!")
	end
	recipe.enabled = false
end
local function removeRecipeEffectFromTechnologyEffectsWithoutMode(technology_candidate, recipe_name)
	local technology = checkTechnologyCandidate(technology_candidate)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		error("technology effects not specified!")
	end
	_table.remove_item(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end
local function moveRecipeEffectsToTechnology(from_name, to_name, recipe_name)
	local technologies = data.raw["technology"]
	removeRecipeEffectFromTechnologyEffectsWithoutMode(technologies[from_name], recipe_name)
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies[to_name], recipe_name)
end
local function updateEffectsAndTechnologyPrerequisites()
	local technologies = data.raw["technology"]
	local logistic_0_technology = technologies["logistics-0"]
	addRecipeEffectToTechnologyEffectsWithoutMode(logistic_0_technology, "basic-transport-belt")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["military-2"], "copper-nickel-firearm-magazine")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["basic-fluid-handling"], "offshore-pump-0")
	local ore_crushing_technology = technologies["ore-crushing"]
	addPrerequisitesToTechnologyWithoutMode(ore_crushing_technology, { "burner-ore-crushing" })
	addPrerequisitesToTechnologyWithoutMode(technologies["electric-mining"], { "burner-ore-mining" })

	removeRecipeEffectFromTechnologyEffectsWithoutMode(technologies["sulfur-processing"], "sulfuric-acid-2")
	--
end
local function moveRecipesToNewTechnologies()
	moveRecipeEffectsToTechnology("resins", "resin-1", "solid-resin")
	moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-1")
	moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-2")
	moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-3", "puffer-egg-3")
	moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-4")
	moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-5")
	moveRecipeEffectsToTechnology("w93-modular-turrets", "w93-modular-turrets2", "w93-hmg-turret2")
	moveRecipeEffectsToTechnology("rubber", "rubbers", "liquid-rubber-1")
	moveRecipeEffectsToTechnology(
		"phosphorus-processing-1",
		"phosphorus-processing-2",
		"solid-tetrasodium-pyrophosphate"
	)
end
local function removePrerequisites()
	local technologies = data.raw["technology"]
	removePrerequisitesFromTechnologyWithoutMode(technologies["modules-3"], "advanced-electronics-3")
	removePrerequisitesFromTechnologyWithoutMode(technologies["advanced-electronics"], { "offshore-pump-2" })
end

local function addRecipeEffects()
	local technologies = data.raw["technology"]

	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore5-crushed")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore6-crushed")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "iron-plate")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "copper-plate")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "lead-plate")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "tin-plate")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "glass-from-ore4")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore5-crushed-smelting")
	addRecipeEffectToTechnologyEffectsWithoutMode(ore_crushing_technology, "angelsore6-crushed-smelting")
	removeRecipeEffectFromTechnologyEffectsWithoutMode(technologies["basic-automation"], "steam-inserter")
	local steam_power_technology = technologies["steam-power"]
	addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, "steam-inserter")
	addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, createSteamRecipe())
	addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, "steam-assembling-machine")
	addRecipeEffectToTechnologyEffectsWithoutMode(steam_power_technology, "steam-mining-drill")
	addRecipeEffectToTechnologyEffectsWithoutMode(logistic_0_technology, "chute-miniloader")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["electricity"], "bob-burner-generator")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["nuclear-power"], "used-up-uranium-fuel-cell")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["nuclear-power"], "used-up-RITEG-1")

	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["mixed-oxide-fuel"], "used-up-thorium-fuel-cell")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-nuclear-power-3"], "used-up-deuterium-fuel-cell")
	--bob warfare mod восстанавливаем удалённые рецепты
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "bullet-casing")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "magazine")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "bullet-projectile")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "bullet")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "uranium-bullet-projectile")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "uranium-bullet")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["bob-bullets"], "shotgun-shell-casing")
	addRecipeEffectToTechnologyEffectsWithoutMode(technologies["CW-air-filtering-1"], "CW-used-air-filter")
	addRecipeEffectToTechnologyEffectsWithoutMode(
		technologies["dense-neutron-flux"],
		"used-up-advanced-tritium-breeder-fuel-cell"
	)
end
resetBasicTechnologyPrerequisitesToNormalTree()()
updateEffectsAndTechnologyPrerequisites()
moveRecipesToNewTechnologies()
removePrerequisites()
hideTechnologies()
addRecipeEffects()