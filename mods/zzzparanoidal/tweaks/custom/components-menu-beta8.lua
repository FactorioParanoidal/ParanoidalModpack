-- Approved thematic Components menu, after OV, Reskins and earlier menu patches.
-- Recipes only: items, entities, research and crafting mechanics stay untouched.
local layout = require("tweaks.custom.components-menu-beta8-data")

if not data.raw["item-group"]["intermediate-products"] then return end

local moved, icons, missing = 0, 0, 0
for _, row in ipairs(layout.rows) do
    if not data.raw["item-subgroup"][row.subgroup] then
        data:extend({{
            type = "item-subgroup",
            name = row.subgroup,
            group = "intermediate-products",
            order = row.order,
        }})
    end
    for _, entry in ipairs(row.recipes) do
        local recipe = data.raw.recipe[entry.name]
        if recipe then
            recipe.subgroup = row.subgroup
            recipe.order = entry.order
            if entry.icon then
                recipe.icon = entry.icon.icon
                recipe.icon_size = entry.icon.icon_size
                recipe.icons = entry.icon.icons and table.deepcopy(entry.icon.icons) or nil
                recipe.icon_mipmaps = nil
                icons = icons + 1
            end
            moved = moved + 1
        else
            missing = missing + 1 -- Optional owner absent: never resurrect recipes.
            log("[components-menu-beta8] missing approved recipe: " .. entry.name)
        end
    end
end
log(string.format("[components-menu-beta8] approved=%d icons=%d missing=%d", moved, icons, missing))
