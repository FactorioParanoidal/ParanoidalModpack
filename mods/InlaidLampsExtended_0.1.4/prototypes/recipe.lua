-- recipe/inlaid lamp

-- Flat Lamp Recipe
local lamp = util.table.deepcopy(data.raw["recipe"]["small-lamp"])
lamp.name = "flat-lamp-c"
lamp.result = "flat-lamp"
lamp.enabled = false
data:extend({lamp})

-- 2x2 Flat Lamp Recipe
local lampbig = util.table.deepcopy(data.raw["recipe"]["small-lamp"])
lampbig.name = "flat-lamp-big"
lampbig.result = "flat-lamp-big"
lampbig.enabled = false
data:extend({lampbig})