local rro = Muluna.rro

for _, category in pairs({"item", "tool"}) do
    if data.raw[category] then
        for name, prototype in pairs(data.raw[category]) do
            if prototype.data_capacity ~= nil then
                local data_cell = table.deepcopy(prototype)
                data_cell.name = name .. "-astronomical-data"
                data_cell.data_capacity = nil
                data_cell.localised_name = {"item-name.muluna-databank-filled",{"item-name."..name}}
                data_cell.icons = {
                    {
                        icon = prototype.icon,
                        icon_size = prototype.icon_size,
                        scale = 0.5,
                    },
                    {
                        icon = data.raw["fluid"]["muluna-astronomical-data"].icon,
                        icon_size = data.raw["fluid"]["muluna-astronomical-data"].icon_size,
                        scale = 0.4,
                        --shift = {0,-4},
                    }
                }
                data_cell.icon = nil

                local recipe = {
                    type = "recipe",
                    name = data_cell.name,
                    localised_name = data_cell.localised_name,
                    categories = {"crafting-with-fluid-and-data"},
                    enabled = false,
                    ingredients = { 
                        {type = "item",name = prototype.name, amount = 1,ignored_by_stats = 1},
                        {type = "fluid", name = "muluna-astronomical-data", amount = prototype.data_capacity, fluidbox_index = 30,ignored_by_stats = prototype.data_capacity,ignored_by_productivity=prototype.data_capacity},
                    },
                    results = {{type = "item" , name = data_cell.name, amount = 1, fluidbox_index = 30,ignored_by_stats = 1,ignored_by_productivity=1}},
                    main_product = data_cell.name,
                    energy_required = 5,
                    allow_quality = false,
                    requires_ingredients_to_unlock_results = true,
                    
                }

                local recipe_empty = {
                    type = "recipe",
                    name = recipe.name .. "-empty",
                    localised_name = {"recipe-name.muluna-load-data-from-X",{"item-name."..name}},
                    categories = {"crafting-with-fluid-and-data"},
                    subgroup = "muluna-telescope",
                    order = data_cell.order .. "a",
                    enabled = false,
                    ingredients = recipe.results,
                    results = recipe.ingredients,
                    energy_required = 5,
                    icons = Muluna.icons.dual_icon("muluna-astronomical-data",prototype.name),
                    auto_recycle = false,
                    allow_quality = false,
                    requires_ingredients_to_unlock_results = true,
                }

                for _,recipe in pairs({recipe,recipe_empty}) do
                    rro.soft_insert(data.raw["technology"]["muluna-telescope"].effects , 
                    
                    {
                        type = "unlock-recipe",
                        recipe = recipe.name
                    }
                    )
                end

                Muluna:extend{data_cell,recipe,recipe_empty}


                

                
            end
        end
    end
end






local am3 = data.raw["assembling-machine"]["assembling-machine-3"]

