local TechnologyHandler = {}
local tech_util = require("__automated-utility-protocol__.util.technology-util")
local recipe_util = require("__automated-utility-protocol__.util.recipe-util")
local crafting_machine_util = require("__automated-utility-protocol__.util.crafting-machine-util")

local function check_tree_element_not_hidden(active_technology_name, tree_element_name, mode)
    local moded_tree_element = Utils.get_moded_object("technology", tree_element_name, mode)
    if
        not moded_tree_element or
        moded_tree_element.hidden and
        -- исключаем технические технологии, которые будут являться маркерами при "знакомстве" с базовыми ресурсами
        not _string.ends_with(tree_element_name, DETECTED_RESOURCE_TECHNOLOGY_SUFFIX)
    then
        TechnologyTreeUtil.print_technology_tree(active_technology_name, mode)
        error(
            " for technology " ..
            active_technology_name ..
            " prerequisite called " ..
            tree_element_name ..
            " has HIDDEN or not exists for mode " ..
            mode ..
            ".\nTechnology object is " ..
            mode ..
            Utils.dump_to_console(data.raw["technology"][active_technology_name]) ..
            ".\nTree element for mode " .. mode .. " is " .. Utils.dump_to_console(moded_tree_element)
        )
    end
end

local function check_tree_not_has_hidden_element(active_technology_name, tree, mode)
    _table.each(
        tree,
        function(tree_element_table, tree_element_table_name)
            check_tree_element_not_hidden(active_technology_name, tree_element_table_name, mode)
            _table.each(
                tree_element_table,
                function(tree_element_name)
                    check_tree_element_not_hidden(active_technology_name, tree_element_name, mode)
                end
            )
        end
    )
end
local function check_recipes_not_has_hidden_in_tree_element(technology_name, mode)
    local recipe_names = tech_util.get_all_recipe_names_for_specified_technology(technology_name, mode)
    _table.each(
        recipe_names,
        function(recipe_name)
            local moded_recipe = Utils.get_moded_object("recipe", recipe_name, mode)
            if not moded_recipe or moded_recipe.hidden then
                error(
                    " for technology " ..
                    technology_name ..
                    " for mode " .. mode .. " effect recipe with name " .. recipe_name .. " is HIDDEN!"
                )
            end
        end
    )
end
local function check_recipes_not_has_hidden_in_tree(tree, mode)
    _table.each(
        tree,
        function(tree_element_table, tree_element_table_name)
            check_recipes_not_has_hidden_in_tree_element(tree_element_table_name, mode)
            _table.each(
                tree_element_table,
                function(tree_element_name)
                    check_recipes_not_has_hidden_in_tree_element(tree_element_name, mode)
                end
            )
        end
    )
end
local function is_unresolved_ingredient_in_technology_product_list(ingredient, products)
    return not _table.contains_f(
        products,
        function(product)
            return ingredient.type == product.type and ingredient.name == product.name
        end
    )
end
local function get_unresolved_technology_ingredients(active_technology_name, mode)
    local recipe_ingredients = tech_util.get_all_recipe_ingredients_for_specified_technology(active_technology_name, mode)
    local recipe_results = tech_util.get_all_recipe_results_for_specified_technology(active_technology_name, mode)
    local tool_units = tech_util.get_all_tool_units_for_specified_technology(active_technology_name, mode)
    local all_need_ingredients_for_technology_research = {}
    _table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, recipe_ingredients)
    _table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, tool_units)
    local result = {}
    _table.each(
        all_need_ingredients_for_technology_research,
        function(ingredient)
            if is_unresolved_ingredient_in_technology_product_list(ingredient, recipe_results) then
                table.insert(result, ingredient)
            end
        end
    )
    return result
end
local function is_recipe_ingredient_unreachable_in_tree_in_tree_element(
    unresolved_in_technology_ingredient,
    tree_element_name,
    mode)
    local recipe_results = tech_util.get_all_recipe_results_for_specified_technology(tree_element_name, mode)
    return is_unresolved_ingredient_in_technology_product_list(unresolved_in_technology_ingredient, recipe_results)
end
local function filter_technology_name_candidate_by_predicate(
    technology_name_candidate,
    mode,
    effect_ingredient_not_found_in_current_tree)
    local products = tech_util.get_all_recipe_results_for_specified_technology(technology_name_candidate, mode)
    return _table.contains_f(
        products,
        function(product)
            return effect_ingredient_not_found_in_current_tree.type == product.type and
                effect_ingredient_not_found_in_current_tree.name == product.name
        end
    )
