local _table = require("__stdlib__/stdlib/utils/table")

local ENTITY_TYPES_FOR_DISABLING = {
	"assembling-machine", --сборочные автоматы всех типов
	"accumulator", -- аккумуляторы всех типов
	"burner-generator", --твердотопливные генераторы всех типов
	"generator", -- паровые генераторы всех типов
	"boiler", -- кипятильники всех типов
	"beam",
	"beacon", -- радио трансляторы и маяки
	"furnace", -- печки всех типов
	"lab", -- лаборатории всех типов
	"radar", -- радары всех типов
	"solar-panel", --солнечные панели
	"reactor", -- ядерные реакторы всех типов
	"roboport", --робопорты, летать только в пределах заводского здания
	"logistic-container", -- читы для наувиса
	"infinity-container", -- читы для наувиса
}
local SURFACE_NAMES_FOR_ENTITY_DISABLING = { "nauvis" }

local TAX_RATE = 0.13

local MAX_INTEGER = 1000

local function mapIngredientTableToIngredient(research_unit_ingredient_count, research_unit_count)
	return research_unit_ingredient_count * (research_unit_count or MAX_INTEGER * MAX_INTEGER * MAX_INTEGER)
end

local function mapIngredientTableToIngredientArray(research_unit_ingredients, research_unit_count)
	local result = {}
	_table.each(research_unit_ingredients, function(research_unit_ingredient)
		local research_unit_ingredient_name = (research_unit_ingredient.name or research_unit_ingredient[1])
		local research_unit_ingredient_count = (research_unit_ingredient.amount or research_unit_ingredient[2])
		result[research_unit_ingredient_name] =
			mapIngredientTableToIngredient(research_unit_ingredient_count, research_unit_count)
	end)
	return result
end

local function getPlayer()
	if game.is_multiplayer() then
		return nil
	end
	return game.players[1]
end

local function disableEntity(entity)
	entity.active = false
end

