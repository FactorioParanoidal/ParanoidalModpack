local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/technology/"

if BI.Settings.BI_Bio_Fuel or mods["Natural_Evolution_Buildings"] then

  data:extend(
  {
    {
      type = "technology",
      name = "bi-tech-advanced-biotechnology",
      icon_size = 128,
      icon = ICONPATH .. "Biomass_128.png",
      icons = {
        {
          icon = ICONPATH .. "Biomass_128.png",
          icon_size = 128,
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
          recipe = "bi-adv-fertiliser-2"
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
      },
      prerequisites = {
        "bi-tech-fertiliser"
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
end
