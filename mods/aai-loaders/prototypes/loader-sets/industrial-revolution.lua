AAILoaders.make_tier{
  name = "", -- empty name will create "aai-loader"
  transport_belt = "transport-belt",
  color = {255, 217, 85},
  fluid = "lubricant",
  fluid_per_minute = "0.1",
  fluid_technology_prerequisites = {"lubricant"},
  technology = {
    prerequisites = {"logistics"},
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
    ingredients = {
      {type = "item", name = "transport-belt", amount = 1},
      {type = "item", name = "tin-gear-wheel", amount = 4},
      {type = "item", name = "iron-motor", amount = 2}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    ingredients = {
      {type = "item", name = "transport-belt", amount = 1},
      {type = "item", name = "tin-gear-wheel", amount = 40},
      {type = "item", name = "iron-motor", amount = 20}
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
  technology = {
    prerequisites = {"logistics-2", "aai-loader"},
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
    ingredients = {
      {type = "item", name = "fast-transport-belt", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 4},
      {type = "item", name = "iron-gear-wheel", amount = 4},
      {type = "item", name = "electric-engine-unit", amount = 2}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    ingredients = {
      {type = "item", name = "fast-transport-belt", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 40},
      {type = "item", name = "iron-gear-wheel", amount = 40},
      {type = "item", name = "electric-engine-unit", amount = 20}
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
    prerequisites = {"logistics-3", "aai-fast-loader"},
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
    crafting_category = "crafting-with-fluid",
    ingredients = {
      {type = "item", name = "express-transport-belt", amount = 1},
      {type = "item", name = "electric-engine-unit", amount = 4},
      {type = "item", name = "steel-gear-wheel", amount = 4},
      {type = "item", name = "advanced-circuit", amount = 2}
    },
    energy_required = 2
  },
  unlubricated_recipe = {
    crafting_category = "crafting-with-fluid",
    ingredients = {
      {type = "item", name = "express-transport-belt", amount = 1},
      {type = "item", name = "electric-engine-unit", amount = 40},
      {type = "item", name = "steel-gear-wheel", amount = 40},
      {type = "item", name = "advanced-circuit", amount = 20}
    },
    energy_required = 10
  }
}

if data.raw.technology["aai-loader"] then data.raw.technology["aai-loader"].IR_native = true end
if data.raw.technology["aai-fast-loader"] then data.raw.technology["aai-fast-loader"].IR_native = true end
if data.raw.technology["aai-express-loader"] then data.raw.technology["aai-express-loader"].IR_native = true end
