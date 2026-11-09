for _,tech in pairs(data.raw["technology"]) do
    if tech.PlanetsLib_recipe_productivity_effects then 
        PlanetsLib.process_technology_recipe_productivity_effects(tech)
    end
    
end