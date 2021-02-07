-- We may want to remove our coal processing techs and move the unlocks to a
-- similar tech from other mods. So let's store the unlocks for each tech for
-- easier shuffling!

return {
  -- "bi-tech-coal-processing-1"
  {
    {
      type = "unlock-recipe",
      recipe = "bi-charcoal-1"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-charcoal-2"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-ash-2"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-ash-1"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-wood-fuel-brick"
    },
    --~ {
      --~ type = "unlock-recipe",
      --~ recipe = "bi-solid-fuel"
    --~ },
    {
      type = "unlock-recipe",
      recipe = "bi-seed-2"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-seedling-2"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-logs-2"
    },
    --~ {
      --~ type = "unlock-recipe",
      --~ recipe = "bi-stone-brick"
    --~ },
    {
      type = "unlock-recipe",
      recipe = "bi-cokery"
    },
  },

  -- "bi-tech-coal-processing-2"
  {
    {
      type = "unlock-recipe",
      recipe = "bi-coal-1"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-pellet-coke"
    },
    -- Moved here from "bi-tech-coal-processing-1" (0.18.29):
    {
      type = "unlock-recipe",
      recipe = "bi-solid-fuel"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-stone-brick"
    },
  },

  -- "bi-tech-coal-processing-3"
  {
    {
      type = "unlock-recipe",
      recipe = "bi-coal-2"
    },
    {
      type = "unlock-recipe",
      recipe = "bi-coke-coal"
    },
  },
}
