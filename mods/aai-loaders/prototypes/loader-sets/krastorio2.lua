AAILoaders.make_tier{ -- Advanced loader
  name = "kr-advanced",
  transport_belt = "kr-advanced-transport-belt",
  color = {34, 236, 23},
  fluid = "lubricant",
  fluid_per_minute = "0.225",
  technology = {
    prerequisites = { "kr-logistic-4", },
    unit = {
      count = 350,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 }
      },
      time = 60
    }
  },
  recipe = {
    ingredients = {
      {type = "item", name = "kr-advanced-transport-belt", amount = 1},
      {type = "item", name = "aai-express-loader", amount = 1},
      {type = "item", name = "kr-rare-metals", amount = 5},
      {type = "item", name = "kr-steel-gear-wheel", amount = 5},
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    ingredients = {
      {type = "item", name = "kr-advanced-transport-belt", amount = 1},
      {type = "item", name = "aai-express-loader", amount = 1},
      {type = "item", name = "kr-rare-metals", amount = 50},
      {type = "item", name = "kr-steel-gear-wheel", amount = 50},
    },
    energy_required = 10
  },
  next_upgrade = "aai-kr-superior-loader"
}

AAILoaders.make_tier{ -- Superior loader
  name = "kr-superior",
  transport_belt = "kr-superior-transport-belt",
  color = {210, 1, 247},
  fluid = "lubricant",
  fluid_per_minute = "0.25",
  technology = {
    prerequisites = { "kr-logistic-5", },
    unit = {
      count = 450,
      ingredients = {
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
        { "kr-advanced-tech-card", 1 }
      },
      time = 60
    }
  },
  recipe = {
    ingredients = {
      {type = "item", name = "kr-superior-transport-belt", amount = 1},
      {type = "item", name = "aai-kr-advanced-loader", amount = 1},
      {type = "item", name = "kr-imersium-gear-wheel", amount = 5},
      {type = "item", name = "kr-imersium-plate", amount = 5},
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    ingredients = {
      {type = "item", name = "kr-superior-transport-belt", amount = 1},
      {type = "item", name = "aai-kr-advanced-loader", amount = 1},
      {type = "item", name = "kr-imersium-gear-wheel", amount = 50},
      {type = "item", name = "kr-imersium-plate", amount = 50},
    },
    energy_required = 10
  }
}
if settings.startup["aai-loaders-mode"].value ~= "graphics-only" then
  --graphics only mode won't have aai's loader defined
  data.raw["loader-1x1"]["aai-express-loader"].next_upgrade = "aai-kr-advanced-loader"
end
