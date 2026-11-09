local productivity_list = --Full list of recipe productivity technologies with one output in vanilla Space Age 2.0.
{
    --"asteroid-productivity",
    "low-density-structure",
    "plastic-bar",
    "processing-unit",
    "rocket-fuel",
    "rocket-part",
    --"scrap-recycling-productivity", 
    "steel-plate",
}

if settings.startup["PlanetsLib-update-vanilla-recipe-productivity-techs"].value == true then
    for _,item_name in pairs(productivity_list) do
        local tech_name = item_name .. "-productivity"
        local tech = data.raw["technology"][tech_name]
        if tech then
            tech.PlanetsLib_recipe_productivity_effects = {
                --purge_other_effects = true,
                technology_name = tech_name,
                effects = {
                    {
                        type = "item",
                        name = item_name,
                        --change = (tech.effects and tech.effects[1].change) or 0.1,
                        category_blacklist = {"recycling"}, --Excluded recipe categories
                        
                    }
                }
            }
            if tech.effects and #tech.effects >= 1 and tech.effects[1].change then
                tech.PlanetsLib_recipe_productivity_effects.effects[1].change = tech.effects[1].change 
            else
                tech.PlanetsLib_recipe_productivity_effects.effects[1].change = 0.1
            end
        end
    end
end