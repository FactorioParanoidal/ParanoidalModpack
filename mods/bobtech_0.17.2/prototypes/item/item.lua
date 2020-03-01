data:extend(
{
  {
    type = "tool",
    name = "advanced-logistic-science-pack",
    icon = "__bobtech__/graphics/icons/logistic-science-pack.png",
    icon_size = 32,
    
    subgroup = "science-pack",
    order = "e[advanced-logistic-science-pack]",
    stack_size = 200,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value"
  },

  {
    type = "item",
    name = "lab-2",
    icon = "__bobtech__/graphics/icons/lab2.png",
    icon_size = 32,
    
    subgroup = "production-machine",
    order = "g[lab-2]",
    place_result = "lab-2",
    stack_size = 10
  },
}
)


table.insert(data.raw["lab"]["lab"].inputs, "advanced-logistic-science-pack")
