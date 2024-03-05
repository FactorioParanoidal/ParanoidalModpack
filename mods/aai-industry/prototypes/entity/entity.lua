local medium_electric_pole = data.raw["electric-pole"]["medium-electric-pole"]
local fast_replace = medium_electric_pole.fast_replaceable_group or "medium-electric-pole"
medium_electric_pole.fast_replaceable_group = fast_replace

local small_electric_pole = data.raw["electric-pole"]["small-electric-pole"]
small_electric_pole.fast_replaceable_group = fast_replace
--local small_iron_electric_pole = table.deepcopy(small_electric_pole)
--small_iron_electric_pole.name = "small-iron-electric-pole"
--small_iron_electric_pole.minable.result = "small-iron-electric-pole"
--small_iron_electric_pole.max_health = small_iron_electric_pole.max_health * 1.25
--[[small_iron_electric_pole.pictures =
{
  filename = "__aai-industry__/graphics/entity/small-iron-electric-pole.png",
  priority = "extra-high",
  width = 123,
  height = 124,
  direction_count = 4,
  shift = {1.4, -1.1}
},
data:extend({small_iron_electric_pole})
]]