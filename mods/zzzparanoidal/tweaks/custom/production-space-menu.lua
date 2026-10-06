-- Final menu-only assignments after previous menu patches.
-- Keep all prototype IDs, current icons, availability and gameplay unchanged.
local layout = require("tweaks.custom.production-space-menu-data")
local moved, missing = 0, 0
for _, row in ipairs(layout.rows) do
    if data.raw["item-group"][row.group] then
        if not data.raw["item-subgroup"][row.subgroup] then
            data:extend({{
                type = "item-subgroup", name = row.subgroup,
                group = row.group, order = row.order,
            }})
        end
        for _, entry in ipairs(row.recipes) do
            local recipe = data.raw.recipe[entry.name]
            if recipe then
                recipe.subgroup = row.subgroup
                recipe.order = entry.order
                moved = moved + 1
            else
                missing = missing + 1
                log("[production-space-menu] missing approved recipe: " .. entry.name)
            end
        end
    else
        missing = missing + #row.recipes
        log("[production-space-menu] missing target group: " .. row.group)
    end
end
log(string.format("[production-space-menu] moved=%d missing=%d", moved, missing))
