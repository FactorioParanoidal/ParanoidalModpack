require("__automated-utility-protocol__.util.main")
local techUtil = require("__automated-utility-protocol__.util.technology-util")

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
--from mod "research evolution_factor"
local science_packet_cost = { --evolution cost coefficients for specific science packs
	["planetary-data"] = 1400,
	["station-science"] = 3000,
}
local constant_factor = 0.15 --percent of evolution per each researched technology
local linear_factor = 0.35 --percent of evolution per 1000 total researched science packs
--from mod "research evolution_factor"
local function tech_cost(tech)
	local sum = 0
	if tech.research_unit_ingredients then
		for _, item in pairs(tech.research_unit_ingredients) do
			local name, amount
			if item.type then
				if item.type == "item" then
					name = item.name
					amount = item.amount
				end
			else
				name = item[1]
				amount = item[2]
			end
			if name then
				--log(name..'----'..amount)
				sum = sum + amount * (science_packet_cost[name] or 1)
			end
		end
	end
	local unit_count = tech.research_unit_count
	if tech.research_unit_count_formula then
		if tech.name then
			unit_count = global.infinite_research_units[tech.name]
			global.infinite_research_units[tech.name] = nil --erasing unusial record
		end
	end
	sum = sum * (unit_count or 0)
	return sum * 0.00001 * linear_factor + constant_factor * 0.01
end
--from mod "research evolution_factor"
local function ignored_tech(tech)
	return tech.force.name ~= "player"
		or tech.prototype.hidden
		or (string.sub(tech.name, 1, 4) == "qol-")
		or tech.research_unit_count_formula
end
local function filter_only_research_technologies(technology)
	return technology.researched
end
local function get_player()
	if game.is_multiplayer() then
		return nil
	end
	return game.players[1]
end
--from mod "research evolution_factor" updated
local function reset_evolution_factor_to_researched_technologies()
	local player = get_player()
	if not player then
		return
	end

	local researched_technologies = _table.filter(player.force.technologies, filter_only_research_technologies)
	log("researched_technologies " .. Utils.dump_to_console(_table.keys(researched_technologies)))
	if _table.size(researched_technologies) == 1 then
		log("no technologies!")
		for _, force in pairs(game.forces) do
			if force.ai_controllable or force == game.forces.enemy then
				force.reset_evolution()
				return
			end
		end
	end
	_table.each(researched_technologies, function(tech)
		if ignored_tech(tech) then
			return
		end

		local inc = tech_cost(tech)

		for _, force in pairs(game.forces) do
			if force.ai_controllable or force == game.forces.enemy then
				force.evolution_factor = 1 - (1 - force.evolution_factor) * math.exp(-inc)
			end
		end
	end)
end

local SURFACE_NAMES_FOR_ENTITY_DISABLING = { "nauvis" }
local TAX_RATE = 0.13
local MAX_INTEGER = 1000

local function map_ingredient_table_to_ingredient(research_unit_ingredient_count, research_unit_count)
	return research_unit_ingredient_count * (research_unit_count or MAX_INTEGER * MAX_INTEGER * MAX_INTEGER)
end

local function map_ingredient_table_to_ingredient_array(research_unit_ingredients, research_unit_count)
	local result = {}
	_table.each(research_unit_ingredients, function(research_unit_ingredient)
		local research_unit_ingredient_name = (research_unit_ingredient.name or research_unit_ingredient[1])
		local research_unit_ingredient_count = (research_unit_ingredient.amount or research_unit_ingredient[2])
		result[research_unit_ingredient_name] =
			map_ingredient_table_to_ingredient(research_unit_ingredient_count, research_unit_count)
	end)
	return result
end

local function disable_entity(entity)
	entity.active = false
end

local function disable_entity_on_surface_by_type(surface_name, entity_type, force)
	local entities = game.surfaces[surface_name].find_entities_filtered({ type = entity_type, force = force })
	_table.each(entities, disable_entity)
end

local function disable_entity_on_all_surfcases_by_type(entity_type, force)
	_table.each(SURFACE_NAMES_FOR_ENTITY_DISABLING, function(surface_name)
		disable_entity_on_surface_by_type(surface_name, entity_type, force)
	end)
end

local function disable_player_entities()
	log("production entities must be disabled on surfaces!")
	local player = get_player()
	if not player then
		return
	end
	local disabling_entity_type_names = _table.deep_copy(ENTITY_TYPES_FOR_DISABLING)
	table.insert(disabling_entity_type_names, "turret")
	_table.each(disabling_entity_type_names, function(entity_type)
		disable_entity_on_all_surfcases_by_type(entity_type, player.force)
	end)
	log("production entities disabled on surfaces")
end

