-- Read the final limits instead of duplicating numbers in item/entity locale keys.
-- Only the standard and electronics assembler families; no gameplay changes.
local names = {
    "assembling-machine-1", "assembling-machine-2", "assembling-machine-3",
    "bob-assembling-machine-4", "bob-assembling-machine-5", "bob-assembling-machine-6",
    "assembling-machine-7", "assembling-machine-8", "assembling-machine-9",
    "bob-electronics-machine-1", "bob-electronics-machine-2", "bob-electronics-machine-3",
    "electronics-machine-4", "electronics-machine-5",
}

for _, name in ipairs(names) do
    local machine = data.raw["assembling-machine"][name]
    if machine then
        -- Factorio 2.0 defaults to 65535 when ingredient_count is absent.
        local description = { "paranoidal-assembler.ingredient-limit", tostring(machine.ingredient_count or 65535) }
        machine.localised_description = description
        local item = data.raw.item[name]
        if item and item.place_result == name then
            item.localised_description = description
        end
    end
end
