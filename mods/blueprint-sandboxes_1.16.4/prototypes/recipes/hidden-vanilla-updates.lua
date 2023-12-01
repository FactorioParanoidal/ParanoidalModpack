-- Recipes for hidden/infinity items, only unlocked in Lab
function createLockedRecipeForHiddenItem(name)
    if data.raw.item[name] then
        data:extend({
            {
                type = "recipe",
                name = BPSB.pfx .. name,
                energy_required = 1,
                enabled = false,
                ingredients = {},
                result = name,
            }
        })
    end
end

-- Loaders will only be enabled if nothing else shows them
local shouldEnableLoaders = true
for _, recipe in pairs(data.raw.recipe) do
    if not recipe.hidden then
        if recipe.result == "loader" then
            shouldEnableLoaders = false
            break
        end
        if recipe.results then
            for _, result in pairs(recipe.results) do
                if result.name == "loader" then
                    shouldEnableLoaders = false
                    break
                end
            end
        end
    end
end
if shouldEnableLoaders then
    createLockedRecipeForHiddenItem("loader")
    createLockedRecipeForHiddenItem("fast-loader")
    createLockedRecipeForHiddenItem("express-loader")
end

-- Infinity Entities will always be enabled
createLockedRecipeForHiddenItem("electric-energy-interface")
createLockedRecipeForHiddenItem("infinity-chest")
createLockedRecipeForHiddenItem("infinity-pipe")
