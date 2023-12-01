require "constants"
require "config"
require "functions"

if Config.glowPlants then
	data:extend({
	  {
		type = "item-group",
		name = "glowing-plants",
		order = "g",
		icon = "__Bioluminescence__/graphics/item-group.png",
		icon_size = 64,
	  },
	  {
		type = "item-subgroup",
		name = "glowing-tree",
		group = "glowing-plants",
		order = "g"
	  },
	  {
		type = "item-subgroup",
		name = "glowing-bush",
		group = "glowing-plants",
		order = "g"
	  },
	  {
		type = "item-subgroup",
		name = "glowing-lily",
		group = "glowing-plants",
		order = "g"
	  },
	  {
		type = "item-subgroup",
		name = "glowing-reed",
		group = "glowing-plants",
		order = "g"
	  },
	})
	for color,render in pairs(RENDER_COLORS) do
		createGlowingPlants(color, 1)
	end
end