end
local function filter_all_available_technologies_with_ingredient(
    all_found_technology_names,
    mode,
    effect_ingredient_not_found_in_current_tree)
    return _table.filter(
        all_found_technology_names,
        function(found_technology_name)
            return filter_technology_name_candidate_by_predicate(
                found_technology_name,
                mode,
                effect_ingredient_not_found_in_current_tree
            )
        end
    )
end

local function get_another_trees_handling_error_message(
    effect_ingredient_not_found_in_current_tree,
    technology_name,
    mode)
    local all_found_technology_names = tech_util.get_all_active_technology_names(mode)
    local available_technology_names_for_missed_ingredient =
        filter_all_available_technologies_with_ingredient(
            all_found_technology_names,
            mode,
            effect_ingredient_not_found_in_current_tree
        )
    local all_with_hidden_technology_names = tech_util.get_all_technology_names_with_hidden()
    local result = "all with hidden technology names " .. Utils.dump_to_console(all_with_hidden_technology_names) .. "\n"
    local all_with_hidden_technology_names_for_missed_ingredient =
        filter_all_available_technologies_with_ingredient(
            all_with_hidden_technology_names,
            mode,
            effect_ingredient_not_found_in_current_tree
        )

    local effect_ingredient_not_found_in_current_tree_name =
        effect_ingredient_not_found_in_current_tree.name or effect_ingredient_not_found_in_current_tree[1]
    result =
        result ..
        "with ingredient as result " ..
        effect_ingredient_not_found_in_current_tree_name ..
        " all ACTIVE technologies " .. Utils.dump_to_console(available_technology_names_for_missed_ingredient) .. "\n"
    result =
        result ..
        "with ingredient as result " ..
        effect_ingredient_not_found_in_current_tree_name ..
        " all WITH HIDDEN technologies " ..
        Utils.dump_to_console(all_with_hidden_technology_names_for_missed_ingredient) .. "\n"

    result =
        result ..
        'data.raw["technology"][' ..
        technology_name .. "]" .. Utils.dump_to_console(data.raw["technology"][technology_name]) .. "\n"
    result =
        result ..
        "technology tree of " ..
        technology_name ..
        " is " ..
        Utils.dump_to_console(TechnologyTreeUtil.find_prerequisites_for_technology_for_all_levels(technology_name, mode)) ..
        "\n"

    local recipe_names = tech_util.get_all_recipe_names_for_specified_technology(technology_name, mode)
    local available_recipe_names_for_ingredient =
        _table.filter(
            recipe_names,
            function(recipe_name)
                return _table.contains_f_deep(
                    recipe_util.get_all_recipe_ingredients(recipe_name, mode),
                    effect_ingredient_not_found_in_current_tree
                )
            end
        )

    result =
        result ..
        "for technology " ..
        technology_name ..
        " for mode " ..
        mode ..
        " keep unresolved " ..
        Utils.dump_to_console(effect_ingredient_not_found_in_current_tree) ..
        " ingredient dependency! Contained recipe names: " ..
        Utils.dump_to_console(available_recipe_names_for_ingredient) .. "\n"
    return result
end
local function raise_error_unresolved_ingredient_in_technology_tree(technology_name, mode, unresolved_ingredient)
    log("\nhandle unresolved ingredient")
    local error_message = get_another_trees_handling_error_message(unresolved_ingredient, technology_name, mode)
    log("\nunresolved ingredient handled")
    error(error_message)
end
local function check_recipe_ingredient_reachable_in_tree(
    unresolved_in_technology_ingredient,
    active_technology_name,
    tree,
    mode)
    local recipe_result_unresolved_ingredient = true
    _table.each(
        tree,
        function(tree_element_table, tree_element_table_name)
            if recipe_result_unresolved_ingredient then
                recipe_result_unresolved_ingredient =
                    is_recipe_ingredient_unreachable_in_tree_in_tree_element(
                        unresolved_in_technology_ingredient,
                        tree_element_table_name,
                        mode
                    )
            end
            _table.each(
                tree_element_table,
                function(tree_element_name)
                    if recipe_result_unresolved_ingredient then
                        recipe_result_unresolved_ingredient =
                            is_recipe_ingredient_unreachable_in_tree_in_tree_element(
                                unresolved_in_technology_ingredient,
                                tree_element_name,
                                mode
                            )
                    end
                end
            )
        end
    )
    if recipe_result_unresolved_ingredient then
        raise_error_unresolved_ingredient_in_technology_tree(
            active_technology_name,
            mode,
            unresolved_in_technology_ingredient
        )
    end
