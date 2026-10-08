-- zzzparanoidal hides modules outside its Beta 8 set. Keep only the existing
-- Quality/Bob quality-module family visible; preserve unlocks, costs and effects.
return function(raw)
    for _, name in ipairs({"quality-module", "quality-module-2", "quality-module-3",
        "bob-quality-module-4", "bob-quality-module-5"}) do
        local module = raw.module and raw.module[name]
        local recipe = raw.recipe and raw.recipe[name]
        if module then module.hidden = false end
        if recipe then recipe.hidden = false end
    end
end
