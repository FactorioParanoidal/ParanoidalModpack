local function get_minable_datas()
    local result = {}
    _table.each(data.raw["resource"], function(prototype)
        local prototype_name = prototype.name
        if string.find(prototype_name, "infinite-", 1, true) then
            return
        end
        if not prototype.minable then
            return
        end
        --log("resource prototype data " .. Utils.dump_to_console(prototype.minable))
        if prototype.minable.results then
            _table.each(prototype.minable.results, function(minable_result)
                table.insert(result, {
                    type = minable_result.type,
                    name = minable_result.name or minable_result[1],
                    required_fluid = prototype.minable.required_fluid,
                    amount = prototype.minable.fluid_amount,
                })
                --log("prototype " .. Utils.dump_to_console(prototype))
            end)
        end
    end)
    _table.insert_all_if_not_exists(result, {
        -- сады разных зон
        { type = "item", name = "swamp-garden" },
        { type = "item", name = "desert-garden" },
        { type = "item", name = "temperate-garden" },
        -- деревья различных зон
        { type = "item", name = "temperate-tree" },
        { type = "item", name = "swamp-tree" },
        { type = "item", name = "desert-tree" },
        { type = "item", name = "temperate-1" },
        { type = "item", name = "temperate-2" },
        { type = "item", name = "temperate-3" },
        { type = "item", name = "temperate-4" },
        { type = "item", name = "temperate-5" },
        { type = "item", name = "swamp-1" },
        { type = "item", name = "swamp-2" },
        { type = "item", name = "swamp-3" },
        { type = "item", name = "swamp-4" },
        { type = "item", name = "swamp-5" },
        { type = "item", name = "desert-1" },
        { type = "item", name = "desert-2" },
        { type = "item", name = "desert-3" },
        { type = "item", name = "desert-4" },
        { type = "item", name = "desert-5" },
        -- инопланетные артефакты
        { type = "item", name = "small-alien-artifact" },
        { type = "item", name = "small-alien-artifact-red" },
        { type = "item", name = "small-alien-artifact-orange" },
        { type = "item", name = "small-alien-artifact-yellow" },
        { type = "item", name = "small-alien-artifact-green" },
        { type = "item", name = "small-alien-artifact-blue" },
        { type = "item", name = "small-alien-artifact-purple" },
        -- фугу
        { type = "item", name = "bio-puffer-egg-1" },
        { type = "item", name = "bio-puffer-egg-2" },
        { type = "item", name = "bio-puffer-egg-3" },
        { type = "item", name = "bio-puffer-egg-4" },
        { type = "item", name = "bio-puffer-egg-5" },
        --рыбы
        --[[ { type = "capsule", name = "raw-fish" },
        { type = "capsule", name = "alien-fish-1-raw" },
        { type = "capsule", name = "alien-fish-2-raw" },
        { type = "capsule", name = "alien-fish-3-raw" }]]
    })
    return result
end

function get_basic_fluid_names()
    return _table.map(
        _table.filter(get_minable_datas(), function(minable_data)
            return minable_data.type and minable_data.type == "fluid"
        end),
        function(minable_data)
            return minable_data.name
        end
    )
end

function create_basic_resource_recipe(basic_data, suffix)
    local resource_type = basic_data.type
    local resource_name = basic_data.name
    local resource_recipe_name = resource_name .. "-" .. suffix
    --log("creating basic recipe " .. resource_recipe_name)
    --log("resource data " .. Utils.dump_to_console(basic_data))
    local resource_item_prototype = data.raw[resource_type][resource_name]
    local recipe_data = {
        results = {
            {
                type = resource_type,
                name = resource_name,
                amount = 1,
            },
        },
        ingredients = {},
        enabled = false,
        always_show_made_in = false,
        always_show_products = true,
        allow_intermediates = false,
        allow_as_intermediate = false,
        allow_decomposition = false,
        allow_inserter_overload = false,
    }
    local recipe = {
        type = "recipe",
        name = resource_recipe_name,
        icons = resource_item_prototype.icons,
        icon = resource_item_prototype.icon,
        icon_size = resource_item_prototype.icon_size,

        normal = recipe_data,
        expensive = recipe_data,
    }
    if resource_type == "fluid" then
        recipe.category = "crafting-with-fluid"
    end
    if basic_data.required_fluid then
        recipe.category = "crafting-with-fluid"
        recipe.normal.ingredients = { { type = "fluid", name = basic_data.required_fluid, amount = basic_data.amount } }
        recipe.expensive.ingredients =
        { { type = "fluid", name = basic_data.required_fluid, amount = basic_data.amount } }
    end
    data:extend({
        recipe,
    })
    --log("basic recipe " .. resource_recipe_name .. " created")

    return recipe
end

function create_resource_recipes()
    local minable_datas = get_minable_datas()
    local result = {}
    _table.each(minable_datas, function(minable_data)
        table.insert(result, create_basic_resource_recipe(minable_data, "minable"))
    end)
    return result
end

function create_water_recipe()
    return create_basic_resource_recipe({ type = "fluid", name = "water" }, "minable")
end

function create_coal_recipe()
    return create_basic_resource_recipe({ type = "item", name = "coal" }, "minable")
end

function create_wood_recipe()
    return create_basic_resource_recipe({ type = "item", name = "wood" }, "minable")
end

function create_stone_recipe()
    return create_basic_resource_recipe({ type = "item", name = "stone" }, "minable")
end
