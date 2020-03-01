data:extend(
{
  {
    type = "technology",
    name = "electrolysis-1",
	hidden=true, --DrD
    icon = "__bobplates__/graphics/icons/technology/electrolysis.png",
    icon_size = 128,
    prerequisites =
    {
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "electrolyser"
      },
      {
        type = "unlock-recipe",
        recipe = "water-electrolysis"
      },
    },
    unit =
    {
      count = 20,
      ingredients = 
      {
        {"automation-science-pack", 1},
      },
      time = 15
    },
    order = "d-b-a1"
  },

  {
    type = "technology",
    name = "electrolysis-2",
		hidden=true, --DrD
    icon = "__bobplates__/graphics/icons/technology/electrolysis.png",
    icon_size = 128,
    prerequisites =
    {
      "electrolysis-1",
      "chemical-processing-1"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "salt-water-electrolysis"
      },
      {
        type = "unlock-recipe",
        recipe = "storage-tank"
      },
    },
    unit =
    {
      count = 30,
      ingredients = 
      {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 1},
      },
      time = 20
    },
    order = "d-b-a2"
  },


  {
    type = "technology",
    name = "chemical-processing-1",
    icon = "__bobplates__/graphics/icons/technology/chemical-processing.png",
    icon_size = 128,
    prerequisites =
    {
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "chemical-boiler"
      },
      {
        type = "unlock-recipe",
        recipe = "salt"
      },
      {
        type = "unlock-recipe",
        recipe = "carbon"
      },
    },
    unit =
    {
      count = 25,
      ingredients = 
      {
        {"automation-science-pack", 1},
      },
      time = 15
    },
    order = "d-b-b1"
  },

  {
    type = "technology",
    name = "chemical-processing-2",
    icon = "__bobplates__/graphics/icons/technology/chemical-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "electrolysis-2",
      "chemical-processing-1"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "chemical-steel-furnace"
      },
      {
        type = "unlock-recipe",
        recipe = "chemical-plant"
      },
      {
        type = "unlock-recipe",
        recipe = "hydrogen-chloride"
      },
      {
        type = "unlock-recipe",
        recipe = "calcium-chloride"
      },
      {
        type = "unlock-recipe",
        recipe = "ferric-chloride-solution"
      },
      {
        type = "unlock-recipe",
        recipe = "solid-fuel-from-hydrogen"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "d-b-b2"
  },

  {
    type = "technology",
    name = "chemical-processing-3",
    icon = "__bobplates__/graphics/icons/technology/chemical-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "chemical-processing-2",
      "advanced-material-processing-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "chemical-furnace"
      },
      {
        type = "unlock-recipe",
        recipe = "enriched-fuel-from-liquid-fuel"
      },
    },
    unit =
    {
      count = 75,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = "d-b-b3"
  },


  {
    type = "technology",
    name = "alloy-processing-1",
    icon = "__bobplates__/graphics/icons/technology/alloy-processing.png",
    icon_size = 128,
    prerequisites =
    {
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "mixing-furnace"
      },
      {
        type = "unlock-recipe",
        recipe = "bronze-alloy"
      },
    },
    unit =
    {
      count = 25,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 30
    },
    order = "c-c-a-a"
  },

  {
    type = "technology",
    name = "mixing-steel-furnace",
    icon = "__bobplates__/graphics/icons/technology/alloy-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "alloy-processing-1",
      "advanced-material-processing"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "mixing-steel-furnace"
      },
    },
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "c-c-a-b"
  },

  {
    type = "technology",
    name = "alloy-processing-2",
    icon = "__bobplates__/graphics/icons/technology/alloy-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "alloy-processing-1",
      "advanced-material-processing-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "electric-mixing-furnace"
      },
    },
    unit =
    {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = "c-c-a-c"
  },


  {
    type = "technology",
    name = "nitrogen-processing",
    icon = "__bobplates__/graphics/icons/technology/nitrogen-processing.png",
    icon_size = 128,
    prerequisites =
    {
      "chemical-processing-2",
      "air-compressor-1"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "nitrogen"
      },
      {
        type = "unlock-recipe",
        recipe = "nitrogen-dioxide"
      },
      {
        type = "unlock-recipe",
        recipe = "nitric-acid"
      },
    },
    unit =
    {
      count = 35,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "d-b-b5"
  },

  {
    type = "technology",
    name = "ceramics",
    icon = "__bobplates__/graphics/icons/technology/ceramics.png",
    icon_size = 64,
    prerequisites =
    {
      "nitrogen-processing",
      "silicon-processing"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "silicon-nitride"
      },
      {
        type = "unlock-recipe",
        recipe = "ceramic-bearing-ball"
      },
      {
        type = "unlock-recipe",
        recipe = "ceramic-bearing"
      },
    },
    unit =
    {
      count = 60,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "d-b-b6"
  },


  {
    type = "technology",
    name = "air-compressor-1",
    icon = "__bobplates__/graphics/icons/liquid-air.png",
    icon_size = 32,
    prerequisites =
    {
    },
--[[DrD
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-pump"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-liquid-air"
      },
    },
]]	
    unit =
    {
      count = 30,
      ingredients = 
      {
        {"automation-science-pack", 1},
      },
      time = 20
    },
    order = "d-c-a1"
  },
