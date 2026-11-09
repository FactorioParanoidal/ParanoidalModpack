local rro = Muluna.rro
local dual_icon = require("lib.dual-item-icon").dual_icon
local old_metal = "copper"
local new_metal = "aluminum"
local function replace_metal(old_string)
    local new_string = old_string
    
    new_string = string.gsub(new_string,old_metal,new_metal,1)
    if new_string == "crushed-aluminum-ore" then new_string = "alumina-crushed" end
    if new_string == "ei-enriched-aluminum-ore" then new_string = "alumina-crushed" end
    if new_string == "aluminum-ore" then new_string = "alumina" end
    if new_string == "aluminum-cable" then new_string = "copper-cable" end
    return new_string
end

local function melting_icon(metal,ore)

    return {
        
        {
            icon = data.raw["item"]["calcite"].icon,
            icon_size=64,
            scale = 0.25,
            shift = {8,-8},
            draw_background = true
        },
        {
            icon = ore,
            icon_size=64,
            scale = 0.25,
            shift = {-8,-8},
            draw_background = true
        },
        {
            icon = metal,
            scale = 0.45,
            shift = {-2,3},
            draw_background = true
        },
    }

end

local old_recipes = 

{
    "copper-ore-melting",
    "casting-copper",
    "casting-copper-cable",
    "casting-low-density-structure"
}

for _,recipe_name in pairs(old_recipes) do
    local recipe = nil
    if data.raw["recipe"][recipe_name] then
        recipe = data.raw["recipe"][recipe_name]
    end
    assert(data.raw["recipe"][recipe_name],recipe)
    if rro.contains(recipe.categories,"metallurgy") then
        local new_recipe = table.deepcopy(recipe)
        new_recipe.hide_from_signal_gui = false
        if string.find(new_recipe.name, old_metal) then
            new_recipe.name = replace_metal(new_recipe.name)
        else
            new_recipe.name = new_recipe.name .. "-" .. new_metal
        end

        for _,ingredient in pairs(new_recipe.ingredients) do
            ingredient.name = replace_metal(ingredient.name)
        end
        if new_recipe.results then
            for _,product in pairs(new_recipe.results) do
                product.name = replace_metal(product.name)
            end
        end
        if new_recipe.main_product then
            new_recipe.main_product = replace_metal(new_recipe.main_product)
        end
        
        if not rro.deep_equals(recipe,new_recipe) then
            Muluna:extend{new_recipe}
            table.insert(data.raw["technology"]["foundry"].effects,
                {
                    type = "unlock-recipe",
                    recipe = new_recipe.name
                }
                )
            else
        end
    end

    
        
end

if data.raw["fluid"]["molten-copper"] then
            local new_fluid = table.deepcopy(data.raw["fluid"]["molten-copper"])
            if string.find(new_fluid.name,old_metal) then
                new_fluid.name = replace_metal(new_fluid.name)
            else
                new_fluid.name = "molten-aluminum"
            end
            Muluna:extend{new_fluid}
        end

data.raw["fluid"]["molten-aluminum"].icon = "__muluna-graphics__/graphics/icons/molten-aluminum.png"
data.raw["fluid"]["molten-aluminum"].order = "b[new-fluid]-b[vulcanus]-ba[molten-aluminum]"
data.raw["recipe"]["casting-aluminum"].order = "b[casting]-ba[casting-aluminum]"
data.raw["recipe"]["casting-low-density-structure-aluminum"].order = "b[casting]-fa[low-density-structure]"
data.raw["recipe"]["casting-aluminum-cable"].order = "b[casting]-ha[casting-aluminum-cable]"
table.insert(data.raw["recipe"]["aluminum-ore-melting"].results,{type = "fluid", name = "oxygen", amount = 750})
data.raw["fluid"]["molten-aluminum"].base_color = {0.7,0.7,0.7}
data.raw["fluid"]["molten-aluminum"].flow_color = {0.7,0.7,0.7}
data.raw["recipe"]["aluminum-ore-melting"].icons = melting_icon(data.raw["fluid"]["molten-aluminum"].icon,data.raw["item"]["alumina"].icon)
data.raw["recipe"]["aluminum-ore-melting"].localised_name = {"recipe-name.molten-aluminum"}
data.raw["recipe"]["aluminum-ore-melting"].order = "b[new-fluid]-b[vulcanus]-ba[molten-aluminum]"
data.raw["recipe"]["casting-aluminum-cable"].icons = dual_icon("copper-cable","molten-aluminum") --{

    -- {
    --     icon = data.raw["fluid"]["molten-aluminum"].icon,
    --     icon_size = data.raw["fluid"]["molten-aluminum"].icon_size,
    -- },
    -- {
    --     icon = data.raw["fluid"]["copper-cable"].icon,
    --     icon_size = data.raw["fluid"]["copper-cable"].icon_size,
    --     scale = 0.25,
    --     shift = {10,-10},
    -- }
--}

data.raw["recipe"]["casting-aluminum"].icons = dual_icon("aluminum-plate","molten-aluminum")
data.raw["recipe"]["casting-low-density-structure-aluminum"].icons = dual_icon("low-density-structure","molten-aluminum","molten-iron")

if data.raw["technology"]["low-density-structure-productivity"] then
    rro.soft_insert(data.raw["technology"]["low-density-structure-productivity"].effects,{type="change-recipe-productivity",recipe="casting-low-density-structure-aluminum",change=0.1})
end
