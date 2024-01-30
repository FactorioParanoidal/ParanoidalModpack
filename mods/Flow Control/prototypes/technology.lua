--[[
table.insert(
  data.raw["technology"]["fluid-handling"].effects,
  {type = "unlock-recipe",recipe = "check-valve"})
table.insert(
  data.raw["technology"]["fluid-handling"].effects,
  {type = "unlock-recipe",recipe = "overflow-valve"})
table.insert(
  data.raw["technology"]["fluid-handling"].effects,
  {type = "unlock-recipe",recipe = "underflow-valve"})
]]

data:extend ({
{
  type = "technology",
  name = "flow_control_valves_tech",
  icon = "__Flow Control__/graphics/technology/flow_control_valves_tech.png",
  icon_size = 256,
  effects = {
    {
      type = "unlock-recipe",
      recipe = "check-valve"
    },
    {
      type = "unlock-recipe",
      recipe = "overflow-valve"
    },
    {
      type = "unlock-recipe",
      recipe = "underflow-valve"
    },
  },
  prerequisites = {"fluid-handling"},
  unit = {
    count = 30,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 15
  },
  order = "z-g-a",
},
})