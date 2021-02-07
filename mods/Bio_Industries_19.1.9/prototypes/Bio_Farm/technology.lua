local BioInd = require('common')('Bio_Industries')
local coal_processing = require("prototypes.Bio_Farm.coal_processing")

local ICONPATH = BioInd.modRoot .. "/graphics/technology/"

---- Bio Farm
data:extend({
  {
    type = "technology",
    name = "bi-tech-bio-farming",
    icon_size = 128,
    icon = ICONPATH .. "Bio_Farm_Tech_128.png",
    icons = {
      {
        icon = ICONPATH .. "Bio_Farm_Tech_128.png",
        icon_size = 128,
      }
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "bi-seed-1"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-seedling-1"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-logs-1"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-bio-greenhouse"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-bio-farm"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-arboretum"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-arboretum-r1"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-woodpulp"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-resin-pulp"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-wood-from-pulp"
      },
    },
    prerequisites = {"optics"},
    unit = {
      count = 25,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 20
    },
  },

  {
    type = "technology",
    name = "bi-tech-coal-processing-1",
    localised_name = {"technology-name.bi-tech-coal-processing-1"},
    localised_description = {"technology-description.bi-tech-coal-processing-1"},
    icon_size = 128,
    icon = ICONPATH .. "Coal_128.png",
    icons = {
      {
        icon = ICONPATH .. "Coal_128.png",
        icon_size = 128,
      }
    },
    --~ effects = {
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-charcoal-1"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-charcoal-2"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-ash-2"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-ash-1"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-wood-fuel-brick"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-seed-2"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-seedling-2"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-logs-2"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-cokery"
      --~ },
    --~ },
    effects = coal_processing[1],
    prerequisites = {"advanced-material-processing"},
    unit = {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
  },

  {
    type = "technology",
    name = "bi-tech-coal-processing-2",
    localised_name = {"technology-name.bi-tech-coal-processing-2"},
    localised_description = {"technology-description.bi-tech-coal-processing-2"},
    icon_size = 128,
    icon = ICONPATH .. "Coal_128.png",
    icons = {
      {
        icon = ICONPATH .. "Coal_128.png",
        icon_size = 128,
      }
    },
    --~ effects = {
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-coal-1"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-pellet-coke"
      --~ },
      --~ -- Moved here from "bi-tech-coal-processing-1" (0.18.29):
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-solid-fuel"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-stone-brick"
      --~ },
    --~ },
    effects = coal_processing[2],
    --~ prerequisites = {"bi-tech-coal-processing-1"},
    prerequisites = {"bi-tech-coal-processing-1", "chemical-science-pack"},
    unit = {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 35
    },
    -- Changed for 0.18.34/1.1.4 (Fixes that tech is not listed among researched techs.)
    --~ upgrade = true,
  },

  {
    type = "technology",
    name = "bi-tech-coal-processing-3",
    localised_name = {"technology-name.bi-tech-coal-processing-3"},
    localised_description = {"technology-description.bi-tech-coal-processing-3"},
    icon_size = 128,
    icon = ICONPATH .. "Coal_128.png",
    icons = {
      {
        icon = ICONPATH .. "Coal_128.png",
        icon_size = 128,
      }
    },
   --~ effects = {
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-coal-2"
      --~ },
      --~ {
        --~ type = "unlock-recipe",
        --~ recipe = "bi-coke-coal"
      --~ },
    --~ },
    effects = coal_processing[3],
    --~ prerequisites = {"bi-tech-coal-processing-2"},
    prerequisites = {"bi-tech-coal-processing-2", "production-science-pack"},
    unit = {
      count = 250,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 40
    },
    -- Changed for 0.18.34/1.1.4 (Fixes that tech is not listed among researched techs.)
    --~ upgrade = true,
  },

  {
    type = "technology",
    name = "bi-tech-fertilizer",
    icon_size = 128,
    icon = ICONPATH .. "Fertilizer_128.png",
    icons = {
      {
        icon = ICONPATH .. "Fertilizer_128.png",
        icon_size = 128,
      }
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "bi-liquid-air"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-nitrogen"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-fertilizer-1"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-seed-3"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-seedling-3"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-logs-3"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-bio-garden"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-purified-air-1"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-seed-bomb-basic"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-seed-bomb-standard"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-arboretum-r2"
      },
      {
        type = "unlock-recipe",
        recipe = "bi-arboretum-r4"
      },
    },
    prerequisites = {
      "fluid-handling",
      "bi-tech-bio-farming"
    },
    unit = {
      count = 250,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    }
  }
})
