local RecipeUtil = {}

local function get_recipe_object_for_mode(recipe_name, mode)
    return Utils.get_moded_object("recipe", recipe_name, mode)
end

local function get_recipe_data_products(recipe_data)
    local result = {}
    if not recipe_data then
        return result
    end
    if recipe_data.result and recipe_data.result ~= "" then
        table.insert(
            result,
            {
                name = recipe_data.result,
                type = "item"
            }
        )
    end
    if recipe_data.results and _table.size(recipe_data.results) > 0 then
        _table.each(
            recipe_data.results,
            function(result_data)
                local result_name = result_data.name or result_data[1]
                if result_name ~= "" then
                    table.insert(
                        result,
                        {
                            name = result_name,
                            type = result_data.type or "item"
                        }
                    )
                end
            end
        )
    end
    -- только в случае когда ничего ранее не указано, иначе есть хоть один продукт
    if _table.size(result) == 0 and recipe_data.main_product and recipe_data.main_product ~= "" then
        table.insert(
            result,
            {
                name = recipe_data.main_product,
                type = "item"
            }
        )
    end
    return result
end

local function create_technology_effect_result_from_rocket_launch_product(rocket_launch_product_data)
    if not rocket_launch_product_data then
        error("rocket launch product not found")
    end
    local rocket_launch_product_data_type = rocket_launch_product_data.type or "item"
    local rocket_launch_product_data_name = rocket_launch_product_data.name or rocket_launch_product_data[1]
    --log("rocket launch result type " .. rocket_launch_product_data_type .. " name " .. rocket_launch_product_data_name)
    return {
        name = rocket_launch_product_data_name,
        type = rocket_launch_product_data_type
    }
end
local function get_rocket_launch_results(result_data)
    local result = {}
    local result_data_item = data.raw[result_data.type][result_data.name]
    if not result_data_item then
        return result
    end
    if result_data_item.rocket_launch_product then
        table.insert(
            result,
            create_technology_effect_result_from_rocket_launch_product(result_data_item.rocket_launch_product)
        )
    end
    if result_data_item.rocket_launch_products and _table.size(result_data_item.rocket_launch_products) > 0 then
        _table.each(
            result_data_item.rocket_launch_products,
            function(rocket_launch_product_data)
                table.insert(result,
                    create_technology_effect_result_from_rocket_launch_product(rocket_launch_product_data))
            end
        )
    end
    return result
end

local function get_burnt_result_results(result_data)
    local result = {}
    local result_data_item = data.raw[result_data.type][result_data.name]
    if not result_data_item then
        return result
    end
    local burnt_result_name = result_data_item.burnt_result
    local burnt_result_type = "item"
    if not burnt_result_name then
        return result
    end
    if not data.raw[burnt_result_type][burnt_result_name] then
        error("data.raw[" .. burnt_result_type .. "][" .. burnt_result_name .. "] as burnt_result not exists!")
    end
    return {
        {
            type = burnt_result_type,
            name = burnt_result_name
        }
    }
end

RecipeUtil.get_all_recipe_results = function(recipe_name, mode, use_only_real_products)
    local result = {}
    local recipe_data = get_recipe_object_for_mode(recipe_name, mode)
    _table.insert_all_if_not_exists(result, get_recipe_data_products(recipe_data))
    local additional_results = {}
    if (not use_only_real_products) then
        _table.each(
            result,
            function(result_data)
                _table.insert_all_if_not_exists(additional_results, get_rocket_launch_results(result_data))
            end
        )
        _table.each(
            result,
            function(result_data)
                _table.insert_all_if_not_exists(additional_results, get_burnt_result_results(result_data))
            end
        )
    end
    _table.insert_all_if_not_exists(result, additional_results)
    return result
end
RecipeUtil.get_rocket_launch_recipe_results = function(recipe_name, mode)
    local result = {}
    local recipe_data = get_recipe_object_for_mode(recipe_name, mode)
    local recipe_basic_results = get_recipe_data_products(recipe_data)
    _table.each(
        recipe_basic_results,
        function(result_data)
            _table.insert_all_if_not_exists(result, get_rocket_launch_results(result_data))
        end
    )
    return result
end

local function get_recipe_data_ingredients(recipe_data)
    local result = {}
    if not recipe_data then
        return result
    end
    if recipe_data.ingredients and _table.size(recipe_data.ingredients) > 0 then
        _table.each(
            recipe_data.ingredients,
            function(result_data)
                local result_name = result_data.name or result_data[1]
                if result_name ~= "" then
                    table.insert(
                        result,
                        {
                            name = result_name,
                            type = result_data.type or "item"
                        }
                    )
                end
            end
        )
    end
    return result
