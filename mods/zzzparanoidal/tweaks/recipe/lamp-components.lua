-- Lamp technology follows electricity, which already unlocks the basic circuit board.
if not data.raw.item["bob-basic-circuit-board"] then return end

local replacements = {
    ["deadlock-electric-copper-lamp"] = "advanced-circuit",
    ["hs_holo_sign"] = "electronic-circuit",
}
for name, old_ingredient in pairs(replacements) do
    local recipe = data.raw.recipe[name]
    if recipe then
        for _, ingredient in pairs(recipe.ingredients or {}) do
            if ingredient.type == "item" and ingredient.name == old_ingredient then
                ingredient.name = "bob-basic-circuit-board"
            end
        end
    end
end