--[[ DrD
  {
    type = "technology",
    name = "air-compressor-2",
    icon = "__bobplates__/graphics/icons/liquid-air.png",
    icon_size = 32,
    prerequisites =
    {
      "air-compressor-1",
      "steel-processing",
      "alloy-processing-1",
      "advanced-electronics",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-pump-2"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "d-c-a2"
  },

  {
    type = "technology",
    name = "air-compressor-3",
    icon = "__bobplates__/graphics/icons/liquid-air.png",
    icon_size = 32,
    prerequisites =
    {
      "air-compressor-2",
      "zinc-processing",
      "titanium-processing",
      "advanced-electronics-2",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-pump-3"
      },
    },
    unit =
    {
      count = 75,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 45
    },
    order = "d-c-a3"
  },

  {
    type = "technology",
    name = "air-compressor-4",
    icon = "__bobplates__/graphics/icons/liquid-air.png",
    icon_size = 32,
    prerequisites =
    {
      "air-compressor-3",
      "nitinol-processing",
      "electric-engine",
      "advanced-electronics-3",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-pump-4"
      },
    },
    unit =
    {
      count = 100,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    order = "d-c-a4"
  },


  {
    type = "technology",
    name = "water-bore-1",
    icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 32,
    prerequisites =
    {
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "water-pump"
      },
    },
    unit =
    {
      count = 30,
      ingredients = 
      {
        {"automation-science-pack", 1},
      },
      time = 20
    },
    order = "d-c-b1"
  },

  {
    type = "technology",
    name = "water-bore-2",
    icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 32,
    prerequisites =
    {
      "water-bore-1",
      "steel-processing",
      "alloy-processing-1",
      "advanced-electronics",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "water-pump-2"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "d-c-b2"
  },

  {
    type = "technology",
    name = "water-bore-3",
    icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 32,
    prerequisites =
    {
      "water-bore-2",
      "zinc-processing",
      "titanium-processing",
      "advanced-electronics-2",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "water-pump-3"
      },
    },
    unit =
    {
      count = 75,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 45
    },
    order = "d-c-b3"
  },

  {
    type = "technology",
    name = "water-bore-4",
    icon = "__base__/graphics/icons/fluid/water.png",
    icon_size = 32,
    prerequisites =
    {
      "water-bore-3",
      "nitinol-processing",
      "electric-engine",
      "advanced-electronics-3",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "water-pump-4"
      },
    },
    unit =
    {
      count = 100,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
    order = "d-c-b4"
  },
]] --DrD

  {
    type = "technology",
    name = "gas-canisters",
    icon = "__bobplates__/graphics/icons/technology/gas-canister.png",
    icon_size = 64,
    prerequisites =
    {
      "air-compressor-1",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "gas-canister"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "d-b-a1"
  },

--[[
  {
    type = "technology",
    name = "barrels",
    icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png",
    icon_size = 32,
    prerequisites =
    {
      "water-bore-1",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "empty-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-heavy-oil-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-heavy-oil-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-light-oil-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-light-oil-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-lubricant-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-lubricant-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-sulfuric-acid-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-sulfuric-acid-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-nitric-acid-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-nitric-acid-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-fill-crude-oil-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-empty-crude-oil-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-water-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-water-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "fill-lithia-water-barrel"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-lithia-water-barrel"
      },

      {
        type = "unlock-recipe",
        recipe = "empty-canister"
      },
      {
        type = "unlock-recipe",
        recipe = "liquid-fuel-canister"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-liquid-fuel-canister"
      },
      {
        type = "unlock-recipe",
        recipe = "ferric-chloride-canister"
      },
      {
        type = "unlock-recipe",
        recipe = "empty-ferric-chloride-canister"
      },
    },
    unit =
    {
      count = 50,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "d-b-a1"
  },
]]--

  {
    type = "technology",
    name = "grinding",
    icon = "__bobplates__/graphics/icons/technology/grinding.png",
    icon_size = 64,
    prerequisites =
    {
      "chemical-processing-1",
      "silicon-processing",
    },
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "silicon-carbide"
      },
      {
        type = "unlock-recipe",
        recipe = "grinding-wheel"
      },
    },
    order = "b-c-b"
  },

  {
    type = "technology",
    name = "polishing",
    icon = "__bobplates__/graphics/icons/technology/polishing.png",
    icon_size = 64,
    prerequisites =
    {
      "oil-processing",
      "aluminium-processing",
    },
    unit =
    {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "polishing-compound"
      },
      {
        type = "unlock-recipe",
        recipe = "polishing-wheel"
      },
    },
    order = "b-c-c"
  },


  {
    type = "technology",
    name = "gem-processing-1",
    icon = "__bobplates__/graphics/icons/technology/gems.png",
    icon_size = 64,
    prerequisites =
    {
      "grinding",
    },
    unit =
    {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "bob-ruby-4"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-sapphire-4"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-emerald-4"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-amethyst-4"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-topaz-4"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-diamond-4"
      },
    },
    order = "c-b-i1"
  },

  {
    type = "technology",
    name = "gem-processing-2",
    icon = "__bobplates__/graphics/icons/technology/gems.png",
    icon_size = 64,
    prerequisites =
    {
      "gem-processing-1",
      "polishing",
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "bob-ruby-5"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-sapphire-5"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-emerald-5"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-amethyst-5"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-topaz-5"
      },
      {
        type = "unlock-recipe",
        recipe = "bob-diamond-5"
      },
    },
    order = "c-b-i2"
  },

  {
    type = "technology",
    name = "void-fluid",
    icon = "__bobplates__/graphics/icons/technology/void128.png",
    icon_size = 128,
    prerequisites =
    {
      "air-compressor-1",
    },
    unit =
    {
      count = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 10
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "void-pump"
      },
    },
    order = "void-fluid"
  },

  {
    type = "technology",
    name = "advanced-electronics-3",
    icon = "__bobplates__/graphics/icons/technology/advanced-electronics-3.png",
    icon_size = 128,
    prerequisites =
    {
      "advanced-electronics-2",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-processing-unit"
      },
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    order = "a-d-d",
  },

  {
    type = "technology",
    name = "battery-2",
    icon = "__base__/graphics/technology/battery.png",
    icon_size = 128,
    prerequisites =
    {
      "battery",
      "lithium-processing",
      "cobalt-processing",
    },
    unit =
    {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "lithium-cobalt-oxide"
      },
      {
        type = "unlock-recipe",
        recipe = "lithium-ion-battery"
      },
    },
    order = "b-c-a"
  },

  {
    type = "technology",
    name = "battery-3",
    icon = "__base__/graphics/technology/battery.png",
    icon_size = 128,
    prerequisites =
    {
      "battery-2",
      "nitrogen-processing",
      "electrolysis-2",
      "zinc-processing",
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "silver-oxide"
      },
      {
        type = "unlock-recipe",
        recipe = "silver-nitrate"
      },
      {
        type = "unlock-recipe",
        recipe = "silver-zinc-battery"
      },
    },
    order = "b-c-b",
  },
}
)

