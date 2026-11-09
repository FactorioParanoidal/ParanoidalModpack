local rro = Muluna.rro
local dual_icon = require("lib.dual-item-icon").dual_icon
local greenhouse_entity = table.deepcopy(data.raw["assembling-machine"]["muluna-greenhouse-wood"])
local greenhouse_recipe = table.deepcopy(data.raw["recipe"]["muluna-greenhouse-wood"])
local greenhouse_item = table.deepcopy(data.raw["item"]["muluna-greenhouse-wood"])
local recipes = {table.deepcopy(data.raw["recipe"]["muluna-tree-growth-greenhouse-vulcanus"]),
                 table.deepcopy(data.raw["recipe"]["muluna-tree-growth-greenhouse-water-saving-vulcanus"])}

local new_tech = data.raw["technology"]["muluna-gleba-greenhouses"]

local possible_plant_list = {
    ["yumako-tree"] = "yumako",
    jellystem = "jellynut",
    --["coralmium-cluster"] = "coralmium", --I'd like to eventually add support for more plants, but I don't understand the nuances of these modded plants at this time.
    -- ["boompuff-plant"] = "boompuff-spore",
    -- ["demolisher-pupae"] = 
} 



local plant_list = {}

for plant,fruit in pairs(possible_plant_list) do
    if data.raw["plant"][plant] then
        plant_list[plant] = fruit
    end
end
local j = 0
for plant,fruit in pairs(plant_list) do
    j = j + 1
    local recipe_category = {
            type = "recipe-category",
            name = "muluna-greenhouse-".. fruit,
        }
    local new_greenhouse_entity = rro.merge(greenhouse_entity,
        {
            name = "muluna-greenhouse-" .. fruit,
            --name = string.gsub(greenhouse_entity.name,"wood",fruit)
             crafting_categories = {recipe_category.name},
             icons = {
                {
                    icon = "__muluna-graphics__/graphics/greenhouse/sprites/greenhouse-icon.png",
                    icon_size = 64,
                },
                {
                    icon = data.raw["capsule"][fruit].icon or nil,
                    icon_size = data.raw["capsule"][fruit].icon_size or nil,
                    scale = 0.25,
                    shift = {10,-10},
                    draw_background = true,
                }
            },
            order = greenhouse_entity.order and greenhouse_entity.order .. tostring(j) or nil
        }
        )
    rro.deep_replace(new_greenhouse_entity,greenhouse_entity.name,"muluna-greenhouse-" .. fruit)
    local new_greenhouse_item = rro.merge(greenhouse_item, 
        {
            name = new_greenhouse_entity.name,
            
            place_result = new_greenhouse_entity.name,

            icons = new_greenhouse_entity.icons,
            order = greenhouse_item.order and greenhouse_item.order .. tostring(j) or nil
        }
    )
    
    rro.deep_replace(new_greenhouse_item,greenhouse_item.name,"muluna-greenhouse-" .. fruit)

    local new_greenhouse_recipe = rro.merge(greenhouse_recipe,
        {
           icons = new_greenhouse_entity.icons,
           order = greenhouse_recipe.order and greenhouse_recipe.order .. tostring(j) or nil
        }
        )

    local new_plant_item = rro.merge(table.deepcopy(data.raw["capsule"][fruit]) ,
    {
        name = fruit .. "-seedless",
        localised_name = {"item-name.seedless-x",{"item-name."..fruit}},
    }

        
        
    )

    local new_processing_recipe = rro.merge(table.deepcopy(data.raw["recipe"][fruit .. "-processing"]) ,
        {
            name = fruit .. "-processing" .. "-seedless",
            localised_name = {"recipe-name.seedless-x-processing",{"item-name."..fruit}},
        }
        

    )
    new_processing_recipe.ingredients[1].name = new_plant_item.name
    rro.remove(new_processing_recipe.results,{type = "item", name = fruit .. "-seed" , amount = "_any", independent_probability = "_any"})
    rro.soft_insert(new_tech.effects, {
            type = "unlock-recipe",
            recipe = new_processing_recipe.name
        })

    rro.deep_replace(new_greenhouse_recipe,new_greenhouse_recipe.name,"muluna-greenhouse-" .. fruit)
    rro.replace(new_greenhouse_recipe.ingredients,{type = "item", name = "muluna-sapling",amount = "_any",quality_max="normal"},{type = "item",quality_max="normal", name = fruit .. "-seed" ,amount = function(other) return 1 * other end})
    rro.replace(new_greenhouse_recipe.ingredients,{type = "item", name = "landfill",amount = "_any"},{type = "item", name = "overgrowth-" .. fruit .. "-soil" ,amount = function(other) return other end})
    rro.soft_insert(new_tech.effects, {
            type = "unlock-recipe",
            recipe = new_greenhouse_recipe.name
        })
    for i,recipe in ipairs(recipes) do
        local third_icon = (string.find(recipe.name,"water%-saving") ~= nil and "water") or "carbon-dioxide"
        
        local new_recipe = rro.merge(recipe, 
            {
                -- name = recipe.name == "muluna-tree-growth-greenhouse-vulcanus" and "muluna-greenhouse-growth-" .. fruit
                --     or recipe.name == "muluna-greenhouse-water-saving-vulcanus" and "muluna-greenhouse-growth-water-saving" .. fruit,
                icons = dual_icon(fruit,"fluoroketone-cold",third_icon),
                categories = {recipe_category.name}
            }
        )
        if i == 1 then
            new_recipe.name = "muluna-greenhouse-growth-" .. fruit
        elseif i == 2 then
            new_recipe.name = "muluna-greenhouse-growth-water-saving-" .. fruit
        end
        new_recipe.order = "zzz-" .. tostring(j)
        rro.replace(new_recipe.ingredients,{type = "item", name = "tree-seed",amount = "_any"},{type = "item", name = fruit .. "-seed",amount = function(other) return other end})
        rro.replace(new_recipe.results,{type = "item", name = "muluna-sapling",amount = "_any"},{type = "item", name = new_plant_item.name ,amount = function(other) return 25 * other end})
        -- Seedless fruit spoils, so without this it inherits the freshness of the nutrients in the
        -- recipe and each generation comes out worse than the last.
        for _,result in pairs(new_recipe.results) do
            if result.type == "item" and result.name == new_plant_item.name then
                result.reset_freshness_on_craft = true
            end
        end

        rro.soft_insert(new_tech.effects, {
            type = "unlock-recipe",
            recipe = new_recipe.name
        })
        Muluna:extend{new_recipe}
    end
    Muluna:extend{recipe_category,new_greenhouse_entity,new_greenhouse_item,new_greenhouse_recipe,new_plant_item,new_processing_recipe}
end