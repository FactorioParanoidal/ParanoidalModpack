local TechUtil = {}
local recipe_util = require("__automated-utility-protocol__.util.recipe-util")
require("__automated-utility-protocol__.util.technology-tree-util")

local function filter_technology_effects_unlock_recipe(effect)
    return effect and effect.type == "unlock-recipe" and effect.recipe
    --	and not recipe_util.is_contain_dry411_srev(effect.recipe)
end

local function get_technology_object_effect_recipes_by_name(technology_candidate_name, mode)
    local technology_object = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if not technology_object or not technology_object.effects then
        return {}
    end
    return _table.filter(technology_object.effects, filter_technology_effects_unlock_recipe)
end

TechUtil.get_all_recipe_ingredients_for_specified_technology = function(technology_name, mode)
    local result = {}
    local unlocked_recipes = get_technology_object_effect_recipes_by_name(technology_name, mode)
    _table.each(
        unlocked_recipes,
        function(unlocked_recipe)
            local recipe_name = unlocked_recipe.recipe
            local ingredients = recipe_util.get_all_recipe_ingredients(recipe_name, mode)
            _table.insert_all_if_not_exists(result, ingredients)
        end
    )
    return result
end

TechUtil.get_all_recipe_results_for_specified_technology = function(technology_name, mode)
    local result = {}
    local unlocked_recipes = get_technology_object_effect_recipes_by_name(technology_name, mode)
    _table.each(
        unlocked_recipes,
        function(unlocked_recipe)
            local recipe_name = unlocked_recipe.recipe
            local results = recipe_util.get_all_recipe_results(recipe_name, mode)
            _table.insert_all_if_not_exists(result, results)
        end
    )
    return result
end

TechUtil.get_all_tool_units_for_specified_technology = function(technology_name, mode)
    local result = {}
    local technology_object = Utils.get_moded_object("technology", technology_name, mode)
    if not technology_object or not technology_object.unit or not technology_object.unit.ingredients then
        return
    end
    _table.each(
        technology_object.unit.ingredients,
        function(research_unit_ingredient)
            local ingredient_name = research_unit_ingredient.name or research_unit_ingredient[1]
            local research_unit_ingredient_type = research_unit_ingredient.type or "item"
            table.insert(result, { type = research_unit_ingredient_type, name = ingredient_name })
        end
    )
    return result
end

TechUtil.get_all_recipe_names_for_specified_technology = function(technology_name, mode)
    return _table.map(
        get_technology_object_effect_recipes_by_name(technology_name, mode),
        function(unlocked_recipe)
            return unlocked_recipe.recipe
        end
    )
end

TechUtil.get_all_technology_names_with_fuel_result_specified_in_another_recipe_by_name = function(recipe_name, mode)
    local with_fuel_value_items_or_fluids =
        _table.filter(
            recipe_util.get_all_recipe_results(recipe_name, mode),
            function(result_data)
                local result_data_type = result_data.type
                local result_data_name = result_data.name or result_data[1]
                return data.raw[result_data_type][result_data_name].fuel_value
            end
        )
    if _table.size(with_fuel_value_items_or_fluids) == 0 then
        return {}
    end
    local technology_names = TechUtil.get_all_active_technology_names(mode)
    local result = {}
    _table.each(
        with_fuel_value_items_or_fluids,
        function(with_fuel_value_item_or_fluid)
            local with_fuel_value_item_or_fluid_name = with_fuel_value_item_or_fluid.name or
                with_fuel_value_item_or_fluid[1]
            local target_item_or_fluid = with_fuel_value_item_or_fluid
            if string.find(with_fuel_value_item_or_fluid_name, "-barrel", 1, true) then
                target_item_or_fluid =
                    _table.filter(
                        recipe_util.get_all_recipe_ingredients(recipe_name, mode),
                        function(recipe_ingredient)
                            return recipe_ingredient.type == "fluid"
                        end
                    )[1]
            end
            local technology_name_with_result =
                _table.filter(
                    technology_names,
                    function(technology_name)
                        local results = TechUtil.get_all_recipe_results_for_specified_technology(technology_name, mode)
                        return _table.contains_f_deep(results, target_item_or_fluid)
                    end
                )
            result[target_item_or_fluid] = technology_name_with_result
        end
    )
    return result
