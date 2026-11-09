-- Tin 2.1.16 still uses the pre-2.1 product field `probability`, which Factorio
-- renamed to `independent_probability`. Factorio rejects the prototype at the
-- end of the data stage, so normalize every result after all data-final-fixes
-- have run. Scoped to bztin because the other BZ 2.1 mods already use the new
-- field.
if mods["bztin"] then
    for _, recipe in pairs(data.raw["recipe"]) do
        for _, result in pairs(recipe.results or {}) do
            if type(result) == "table" and result.probability ~= nil then
                result.independent_probability = result.probability
                result.probability = nil
            end
        end
    end
end
