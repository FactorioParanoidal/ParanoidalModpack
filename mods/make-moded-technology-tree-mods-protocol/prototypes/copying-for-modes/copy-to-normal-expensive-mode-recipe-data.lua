local recipe_data_field_names = {
    "ingredients",
    "results",
    --simples
    "result",
    "result_count",
    "main_product",
    "energy_required",
    "emissions_multiplier",
    "requester_paste_multiplier",
    "overload_multiplier",
    "allow_inserter_overload",
    "enabled",
    "hidden",
    "hide_from_stats",
    "hide_from_player_crafting",
    "allow_decomposition",
    "allow_as_intermediate",
    "allow_intermediates",
    "always_show_made_in",
    "show_amount_in_title",
    "always_show_products",
    "unlock_results",
}

local recipe_data_field_simple_names = {
    "result",
    "result_count",
    "main_product",
    "energy_required",
    "emissions_multiplier",
    "requester_paste_multiplier",
    "overload_multiplier",
    "allow_inserter_overload",
    "enabled",
    "hidden",
    "hide_from_stats",
    "hide_from_player_crafting",
    "allow_decomposition",
    "allow_as_intermediate",
    "allow_intermediates",
    "always_show_made_in",
    "show_amount_in_title",
    "always_show_products",
    "unlock_results",
}
local function merge_recipe_data_and_general_data(for_merging_recipe_data_mode, recipe_data_general)
    _table.each(recipe_data_field_names, function(recipe_data_field_name)
        if not recipe_data_general[recipe_data_field_name] then
            return
        end
        if _table.contains(recipe_data_field_simple_names, recipe_data_field_name) then
            for_merging_recipe_data_mode[recipe_data_field_name] = recipe_data_general[recipe_data_field_name]
            return
        end

        if not for_merging_recipe_data_mode[recipe_data_field_name] then
            for_merging_recipe_data_mode[recipe_data_field_name] = recipe_data_general[recipe_data_field_name]
            return
        end
        if not for_merging_recipe_data_mode[recipe_data_field_name] or not recipe_data_general[recipe_data_field_name] then
            return
        end
        _table.insert_all_if_not_exists_with_compare(
            for_merging_recipe_data_mode[recipe_data_field_name],
            recipe_data_general[recipe_data_field_name],
            function(__table, o2)
                local o2name = o2.name or o2[1]
                local o2type = o2.type or "item"
                local found = true

                _table.each(
                    __table,
                    function(item)
                        local o1name = item.name or item[1]
                        local o1type = item.type or "item"
                        if not found then
                            found = (o1name == o2name) and (o1type == o2type)
                        end
                    end
                )
                -- возвращает правду, если не найдено точное совпадение
                return not found
            end)
    end)
end
local function create_recipe_data_from_general_recipe_data(recipe)
    local result = {}
    _table.each(recipe_data_field_names, function(recipe_data_field_name)
        if recipe[recipe_data_field_name] and type(recipe[recipe_data_field_name]) == "table" then
            result[recipe_data_field_name] = _table.deep_copy(recipe[recipe_data_field_name])
        else
            result[recipe_data_field_name] = recipe[recipe_data_field_name]
        end
    end)
    return result
end
function merge_recipe_for_modes(recipe, mode)
    local recipe_data = create_recipe_data_from_general_recipe_data(recipe)
    if not recipe[mode] then
        recipe[mode] = recipe_data
        return
    end
    local for_merging_recipe_data = recipe[mode]
    merge_recipe_data_and_general_data(for_merging_recipe_data, recipe_data)
end

-- сначала сливаем 2 режима
_table.each(GAME_MODES, function(mode)
    _table.each(data.raw["recipe"], function(recipe)
        merge_recipe_for_modes(recipe, mode)
        --    log("after merge recipe " .. recipe.name .. Utils.dump_to_console(recipe) .. " for mode " .. mode)
    end)
end)
local function clear_general_recipe_data(recipe)
    _table.each(recipe_data_field_names, function(technology_data_field_name)
        recipe[technology_data_field_name] = nil
    end)
end
--затем отдельно убираем общее между режимами без указания режима
_table.each(data.raw["recipe"], function(recipe)
    clear_general_recipe_data(recipe)
end)
