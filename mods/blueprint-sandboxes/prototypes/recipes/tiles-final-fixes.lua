PlannerIcons = require("scripts.planner-icons")
Tiles = require("scripts.tiles")

-- Helpers for Tile Planners
function shouldSkipTilePlanner(tile)
    return tile.name ~= "water"
end

function createTilePlannerPrototypes(tile)
    local localisedName = tile.localised_name or { "tile-name." .. tile.name }
    local icons = PlannerIcons.CreateLayeredIcon(tile)
    return {
        {
            type = "item",
            name = Tiles.pfx .. tile.name,
            localised_name = localisedName,
            icons = icons,
            subgroup = Tiles.name,
            order = tile.order,
            stack_size = 1000,
            stackable = true,
            place_as_tile = {
                result = tile.name,
                condition = {},
                condition_size = 1,
            },
        },
        {
            type = "recipe",
            name = Tiles.pfx .. tile.name,
            localised_name = localisedName,
            icons = icons,
            energy_required = 1,
            enabled = false,
            ingredients = {},
            result = Tiles.pfx .. tile.name,
            hide_from_stats = true,
        }
    }
end

-- New Items/Recipes for Tile Planners
for _, tile in pairs(data.raw.tile) do
    -- Some Tiles are better left alone
    if not shouldSkipTilePlanner(tile) then
        data:extend(createTilePlannerPrototypes(tile))
    end
end
