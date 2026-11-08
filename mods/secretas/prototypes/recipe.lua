local seconds = 60
local minutes = 60*seconds

data:extend(
{
    {
        type = "recipe",
        name = "spaceship-scrap-recycling",
        icons = {
          {
            icon = "__recycler__/graphics/icons/recycling.png"
          },
          {
            icon = "__secretas__/graphics/icons/spaceship-scrap.png",
            scale = 0.4
          },
          {
            icon = "__recycler__/graphics/icons/recycling-top.png"
          }
        },
        categories = {"recycling","hand-crafting"},
        subgroup = "fulgora-processes", 
        order = "a[trash]-b[trash-recycling]",
        enabled = false,
        auto_recycle = false,
        energy_required = 0.2,
        ingredients = {{type = "item", name = "spaceship-scrap", amount = 1}},
        results =
        {
          {type = "item", name = "processing-unit",        amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          {type = "item", name = "advanced-circuit",       amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          {type = "item", name = "low-density-structure",  amount = 1, independent_probability = 0.03, show_details_in_recipe_tooltip = false},
          {type = "item", name = "solid-fuel",             amount = 1, independent_probability = 0.07, show_details_in_recipe_tooltip = false},
          {type = "item", name = "steel-plate",            amount = 1, independent_probability = 0.05, show_details_in_recipe_tooltip = false},
          --11
          {type = "item", name = "battery",                amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "ice",                    amount = 1, independent_probability = 0.07, show_details_in_recipe_tooltip = false},
          --10
          {type = "item", name = "iron-gear-wheel",        amount = 1, independent_probability = 0.10, show_details_in_recipe_tooltip = false},
          --15
          {type = "item", name = "copper-cable",           amount = 1, independent_probability = 0.04, show_details_in_recipe_tooltip = false},
          {type = "item", name = "stone",                  amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "electric-engine-unit",   amount = 1, independent_probability = 0.06, show_details_in_recipe_tooltip = false},
          --14
          {type = "item", name = "plastic-bar",            amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          {type = "item", name = "lithium-plate",          amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "supercapacitor",          amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "tungsten-plate",          amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "carbon-fiber",            amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "solar-panel",            amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "space-platform-foundation", amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "boiler",                  amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "depleted-uranium-fuel-cell",   amount = 1, independent_probability = 0.03, show_details_in_recipe_tooltip = false},
          --10
          {type = "item", name = "holmium-plate",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "spoilage",   amount = 4, independent_probability = 0.03, show_details_in_recipe_tooltip = false},
          {type = "item", name = "flying-robot-frame",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "steam-turbine",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "laser-turret",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          --10
          {type = "item", name = "gun-turret",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "iron-plate",   amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          {type = "item", name = "pipe",   amount = 1, independent_probability = 0.05, show_details_in_recipe_tooltip = false},
          {type = "item", name = "storage-tank",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "rocket",   amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          --10
          {type = "item", name = "inserter",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "pump",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "medium-electric-pole",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "small-lamp",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "gold-ore",   amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          {type = "item", name = "arithmetic-combinator",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "constant-combinator",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "display-panel",   amount = 1, independent_probability = 0.01, show_details_in_recipe_tooltip = false},
          {type = "item", name = "heat-pipe",   amount = 1, independent_probability = 0.02, show_details_in_recipe_tooltip = false},
          --11
          {type = "item", name = "scrap",   amount = 1, independent_probability = 0.11, show_details_in_recipe_tooltip = false},

        }
    },
    {
      type ="recipe",
      name ="gold-plate",
      categories ={"metallurgy"},
      icon ="__secretas__/graphics/icons/gold-plate.png",
      enabled = false,
      ingredients =
      {

        {type ="item", name ="gold-ore", amount = 4},
      },

      energy_required = 5,
      results =
      {
        {type ="item", name ="gold-plate", amount = 1}
      },
      allow_productivity = true,
      allow_quality = true,
      main_product ="gold-plate",
      factoriopedia_description ="Refine gold from ore."
    },
    {
      type ="recipe",
      name ="gold-plate-alt",
      categories ={"smelting"},
      icon ="__secretas__/graphics/icons/gold-plate.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="gold-ore", amount = 4},
      },

      energy_required = 6,
      results =
      {
        {type ="item", name ="gold-plate", amount = 1}
      },
      allow_productivity = true,
      allow_quality = true,
      main_product ="gold-plate",
      factoriopedia_description ="Refine gold from ore."
    },
    {
      type = "recipe",
      name = "auric-asteroid-crushing",
      icon = "__secretas__/graphics/icons/auric-asteroid-crushing.png",
      categories = {"crushing"},
      subgroup="space-crushing",
      order = "c-a-a",
      auto_recycle = false,
      enabled = false,
      ingredients =
      {
        {type = "item", name = "auric-asteroid-chunk", amount = 1},
      },
      energy_required = 2,
      results =
      {
        {type = "item", name = "gold-ore", amount = 10},
        {type = "item", name = "auric-asteroid-chunk", amount = 1, independent_probability = 0.1}
      },
      allow_productivity = true,
      allow_decomposition = false,
      allow_quality = true,
    },
    {
      type ="recipe",
      name ="golden-science-pack",
      categories ={"crafting-with-fluid","metallurgy"},
      icon ="__secretas__/graphics/icons/golden-science-pack.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="gold-plate", amount = 14},
        {type ="item", name ="steam-turbine", amount = 2},
        {type ="item", name ="solid-fuel", amount = 7},
        {type ="item", name ="arithmetic-combinator", amount = 14},
        {type ="fluid", name ="steam", amount = 250},
      },
      surface_conditions =
      {
        {
          property = "pressure",
          min = 200,
          max = 280
        }
      },
      energy_required = 20,
      results =
      {
        {type ="item", name ="golden-science-pack", amount = 8},
        {type ="item", name ="golden-science-pack", amount = 1, independent_probability = 0.652},
      },
      allow_productivity = true,
      allow_quality = true,
      main_product ="golden-science-pack",
      factoriopedia_description ="Refine gold into science.",
      auto_recycle = false,
    },
    {
      type ="recipe",
      name ="hyper-inserter",
      categories ={"crafting"},
      icon ="__secretas__/graphics/icons/hyper-inserter.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="gold-plate", amount = 10},
        {type ="item", name ="low-density-structure", amount = 20},
        {type ="item", name ="advanced-circuit", amount = 10},
        {type ="item", name ="bulk-inserter", amount = 1},
        {type ="item", name ="electric-engine-unit", amount = 10},
        {type ="item", name ="steel-plate", amount = 5},
        {type ="item", name ="iron-gear-wheel", amount = 40},
        {type ="item", name ="uranium-fuel-cell", amount = 3},
      },

      energy_required = 16,
      results =
      {
        {type ="item", name ="hyper-inserter", amount = 1},

      },
      allow_productivity = false,
      allow_quality = true,
      main_product ="hyper-inserter",
    },
    {
      type ="recipe",
      name ="steam-recycler",
      categories ={"crafting"},
      icon ="__secretas__/graphics/icons/steam-recycler.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="processing-unit", amount = 10},
        {type ="item", name ="steel-plate", amount = 20},
        {type ="item", name ="iron-gear-wheel", amount = 40},
        {type ="item", name ="concrete", amount = 20},
        {type ="item", name ="copper-plate", amount = 25},
        {type ="item", name ="pipe", amount = 20},
        {type ="item", name ="iron-plate", amount = 10},
      },

      energy_required = 5,
      results =
      {
        {type ="item", name ="steam-recycler", amount = 1},

      },
      allow_productivity = false,
      allow_quality = true,
      main_product ="steam-recycler",
    },
    {
      type ="recipe",
      name ="golden-egg",
      categories ={"crafting"},
      icon ="__secretas__/graphics/icons/golden-biter-egg.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="biter-egg", amount = 1},
        {type ="item", name ="jelly", amount = 10},
        {type ="item", name ="gold-plate", amount = 2},
      },

      energy_required = 5,
      results =
      {
        {type ="item", name ="golden-biter-egg", amount = 1},

      },
      allow_productivity = true,
      allow_quality = true,
      main_product ="golden-biter-egg",
      maximum_productivity = 2,
    },
    {
      type ="recipe",
      name ="quality-module-4-S",
      categories ={"electromagnetics"},
      icon ="__secretas__/graphics/icons/quality-module-4.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="quality-module-3", amount = 4},
        {type ="item", name ="processing-unit", amount = 7},
        {type ="item", name ="advanced-circuit", amount = 7},
        {type ="item", name ="gold-plate", amount = 6},
        {type ="item", name ="supercapacitor", amount = 4},
      },

      energy_required = 120,
      results =
      {
        {type ="item", name ="quality-module-4-S", amount = 1},

      },
      allow_quality = true,
      main_product ="quality-module-4-S",
    },
    {
      type ="recipe",
      name ="efficiency-module-4-S",
      categories ={"electromagnetics"},
      icon ="__secretas__/graphics/icons/efficiency-module-4.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="efficiency-module-3", amount = 4},
        {type ="item", name ="processing-unit", amount = 7},
        {type ="item", name ="advanced-circuit", amount = 7},
        {type ="item", name ="gold-plate", amount = 6},
        {type ="item", name ="bioflux", amount = 4},
      },

      energy_required = 120,
      results =
      {
        {type ="item", name ="efficiency-module-4-S", amount = 1},

      },
      allow_quality = true,
      main_product ="efficiency-module-4-S",
    },
    {
      type ="recipe",
      name ="productivity-module-4-S",
      categories ={"electromagnetics"},
      icon ="__secretas__/graphics/icons/productivity-module-4.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="productivity-module-3", amount = 4},
        {type ="item", name ="processing-unit", amount = 7},
        {type ="item", name ="advanced-circuit", amount = 7},
        {type ="item", name ="gold-plate", amount = 6},
        {type ="item", name ="golden-biter-egg", amount = 2},
      },

      energy_required = 120,
      results =
      {
        {type ="item", name ="productivity-module-4-S", amount = 1},

      },
      allow_quality = true,
      main_product ="productivity-module-4-S",
    },
    {
      type ="recipe",
      name ="speed-module-4-S",
      categories ={"electromagnetics"},
      icon ="__secretas__/graphics/icons/speed-module-4.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="speed-module-3", amount = 4},
        {type ="item", name ="processing-unit", amount = 7},
        {type ="item", name ="advanced-circuit", amount = 7},
        {type ="item", name ="gold-plate", amount = 6},
        {type ="item", name ="tungsten-plate", amount = 5},
      },

      energy_required = 120,
      results =
      {
        {type ="item", name ="speed-module-4-S", amount = 1},

      },
      allow_quality = true,
      main_product ="speed-module-4-S",
    },
    {
      type = "recipe",
      name = "solid-fuel-liquefaction",
      icons = {
        {
          icon = "__base__/graphics/icons/fluid/coal-liquefaction.png",
        },
        {
          icon = "__base__/graphics/icons/solid-fuel.png",
          scale = 0.2
        },

      },
      categories = {"oil-processing"},
      enabled = false,
      energy_required = 5,
      ingredients =
      {
        {type = "item", name = "solid-fuel", amount = 5},
        {type = "fluid", name = "heavy-oil", amount = 50, ignored_by_stats = 50},
        {type = "fluid", name = "steam", amount = 250}
      },
      results =
      {
        {type = "fluid", name = "heavy-oil", amount = 120, ignored_by_stats = 50, ignored_by_productivity = 50},

      },
      allow_productivity = true,

      subgroup = "fluid-recipes",
      order = "a[oil-processing]-c[solid-fuel-liquefaction]",
      allow_decomposition = false
    },
    {
      type ="recipe",
      name ="gold-heat-pipe",
      categories = {"metallurgy","crafting"},
      icon ="__secretas__/graphics/icons/gold-heat-pipe.png",
      enabled = false,
      ingredients =
      {
        {type ="item", name ="gold-plate", amount = 20},
        {type ="item", name ="tungsten-plate", amount = 1},
        {type ="item", name ="steel-plate", amount = 9},

      },

      energy_required = 3,
      results =
      {
        {type ="item", name ="gold-heat-pipe", amount = 1},

      },
      allow_quality = true,
      main_product ="gold-heat-pipe",
    },
    {
      type = "recipe",
      name = "gold-railgun-turret",
      categories = {"cryogenics"},
      enabled = false,
      energy_required = 30,
      ingredients =
      {
        {type = "item", name = "arithmetic-combinator", amount = 20},
        {type = "item", name = "decider-combinator", amount = 20},
        {type = "item", name = "constant-combinator", amount = 1},
        {type = "item", name = "copper-cable", amount = 100},
        {type = "item", name = "processing-unit", amount = 20},
        {type = "item", name = "tungsten-plate", amount = 35},
        {type = "item", name = "superconductor", amount = 50},
        {type = "item", name = "carbon-fiber", amount = 20},
        {type = "item", name = "gold-plate", amount = 200},
        {type = "item", name = "electric-engine-unit", amount = 400},
        {type = "fluid", name = "lubricant", amount = 100}
      },
      results = {{type="item", name="gold-railgun-turret", amount=1}},
      crafting_machine_tint =
      {
        primary = {r = 0.504, g = 0.448, b = 0.321, a = 1.000}, -- #807251ff
        secondary = {r = 143, g = 153, b = 79, a = 1.000}, --rgb(143, 153, 79)
        tertiary = {r = 199, g = 224, b = 102, a = 1.000}, --rgb(199, 224, 102)
        quaternary = {r = 0.246, g = 0.246, b = 0.246, a = 1.000}, -- #3e3e3eff
      }
    },

    {
      type = "recipe",
      name = "pentapod-egg-unrestricted",
      icon = "__space-age__/graphics/icons/pentapod-egg-3.png",
      categories = {"organic"},
      subgroup = "agriculture-processes",
      order = "d[organic-processing]-b[pentapod-egg]",
      auto_recycle = false,
      enabled = false,
      allow_productivity = true,
      --result_is_always_fresh = true,
      hide_from_signal_gui = true,
      energy_required = 60,
      ingredients =
      {
        {type = "item", name = "pentapod-egg", amount = 1, ignored_by_stats = 1},
        {type = "item", name = "nutrients", amount = 60},
        {type = "fluid", name = "water", amount = 150}
      },
      results =
      {
        {type = "item", name = "pentapod-egg", amount = 2, ignored_by_stats = 1, ignored_by_productivity = 1, always_fresh = true}
      },
      crafting_machine_tint =
      {
        primary = {r = 45, g = 129, b = 86, a = 1.000},
        secondary = {r = 122, g = 75, b = 156, a = 1.000},
      }
    },
})