end

RecipeUtil.get_all_recipe_ingredients = function(recipe_name, mode)
    local result = {}
    local recipe_data = get_recipe_object_for_mode(recipe_name, mode)
    _table.insert_all_if_not_exists(result, get_recipe_data_ingredients(recipe_data))
    return result
end

RecipeUtil.add_recipe_ingredient = function(recipe_name, mode, ingredient)
    if
        not ingredient or not ingredient.type or not type(ingredient.type) == "string" or not ingredient.name or
        not type(ingredient.name) == "string" or
        not ingredient.amount or
        not type(ingredient.amount) == "number"
    then
        error("incorrect ingredient " .. Utils.dump_to_console(ingredient))
    end
    local ingredient_prototype = data.raw[ingredient.type][ingredient.name]
    if not ingredient_prototype then
        error("ingredient with type " .. ingredient.type .. " called " .. ingredient.name .. " not found")
    end
    if not recipe_name or not type(recipe_name) == "string" then
        error("recipe_name is wrong")
    end

    local moded_recipe = Utils.get_moded_object("recipe", recipe_name, mode)
    if not moded_recipe.ingredients then
        moded_recipe.ingredients = {}
    end
    table.insert(moded_recipe.ingredients, ingredient)
end
RecipeUtil.add_recipe_ingredients = function(recipe_name, mode, ingredients)
    if not ingredients or not type(ingredients) == "table" then
        error("incorrect ingredients!")
    end
    _table.each(
        ingredients,
        function(ingredient)
            RecipeUtil.add_recipe_ingredient(recipe_name, mode, ingredient)
        end
    )
end
RecipeUtil.remove_recipe_ingredient = function(recipe_name, mode, ingredient)
    if
        not ingredient or not ingredient.type or not type(ingredient.type) == "string" or not ingredient.name or
        not type(ingredient.name) == "string"
    then
        error("incorrect ingredient " .. Utils.dump_to_console(ingredient))
    end
    local ingredient_prototype = data.raw[ingredient.type][ingredient.name]
    if not ingredient_prototype then
        error("ingredient with type " .. ingredient.type .. " called " .. ingredient.name .. " not found")
    end
    if not recipe_name or not type(recipe_name) == "string" then
        error("recipe_name has wrong type ")
    end
    local moded_recipe = Utils.get_moded_object("recipe", recipe_name, mode)
    if not moded_recipe.ingredients then
        error("ingredients table for " .. recipe_name .. ", mode " .. mode .. " not exists!")
    end
    _table.remove_item(
        moded_recipe.ingredients,
        ingredient,
        function(table_item, item_to_remove)
            local table_item_type = table_item.type or "item"
            local item_to_remove_type = item_to_remove.type
            local table_item_name = table_item.name or table_item[1]
            local item_to_remove_name = item_to_remove.name or item_to_remove[1]
            return table_item_type == item_to_remove_type and table_item_name == item_to_remove_name
        end,
        false
    )
end
RecipeUtil.remove_recipe_ingredients = function(recipe_name, mode, ingredients)
    if not ingredients or not type(ingredients) == "table" then
        error("incorrect ingredients!")
    end
    _table.each(
        ingredients,
        function(ingredient)
            RecipeUtil.remove_recipe_ingredient(recipe_name, mode, ingredient)
        end
    )
end

RecipeUtil.get_recipe_category = function(recipe_name)
    return data.raw["recipe"][recipe_name].category or "crafting"
end

RecipeUtil.get_recipe_signature = function(recipe_name, mode)
    local ingredients = RecipeUtil.get_all_recipe_ingredients(recipe_name, mode)
    local recipe_results = RecipeUtil.get_all_recipe_results(recipe_name, mode, true)
    log("recipe_results " .. Utils.dump_to_console(recipe_results))
    return {
        ingredients = {
            solid = _table.size(
                _table.filter(
                    ingredients,
                    function(ingredient)
                        return ingredient.type == "item"
                    end
                )
            ),
            fluid = _table.size(
                _table.filter(
                    ingredients,
                    function(ingredient)
                        return ingredient.type == "fluid"
                    end
                )
            )
        },
        results = {
            solid = _table.size(
                _table.filter(
                    recipe_results,
                    function(recipe_result)
                        return recipe_result.type == "item"
                    end
                )
            ),
            fluid = _table.size(
                _table.filter(
                    recipe_results,
                    function(recipe_result)
                        return recipe_result.type == "fluid"
                    end
                )
            )
        },
        category = RecipeUtil.get_recipe_category(recipe_name),
        name = recipe_name
    }
end

return RecipeUtil
