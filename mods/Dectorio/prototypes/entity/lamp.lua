-- entity/lamp

-- Make base lamp fast replacable
local base_lamp = data.raw["lamp"]["small-lamp"]
base_lamp.fast_replaceable_group = "lamp"

-- Add glowing coloured lamp
local lamp = util.table.deepcopy(base_lamp)
lamp.name = "dect-small-lamp-glow"
lamp.icon = "__Dectorio__/graphics/icons/small-lamp-glow.png"
lamp.icon_size = 64
lamp.icon_mipmaps = 1
lamp.minable.result = "dect-small-lamp-glow"
lamp.glow_size = 25
lamp.glow_color_intensity = 0.8
lamp.glow_render_mode = "multiplicative"
lamp.light_when_colored.size = 0
lamp.light_when_colored.intensity = 0
lamp.fast_replaceable_group = "lamp"
data:extend({lamp})

-- Increase light search radius
local limit = lamp.glow_size
if data.raw["utility-constants"]["default"]["light_renderer_search_distance_limit"] and data.raw["utility-constants"]["default"]["light_renderer_search_distance_limit"] < limit then
	data.raw["utility-constants"]["default"]["light_renderer_search_distance_limit"] = limit
end
