local cfg1 = require("config.config-1")



if cfg1.tiered_subgroups then
  data:extend{
    {
      type = "item-subgroup",
      name = "vehicles-military-1",
      group = "transport",
      order = "d-1",
    },
    {
      type = "item-subgroup",
      name = "vehicles-military-2",
      group = "transport",
      order = "d-2",
    },
  }
end



data:extend
{
  {
    type = "item-subgroup",
    name = "Schall-parts",
    group = "intermediate-products",
    order = "p"
  },
  {
    type = "item-subgroup",
    name = "Schall-parts-civilian",
    group = "intermediate-products",
    order = "p-c"
  },
  {
    type = "item-subgroup",
    name = "Schall-parts-military",
    group = "intermediate-products",
    order = "p-m"
  },
}
