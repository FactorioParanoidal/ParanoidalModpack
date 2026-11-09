local Public = {}

function Public.research_technology(force,technology_name)
    force.technologies[technology_name].researched = true
    force.print({"technology-researched","[technology=" .. technology_name .. "]"}, {sound_path = "utility/research_completed"})  

end

return Public