local function disable_recipe_for_manual_crafting(recipe_name, force)
	log(recipe_name .. " is disabling for manual crafting")
	force.set_hand_crafting_disabled_for_recipe(recipe_name, true)
	if not force.get_hand_crafting_disabled_for_recipe(recipe_name) then
		error("recipe_name " .. recipe_name .. "can't disable for manual crafting!")
	end
	log(recipe_name .. " is disabled for manual crafting")
end

local function disable_all_recipes_for_manual_crafting()
	local player = get_player()
	if not player then
		return
	end
	_table.each(game.recipe_prototypes, function(recipe, recipe_name)
		disable_recipe_for_manual_crafting(recipe_name, player.force)
	end)
end

local function add_ingredient_to(targetIngredients, ingredient_amount, ingredient_name)
	if not targetIngredients[ingredient_name] then
		targetIngredients[ingredient_name] = ingredient_amount
	else
		targetIngredients[ingredient_name] = targetIngredients[ingredient_name] + ingredient_amount
	end
end

local function add_ingredients_to(targetIngredients, sourceIngredients)
	_table.each(sourceIngredients, function(ingredient_amount, ingredient_name)
		add_ingredient_to(targetIngredients, ingredient_amount, ingredient_name)
	end)
end

local function reset_technology_ingredients_if_technology_has_unresearched_prerequisite(technology)
	if not technology.researched then
		return nil
	end
	local result = {}
	if not technology.prerequisites then
		return result
	end
	local has_unresearched_in_the_path = false
	for _, prerequisite in pairs(technology.prerequisites) do
		local ingredients = reset_technology_ingredients_if_technology_has_unresearched_prerequisite(prerequisite)
		if not ingredients then
			has_unresearched_in_the_path = true
		elseif ingredients and _table.size(ingredients) > 0 then
			has_unresearched_in_the_path = true
			add_ingredients_to(result, ingredients)
		end
	end
	if has_unresearched_in_the_path then
		local mapped_ingredient_array = map_ingredient_table_to_ingredient_array(
			technology.research_unit_ingredients,
			technology.research_unit_count
		)
		technology.researched = false
		add_ingredients_to(result, mapped_ingredient_array)
	end
	return result
end

local returned_ingredients = {}

local function handle_one_reasearched_technology(technology)
	local ingredients = reset_technology_ingredients_if_technology_has_unresearched_prerequisite(technology)
	if ingredients and _table.size(ingredients) > 0 then
		add_ingredients_to(returned_ingredients, ingredients)
	end
end

local function return_ingredient_to_player(ingredient_value, ingredient_name, player)
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

local function return_ingredients_to_player(player, all_returned_ingredients)
	_table.each(all_returned_ingredients, function(value, name)
		return_ingredient_to_player(value, name, player)
	end)
end

local function reset_technologies_with_unresearched_prerequisites_in_the_path()
	local player = get_player()
	if not player then
		return
	end
	log("START all researched technologies")
	player.force.research_queue = nil
	local researched_technologies = _table.filter(player.force.technologies, filter_only_research_technologies)
	log("END all researched technologies")
	local all_returned_ingredients = {}
	repeat
		_table.each(researched_technologies, handle_one_reasearched_technology)
		add_ingredients_to(all_returned_ingredients, returned_ingredients)
		returned_ingredients = {}
	until #returned_ingredients == 0
	log("total ingredients for return to player are " .. game.table_to_json(all_returned_ingredients))
	return_ingredients_to_player(player, all_returned_ingredients)
end

local loaded = false
function on_tick_disabling_event(e)
	if not loaded then
		if Utils.is_freeplay_scenario() then
			if settings.global["disable-production-entities-beyond-factorissimo-building"].value then
				disable_player_entities()
			end
			if settings.global["disable-hand-crafting"].value then
				disable_all_recipes_for_manual_crafting()
			end
			if settings.global["enable-technology-research-reevaluting"].value then
				reset_technologies_with_unresearched_prerequisites_in_the_path()
			end
			reset_evolution_factor_to_researched_technologies()
			loaded = true
		end
	end
end

function on_built_disabling_event(e)
	local created_entity = e.created_entity
	if not created_entity then
		return
	end
	local created_entity_type = created_entity.type
	log("created_entity " .. created_entity_type .. " name " .. created_entity.name)
	created_entity_surface_name = created_entity.surface.name
	local is_type_for_disabling = _table.contains(ENTITY_TYPES_FOR_DISABLING, created_entity_type)
			and _table.contains(SURFACE_NAMES_FOR_ENTITY_DISABLING, created_entity_surface_name)
		or created_entity_type == "solar-panel" -- отключаем солнечные панели в принципе, это чит.
	created_entity.active = not is_type_for_disabling
end

function on_load_disabling_event()
	game_reload = false
end
