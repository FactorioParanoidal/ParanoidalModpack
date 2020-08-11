local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/technology/"

if BI.Settings.Bio_Cannon then

  data:extend({
    {
      type = "technology",
      name = "bi-tech-bio-cannon",
      icon_size = 128,
      icon = ICONPATH .. "Bio_Cannon.png",
      icons = {
        {
          icon = ICONPATH .. "Bio_Cannon.png",
          icon_size = 128,
        }
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "bi-bio-cannon"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-bio-cannon-proto-ammo"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-bio-cannon-basic-ammo"
        },
        {
          type = "unlock-recipe",
          recipe = "bi-bio-cannon-poison-ammo"
        },

      },
      prerequisites = {"military-2"},
      unit =
      {
        count = 300,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"military-science-pack", 1},
        },
        time = 30,
      }
    },

  })

end