local function disableEntityOnSurfaceByType(surface_name, entity_type, force)
	local entities = game.surfaces[surface_name].find_entities_filtered({ type = entity_type, force = force })
	--log('entities count '.. tostring(#entities))
	_table.each(entities, disableEntity)
end

local function disableEntityTypeForSurfaces(entity_type, force)
	--log('entity_type '..entity_type)
	_table.each(SURFACE_NAMES_FOR_ENTITY_DISABLING, function(surface_name)
		disableEntityOnSurfaceByType(surface_name, entity_type, force)
	end)
end

local function disablePlayerEntities()
	log("production entities must be disabled on surfaces!")
	local player = getPlayer()
	if not player then
		return
	end
	local disabling_entity_type_names = _table.deep_copy(ENTITY_TYPES_FOR_DISABLING)
	table.insert(disabling_entity_type_names, "turret")
	_table.each(disabling_entity_type_names, function(entity_type)
		disableEntityTypeForSurfaces(entity_type, player.force)
	end)
	log("production entities disabled on surfaces")
end

local function disableRecipe(recipe_name, force)
	log(recipe_name .. " is disabling for manual crafting")
	force.set_hand_crafting_disabled_for_recipe(recipe_name, true)
	if not force.get_hand_crafting_disabled_for_recipe(recipe_name) then
		error("recipe_name " .. recipe_name .. "can't disable for manual crafting!")
	end
	log(recipe_name .. " is disabled for manual crafting")
end

local function disableAllRecipes()
	local player = getPlayer()
	if not player then
		return
	end
	_table.each(game.recipe_prototypes, function(recipe, recipe_name)
		disableRecipe(recipe_name, player.force)
	end)
end

local function addIngredientTo(targetIngredients, ingredient_amount, ingredient_name)
	if not targetIngredients[ingredient_name] then
		targetIngredients[ingredient_name] = ingredient_amount
	else
		targetIngredients[ingredient_name] = targetIngredients[ingredient_name] + ingredient_amount
	end
end

local function addIngredientsTo(targetIngredients, sourceIngredients)
	_table.each(sourceIngredients, function(ingredient_amount, ingredient_name)
		addIngredientTo(targetIngredients, ingredient_amount, ingredient_name)
	end)
end

local function resetTechnologyIngredientsIfTechnologyHasUnresearchedPrerequisite(technology)
	if not technology.researched then
		--log('technology "'..technology.name..'" not researched!')
		return nil
	end
	local result = {}
	if not technology.prerequisites then
		return result
	end
	local hasUnresearchedInPath = false
	for _, prerequisite in pairs(technology.prerequisites) do
		local ingredients = resetTechnologyIngredientsIfTechnologyHasUnresearchedPrerequisite(prerequisite)
		if not ingredients then
			hasUnresearchedInPath = true
		elseif ingredients and _table.size(ingredients) > 0 then
			hasUnresearchedInPath = true
			addIngredientsTo(result, ingredients)
		end
	end
	if hasUnresearchedInPath then
		local mappedIngredientArray =
			mapIngredientTableToIngredientArray(technology.research_unit_ingredients, technology.research_unit_count)
		technology.researched = false
		addIngredientsTo(result, mappedIngredientArray)
	end
	return result
end

local function filterOnlyResearchTechnologies(technology)
	return technology.researched
end

local returned_ingredients = {}

local function handleOneReasearchedTechnology(technology)
	local ingredients = resetTechnologyIngredientsIfTechnologyHasUnresearchedPrerequisite(technology)
	if ingredients and _table.size(ingredients) > 0 then
		addIngredientsTo(returned_ingredients, ingredients)
	end
end

local function returnIngredientToPlayer(ingredient_value, ingredient_name, player)
	local ingredient_count = math.floor(ingredient_value * (1 - TAX_RATE))
	log(
		'after tax_rate descrease has count of ingredient called "'
			.. ingredient_name
			.. '"  is '
			.. tostring(ingredient_count)
	)
	player.surface.spill_item_stack(
		player.position,
		{ name = ingredient_name, count = ingredient_count },
		true,
		player.force,
		false
	)
	log(
		'after tax_rate descrease has count of ingredient called "'
			.. ingredient_name
			.. '"  is '
			.. tostring(ingredient_count)
			.. " will be returned to player!"
	)
end

local function returnIngredientsToPlayer(player, all_returned_ingredients)
	_table.each(all_returned_ingredients, function(value, name)
		returnIngredientToPlayer(value, name, player)
	end)
end

local function resetTechnologiesWithUnresearchedInPath()
	local player = getPlayer()
	if not player then
		return
	end
	log("START all researched technologies")
	player.force.research_queue = nil
	local researched_technologies = _table.filter(player.force.technologies, filterOnlyResearchTechnologies)
	log("END all researched technologies")
	local all_returned_ingredients = {}
	repeat
		_table.each(researched_technologies, handleOneReasearchedTechnology)
		addIngredientsTo(all_returned_ingredients, returned_ingredients)
		returned_ingredients = {}
	until #returned_ingredients == 0
	log("total ingredients for return to player are " .. game.table_to_json(all_returned_ingredients))
	returnIngredientsToPlayer(player, all_returned_ingredients)
end

local function OnConfigurationChanged(e)
	log("configuration changed!")
	disablePlayerEntities()
	disableAllRecipes()
	resetTechnologiesWithUnresearchedInPath()
end

local function onBuilt(e)
	local created_entity = e.created_entity
	if not created_entity then
		return
	end
	local created_entity_type = created_entity.type
	created_entity_surface_name = created_entity.surface.name
	local is_type_for_disabling = _table.contains(ENTITY_TYPES_FOR_DISABLING, created_entity_type)
			and _table.contains(SURFACE_NAMES_FOR_ENTITY_DISABLING, created_entity_surface_name)
		or created_entity_type == "solar-panel" -- отключаем солнечные панели в принципе, это чит.
	created_entity.active = not is_type_for_disabling
end

local function onLoad()
	game_reload = false
end

script.on_configuration_changed(OnConfigurationChanged)
script.on_event({ defines.events.on_built_entity, defines.events.script_raised_built }, onBuilt)
script.on_load(onLoad)
