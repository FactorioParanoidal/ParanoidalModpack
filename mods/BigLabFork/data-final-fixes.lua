local inputs = {}
for _, lab in pairs(data.raw.lab) do
    for _, input in pairs(lab.inputs) do
        inputs[input] = true
    end
end

local biglab = data.raw.lab["big-lab"]

local c = 0
for input in pairs(inputs) do
    c = c + 1
    biglab.inputs[c] = input
end

for _, technology in pairs(data.raw.technology) do
    for i, effect in pairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == "lab" then
            table.insert(technology.effects, i + 1, {
                type = "unlock-recipe",
                recipe = "big-lab",
            })
            break
        end
    end
end