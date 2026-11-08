for _, category in pairs{
    "overclock"
} do
    if data.raw["module-category"][category] then
        table.insert(ModuleCategoryDefaults.default_categories, category)
    end
end
-- for _, category in pairs{} do
--     if data.raw["module-category"][category] then
--         table.insert(ModuleCategoryDefaults.restricted_categories, category)
--     end
-- end