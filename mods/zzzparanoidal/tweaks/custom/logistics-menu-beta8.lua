-- Crafting-menu layout only, after OV, Reskins and the pack's late icon overrides.
-- Explicit IDs keep subsequent category audits from sweeping recipes back here.
local layout = require("tweaks.custom.logistics-menu-beta8-data")

if not data.raw["item-group"].logistics then return end

if not data.raw["item-group"]["paranoidal-unassigned"] then
    data:extend({{
        type = "item-group",
        name = "paranoidal-unassigned",
        order = "zz[paranoidal-unassigned]",
        icon = "__base__/graphics/icons/steel-chest.png",
        icon_size = 64,
    }})
end

local function subgroup(name, group, order)
    if not data.raw["item-subgroup"][name] then
        data:extend({{type = "item-subgroup", name = name, group = group, order = order}})
    end
end

local moved, parked, icons, missing = 0, 0, 0, 0
for _, row in ipairs(layout.rows) do
    subgroup(row.subgroup, "logistics", row.order)
    for _, entry in ipairs(row.recipes) do
        local recipe = data.raw.recipe[entry.name]
        if recipe then
            recipe.subgroup = row.subgroup
            recipe.order = entry.order
            if entry.icon then
                recipe.icon = entry.icon.icon
                recipe.icon_size = entry.icon.icon_size
                recipe.icons = entry.icon.icons and table.deepcopy(entry.icon.icons) or nil
                recipe.icon_mipmaps = nil -- 1.1 metadata; original PNG tiles are retained.
                icons = icons + 1
            end
            moved = moved + 1
        else
            missing = missing + 1 -- Optional owner absent: never resurrect its recipe.
            log("[logistics-menu-beta8] missing approved recipe: " .. entry.name)
        end
    end
end

for _, entry in ipairs(layout.unassigned) do
    local recipe = data.raw.recipe[entry.name]
    if recipe then
        local name = "paranoidal-unassigned-" .. entry.subgroup
        subgroup(name, "paranoidal-unassigned", entry.subgroup_order)
        recipe.subgroup = name
        recipe.order = entry.order
        parked = parked + 1
        -- Preserve enabled/hidden, ingredients, results, unlocks and all item/entity fields.
    end
end
log(string.format("[logistics-menu-beta8] approved=%d unassigned=%d icons=%d missing=%d", moved, parked, icons, missing))
