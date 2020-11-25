-- DEADLOCK's LARGER LAMPS

require("prototypes.item")
require("prototypes.recipe")
require("prototypes.entity")
require("prototypes.technology")

-- Increase light renderer search radius (0.17.70 onwards)

local limit = 25
if data.raw["utility-constants"]["default"]["light_renderer_search_distance_limit"] and data.raw["utility-constants"]["default"]["light_renderer_search_distance_limit"] < limit then
	data.raw["utility-constants"]["default"]["light_renderer_search_distance_limit"] = limit
end