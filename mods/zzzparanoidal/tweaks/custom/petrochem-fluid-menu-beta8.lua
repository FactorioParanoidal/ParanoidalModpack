-- After prior menu patches: petrochem/fluid recipe placement and icons only.
-- Explicit lists preserve all visible recipes; hidden recipes and gameplay stay untouched.
local layout = require("tweaks.custom.petrochem-fluid-menu-beta8-data")

local function set_icon(prototype, icon)
    prototype.icon = icon.icon
    prototype.icon_size = icon.icon_size
    prototype.icons = icon.icons and table.deepcopy(icon.icons) or nil
    prototype.icon_mipmaps = nil
end

for _, entry in ipairs(layout.groups) do
    local group = data.raw["item-group"][entry.name]
    if group then set_icon(group, entry.icon) end
end

local moved, icons, missing = 0, 0, 0
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
                if entry.icon then
                    set_icon(recipe, entry.icon)
                    icons = icons + 1
                end
                moved = moved + 1
            else
                missing = missing + 1 -- Optional mod absent: never recreate a recipe.
                log("[petrochem-fluid-menu-beta8] missing approved recipe: " .. entry.name)
            end
        end
    else
        missing = missing + #row.recipes
        log("[petrochem-fluid-menu-beta8] missing target group: " .. row.group)
    end
end
log(string.format("[petrochem-fluid-menu-beta8] moved=%d icons=%d missing=%d", moved, icons, missing))
