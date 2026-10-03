-- Lighted Poles' fallback puts the giant substation at lamp technology too early.
-- Unlock it alongside the unlit Bio Industries substation instead.
local recipe_name = "lighted-bi-large-substation"
local lamp = data.raw.technology.lamp
local distribution = data.raw.technology["electric-energy-distribution-2"]
if not (data.raw.recipe[recipe_name] and lamp and distribution) then return end

for index = #(lamp.effects or {}), 1, -1 do
    local effect = lamp.effects[index]
    if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
        table.remove(lamp.effects, index)
    end
end

distribution.effects = distribution.effects or {}
for _, effect in ipairs(distribution.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe_name then return end
end
table.insert(distribution.effects, {type = "unlock-recipe", recipe = recipe_name})
