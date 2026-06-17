local fluid_crafting_category =  mods["space-age"] and "crafting-with-fluid-or-metallurgy" or "crafting-with-fluid"
local normal_crafting_category = mods["space-age"] and "pressing"                          or "crafting"
local express_upgrade =          mods["space-age"] and "aai-turbo-loader"                  or nil

AAILoaders.make_tier{
  name = "", -- empty name will create "aai-loader"
  transport_belt = "transport-belt",
  color = {255, 217, 85},
  fluid = "lubricant",
  fluid_per_minute = "0.1",
  fluid_technology_prerequisites = {"oil-processing"},
  technology = {
    prerequisites = {"logistics", "logistic-science-pack"},
    unit = {
      count = 30,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    }
  },
  recipe = {
    crafting_category = normal_crafting_category,
    ingredients = {
      {type = "item", name = "transport-belt", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "electronic-circuit", amount = 5}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    crafting_category = normal_crafting_category,
    ingredients = {
      {type = "item", name = "transport-belt", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 100},
      {type = "item", name = "electronic-circuit", amount = 50}
    },
    energy_required = 10
  },
  next_upgrade = "aai-fast-loader", -- not yet defined
  localise = false -- we have baked in localisation, if you don't you might want to set this to true.
}

AAILoaders.make_tier{
  name = "fast",
  transport_belt = "fast-transport-belt",
  color = {255, 24, 38},
  fluid = "lubricant",
  fluid_per_minute = "0.15",
  fluid_technology_prerequisites = {"lubricant"},
  technology = {
    prerequisites = {"logistics-2", "aai-loader", "advanced-circuit", "chemical-science-pack"},
    unit = {
      count = 250,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    }
  },
  recipe = {
    crafting_category = normal_crafting_category,
    ingredients = {
      {type = "item", name = "fast-transport-belt", amount = 1},
      {type = "item", name = "engine-unit", amount = 5},
      {type = "item", name = "advanced-circuit", amount = 5}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    crafting_category = normal_crafting_category,
    ingredients = {
      {type = "item", name = "fast-transport-belt", amount = 1},
      {type = "item", name = "engine-unit", amount = 50},
      {type = "item", name = "advanced-circuit", amount = 50}
    },
    energy_required = 10
  },
  next_upgrade = "aai-express-loader"
}

AAILoaders.make_tier{
  name = "express",
  transport_belt = "express-transport-belt",
  color = {90, 190, 255},
  fluid = "lubricant",
  fluid_per_minute = "0.2",
  technology = {
    prerequisites = {"logistics-3", "aai-fast-loader", "processing-unit"},
    unit = {
      count = 350,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 15
    }
  },
  recipe = {
    crafting_category = fluid_crafting_category,
    ingredients = {
      {type = "item", name = "express-transport-belt", amount = 1},
      {type = "item", name = "electric-engine-unit", amount = 5},
      {type = "item", name = "processing-unit", amount = 5},
      {type = "fluid", name = "lubricant", amount = 50}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    crafting_category = fluid_crafting_category,
    ingredients = {
      {type = "item", name = "express-transport-belt", amount = 1},
      {type = "item", name = "electric-engine-unit", amount = 50},
      {type = "item", name = "processing-unit", amount = 50},
      {type = "fluid", name = "lubricant", amount = 500}
    },
    energy_required = 10
  },
  next_upgrade = express_upgrade
}