end
local function check_recipe_ingredients_reachable_in_tree(
    unresolved_in_technology_ingredients,
    active_technology_name,
    tree,
    mode)
    _table.each(
        unresolved_in_technology_ingredients,
        function(unresolved_in_technology_ingredient)
            check_recipe_ingredient_reachable_in_tree(unresolved_in_technology_ingredient, active_technology_name, tree,
                mode)
        end
    )
end

local function is_check_recipe_signature_allowed_automated(recipe_signature, active_technology_name, tree, mode)
    return string.find(recipe_signature.name, "steam-", 1, true) and
        string.find(recipe_signature.name, "-with-fuel-", 1, true) or
        recipe_signature.name == "steam" or
        string.find(recipe_signature.name, "-minable", 1, true) or
        crafting_machine_util.has_one_crafting_machine_in_technology_tree_by_recipe_signature(
            recipe_signature,
            active_technology_name,
            tree,
            mode
        )
end
local function raise_error_check_recipe_signature_allowed_automated(active_technology_name, tree, mode, recipe_name)
    --	TechnologyTreeUtil.print_technology_tree(active_technology_name, mode)
    local recipe_signature = recipe_util.get_recipe_signature(recipe_name, mode)
    error(
        "for recipe with signature " ..
        Utils.dump_to_console(recipe_signature) ..
        "\nin technology tree " ..
        active_technology_name ..
        ", mode " ..
        mode ..
        " not found no one crafting machine with appropriate signature.\nAvailable machine signatures in technology tree\n" ..
        Utils.dump_to_console(
            crafting_machine_util.get_crafting_machines_in_technology_tree(
                active_technology_name,
                tree,
                mode,
                recipe_signature.results.solid
            )
        ) ..
        "\n" .. Utils.dump_to_console(data.raw["recipe"][recipe_name])
    )
end

local function check_recipe_signature_allowed_automated(recipe_name, active_technology_name, tree, mode)
    local recipe_signature = recipe_util.get_recipe_signature(recipe_name, mode)
    local recipe_signature_allowed_automated =
        is_check_recipe_signature_allowed_automated(recipe_signature, active_technology_name, tree, mode)
    if not recipe_signature_allowed_automated then
        raise_error_check_recipe_signature_allowed_automated(active_technology_name, tree, mode, recipe_name)
    end
    return recipe_signature_allowed_automated
end

local function check_recipe_signatures_allowed_automated(active_technology_name, tree, mode)
    local all_technology_recipe_names =
        tech_util.get_all_recipe_names_for_specified_technology(active_technology_name, mode)
    _table.each(
        all_technology_recipe_names,
        function(recipe_name)
            check_recipe_signature_allowed_automated(recipe_name, active_technology_name, tree, mode)
        end
    )
end
local based_prototype_types = { "item", "fluid", "recipe", "technology" }
local function is_prototype_type_based(prototype_type)
    return _table.contains(based_prototype_types, prototype_type)
end
local function test_place_result_candidate(place_result_candidate_name)
    if not place_result_candidate_name then return false end
    local found_place_result = false
    _table.each(data.raw, function(prototype_type_table, prototype_type)
        if found_place_result then return end
        --
        if is_prototype_type_based(prototype_type) then return end
        --[[  log('data.raw[' ..
            prototype_type ..
            '][' ..
            place_result_candidate_name .. '] = ' ..
            Utils.dump_to_console(data.raw[prototype_type][place_result_candidate_name]))
        ]]
        found_place_result = data.raw[prototype_type][place_result_candidate_name] ~= nil
    end)
    return found_place_result
end

