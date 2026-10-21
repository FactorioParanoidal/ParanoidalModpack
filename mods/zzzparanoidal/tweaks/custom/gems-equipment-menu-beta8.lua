-- After Bob/combat: consolidate personal equipment; keep vehicle equipment separate.
-- Gems retain their existing eight rows. Only recipe placement and menu icons change.
local layout = require("tweaks.custom.gems-equipment-menu-beta8-data")

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
local function apply(entry, subgroup)
    local recipe = data.raw.recipe[entry.name]
    if not recipe then
        missing = missing + 1 -- Optional owner absent: never recreate recipes.
        log("[gems-equipment-menu-beta8] missing approved recipe: " .. entry.name)
        return
    end
    if subgroup then
        recipe.subgroup = subgroup
        recipe.order = entry.order
        moved = moved + 1
    end
    if entry.icon then
        set_icon(recipe, entry.icon)
        icons = icons + 1
    end
end

for _, row in ipairs(layout.rows) do
    if data.raw["item-group"][row.group] then
        if row.create and not data.raw["item-subgroup"][row.subgroup] then
            data:extend({{
                type = "item-subgroup", name = row.subgroup,
                group = row.group, order = row.order,
            }})
        end
        if data.raw["item-subgroup"][row.subgroup] then
            for _, entry in ipairs(row.recipes) do apply(entry, row.subgroup) end
        else
            missing = missing + #row.recipes
            log("[gems-equipment-menu-beta8] missing target subgroup: " .. row.subgroup)
        end
    else
        missing = missing + #row.recipes
        log("[gems-equipment-menu-beta8] missing target group: " .. row.group)
    end
end
for _, entry in ipairs(layout.icons_only) do apply(entry) end
log(string.format("[gems-equipment-menu-beta8] moved=%d icons=%d missing=%d", moved, icons, missing))
