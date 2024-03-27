local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
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
end

local function add_prerequisites_to_technologies_in_regular_tree(mode)
	local technologies = data.raw["technology"]
	techUtil.add_prerequisites_to_technology(technologies["ore-crushing"], { "burner-ore-crushing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electric-mining"], { "burner-ore-mining" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["electric-chemical-furnace"], { "basic-chemistry" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["electric-mixing-furnace"],
		{ "electric-chemical-furnace" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["angels-solder-smelting-basic"], { "ore-crushing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["physical-projectile-damage-7"], {
		"automation-science-pack",
		"chemical-science-pack",
		"logistic-science-pack",
		"military-science-pack",
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["physical-projectile-damage-6"], {
		"automation-science-pack",
		"chemical-science-pack",
		"logistic-science-pack",
		"military-science-pack",
		"utility-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-5"],
		{ "automation-science-pack", "logistic-science-pack", "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-4"],
		{ "automation-science-pack", "logistic-science-pack", "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-3"],
		{ "automation-science-pack", "logistic-science-pack", "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-2"],
		{ "automation-science-pack", "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["military"], {
		"basic-metal-processing",
		"coal-ore-smelting",
		"basic-wood-production",
		"automation-science-pack",
		"military-0",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["basic-automation"],
		{ "coal-ore-smelting", "coal-stone-smelting", "basic-electronics" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["basic-electronics"],
		{ "basic-wood-production", "coal-ore-smelting" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["electronics"], {
		"basic-electronics",
		"angels-tin-smelting-1",
		"bi-tech-timber",
		"bio-wood-processing",
		"automation-science-pack",
	}, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["military-0"],
		{ "coal-detected-resource-technology", "salvaged-automation-tech" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["basic-wood-production"], {
		"basic-metal-processing",
		"water-detected-resource-technology",
		"coal-detected-resource-technology",
		"wood-detected-resource-technology",
		"salvaged-automation-tech",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["coal-stone-smelting"], { "salvaged-automation-tech" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["coal-ore-smelting"], { "salvaged-automation-tech" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["coal-ore-crushing"], {
		"wood-detected-resource-technology",
		"salvaged-automation-tech",
		"coal-wooden-fluid-handling",
		"water-detected-resource-technology",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["coal-ore-mining"], {
		"wood-detected-resource-technology",
		"salvaged-automation-tech",
		"coal-wooden-fluid-handling",
		"water-detected-resource-technology",
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
		technologies["coal-lighting"],
		{ "wood-detected-resource-technology", "coal-detected-resource-technology" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["basic-logistics"],
		{ "salvaged-automation-tech", "basic-electronics" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["coal-stone-processing"],
		{ "salvaged-automation-tech" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["automation-science-pack"],
		{ "coal-detected-resource-technology" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["logistics"], { "electricity" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["logistic-science-pack"],
		{ "logistics", "automation-science-pack", "angels-lead-smelting-1", "angels-tin-smelting-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["electric-engine"],
		{ "coal-detected-resource-technology" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["bob-boiler-2"],
		{ "flammables", "bi-tech-coal-processing-1" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["electricity"], {
		"basic-wood-production",
		"coal-ore-mining",
		"coal-detected-resource-technology",
		"wood-detected-resource-technology",
	}, mode)
	techUtil.add_prerequisites_to_technology(technologies["burner-reactor-1"], { "nuclear-power" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["bi-tech-bio-boiler"], { "bio-processing-alien-3" }, mode)
	--techUtil.add_prerequisites_to_technology(technologies["electronics"], { "basic-wood-production" }, mode)
end

local function remove_prerequisites_from_technologies_in_regular_tree(mode)
	local technologies = data.raw["technology"]
	techUtil.remove_prerequisites_to_technology(technologies["modules-3"], { "advanced-electronics-3" }, mode)
end

local function remove_recipes_from_technology_effects_in_regular_tree(mode)
	local technologies = data.raw["technology"]
	techUtil.remove_recipe_effect_from_technology(technologies["sulfur-processing"], "sulfuric-acid-2", mode)
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
end

local function move_recipes_to_another_technologies(mode)
	techUtil.move_recipe_effects_to_another_technology("resins", "resin-1", "solid-resin", mode)
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
		"w93-modular-turrets",
		"w93-modular-turrets2",
		"w93-hmg-turret2",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology("rubber", "rubbers", "liquid-rubber-1", mode)
	techUtil.move_recipe_effects_to_another_technology(
		"phosphorus-processing-1",
		"phosphorus-processing-2",
		"solid-tetrasodium-pyrophosphate",
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
		"angels-advanced-chemistry-3",
		"angels-advanced-chemistry-4",
		"catalyst-metal-violet",
		mode
	)
	techUtil.move_recipe_effects_to_another_technology("electricity", "repair-pack", "repair-pack", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-logistics", "burner-filter-inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("basic-automation", "basic-logistics", "burner-inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "condensator", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "wooden-board", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "basic-electronics", "basic-circuit-board", mode)
	techUtil.move_recipe_effects_to_another_technology("electricity", "logistics", "inserter", mode)
	techUtil.move_recipe_effects_to_another_technology("electronics", "logistics", "yellow-filter-inserter", mode)
end

local function add_recipe_to_technology_effects(mode)
	--#region basic tech recipes
	local technologies = data.raw["technology"]
	techUtil.add_recipe_effect_to_technology(
		technologies["salvaged-automation-tech"],
		"salvaged-mining-drill-bit-mk0",
		mode
	)
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
	techUtil.add_recipe_effect_to_technology(technologies["electric-lab"], "electric-motor", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military-0"], "pistol-rearm-ammo", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military-0"], "bi-wooden-fence", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military-0"], "respirator", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-mining"], "mining-drill-bit-mk0", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-crushing"], "burner-ore-crusher", mode)
	techUtil.add_recipe_effect_to_technology(technologies["automation-science-pack"], "burner-lab", mode)
	techUtil.add_recipe_effect_to_technology(technologies["automation-science-pack"], "sci-component-1", mode)
	techUtil.add_recipe_effect_to_technology(technologies["logistics"], "transport-belt", mode)
	--#end region basic tech recipes
end
local function create_resource_detected_technologies_and_add_it_to_normal_technology_prerequisities_by_recipe_name(mode)
	local resource_recipes = create_resource_recipes()
	local active_technology_names = techUtil.get_all_active_technology_names(mode)
	_table.each(resource_recipes, function(resource_recipe)
		local resource_recipe_name = resource_recipe.name
		local results = recipeUtil.get_all_recipe_results(resource_recipe_name, mode)
		local recipe_result = results[1]
		local recipe_result_name = recipe_result.name or recipe_result[1]
		local recipe_result_data = data.raw[recipe_result.type][recipe_result_name]
		--log("recipe_result_data " .. Utils.dump_to_console(recipe_result_data))
		local resource_detected_technology = create_resource_detected_technology(
			recipe_result_name,
			recipe_result_data.icon or recipe_result_data.icons[1].icon,
			recipe_result_data.icon_size or recipe_result_data.icons[1].icon_size,
			resource_recipe_name
		)
		--log("resource_detected_technology " .. Utils.dump_to_console(resource_detected_technology))
		data:extend({
			resource_detected_technology,
		})
		_table.each(active_technology_names, function(active_technology_name)
			local recipe_ingredients =
				techUtil.get_all_recipe_ingredients_for_specified_technology(active_technology_name, mode)
			local active_technology = data.raw["technology"][active_technology_name]
			if _table.contains_f_deep(recipe_ingredients, recipe_result) then
				techUtil.add_recipe_effect_to_technology(active_technology, resource_recipe_name, mode)
				techUtil.add_prerequisites_to_technology(active_technology, { resource_detected_technology.name }, mode)
				--[[	log(
					"for technology "
						.. active_technology_name
						.. " mode "
						.. mode
						.. " added recipe effect "
						.. resource_recipe_name
				)]]
			end
		end)
	end)
end
local function hide_recipes(mode)
	local recipes = data.raw["recipe"]
	techUtil.hide_recipe(recipes["torch"], mode)
end
_table.each(GAME_MODES, function(mode)
	create_resource_detected_technologies_and_add_it_to_normal_technology_prerequisities_by_recipe_name(mode)
	reset_basic_technology_prerequisites_to_regular_tree(mode)
	remove_prerequisites_from_technologies_in_regular_tree(mode)
	add_prerequisites_to_technologies_in_regular_tree(mode)
	remove_recipes_from_technology_effects_in_regular_tree(mode)
	add_recipe_to_technology_effects(mode)
	move_recipes_to_another_technologies(mode)
	hide_recipes(mode)
end)
