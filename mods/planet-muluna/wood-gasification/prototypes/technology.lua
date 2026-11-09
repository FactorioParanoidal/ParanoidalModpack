Muluna:extend({
  {
    type = "technology",
    name = "wood-gas-processing",
    icon = "__muluna-graphics__/graphics/wood-gasification/technology/wood-gas-processing.png",
    icon_size = 256,
    prerequisites = {"oil-processing"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "wood-gasification",
      },
      {
        type = "unlock-recipe",
        recipe = "solid-fuel-from-tar"
      },
      -- {
      --   type = "unlock-recipe",
      --   recipe = "greenhouse"
      -- },
    },
    unit =
    {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}},
      time = 30
    },
    order = "d-b"
  },
  {
    type = "technology",
    name = "wood-gas-processing-to-crude-oil",
    icon = "__muluna-graphics__/graphics/wood-gasification/technology/wood-gas-processing-to-crude-oil.png",
    icon_size = 256,
    prerequisites = {"wood-gas-processing"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "crude-oil-from-tar",
      },
    },
    unit =
    {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "d-b"
  },
  {
    type = "technology",
    name = "advanced-wood-gas-processing",
    icon = "__muluna-graphics__/graphics/wood-gasification/technology/advanced-wood-gas-processing.png",
    icon_size = 256,
    prerequisites = {"wood-gas-processing"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-wood-gasification",
      }
    },
    unit =
    {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "d-b"
  },
  -- {
  --   type = "technology",
  --   name = "wood-seed-greenhouse",
  --   localised_name = {"", {"entity-name.E-greenhouse"}, " ", {"item-name.tree-seed"}},
  --   icon = "__space-age__/graphics/icons/tree-seed.png",
  --   icon_size = 64,
  --   essential = false,
  --   effects =
  --   {
  --     {
  --       type = "unlock-recipe",
  --       recipe = "wood-seed-greenhouse"
  --     }
  --   },
  --   prerequisites = {"agriculture"},
  --   research_trigger =
  --   {
  --     type = "mine-entity",
  --     entity = "dry-tree"
  --   }
  -- },
})