local function recipe_result_applied_something(recipe_result, recipe_name, active_technology_name, mode,
                                               visited_technology_names)
    local found_place_result = false
    --[[ищем, является ли это чем устанавливаемым на поверхность(здания, сооружения, транспорт, что угодно, entity прототип) или то, что может использоваться как продукт сгорания
    или то, что может использоваться как снаряжение]]
    local recipe_result_name = recipe_result.name
    local prototype = data.raw[recipe_result.type][recipe_result_name]

    if prototype and prototype.type == "item" then
        --сущность
        found_place_result = test_place_result_candidate(prototype.place_result)
        if found_place_result then return true end
        -- продукт сгорания
        found_place_result = test_place_result_candidate(prototype.burnt_result)
        if found_place_result then return true end
        -- экипировка
        found_place_result = test_place_result_candidate(prototype.placed_as_equipment_result)
        if found_place_result then return true end
        -- прототип "клетка"
        if prototype.place_as_tile then
            found_place_result = test_place_result_candidate(prototype.place_as_tile.result)
            if found_place_result then return true end
        end
        --
    end
    -- проверяем результаты запуска ракеты, если такие есть
    local rocket_launch_results = recipe_util.get_rocket_launch_recipe_results(recipe_name, mode)
    if _table.size(rocket_launch_results) > 0 then return true end
    --другие типы, оружие, локомотивы, что угодно, кроме предметов и жидкостей в явном виде.
    found_place_result = test_place_result_candidate(recipe_result_name)
    if found_place_result then return true end
    --если результат используется прямо в нашей технологии.
    local ingredients = tech_util.get_all_recipe_ingredients_for_specified_technology(active_technology_name, mode)
    found_place_result = _table.contains_f_deep(ingredients, recipe_result)
    if found_place_result then return true end
    -- поиск вниз по цепочке от корня к листьям. Если не нашли ранее устанавливаемый на поверхность результат явно, ищем используется ли где в технологиях, являющихся прямыми потомками данной и далее вниз.
    if _table.contains(visited_technology_names, active_technology_name) then return false end
    table.insert(visited_technology_names, active_technology_name)
    local leaf_names = tech_util.find_all_active_technology_names_with_specified_prerequisite_name(
        active_technology_name, mode)
    if _table.size(leaf_names) == 0 then return false end
    _table.each(leaf_names, function(leaf_name)
        if found_place_result then return end
        found_place_result = recipe_result_applied_something(recipe_result, recipe_name, leaf_name, mode,
            visited_technology_names)
    end)
    return found_place_result
