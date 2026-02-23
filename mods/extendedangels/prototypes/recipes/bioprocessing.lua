if not angelsmods.bioprocessing then
  return
end

angelsmods.functions.RB.build({
  -- Algae farm 5
  {
    type = "recipe",
    name = "angels-algae-farm-5",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-algae-farm-4", amount = 1 },
      { type = "item", name = "t4-plate", amount = 11 },
      { type = "item", name = "t4-circuit", amount = 4 },
      { type = "item", name = "t4-brick", amount = 11 },
      { type = "item", name = "t4-pipe", amount = 18 },
    },
    results = { { type = "item", name = "angels-algae-farm-5", amount = 1 } },
  },

  -- Temperate tree seed generator 2
  {
    type = "recipe",
    name = "angels-bio-generator-temperate-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-generator-temperate-1", amount = 1 },
      { type = "item", name = "angels-temperate-tree", amount = 1 },
      { type = "item", name = "t2-plate", amount = 2 },
      { type = "item", name = "t2-circuit", amount = 2 },
      { type = "item", name = "t2-brick", amount = 1 },
      { type = "item", name = "t2-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-bio-generator-temperate-2", amount = 1 } },
  },

  -- Swamp tree seed generator 2
  {
    type = "recipe",
    name = "angels-bio-generator-swamp-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-generator-swamp-1", amount = 1 },
      { type = "item", name = "angels-swamp-tree", amount = 1 },
      { type = "item", name = "t2-plate", amount = 2 },
      { type = "item", name = "t2-circuit", amount = 2 },
      { type = "item", name = "t2-brick", amount = 1 },
      { type = "item", name = "t2-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-bio-generator-swamp-2", amount = 1 } },
  },
  -- Desert tree seed generator 2
  {
    type = "recipe",
    name = "angels-bio-generator-desert-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-generator-desert-1", amount = 1 },
      { type = "item", name = "angels-desert-tree", amount = 1 },
      { type = "item", name = "t2-plate", amount = 2 },
      { type = "item", name = "t2-circuit", amount = 2 },
      { type = "item", name = "t2-brick", amount = 1 },
      { type = "item", name = "t2-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-bio-generator-desert-2", amount = 1 } },
  },

  -- Arboretum 2
  {
    type = "recipe",
    name = "angels-bio-arboretum-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-arboretum-1", amount = 1 },
      { type = "item", name = "t2-plate", amount = 6 },
      { type = "item", name = "t2-circuit", amount = 2 },
      { type = "item", name = "t2-brick", amount = 6 },
      { type = "item", name = "t2-pipe", amount = 8 },
    },
    results = { { type = "item", name = "angels-bio-arboretum-2", amount = 1 } },
  },

  -- Temperate tree seed generator 3
  {
    type = "recipe",
    name = "angels-bio-generator-temperate-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-generator-temperate-2", amount = 1 },
      { type = "item", name = "angels-temperate-tree", amount = 1 },
      { type = "item", name = "t3-plate", amount = 2 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 1 },
      { type = "item", name = "t3-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-bio-generator-temperate-3", amount = 1 } },
  },

  -- Swamp tree seed generator 3
  {
    type = "recipe",
    name = "angels-bio-generator-swamp-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-generator-swamp-2", amount = 1 },
      { type = "item", name = "angels-swamp-tree", amount = 1 },
      { type = "item", name = "t3-plate", amount = 2 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 1 },
      { type = "item", name = "t3-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-bio-generator-swamp-3", amount = 1 } },
  },

  -- Desert tree seed generator 3
  {
    type = "recipe",
    name = "angels-bio-generator-desert-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-generator-desert-2", amount = 1 },
      { type = "item", name = "angels-desert-tree", amount = 1 },
      { type = "item", name = "t3-plate", amount = 2 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 1 },
      { type = "item", name = "t3-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-bio-generator-desert-3", amount = 1 } },
  },

  --Arboretum 3
  {
    type = "recipe",
    name = "angels-bio-arboretum-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-arboretum-2", amount = 1 },
      { type = "item", name = "t3-plate", amount = 6 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 6 },
      { type = "item", name = "t3-pipe", amount = 8 },
    },
    results = { { type = "item", name = "angels-bio-arboretum-3", amount = 1 } },
  },

  --Bio press 2
  {
    type = "recipe",
    name = "angels-bio-press-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-press", amount = 1 },
      { type = "item", name = "t3-plate", amount = 2 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 1 },
      { type = "item", name = "t3-pipe", amount = 1 },
      { type = "item", name = "t3-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-bio-press-2", amount = 1 } },
  },

  -- Bio press 3
  {
    type = "recipe",
    name = "angels-bio-press-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-press-2", amount = 1 },
      { type = "item", name = "t4-plate", amount = 2 },
      { type = "item", name = "t4-circuit", amount = 2 },
      { type = "item", name = "t4-brick", amount = 1 },
      { type = "item", name = "t4-pipe", amount = 1 },
      { type = "item", name = "t4-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-bio-press-3", amount = 1 } },
  },

  -- Bio processor 2
  {
    type = "recipe",
    name = "angels-bio-processor-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-processor", amount = 1 },
      { type = "item", name = "t2-plate", amount = 5 },
      { type = "item", name = "t2-circuit", amount = 8 },
      { type = "item", name = "t2-brick", amount = 5 },
      { type = "item", name = "t2-gears", amount = 4 },
    },
    results = { { type = "item", name = "angels-bio-processor-2", amount = 1 } },
  },

  -- Bio processor 3
  {
    type = "recipe",
    name = "angels-bio-processor-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-processor-2", amount = 1 },
      { type = "item", name = "t3-plate", amount = 5 },
      { type = "item", name = "t3-circuit", amount = 8 },
      { type = "item", name = "t3-brick", amount = 5 },
      { type = "item", name = "t3-gears", amount = 4 },
    },
    results = { { type = "item", name = "angels-bio-processor-3", amount = 1 } },
  },

  -- Butchery 2
  {
    type = "recipe",
    name = "angels-bio-butchery-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-butchery", amount = 1 },
      { type = "item", name = "t3-plate", amount = 3 },
      { type = "item", name = "t3-circuit", amount = 1 },
      { type = "item", name = "t3-brick", amount = 2 },
      { type = "item", name = "t3-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-bio-butchery-2", amount = 1 } },
  },

  -- Butchery 3
  {
    type = "recipe",
    name = "angels-bio-butchery-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-butchery-2", amount = 1 },
      { type = "item", name = "t4-plate", amount = 3 },
      { type = "item", name = "t4-circuit", amount = 1 },
      { type = "item", name = "t4-brick", amount = 2 },
      { type = "item", name = "t4-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-bio-butchery-3", amount = 1 } },
  },

  -- Composter 2
  {
    type = "recipe",
    name = "angels-composter-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-composter", amount = 1 },
      { type = "item", name = "t2-plate", amount = 2 },
      { type = "item", name = "t2-circuit", amount = 2 },
      { type = "item", name = "t2-brick", amount = 2 },
      { type = "item", name = "t2-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-composter-2", amount = 1 } },
  },

  -- Composter 3
  {
    type = "recipe",
    name = "angels-composter-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-composter-2", amount = 1 },
      { type = "item", name = "t3-plate", amount = 2 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 2 },
      { type = "item", name = "t3-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-composter-3", amount = 1 } },
  },

  -- Basic farm 2
  {
    type = "recipe",
    name = "angels-crop-farm-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-crop-farm", amount = 1 },
      { type = "item", name = "t2-plate", amount = 8 },
      { type = "item", name = "t2-circuit", amount = 2 },
      { type = "item", name = "t2-brick", amount = 9 },
      { type = "item", name = "t2-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-crop-farm-2", amount = 1 } },
  },

  -- Basic farm 3
  {
    type = "recipe",
    name = "angels-crop-farm-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-crop-farm-2", amount = 1 },
      { type = "item", name = "t3-plate", amount = 8 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 9 },
      { type = "item", name = "t3-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-crop-farm-3", amount = 1 } },
  },

  -- Temperate-environment farm 2
  {
    type = "recipe",
    name = "angels-temperate-farm-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-temperate-farm", amount = 1 },
      { type = "item", name = "angels-temperate-upgrade", amount = 1 },
      { type = "item", name = "t4-plate", amount = 8 },
      { type = "item", name = "t4-circuit", amount = 2 },
      { type = "item", name = "t4-brick", amount = 9 },
      { type = "item", name = "t4-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-temperate-farm-2", amount = 1 } },
  },

  -- Temperate-environment farm 3
  {
    type = "recipe",
    name = "angels-temperate-farm-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-temperate-farm-2", amount = 1 },
      { type = "item", name = "angels-temperate-upgrade", amount = 1 },
      { type = "item", name = "t5-plate", amount = 8 },
      { type = "item", name = "t5-circuit", amount = 2 },
      { type = "item", name = "t5-brick", amount = 9 },
      { type = "item", name = "t5-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-temperate-farm-3", amount = 1 } },
  },

  -- Desert-environment farm 2
  {
    type = "recipe",
    name = "angels-desert-farm-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-desert-farm", amount = 1 },
      { type = "item", name = "angels-desert-upgrade", amount = 1 },
      { type = "item", name = "t4-plate", amount = 8 },
      { type = "item", name = "t4-circuit", amount = 2 },
      { type = "item", name = "t4-brick", amount = 9 },
      { type = "item", name = "t4-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-desert-farm-2", amount = 1 } },
  },

  -- Desert-environment farm 3
  {
    type = "recipe",
    name = "angels-desert-farm-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-desert-farm-2", amount = 1 },
      { type = "item", name = "angels-desert-upgrade", amount = 1 },
      { type = "item", name = "t5-plate", amount = 8 },
      { type = "item", name = "t5-circuit", amount = 2 },
      { type = "item", name = "t5-brick", amount = 9 },
      { type = "item", name = "t5-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-desert-farm-3", amount = 1 } },
  },

  -- Swamp-environment farm 2
  {
    type = "recipe",
    name = "angels-swamp-farm-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-swamp-farm", amount = 1 },
      { type = "item", name = "angels-swamp-upgrade", amount = 1 },
      { type = "item", name = "t4-plate", amount = 8 },
      { type = "item", name = "t4-circuit", amount = 2 },
      { type = "item", name = "t4-brick", amount = 9 },
      { type = "item", name = "t4-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-swamp-farm-2", amount = 1 } },
  },

  -- Swamp-environment farm 3
  {
    type = "recipe",
    name = "angels-swamp-farm-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-swamp-farm-2", amount = 1 },
      { type = "item", name = "angels-swamp-upgrade", amount = 1 },
      { type = "item", name = "t5-plate", amount = 8 },
      { type = "item", name = "t5-circuit", amount = 2 },
      { type = "item", name = "t5-brick", amount = 9 },
      { type = "item", name = "t5-pipe", amount = 3 },
    },
    results = { { type = "item", name = "angels-swamp-farm-3", amount = 1 } },
  },

  -- Hatchery 2
  {
    type = "recipe",
    name = "angels-bio-hatchery-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-hatchery", amount = 1 },
      { type = "item", name = "t4-plate", amount = 2 },
      { type = "item", name = "t4-circuit", amount = 4 },
      { type = "item", name = "t4-brick", amount = 2 },
    },
    results = { { type = "item", name = "angels-bio-hatchery-2", amount = 1 } },
  },

  -- Hatchery 3
  {
    type = "recipe",
    name = "angels-bio-hatchery-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-hatchery-2", amount = 1 },
      { type = "item", name = "t5-plate", amount = 2 },
      { type = "item", name = "t5-circuit", amount = 4 },
      { type = "item", name = "t5-brick", amount = 2 },
    },
    results = { { type = "item", name = "angels-bio-hatchery-3", amount = 1 } },
  },

  -- Nutrient extractor 2
  {
    type = "recipe",
    name = "angels-nutrient-extractor-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-nutrient-extractor", amount = 1 },
      { type = "item", name = "t3-plate", amount = 1 },
      { type = "item", name = "t3-circuit", amount = 2 },
      { type = "item", name = "t3-brick", amount = 1 },
      { type = "item", name = "t3-pipe", amount = 2 },
      { type = "item", name = "t3-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-nutrient-extractor-2", amount = 1 } },
  },

  -- Nutrient extractor 3
  {
    type = "recipe",
    name = "angels-nutrient-extractor-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-nutrient-extractor-2", amount = 1 },
      { type = "item", name = "t4-plate", amount = 1 },
      { type = "item", name = "t4-circuit", amount = 2 },
      { type = "item", name = "t4-brick", amount = 1 },
      { type = "item", name = "t4-pipe", amount = 2 },
      { type = "item", name = "t4-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-nutrient-extractor-3", amount = 1 } },
  },

  -- Fish tank 2
  {
    type = "recipe",
    name = "angels-bio-refugium-fish-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-refugium-fish", amount = 1 },
      { type = "item", name = "t3-plate", amount = 2 },
      { type = "item", name = "t3-circuit", amount = 5 },
      { type = "item", name = "t3-brick", amount = 4 },
      { type = "item", name = "t3-pipe", amount = 25 },
    },
    results = { { type = "item", name = "angels-bio-refugium-fish-2", amount = 1 } },
  },
  -- Fish tank 3
  {
    type = "recipe",
    name = "angels-bio-refugium-fish-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-refugium-fish-2", amount = 1 },
      { type = "item", name = "t4-plate", amount = 2 },
      { type = "item", name = "t4-circuit", amount = 5 },
      { type = "item", name = "t4-brick", amount = 4 },
      { type = "item", name = "t4-pipe", amount = 25 },
    },
    results = { { type = "item", name = "angels-bio-refugium-fish-3", amount = 1 } },
  },

  -- Puffer refugium 2
  {
    type = "recipe",
    name = "angels-bio-refugium-puffer-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-refugium-puffer", amount = 1 },
      { type = "item", name = "t4-plate", amount = 4 },
      { type = "item", name = "t4-circuit", amount = 4 },
      { type = "item", name = "t4-brick", amount = 3 },
      { type = "item", name = "t4-pipe", amount = 11 },
    },
    results = { { type = "item", name = "angels-bio-refugium-puffer-2", amount = 1 } },
  },

  -- Puffer refugium 3
  {
    type = "recipe",
    name = "angels-bio-refugium-puffer-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-refugium-puffer-2", amount = 1 },
      { type = "item", name = "t5-plate", amount = 4 },
      { type = "item", name = "t5-circuit", amount = 4 },
      { type = "item", name = "t5-brick", amount = 3 },
      { type = "item", name = "t5-pipe", amount = 11 },
    },
    results = { { type = "item", name = "angels-bio-refugium-puffer-3", amount = 1 } },
  },

  -- Biter refugium 2
  {
    type = "recipe",
    name = "angels-bio-refugium-biter-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-refugium-biter", amount = 1 },
      { type = "item", name = "t5-plate", amount = 10 },
      { type = "item", name = "t5-circuit", amount = 4 },
      { type = "item", name = "t5-brick", amount = 19 },
      { type = "item", name = "t5-pipe", amount = 11 },
    },
    results = { { type = "item", name = "angels-bio-refugium-biter-2", amount = 1 } },
  },

  -- Biter refugium 3
  {
    type = "recipe",
    name = "angels-bio-refugium-biter-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-bio-refugium-biter-2", amount = 1 },
      { type = "item", name = "t6-plate", amount = 10 },
      { type = "item", name = "t6-circuit", amount = 4 },
      { type = "item", name = "t6-brick", amount = 19 },
      { type = "item", name = "t6-pipe", amount = 11 },
    },
    results = { { type = "item", name = "angels-bio-refugium-biter-3", amount = 1 } },
  },

  -- Seed extractor 2
  {
    type = "recipe",
    name = "angels-seed-extractor-2",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-seed-extractor", amount = 1 },
      { type = "item", name = "t2-plate", amount = 1 },
      { type = "item", name = "t2-circuit", amount = 4 },
      { type = "item", name = "t2-brick", amount = 1 },
      { type = "item", name = "t2-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-seed-extractor-2", amount = 1 } },
  },

  -- Seed extractor 3
  {
    type = "recipe",
    name = "angels-seed-extractor-3",
    energy_required = 5,
    enabled = false,
    ingredients = {
      { type = "item", name = "angels-seed-extractor-2", amount = 1 },
      { type = "item", name = "t3-plate", amount = 1 },
      { type = "item", name = "t3-circuit", amount = 4 },
      { type = "item", name = "t3-brick", amount = 1 },
      { type = "item", name = "t3-gears", amount = 2 },
    },
    results = { { type = "item", name = "angels-seed-extractor-3", amount = 1 } },
  },
})
