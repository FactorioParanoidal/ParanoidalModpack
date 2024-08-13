local tech_util = require("__automated-utility-protocol__.util.technology-util")
local recipe_util = require("__automated-utility-protocol__.util.recipe-util")

local function create_resource_detected_technologies_and_add_it_to_normal_technology_prerequisities_by_recipe_name(mode)
    local resource_recipes = create_resource_recipes()
    local active_technology_names = tech_util.get_all_active_technology_names(mode)
    _table.each(resource_recipes, function(resource_recipe)
        local resource_recipe_name = resource_recipe.name
        local results = recipe_util.get_all_recipe_results(resource_recipe_name, mode)
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
                tech_util.get_all_recipe_ingredients_for_specified_technology(active_technology_name, mode)
            if _table.contains_f_deep(recipe_ingredients, recipe_result) then
                tech_util.add_recipe_effect_to_technology(active_technology_name, resource_recipe_name, mode)
                tech_util.add_prerequisites_to_technology(active_technology_name, { resource_detected_technology.name },
                    mode)
            end
        end)
    end)
end
if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
    _table.each(GAME_MODES, function(mode)
        create_resource_detected_technologies_and_add_it_to_normal_technology_prerequisities_by_recipe_name(mode)
    end)
end
