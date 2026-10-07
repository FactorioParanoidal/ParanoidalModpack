-- Approved crafting-menu layout, after OV, Reskins and other late menu patches.
-- Recipe layout and explicit item ordering; item/entity grouping stays untouched.
local layout = require("tweaks.custom.bob-logistics-menu-beta8-data")

if not data.raw["item-group"]["bob-logistics"] then return end

local moved, icons, missing = 0, 0, 0
for _, row in ipairs(layout.rows) do
    if not data.raw["item-subgroup"][row.subgroup] then
        data:extend({{
            type = "item-subgroup",
            name = row.subgroup,
            group = "bob-logistics",
            order = row.order,
        }})
    end
    for _, entry in ipairs(row.recipes) do
        if entry.item_order then
            local item = data.raw.item[entry.name]
            if item then item.order = entry.item_order end
        end
        local recipe = data.raw.recipe[entry.name]
        if recipe then
            recipe.subgroup = row.subgroup
            recipe.order = entry.order
            if entry.icon then
                recipe.icon = entry.icon.icon
                recipe.icon_size = entry.icon.icon_size
                recipe.icons = entry.icon.icons and table.deepcopy(entry.icon.icons) or nil
                recipe.icon_mipmaps = nil -- 1.1-only metadata; keep original PNG tiles.
                icons = icons + 1
            end
            moved = moved + 1
        else
            missing = missing + 1 -- An optional owner may be absent; never recreate recipes.
            log("[bob-logistics-menu-beta8] missing approved recipe: " .. entry.name)
        end
    end
end
log(string.format("[bob-logistics-menu-beta8] approved=%d icons=%d missing=%d", moved, icons, missing))
