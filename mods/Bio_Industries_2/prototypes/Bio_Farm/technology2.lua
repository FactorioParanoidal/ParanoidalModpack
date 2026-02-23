local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/technology/"


  data:extend(
  {
    {
      type = "technology",
      name = "bi-tech-advanced-biotechnology",
      icon_size = 256,
      icon = ICONPATH .. "bi-tech-biomass.png",
      icons = {
        {
          icon = ICONPATH .. "bi-tech-biomass.png",
          icon_size = 256,
        }
      },
      effects = {
        {
          type = "unlock-recipe",
          recipe = "bi-seed-4"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-seedling-4"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-logs-4"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-adv-fertilizer-2"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-seed-bomb-advanced"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-arboretum-r3"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-arboretum-r5"
        },
        -- Added for 0.18.29: We always want to make advanced fertilizer, so we need to
        -- unlock the bio-reactor and the most basic recipe for algae biomass even if
        -- BI.Settings.BI_Bio_Fuel has been turned off!
        {
          type = "unlock-recipe",
          recipe = "bi-bio-reactor"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-biomass-1"
        },

        -- Added for 0.18.29: Now that we always make advanced fertilizer, we can also add
        -- the advanced recipe for purified air even if BI.Settings.BI_Bio_Fuel has been
        -- turned off!
        {
          type = "unlock-recipe",
          recipe = "bi-purified-air-2"
        },


      },
      prerequisites = {
        "bi-tech-fertilizer"
      },
      unit = {
        count = 200,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        },
        time = 30
      }
    },
  })
