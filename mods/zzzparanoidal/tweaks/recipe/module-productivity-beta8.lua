-- These renamed recipes were in both Beta 8 productivity whitelists.
-- Apply after the generated module integration; leave hidden solder, unlocks,
-- ingredients, outputs and maximum_productivity unchanged.
local categories = { "productivity", "raw-productivity", "god" }
for _, name in ipairs({
    "bob-silicon-wafer",
    "clowns-thorium-mixed-oxide",
    "angels-liquid-plastic-bio",
    "angels-liquid-resin-bio",
    "angels-liquid-rubber-bio",
    "barrel",
    "lithium-plate",
}) do
    local recipe = data.raw.recipe[name]
    if recipe then
        recipe.allow_productivity = true
        -- A missing category filter already permits all categories.
        if recipe.allowed_module_categories then
            local allowed = table.deepcopy(recipe.allowed_module_categories)
            for _, category in ipairs(categories) do
                local present = false
                for _, existing in ipairs(allowed) do
                    if existing == category then present = true; break end
                end
                if not present and data.raw["module-category"][category] then
                    allowed[#allowed + 1] = category
                end
            end
            table.sort(allowed)
            recipe.allowed_module_categories = allowed
        end
    end
end
