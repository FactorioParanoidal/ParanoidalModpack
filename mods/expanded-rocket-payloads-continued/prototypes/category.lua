--This sets up a whole new tab in the players inventory to stort the mod's stuff. Also subcategories for each recipe. 

data:extend(
{
  {
    type = "item-group",
    name = "satellites",
    order = "xx",
    icon = "__expanded-rocket-payloads-continued__/graphic/advanced-probe-128.png",
    icon_size = 128,
  },
  {
    type = "item-subgroup",
    name = "buildings",
    group = "satellites",
    order = "a-1"
  },
  {
    type = "item-subgroup",
    name = "satellites",
    group = "satellites",
    order = "b-2"
  },
  {
    type = "item-subgroup",
    name = "satellite-intermediaries",
    group = "satellites",
    order = "c-3"
  },
  {
    type = "item-subgroup",
    name = "Space-Shuttles",
    group = "satellites",
    order = "d-4"
  },

  {
    type = "item-subgroup",
    name = "shuttle-processies",
    group = "satellites",
    order = "e-5"
  },
  {
    type = "item-subgroup",
    name = "space-mining",
    group = "satellites",
    order = "f-6"
  },
  {
    type = "item-subgroup",
    name = "building-recipies",
    group = "satellites",
    order = "g-7"
  },
  {
    type = "item-subgroup",
    name = "satellite-data",
    group = "satellites",
    order = "h-8"
  },
}
)

