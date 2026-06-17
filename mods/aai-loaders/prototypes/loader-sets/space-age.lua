local turbo_specs = {
  name = "turbo",
  transport_belt = "turbo-transport-belt",
  color = {155, 182, 0},
  fluid = "lubricant",
  fluid_per_minute = "0.25",
  default_import_location = "vulcanus",
  technology = {
    prerequisites = {"turbo-transport-belt", "aai-express-loader", "processing-unit"},
    unit = {
      count = 500,
      ingredients = data.raw.technology["turbo-transport-belt"].unit.ingredients,
      time = 15
    }
  },
  recipe = {
    crafting_category = "crafting-with-fluid-or-metallurgy",
    ingredients = {
      {type = "item", name = "turbo-transport-belt", amount = 1},
      {type = "item", name = "tungsten-plate", amount = 30},
      {type = "item", name = "processing-unit", amount = 5},
      {type = "fluid", name = "lubricant", amount = 50}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    crafting_category = "crafting-with-fluid-or-metallurgy",
    ingredients = {
      {type = "item", name = "turbo-transport-belt", amount = 1},
      {type = "item", name = "tungsten-plate", amount = 300},
      {type = "item", name = "processing-unit", amount = 50},
      {type = "fluid", name = "lubricant", amount = 500}
    },
    energy_required = 10
  }
}

if mods["aai-industry"] then
  turbo_specs.recipe.ingredients = {
    {type = "item", name = "aai-express-loader", amount = 1},
    {type = "item", name = "tungsten-plate", amount = 30},
    {type = "item", name = "processing-unit", amount = 5},
    {type = "fluid", name = "lubricant", amount = 50}
  }
  turbo_specs.unlubricated_recipe.ingredients = {
    {type = "item", name = "aai-express-loader", amount = 1},
    {type = "item", name = "tungsten-plate", amount = 300},
    {type = "item", name = "processing-unit", amount = 50},
    {type = "fluid", name = "lubricant", amount = 500}
  }
end

AAILoaders.make_tier(turbo_specs)

if settings.startup["aai-loaders-mode"].value ~= "graphics-only" then
  --graphics only mode won't have aai's loader defined, so avoid interacting with them if it is graphics only

  --turbo loaders are faster than a single normal quality stack inserter, but are slower than a legendary one. they deserve to be expensive to launch
  for _,loader in pairs({{name = "", count = 50}, {name = "fast-", count = 50}, {name = "express-", count = 25}, {name = "turbo-", count = 10}}) do
    data.raw["item"]["aai-" .. loader.name .. "loader"].weight = 1000000/loader.count
  end
  data.raw["recipe"]["aai-turbo-loader"].surface_conditions = data.raw["recipe"]["turbo-transport-belt"].surface_conditions
end