end
local function check_recipe_result_applied_something(recipe_name, active_technology_name, mode)
    local recipe_results = recipe_util.get_all_recipe_results(recipe_name, mode)
    _table.each(recipe_results, function(recipe_result)
        local result_used_in_tree_or_surface = recipe_result_applied_something(recipe_result, recipe_name,
            active_technology_name, mode, {})
        if result_used_in_tree_or_surface then return end
        -- пытаемся найти в любых открытых технологиях, если хоть кому-то этот продукт нужен, пусть в других цепях - значит технически это может быть улучшение рецепта
        local all_active_technology_names = tech_util.get_all_active_technology_names(mode)
        _table.each(all_active_technology_names, function(technology_candidate_name)
            if result_used_in_tree_or_surface then return end
            local ingredients = tech_util.get_all_recipe_ingredients_for_specified_technology(technology_candidate_name,
                mode)
            result_used_in_tree_or_surface = _table.contains_f_deep(ingredients, recipe_result)
        end)
        if result_used_in_tree_or_surface then return end
        --если это топливо, то проверяем, является ли категория топлива зарегистрированной хоть у одного сжигателя. Если так - разрешаем использовать результат рецепта
        local recipe_result_prototype = data.raw[recipe_result.type][recipe_result.name]
        local fuel_category_by_name = recipe_result_prototype.type .. "-" .. recipe_result_prototype.name
        local fuel_category_by_category = recipe_result_prototype.fuel_category
        _table.each(data.raw, function(prototype_type_table, prototype_type)
            if result_used_in_tree_or_surface then return end
            _table.each(prototype_type_table, function(prototype)
                if result_used_in_tree_or_surface then return end
                local burner_energy_source = prototype.burner or prototype.energy_source
                if not burner_energy_source then return end
                result_used_in_tree_or_surface = recipe_result.type == "fluid" and burner_energy_source.fluid_box
                    and burner_energy_source.fluid_box.filter == recipe_result.name
                    or recipe_result.type == "item" and
                    (burner_energy_source.fuel_categories and (_table.contains(burner_energy_source.fuel_categories,
                                fuel_category_by_name)
                            or _table.contains(burner_energy_source.fuel_categories,
                                fuel_category_by_category)) or
                        (burner_energy_source.fuel_category and (fuel_category_by_category == burner_energy_source.fuel_category or
                            burner_energy_source.fuel_category == fuel_category_by_name))
                        or string.find(recipe_result_prototype.name, "-fuel-cell", 1, true))
            end)
        end)
        if result_used_in_tree_or_surface then return end
        --если у прототипа есть флаг hidden, то он не будет появляться в инвенторе, но будет результатом работы сборочного автомата по рецепту
        result_used_in_tree_or_surface = recipe_result_prototype.flags and
            _table.contains(recipe_result_prototype.flags, "hidden")
        if result_used_in_tree_or_surface then return end
        -- выводы космических модов
        if mods["SpaceMod"] then result_used_in_tree_or_surface = recipe_result_prototype.subgroup == "spacex" end
        if result_used_in_tree_or_surface then return end
        if mods["SpaceXGAR"] then
            result_used_in_tree_or_surface = string.find(recipe_result_prototype.subgroup,
                "space-exploration-", 1, true)
        end
        if result_used_in_tree_or_surface then return end
        --ядерное оружие
        if mods["True-Nukes"] then
            result_used_in_tree_or_surface = string.find(recipe_result_prototype.name,
                "TN-warhead-", 1, true)
        end
        if result_used_in_tree_or_surface then return end

        --если не нашли ничего - выкидываем ошибку, мы нашли лишний, неиспользуемый результат рецепта, надо удалить бесполезный рецепт или добавить нужный в данной цепочке.
        error("recipe_result " ..
            Utils.dump_to_console(recipe_result) ..
            " don't use in technology tree(AS from root node) or as placeable entity on surfaсe or as placeable in equipment grid equipment or as gun or placeable tile "
            .. " active_technology_name " ..
            active_technology_name .. ", recipe_name " .. recipe_name .. ", for mode " ..
            mode)
    end)
end

local function check_recipe_results_applied_something(active_technology_name, mode)
    local all_technology_recipe_names =
        tech_util.get_all_recipe_names_for_specified_technology(active_technology_name, mode)
    _table.each(
        all_technology_recipe_names,
        function(recipe_name)
            check_recipe_result_applied_something(recipe_name, active_technology_name, mode)
        end
    )
    --
end

local function handle_technology_tree(active_technology_name, mode)
    log("checking technology tree " .. active_technology_name .. " for mode " .. mode)
    local tree = TechnologyTreeUtil.get_technology_tree(active_technology_name, mode)
    check_tree_not_has_hidden_element(active_technology_name, tree, mode)
    check_recipes_not_has_hidden_in_tree_element(active_technology_name, mode)
    check_recipes_not_has_hidden_in_tree(tree, mode)
    local unresolved_in_technology_ingredients = get_unresolved_technology_ingredients(active_technology_name, mode)
    if settings.startup["check-technology-tree-mods-protocol-use-recipe-ingredient-reacheable-validating"].value then
        check_recipe_ingredients_reachable_in_tree(unresolved_in_technology_ingredients, active_technology_name, tree,
            mode)
    end
    if settings.startup["check-technology-tree-mods-protocol-use-recipe-signature-in-machine-automated-validating"].value then
        check_recipe_signatures_allowed_automated(active_technology_name, tree, mode)
    end
    if settings.startup["check-technology-tree-mods-protocol-use-recipe-result-as-ingredient-or-placeable-item-validating"].value then
        check_recipe_results_applied_something(active_technology_name, mode)
    end
    log("technology tree " .. active_technology_name .. " for mode " .. mode .. " checked")
end

TechnologyHandler.handle_technologies = function(mode)
    local all_active_technology_names = tech_util.get_all_active_technology_names(mode)
    local count = _table.size(all_active_technology_names)
    local index = 1
    _table.each(
        all_active_technology_names,
        function(active_technology_name)
            log("handling technology " .. tostring(index) .. " of " .. tostring(count))
            handle_technology_tree(active_technology_name, mode)
            log("technology " .. tostring(index) .. " of " .. tostring(count) .. " handled")
            index = index + 1
        end
    )
end

return TechnologyHandler
