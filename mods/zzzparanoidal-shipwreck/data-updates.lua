-- Restore the electronics capability Bob 1.1 added to crafting assemblers.
local assembler = data.raw["assembling-machine"]["salvaged-assembling-machine"]
if assembler and data.raw["recipe-category"].electronics then
    local present = false
    for _, category in ipairs(assembler.crafting_categories) do
        if category == "electronics" then present = true end
    end
    if not present then table.insert(assembler.crafting_categories, "electronics") end
end
