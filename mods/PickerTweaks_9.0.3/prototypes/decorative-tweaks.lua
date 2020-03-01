local Data = require('__stdlib__/stdlib/data/data')

--(( Disable Decorations ))--
-- "name": "disable-decorations",
--	"title": "Disable Decorations",
--	"author": "Pithlit",
--	"description":
-- "This mod prevents placement of decoration elements at terrain generation.
--   Removing decorations will reduce the size of save-games.
--   Other mods may place decoration elements manually. Decorations from existing games will not be removed
if settings.startup["picker-disable-decorations"].value then
    for _, deco in pairs(data.raw["optimized-decorative"]) do
        deco.autoplace = nil
    end
end

--(( Cleaner Tree Burning ))--
-- "name": "Clean_Tree_Burning",
-- "title": "Clean Tree Burning",
-- "author": "Gegell",
-- "description": "Burnt trees won't be left when burning forests ",
if settings.startup['picker-clean-tree-burning'].value then
    Data('fire-flame-on-tree', 'fire').tree_dying_factor = 1
end

--(( RoundUp ))--
if settings.startup['picker-roundup'].value then
    local tiles = {
        'concrete',
        'stone-path',
        'hazard-concrete-left',
        'hazard-concrete-right',
        'refined-concrete',
        'refined-hazard-concrete-left',
        'refined-hazard-concrete-right'
    }

    for _, tile in pairs(tiles) do
        Data(tile, 'tile').decorative_removal_probability = 1
    end
end

if settings.startup['picker-roundup-resources'].value then
    for _, tree in Data:pairs(data.raw.resource) do
        tree.tree_removal_probability = 1
        tree.tree_removal_max_distance = 1000000
    end
end
