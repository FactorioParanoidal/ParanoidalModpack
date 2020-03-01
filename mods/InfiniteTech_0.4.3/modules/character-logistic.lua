-- remove finite techs added by boblogistics
if mods["boblogistics"] then
  data.raw["technology"]["character-logistic-slots-7"] = nil
  data.raw["technology"]["character-logistic-slots-8"] = nil
  data.raw["technology"]["character-logistic-slots-9"] = nil
  data.raw["technology"]["character-logistic-slots-10"] = nil
end

data:extend
({
  {
    type = "technology",
    name = "character-logistic-slots-7",
    icon = "__base__/graphics/technology/character-logistic-slots.png",
    icon_size = 128,
    effects =
    {
      {
        type = "character-logistic-slots",
        modifier = 6
      }
    },
    prerequisites = {"character-logistic-slots-6", "space-science-pack"},
    unit =
    {
      count_formula = "2^(L-6)*1000",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    },
    max_level = "infinite",
    upgrade = true,
    order = "c-k-e-g"
  },
})