end

TechUtil.get_all_active_technology_names = function(mode)
    local result = {}
    _table.each(
        data.raw["technology"],
        function(technology_candidate)
            local technology_name = technology_candidate.name
            local technology = Utils.get_moded_object("technology", technology_candidate.name, mode)
            if
                not technology.hidden or
                technology.hidden and _string.ends_with(technology_name, DETECTED_RESOURCE_TECHNOLOGY_SUFFIX)
            then
                table.insert(result, technology_name)
            end
        end
    )
    return result
end

TechUtil.get_all_technology_names_with_hidden = function()
    return _table.map(
        data.raw["technology"],
        function(technology)
            return technology.name
        end
    )
end

TechUtil.add_prerequisites_to_technology = function(technology_candidate_name, prerequisites, mode)
    if not prerequisites or type(prerequisites) ~= "table" then
        error("prerequisites not specified")
    end
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    --проверяем на создание циклов.
    _table.each(
        prerequisites,
        function(prerequisite_name)
            if TechnologyTreeUtil.have_technology_in_tree(prerequisite_name, technology_candidate_name, mode) then
                TechnologyTreeUtil.print_technology_tree(prerequisite_name, mode)
                error(
                    "prerequisite_name " ..
                    prerequisite_name ..
                    " contains implicitly technology " ..
                    technology_candidate_name .. " and can't be added to it prerequisites!! NO CYCLE IN TREE!!!"
                )
            end
            if not technology.prerequisites then
                technology.prerequisites = {}
            end
            if not _table.contains(technology.prerequisites, prerequisite_name) then
                table.insert(technology.prerequisites, prerequisite_name)
            end
        end
    )
end
TechUtil.remove_prerequisites_from_technology = function(technology_candidate_name, prerequisites, mode)
    if not prerequisites then
        error("prerequisites not specified")
    end
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if not technology.prerequisites then
        error("try to remove from not exists prerequisistes")
    end
    _table.each(
        prerequisites,
        function(prerequisite)
            _table.remove_item(technology.prerequisites, prerequisite)
        end
    )
end

TechUtil.reset_prerequisites_for_technology = function(technology_candidate_name, prerequisites, mode)
    if not prerequisites then
        error("prerequisites not specified")
    end
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if technology.prerequisites then
        technology.prerequisites = nil
    end
    TechUtil.add_prerequisites_to_technology(technology_candidate_name, prerequisites, mode)
end
TechUtil.add_recipe_effect_to_technology = function(technology_candidate_name, recipe_name, mode)
    if not recipe_name then
        error("recipe_name not specified!")
    end
    local technology_candidate = data.raw["technology"][technology_candidate_name]
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if not technology.effects then
        technology.effects = {}
    end
    _table.insert_all_if_not_exists(technology.effects, { { type = "unlock-recipe", recipe = recipe_name } })
    local recipe = Utils.get_moded_object("recipe", recipe_name, mode)
    if not recipe then
        error("recipe with name " .. recipe_name .. " not found!")
    end
    recipe.enabled = false
end

