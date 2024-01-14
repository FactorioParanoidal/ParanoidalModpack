local technology_unlocks = {
    ["gardens-2"] = "seed-extractor-2",
    ["gardens-3"] = "seed-extractor-3",
}

for _, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes

    for technology, recipe in pairs(technology_unlocks) do
        if technologies[technology].researched then
            recipes[recipe].enabled = true
        end
    end
end
