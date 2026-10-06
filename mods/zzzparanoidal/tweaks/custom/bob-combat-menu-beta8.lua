-- Approved Bob split and combat/defense/equipment layout, after prior menu patches.
-- Earlier Components assignments remain historical; this is the final owner of these recipes.
local layout = require("tweaks.custom.bob-combat-menu-beta8-data")

for _, group in ipairs(layout.groups) do
    if not data.raw["item-group"][group.name] then
        data:extend({table.deepcopy(group)})
    end
end

local moved, icons, missing = 0, 0, 0
for _, row in ipairs(layout.rows) do
    if data.raw["item-group"][row.group] then
        if not data.raw["item-subgroup"][row.subgroup] then
            data:extend({{
                type = "item-subgroup",
                name = row.subgroup,
                group = row.group,
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
                log("[bob-combat-menu-beta8] missing approved recipe: " .. entry.name)
            end
        end
    else
        missing = missing + #row.recipes
        log("[bob-combat-menu-beta8] missing target group: " .. row.group)
    end
end
log(string.format("[bob-combat-menu-beta8] approved=%d icons=%d missing=%d", moved, icons, missing))
