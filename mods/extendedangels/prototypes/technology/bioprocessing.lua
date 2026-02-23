if not angelsmods.bioprocessing then
  return
end

data:extend({
  -- Advanced angel's bioprocessing
  {
    type = "technology",
    name = "angels-advanced-bio-processing",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/algae-farm-tech.png",
    icon_size = 128,
    prerequisites = {
      "angels-bio-processing-blue",
      "production-science-pack",
      "angels-stone-smelting-3",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-algae-farm-5",
      },
    },
    unit = {
      count = 150,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
      },
      time = 30,
    },
  },

  -- Bio farm 3
  {
    type = "technology",
    name = "angels-bio-farm-3",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/base-farm-tech.png",
    icon_size = 128,
    prerequisites = {
      "angels-bio-farm-2",
      "chemical-science-pack",
      "angels-aluminium-smelting-1",
      "angels-stone-smelting-2",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-crop-farm-3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-composter-3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-bio-processor-3",
      },
    },
    unit = {
      count = 150,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
      },
      time = 30,
    },
  },

  -- Bio refugium butchery 3
  {
    type = "technology",
    name = "angels-bio-refugium-butchery-3",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/bio-refugium-butchery-tech.png",
    icon_size = 160,
    order = "c-a",
    prerequisites = {
      "angels-bio-refugium-butchery-2",
      "production-science-pack",
      "angels-stone-smelting-3",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-butchery-3",
      },
    },
    unit = {
      count = 150,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "angels-token-bio", 1 },
      },
      time = 30,
    },
  },

  -- Bio farm advanced upgrades
  {
    type = "technology",
    name = "angels-bio-farm-advanced-upgrade-1",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/base-farm-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-temperate-farming-2",
      "angels-bio-desert-farming-2",
      "angels-bio-swamp-farming-2",
      "production-science-pack",
      "angels-stone-smelting-3",
      
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-temperate-farm-2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-desert-farm-2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-swamp-farm-2",
      },
    },
    unit = {
      count = 128,
      ingredients = {
        { "automation-science-pack", 4 },
        { "logistic-science-pack", 4 },
        { "chemical-science-pack", 4 },
        { "production-science-pack", 4 },
        { "angels-token-bio", 1 },
      },
      time = 30,
    },
  },

  {
    type = "technology",
    name = "angels-bio-farm-advanced-upgrade-2",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/base-farm-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-farm-advanced-upgrade-1",
      "angels-stone-smelting-4",
      "utility-science-pack",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-temperate-farm-3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-desert-farm-3",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-swamp-farm-3",
      },
    },
    unit = {
      count = 256,
      ingredients = {
        { "automation-science-pack", 4 },
        { "logistic-science-pack", 4 },
        { "chemical-science-pack", 4 },
        { "production-science-pack", 4 },
        { "utility-science-pack", 4 },
        { "angels-token-bio", 1 },
      },
      time = 30,
    },
  },

  -- Bio refugium hatchery 2
  {
    type = "technology",
    name = "angels-bio-refugium-hatchery-2",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/bio-refugium-puffer-hatchery-tech.png",
    icon_size = 160,
    order = "c-a",
    prerequisites = {
      "angels-bio-refugium-hatchery",
      "production-science-pack",
      "angels-stone-smelting-3",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-hatchery-2",
      },
    },
    unit = {
      count = 100,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "angels-token-bio", 1 },
      },
      time = 30,
    },
  },

  -- Bio refugium hatchery 3
  {
    type = "technology",
    name = "angels-bio-refugium-hatchery-3",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/bio-refugium-puffer-hatchery-tech.png",
    icon_size = 160,
    order = "c-a",
    prerequisites = {
      "angels-bio-refugium-hatchery-2",
      "angels-stone-smelting-4",
      "production-science-pack",
      "utility-science-pack",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-hatchery-3",
      },
    },
    unit = {
      count = 150,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
        { "angels-token-bio", 1 },
      },
      time = 30,
    },
  },

  -- Bio nutrient paste 2
  {
    type = "technology",
    name = "angels-bio-nutrient-paste-2",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/nutrient-extractor-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-nutrient-paste",
      "chemical-science-pack",
      "angels-aluminium-smelting-1",
      "angels-stone-smelting-2",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-nutrient-extractor-2",
      },
    },
    unit = {
      count = 80,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
      },
      time = 30,
    },
  },

  -- Bio nutrient paste 3
  {
    type = "technology",
    name = "angels-bio-nutrient-paste-3",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/nutrient-extractor-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-nutrient-paste-2",
      "production-science-pack",
      "angels-stone-smelting-3",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-nutrient-extractor-3",
      },
    },
    unit = {
      count = 120,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
      },
      time = 30,
    },
  },

  -- Bio refugium fish 3
  {
    type = "technology",
    name = "angels-bio-refugium-fish-3",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/bio-refugium-fish-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-refugium-fish-2",
      "chemical-science-pack",
      "angels-aluminium-smelting-1",
      "angels-stone-smelting-2",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-refugium-fish-2",
      },
    },
    unit = {
      count = 100,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
      },
      time = 30,
    },
  },

  -- Bio refugium fish 4
  {
    type = "technology",
    name = "angels-bio-refugium-fish-4",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/bio-refugium-fish-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-refugium-fish-3",
      "production-science-pack",
      "angels-stone-smelting-3",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-refugium-fish-3",
      },
    },
    unit = {
      count = 150,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
      },
      time = 30,
    },
  },

  -- Bio refugium puffer 5
  {
    type = "technology",
    name = "angels-bio-refugium-puffer-5",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/bio-refugium-puffer-breeding-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-refugium-puffer-4",
      "angels-stone-smelting-4",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-refugium-puffer-2",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-bio-refugium-puffer-3",
      },
    },
    unit = {
      count = 150,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "angels-token-bio", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
      },
      time = 30,
    },
  },

    -- Bio Press 3
  {
    type = "technology",
    name = "angels-bio-pressing-3",
    icon = "__angelsbioprocessinggraphics__/graphics/technology/press-tech.png",
    icon_size = 128,
    order = "c-a",
    prerequisites = {
      "angels-bio-pressing-2",
      "production-science-pack",
      "angels-stone-smelting-3",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-bio-press-3",
      },
    },
    unit = {
      count = 100,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
      },
      time = 30,
    },
  },
})
