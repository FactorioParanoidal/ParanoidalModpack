-- Отливка железных прутьев: открыть новые рецепты в уже изученных технологиях.
local unlocks = {
    { "paranoidal-iron-stick-casting", "angels-ironworks-1" },
    { "angels-rod-stack-iron", "angels-iron-casting-2" },
    { "angels-rod-iron-2", "angels-iron-casting-2" },
    { "angels-rod-stack-iron-2", "angels-iron-casting-3" },
}
for _, force in pairs(game.forces) do
    for _, entry in ipairs(unlocks) do
        local recipe = force.recipes[entry[1]]
        local technology = force.technologies[entry[2]]
        if recipe and technology and technology.researched then
            recipe.enabled = true
        end
    end
end
