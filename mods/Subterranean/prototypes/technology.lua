-- Prerequisites from the final Beta 8 dump, not the pre-Angels source definitions.
local technologies = {
  {
    name = "subterranean-logistics-1", recipe = "subterranean-belt",
    prerequisites = {"logistics"}, count = 50, time = 15,
    ingredients = {{"automation-science-pack", 1}},
  },
  {
    name = "subterranean-logistics-2", recipe = "fast-subterranean-belt",
    prerequisites = {"logistics-2", "subterranean-logistics-1"}, count = 200, time = 30,
    ingredients = {{"logistic-science-pack", 2}, {"automation-science-pack", 1}},
  },
  {
    name = "subterranean-logistics-3", recipe = "express-subterranean-belt",
    prerequisites = {"logistics-3", "subterranean-logistics-2"}, count = 500, time = 30,
    ingredients = {{"logistic-science-pack", 2}, {"automation-science-pack", 2}, {"chemical-science-pack", 1}},
  },
  {
    name = "subterranean-liquid-logistics", recipe = "subterranean-pipe",
    prerequisites = {"angels-oil-processing"}, count = 190, time = 30,
    ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 2}},
  },
}

for _, spec in ipairs(technologies) do
  data:extend({{
    type = "technology",
    name = spec.name,
    icon = "__Subterranean__/graphics/technology/" ..
      (spec.recipe == "subterranean-pipe" and "liquid-logistics" or "logistics") .. ".png",
    icon_size = 128,
    prerequisites = spec.prerequisites,
    effects = {{type = "unlock-recipe", recipe = spec.recipe}},
    unit = {count = spec.count, time = spec.time, ingredients = spec.ingredients},
    order = "a-f-a",
  }})
end