TechUtil.remove_recipe_effect_from_technology = function(technology_candidate_name, recipe_name, mode)
    if not recipe_name then
        error("recipe_name not specified!")
    end
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if not technology.effects then
        error("technology effects not specified!")
    end
    _table.remove_item(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end

local function add_science_pack_to_technology_units(technology_candidate_name, ingredient_value, mode)
    if not ingredient_value then
        error("ingredient_value not specified")
    end
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if technology.unit and technology.unit.ingredients then
        --log("technology.unit.ingredients " .. Utils.dump_to_console(technology.unit.ingredients))
        _table.insert_all_if_not_exists_with_compare(
            technology.unit.ingredients,
            { ingredient_value },
            function(__table, inserting_item)
                local ingredient_names =
                    _table.map(
                        __table,
                        function(item)
                            return item.name or item[1]
                        end
                    )
                --log("ingredient_names " .. Utils.dump_to_console(ingredient_names))
                local inserting_ingredient_name = inserting_item.name or inserting_item[1]
                --log("inserting_ingredient_name " .. inserting_ingrediend_name)
                local result = not _table.contains(ingredient_names, inserting_ingredient_name)
                --log("result " .. tostring(result))
                return result
            end
        )
    end
end
TechUtil.add_science_packs_to_technology_units = function(technology_candidate_name, technology_units, mode)
    if not technology_units then
        error("technology_units not specified")
    end
    _table.each(
        technology_units,
        function(technology_unit)
            add_science_pack_to_technology_units(technology_candidate_name, technology_unit, mode)
        end
    )
end
TechUtil.remove_science_pack_from_technology_units = function(technology_candidate_name, science_pack_name, mode)
    if not science_pack_name then
        error("science_pack_name not specified")
    end
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    _table.remove_item(
        technology.unit.ingredients,
        science_pack_name,
        function(table_item, item_for_remove)
            return table_item[1] == item_for_remove
        end
    )
end

TechUtil.hide_technology = function(technology_candidate_name, mode)
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    technology.hidden = true
end

TechUtil.show_technology = function(technology_candidate_name, mode)
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    technology.hidden = false
end

TechUtil.show_recipe = function(recipe_candidate_name, mode)
    Utils.get_moded_object("recipe", recipe_candidate_name, mode).hidden = false
end

TechUtil.hide_recipe = function(recipe_candidate_name, mode)
    Utils.get_moded_object("recipe", recipe_candidate_name, mode).hidden = true
end
TechUtil.move_recipe_effects_to_another_technology = function(from_name, to_name, recipe_name, mode)
    TechUtil.remove_recipe_effect_from_technology(from_name, recipe_name, mode)
    TechUtil.add_recipe_effect_to_technology(to_name, recipe_name, mode)
end
TechUtil.has_technology_effects = function(technology_candidate_name, mode)
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    return technology.effects and _table.size(technology.effects) > 0
end
TechUtil.has_technology_recipe_effects = function(technology_candidate_name, recipe_name, mode)
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    if not recipe_name then
        error("recipe_name not specified!")
    end
    if not technology.effects then
        error("technology effects not specified!")
    end
    return _table.get_item_index(technology.effects, { type = "unlock-recipe", recipe = recipe_name }) ~= nil
end
TechUtil.replace_all_occurs_prerequisite_to_another_in_active_technologies = function(from, to, mode)
    local with_deleting_prerequisite_technology_names = TechUtil
        .find_all_active_technology_names_with_specified_prerequisite_name(from, mode)
    --[[log(
        "with_deleting_prerequisite_technology_names "
            .. Utils.dump_to_console(with_deleting_prerequisite_technology_names)
            .. " for technology "
            .. from
    )]]
    _table.each(
        with_deleting_prerequisite_technology_names,
        function(with_deleting_prerequisite_technology_name)
            local technology = data.raw["technology"][with_deleting_prerequisite_technology_name]
            TechUtil.remove_prerequisites_from_technology(technology.name, { from }, mode)
            TechUtil.add_prerequisites_to_technology(technology.name, { to }, mode)
        end
    )
end

TechUtil.find_all_active_technology_names_with_specified_prerequisite_name = function(technology_name, mode, excludes)
    local all_active_technology_names = TechUtil.get_all_active_technology_names(mode)
    local real_excludes = excludes or {}
    return _table.filter(
        all_active_technology_names,
        function(all_active_technology_name)
            local prerequisites = Utils.get_moded_object("technology", all_active_technology_name, mode)
                .prerequisites
            return prerequisites and _table.contains(prerequisites, technology_name) and
                not _table.contains(real_excludes, all_active_technology_name)
        end
    )
end
TechUtil.find_all_prerequisite_names_specified_technology = function(technology_candidate_name, mode)
    local technology = Utils.get_moded_object("technology", technology_candidate_name, mode)
    return technology.prerequisites or {}
end
return TechUtil
