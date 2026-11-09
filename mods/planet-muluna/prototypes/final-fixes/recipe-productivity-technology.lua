local rro = require("lib.remove-replace-object")
for _,tech in pairs(data.raw["technology"]) do
    if tech.muluna_recipe_productivity_effects then
        local new_effects = {}
        if not tech.effects then tech.effects = {} end
        if tech.muluna_recipe_productivity_effects.purge_other_effects then
            for _,effect in pairs(tech.effects) do
                if effect.muluna_force_include then
                    table.insert(new_effects,effect)
                end
            end
        else
            new_effects = tech.effects
        end
        
        

        for _,effect in pairs(tech.muluna_recipe_productivity_effects.effects) do
            local type = effect.type
            local name = effect.name
            local change = effect.change
            for _,recipe in pairs(data.raw["recipe"]) do
                if recipe.results and (#recipe.results == 1 or effect.allow_multiple_results) then
                    for _,result in pairs(recipe.results) do
                        if result.type == type and result.name == name then
                            local new_effect = {
                                type = "change-recipe-productivity",
                                recipe = recipe.name,
                                change = change,
                                hidden = effect.hidden,
                                use_icon_overlay_constant = effect.use_icon_overlay_constant,
                                icons = effect.icons,
                                icon = effect.icon,
                                icon_size = effect.icon_size,
                            }
                            rro.soft_insert(new_effects,new_effect)
                        end
                    end
                end
            end
            tech.effects = new_effects

        end
        tech.muluna_recipe_producitivity_effects = nil
    end
end