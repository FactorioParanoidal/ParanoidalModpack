-- recipe/lamp

-- Add glowing coloured lamp
local lamp = util.table.deepcopy(data.raw["recipe"]["small-lamp"])
lamp.name = "dect-small-lamp-glow"
lamp.results = {{type = "item", name = "dect-small-lamp-glow", amount = 1}}
data:extend({lamp})
