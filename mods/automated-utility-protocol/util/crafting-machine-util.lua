require("__automated-utility-protocol__.util.main")
local tech_util = require("__automated-utility-protocol__.util.technology-util")
local CraftingMachineUtil = {}
local function is_appropriate_cratfing_machine_signature_for_recipe_signature(
    crafting_machine_signature,
    recipe_signature)
    return crafting_machine_signature and recipe_signature and crafting_machine_signature.ingredients and
        recipe_signature.ingredients and
        crafting_machine_signature.results and
        recipe_signature.results and
        crafting_machine_signature.crafting_categories and
        recipe_signature.category and
        _table.contains(crafting_machine_signature.crafting_categories, recipe_signature.category) and
        (recipe_signature.name and crafting_machine_signature.fixed_recipe and
            crafting_machine_signature.fixed_recipe == recipe_signature.name or
            crafting_machine_signature.ingredients.solid >= recipe_signature.ingredients.solid and
                crafting_machine_signature.ingredients.fluid >= recipe_signature.ingredients.fluid and
                crafting_machine_signature.results.solid >= recipe_signature.results.solid and
                crafting_machine_signature.results.fluid >= recipe_signature.results.fluid)
end

local function create_crafting_signature(
    crafting_machine_candidate,
    crafting_machine_candidate_max_ingredients_count,
    crafting_machine_candidate_max_results_count)
    local machine_solid_ingredients_count = crafting_machine_candidate_max_ingredients_count or 0
    local machine_solid_result_count = crafting_machine_candidate_max_results_count or 255 --пусть по умолчанию будет 255 выходов(нигде не указано обратное)
    local fluid_boxes = crafting_machine_candidate.fluid_boxes or {}
    return {
        ingredients = {
            solid = machine_solid_ingredients_count,
            fluid = _table.size(
                _table.filter(
                    fluid_boxes,
                    function(fluid_box)
                        return type(fluid_box) == "table" and fluid_box.production_type and
                            (fluid_box.production_type == "input" or fluid_box.production_type == "input-output")
                    end
                )
            )
        },
        results = {
            solid = machine_solid_result_count,
            fluid = _table.size(
                _table.filter(
                    fluid_boxes,
                    function(fluid_box)
                        return type(fluid_box) == "table" and fluid_box.production_type and
                            (fluid_box.production_type == "output" or fluid_box.production_type == "input-output")
                    end
                )
            )
        },
        crafting_categories = crafting_machine_candidate.crafting_categories,
        fixed_recipe = crafting_machine_candidate.fixed_recipe,
        machine = {
            name = crafting_machine_candidate.name,
            type = crafting_machine_candidate.type
        }
    }
end
local function handle_assembling_machines(recipe_results, recipe_signature_result_solid)
    local result = {}
    _table.each(
        recipe_results,
        function(recipe_result)
            local assembling_machine_prototype_candidate = data.raw["assembling-machine"][recipe_result.name]
            if not assembling_machine_prototype_candidate then
                return
            end
            local assembling_machine_signature =
                create_crafting_signature(
                assembling_machine_prototype_candidate,
                assembling_machine_prototype_candidate.ingredient_count or 255,
                recipe_signature_result_solid
            )
            if assembling_machine_signature then
                table.insert(result, assembling_machine_signature)
            end
        end
    )
    return result
end

local function handle_furnaces(recipe_results)
    local result = {}
    _table.each(
        recipe_results,
        function(recipe_result)
            local furnace_prototype_candidate = data.raw["furnace"][recipe_result.name]
            if not furnace_prototype_candidate then
                return
            end
            local furnace_signature =
                create_crafting_signature(
                furnace_prototype_candidate,
                furnace_prototype_candidate.source_inventory_size,
                furnace_prototype_candidate.result_inventory_size
            )
            if furnace_signature then
                table.insert(result, furnace_signature)
            end
        end
    )
    return result
end

local function handle_rocket_silos(recipe_results)
    local result = {}
    _table.each(
        recipe_results,
        function(recipe_result)
            local rocket_silo_prototype_candidate = data.raw["rocket-silo"][recipe_result.name]
            if not rocket_silo_prototype_candidate then
                return
            end
            local rocket_silo_signature =
                create_crafting_signature(
                rocket_silo_prototype_candidate,
                rocket_silo_prototype_candidate.ingredient_count or 255,
                rocket_silo_prototype_candidate.rocket_result_inventory_size
            )
            if rocket_silo_signature then
                table.insert(result, rocket_silo_signature)
            end
        end
    )
    return result
end
CraftingMachineUtil.get_crafting_machines_in_technology = function(
    active_technology_name,
    mode,
    recipe_signature_result_solid)
    if not recipe_signature_result_solid then
        error("recipe_signature_result_solid")
    end
    local recipe_results = tech_util.get_all_recipe_results_for_specified_technology(active_technology_name, mode)
    --log("recipe_results " .. Utils.dump_to_console(recipe_results))
    local result = {}
    _table.insert_all_if_not_exists(result, handle_assembling_machines(recipe_results, recipe_signature_result_solid))
    _table.insert_all_if_not_exists(result, handle_furnaces(recipe_results))
    _table.insert_all_if_not_exists(result, handle_rocket_silos(recipe_results))
    _table.each(
        result,
        function(signature)
            signature.technology_name = active_technology_name
        end
    )
    return result
end
CraftingMachineUtil.get_crafting_machines_in_technology_tree = function(
    active_technology_name,
    tree,
    mode,
    recipe_signature_result_solid)
    local result =
        CraftingMachineUtil.get_crafting_machines_in_technology(
        active_technology_name,
        mode,
        recipe_signature_result_solid
    )
    _table.each(
        tree,
        function(tree_element_table, tree_element_table_name)
            _table.insert_all_if_not_exists(
                result,
                CraftingMachineUtil.get_crafting_machines_in_technology(
                    tree_element_table_name,
                    mode,
                    recipe_signature_result_solid
                )
            )
            _table.each(
                tree_element_table,
                function(tree_element_name)
                    _table.insert_all_if_not_exists(
                        result,
                        CraftingMachineUtil.get_crafting_machines_in_technology(
                            tree_element_name,
                            mode,
                            recipe_signature_result_solid
                        )
                    )
                end
            )
        end
    )
    return result
end
CraftingMachineUtil.has_one_crafting_machine_in_technology_tree_by_recipe_signature = function(
    recipe_signature,
    active_technology_name,
    tree,
    mode)
    return _table.size(
        _table.filter(
            CraftingMachineUtil.get_crafting_machines_in_technology_tree(
                active_technology_name,
                tree,
                mode,
                recipe_signature.results.solid
            ),
            function(crafting_machine_signature)
                return is_appropriate_cratfing_machine_signature_for_recipe_signature(
                    crafting_machine_signature,
                    recipe_signature
                )
            end
        )
    ) > 0
end
return CraftingMachineUtil
