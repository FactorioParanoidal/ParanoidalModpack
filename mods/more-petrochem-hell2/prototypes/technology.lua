data:extend({
  {
    type = "technology",
    name = "Fuel-Additive",
    icon = "__more-petrochem-hell2__/graphics/Fuel-Additive.png",
    icon_size = 64,
    prerequisites = {"angels-steam-cracking-1", "angels-chlorine-processing-1", "angels-sodium-processing-1", "angels-lead-smelting-1"},
    effects =
    {
      { type = "unlock-recipe", recipe = "sodium-lead-alloy" },
      { type = "unlock-recipe", recipe = "gas-chloroethane" },
      { type = "unlock-recipe", recipe = "fluid-tetraethyllead" },
      { type = "unlock-recipe", recipe = "high-octane-enriched-fuel" },
    },
    unit =
    {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = ""
  },
})
