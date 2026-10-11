-- Recipes for hidden/infinity items, only unlocked in Lab
function createLockedRecipeForHiddenItem(name)
    if data.raw.item[name] then
        -- Allows it to show with the ghost cursor
        data.raw.item[name].hidden = false

        -- Allows it to show in the god controller (and ghost cursor)
        data:extend({
            {
                type = "recipe",
                name = BPSB.pfx .. name,
                localised_name = {"entity-name." .. name},
                hidden_in_factoriopedia = true,
                energy_required = 1,
                enabled = false,
                ingredients = {{ type = "item", name = name, amount = 1 }},
                results = {{ type = "item", name = name, amount = 1 }},
                hide_from_signal_gui = true,
            }
        })
    end
end

-- Loaders will only be enabled if nothing else shows them
local shouldEnableLoaders = true
for _, recipe in pairs(data.raw.recipe) do
    if not recipe.hidden then
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
    createLockedRecipeForHiddenItem("turbo-loader")
end

-- Infinity Entities will always be enabled
createLockedRecipeForHiddenItem("heat-interface")
createLockedRecipeForHiddenItem("electric-energy-interface")
createLockedRecipeForHiddenItem("infinity-chest")
createLockedRecipeForHiddenItem("infinity-pipe")
createLockedRecipeForHiddenItem("infinity-cargo-wagon")
