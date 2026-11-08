local techicons = "__Moshine-assets__/graphics/technology/"





data:extend({
  {
    type = "item-group",
    name = "moshine-tech",
    icon = "__core__/graphics/icons/category/unsorted.png",
    icon_size = 128,
    order = "zz"
  },
  {
    type = "item-subgroup",
    name = "moshine-tech-with-datacells",
    group = "moshine-tech",
    order = "e"
  },



  {
    type = "technology",
    name = "planet-discovery-moshine",
    icons = util.technology_icon_constant_planet(techicons .. "moshine-tech-moshine.png"),
    icon_size = 256,
    essential = true,
    effects =
    {
      {
        type = "unlock-space-location",
        space_location = "moshine",
        use_icon_overlay_constant = true
      },
    },
    prerequisites = {"electromagnetic-plant"}, -- Paranoidal: coal liquefaction is hidden in the build (Angels coal chemistry)
    unit =
    {
      count = 750,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1}
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "moshine-concrete-from-molten-iron-and-sand",
    icon = techicons .. "moshine-concrete-from-molten-iron-and-sand.png",
    icon_size = 256,
    --essential = true,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "concrete-from-molten-iron-and-sand"
      },
    },
    prerequisites = {"planet-discovery-moshine"},
    unit =
    {
      count = 250,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1}
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "moshine-petroleum-from-sand-sulfur-steam-carbon",
    icon = techicons .. "moshine-petroleum-from-sand-sulfur-steam-carbon.png",
    icon_size = 256,
    --essential = true,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "petroleum-from-sand-sulfur-steam-carbon"
      },
    },
    prerequisites = {"planet-discovery-moshine"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    },
    --[[
    research_trigger =
    {
      type = "mine-entity",
      entity = "steam-geyser",
    },]]
  },
  {
    type = "technology",
    name = "moshine-tech-silicon",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "silicon"
      },
    },
    prerequisites = {"planet-discovery-moshine"},
    --[[unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 60
    }]]
    research_trigger =
    {
      type = "mine-entity",
      entities = {"multi-ore_dummy_sand"},
    },
  },
  {
    type = "technology",
    name = "moshine-tech-glass",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-glass.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "moshine-glass"
      },
    },
    prerequisites = {"planet-discovery-moshine"},
    unit =
    {
      count = 70,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 60
    }
  },

  {
    type = "technology",
    name = "moshine-tech-silicon-carbide",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon-carbide.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "silicon-carbide"
      },
    },
    prerequisites = {"moshine-tech-silicon"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "moshine-tech-silicon-cell",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-silicon-cell.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "silicon-cell"
      },
    },
    prerequisites = {"moshine-tech-silicon"},
    research_trigger =
    {
      type = "craft-item",
      item = "silicon",
      count = 60
    }
  },
  {
    type = "technology",
    name = "moshine-tech-magnet",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-magnet.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "magnet"
      },
    },
    prerequisites = {"planet-discovery-moshine"},
    --[[unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 60
    }]]
    research_trigger =
    {
      type = "mine-entity",
      entities = {"multi-ore_dummy_neodymium"},
    },
  },
  {
    type = "technology",
    name = "moshine-tech-datacell-empty",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-datacell-empty.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "datacell-empty"
      },
    },
    prerequisites = {"moshine-tech-magnet", "moshine-tech-silicon-cell",},
    --[[unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    }]]
    research_trigger =
    {
      type = "craft-item",
      item = "silicon-cell",
      count = 100
    },
  },
  {
    type = "technology",
    name = "moshine-tech-data-processor-building",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-data-processor-building.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "data-processor"
      },
      {
        type = "unlock-recipe",
        recipe = "optical-cable"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-equation"
      },
    },
    prerequisites = {"moshine-tech-datacell-empty", "automation-3", "productivity-module-2", "moshine-tech-silicon-carbide"},
    unit =
    {
      count = 300,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"electromagnetic-science-pack", 1}
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "moshine-tech-neural_computer",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-neural_computer.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "neural_computer"
      },
    },
    prerequisites = {"moshine-tech-data-processor-building"},
    research_trigger =
    {
      type = "craft-item",
      item = "data-processor",
      count = 1
    },
  },
  {
    type = "technology",
    name = "moshine-tech-opticalfiber-storage-tank",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-opticalfiber-storage-tank.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "opticalfiber-storage-tank"
      },
    },
    prerequisites = {"moshine-tech-neural_computer"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"datacell-equation", 1},
      },
      time = 60
    },
  },
  {
    type = "technology",
    name = "moshine-tech-data-extractor",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-data-extractor.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "data-extractor"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-raw-data"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-remove-raw-data"
      },
    },
    prerequisites = {"circuit-network", "moshine-tech-neural_computer", "moshine-tech-glass"},
    unit =
    {
      count = 10,
      ingredients =
      {
        {"datacell-equation", 1},
      },
      time = 60
    },
  },
  {
    type = "technology",
    name = "moshine-tech-3d-data-storage",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-3d-data-storage.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "3d-data-storage"
      },
    },
    prerequisites = {"moshine-tech-data-extractor"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"datacell-raw-data", 1},
      },
      time = 30
    }
  },

  {
    type = "technology",
    name = "moshine-tech-data-processor",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-data-processor.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "model-unstable"
      },
      {
        type = "unlock-recipe",
        recipe = "model-stable"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-ai-model-data"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-remove-ai-model-data"
      },
    },
    prerequisites = {"moshine-tech-3d-data-storage"},
    unit =
    {
      count = 1000,
      ingredients =
      {
        {"datacell-raw-data", 1},
      },
      time = 10
    }
  },
  {
    type = "technology",
    name = "moshine-tech-processing-grid",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-processing-grid.png",
    icon_size = 256,
    subgroup = "other",
    order = "aaa",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "processing-grid"
      },
      {
        type = "unlock-recipe",
        recipe = "webbed_processor_tile"
      },
      {
        type = "nothing",
        icon = "__Moshine__/graphics/icons/data/processing-grid-process-equation.png",
        effect_description = {"description.equation_to_solved_equation_description"},
      },
    },
    prerequisites = {"moshine-tech-data-processor"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"datacell-raw-data", 10},
        {"datacell-ai-model-data", 1},
      },
      time = 100
    }
  },
  {
    type = "technology",
    name = "moshine-tech-ai-trainer",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-ai-trainer.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "ai-trainer"
      },
    },
    prerequisites = {"moshine-tech-data-processor"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-ai-model-data", 1},
      },
      time = 80
    }
  },
--     ██████  ██████  ███████ ███    ███ ██  ██████     ███████  ██████  █████  ███    ██ ███    ██ ███████ ██████  
--    ██      ██    ██ ██      ████  ████ ██ ██          ██      ██      ██   ██ ████   ██ ████   ██ ██      ██   ██ 
--    ██      ██    ██ ███████ ██ ████ ██ ██ ██          ███████ ██      ███████ ██ ██  ██ ██ ██  ██ █████   ██████  
--    ██      ██    ██      ██ ██  ██  ██ ██ ██               ██ ██      ██   ██ ██  ██ ██ ██  ██ ██ ██      ██   ██ 
--     ██████  ██████  ███████ ██      ██ ██  ██████     ███████  ██████ ██   ██ ██   ████ ██   ████ ███████ ██   ██ 


  {
    type = "technology",
    name = "moshine-tech-cosmic-data-outsignal-creation",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-cosmic-data-outsignal-creation.png",
    order = "zzz",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "datacell-remove-solved-equation"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-solved-equation"
      },
      {
        type = "unlock-recipe",
        recipe = "cosmic-data-outsignal-creation"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-remove-cosmic-data-outsignal"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-cosmic-data-outsignal"
      },
    },
    prerequisites = {"moshine-tech-processing-grid", "moshine-tech-cosmicscanner-construction1"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-ai-model-data", 1},
        {"datacell-solved-equation", 1},
      },
      time = 80
    },
  },
  {
    type = "technology",
    name = "moshine-tech-cosmicscanner-construction1",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-cosmicscanner-construction-1.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "moshine_cosmicscanner-construction-stage-1"
      },
    },
    prerequisites = {"moshine-concrete-from-molten-iron-and-sand"}, --"moshine-tech-silicon", 
    unit =
    {
      count = 390,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1}
      },
      time = 60
    },
    order = "zzz",
  },
  {
    type = "technology",
    name = "moshine-tech-cosmicscanner-construction2",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-cosmicscanner-construction-2.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "moshine_cosmicscanner-construct-1"
      },
    },
    prerequisites = {"moshine-tech-cosmicscanner-construction1", "moshine-tech-silicon-carbide", "moshine-tech-magnet"},
    unit =
    {
      count = 400,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1}
      },
      time = 80
    },
    order = "zzz",
  },
  {
    type = "technology",
    name = "moshine-tech-cosmicscanner-construction3",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-cosmicscanner-construction-3.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "moshine_cosmicscanner-construct-2"
      },
    },
    prerequisites = {"moshine-tech-cosmicscanner-construction2","moshine-tech-neural_computer"},
    unit =
    {
      count = 375,
      ingredients =
      {
        {"datacell-equation", 1},
      },
      time = 60
    },
    order = "zzz",
    --upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-cosmicscanner-construction4",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-cosmicscanner-construction-4.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "moshine_cosmicscanner-construct-3"
      },
    },
    prerequisites = {"moshine-tech-cosmicscanner-construction3", "moshine-tech-data-extractor", "tesla-weapons", "moshine-tech-processing-grid"},
    unit =
    {
      count = 450,
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-solved-equation", 1},
      },
      time = 80
    },
    order = "zzz",
    --upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-cosmicscanner-construction5",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-cosmicscanner-construction-5.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "moshine_cosmicscanner-construct-4"
      },
      {
        type = "unlock-recipe",
        recipe = "cosmic-data-creation"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-cosmic-data"
      },
      {
        type = "unlock-recipe",
        recipe = "datacell-remove-cosmic-data"
      },
    },
    prerequisites = {"moshine-tech-cosmicscanner-construction4", "moshine-tech-cosmic-data-outsignal-creation", "moshine-tech-ai-tier-1"},
    unit =
    {
      count = 600,
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-ai-model-data", 1},
        {"datacell-solved-equation", 1},
        {"datacell-cosmic-data-outsignal", 1},

      },
      time = 80
    },
    order = "zzz",
    --upgrade = true,
  },

--     █████  ██     ████████ ██ ███████ ██████  ███████ 
--    ██   ██ ██        ██    ██ ██      ██   ██ ██      
--    ███████ ██        ██    ██ █████   ██████  ███████ 
--    ██   ██ ██        ██    ██ ██      ██   ██      ██ 
--    ██   ██ ██        ██    ██ ███████ ██   ██ ███████     
  {
    type = "technology",
    name = "moshine-tech-ai-tier-1",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-1.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-1" }},
    prerequisites = {"moshine-tech-ai-trainer"},
    research_trigger =
    {
      type = "craft-item",
      item = "ai-trainer",
      count = 1
    },
    --unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-2",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-2.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-2" }},
    prerequisites = {"moshine-tech-ai-tier-1"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-3",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-3.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    subgroup = "moshine-tech-with-datacells",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-3" }},
    prerequisites = {"moshine-tech-ai-tier-2"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-4",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-4.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-4" }},
    prerequisites = {"moshine-tech-ai-tier-3"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-5",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-5.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-5" }},
    prerequisites = {"moshine-tech-ai-tier-4"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-6",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-6.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-6" }},
    prerequisites = {"moshine-tech-ai-tier-5"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-7",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-7.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-7" }},
    prerequisites = {"moshine-tech-ai-tier-6","moshine-tech-cosmic-data-outsignal-creation"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-8",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-8.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-8" }},
    prerequisites = {"moshine-tech-ai-tier-7", "moshine-tech-cosmic-data-outsignal-creation"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-9",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-9.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-9" }},
    prerequisites = {"moshine-tech-ai-tier-8","moshine-tech-cosmicscanner-construction5"},
    unit = {},
    upgrade = true,
  },
  {
    type = "technology",
    name = "moshine-tech-ai-tier-10",
    icon = "__Moshine-assets__/graphics/technology/ai-tiers/tier-10.png",
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects = {{type = "unlock-recipe", recipe = "ai-tier-10" }},
    prerequisites = {"moshine-tech-ai-tier-9","moshine-tech-cosmicscanner-construction5"},
    unit = {},
    upgrade = true,
  },
  --[[{
    type = "technology",
    name = "moshine-tech-advanced-ai-cores",
    icon = "__Moshine-assets__/graphics/technology/moshine-tech-advanced-ai-cores.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "ai-tier-5"
      },
      {
        type = "unlock-recipe",
        recipe = "ai-tier-6"
      },
      {
        type = "unlock-recipe",
        recipe = "ai-tier-7"
      },
      {
        type = "unlock-recipe",
        recipe = "ai-tier-8"
      },
      {
        type = "unlock-recipe",
        recipe = "ai-tier-9"
      },
    },
    prerequisites = {"moshine-tech-ai-trainer"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-ai-model-data", 1},
      },
      time = 16000
    }
  },]]
  {
    type = "technology",
    name = "moshine-tech-quantum-processor-productivity",
    icons = util.technology_icon_constant_recipe_productivity("__Moshine-assets__/graphics/technology/moshine-tech-quantum-processor-productivity.png"),
    icon_size = 256,
    subgroup = "moshine-tech-with-datacells",
    order = "zzz",
    effects =
    {
      {
        type = "change-recipe-productivity",
        recipe = "quantum-processor",
        change = 0.1
      },
    },
    prerequisites = {"moshine-tech-processing-grid", "quantum-processor","moshine-tech-cosmicscanner-construction5"},
    unit =
    {
      count_formula = "1.4^L*35",
      ingredients =
      {
        {"datacell-raw-data", 1},
        {"datacell-solved-equation", 1},
        {"datacell-cosmic-data-outsignal", 1},
        {"datacell-cosmic-data", 1},
      },
      time = 6000
    },
    max_level = "infinite",
    upgrade = true
  },

})




-- Paranoidal: Moshine's own glass always (the glass processing of aai-industry is not in the build).
data.raw["technology"]["moshine-tech-data-extractor"].prerequisites = {"moshine-tech-neural_computer", "moshine-tech-glass"}
data.raw["technology"]["moshine-tech-glass"].enabled = true


if data.raw["technology"]["big-solar-energy"] then
  table.insert(data.raw["technology"]["moshine-tech-cosmicscanner-construction5"].prerequisites, "big-solar-energy")
end


if data.raw["technology"]["long-stack-inserter"] and data.raw["technology"]["long-stack-inserter"].prerequisites then
  table.insert(data.raw["technology"]["long-stack-inserter"].prerequisites, "moshine-tech-cosmic-data-outsignal-creation")
end

if data.raw["technology"]["electric-energy-big-accumulators"] and data.raw["technology"]["electric-energy-big-accumulators"].prerequisites then
  table.insert(data.raw["technology"]["electric-energy-big-accumulators"].prerequisites, "moshine-tech-cosmic-data-outsignal-creation")
end


local function add_tech_unit(tech, count, time, ingredients)
  if data.raw["technology"][tech] and count and time and ingredients then
    data.raw["technology"][tech].unit =
    {
      count = count,
      ingredients = ingredients,
      time = time,
    }
  end
end

add_tech_unit("moshine-tech-cosmic-data-outsignal-creation",   50, 80,         {{"datacell-raw-data", 1},{"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},} )
add_tech_unit("moshine-tech-cosmicscanner-construction3",      375, 60,        {{"datacell-equation", 1}} )
add_tech_unit("moshine-tech-cosmicscanner-construction4",      450, 80,        {{"datacell-raw-data", 1}, {"datacell-solved-equation", 1},} )
add_tech_unit("moshine-tech-cosmicscanner-construction5",      500, 300,       {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1}, {"datacell-solved-equation", 1}, {"datacell-cosmic-data-outsignal", 1},} )

add_tech_unit("moshine-tech-data-extractor",      40, 60,         {{"datacell-equation", 1}} )
add_tech_unit("moshine-tech-3d-data-storage",     200, 60,        {{"datacell-raw-data", 1}} )
add_tech_unit("moshine-tech-data-processor",      1000, 10,       {{"datacell-raw-data", 1},{"datacell-equation", 1}} )
add_tech_unit("moshine-tech-ai-trainer",          50, 80,         {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-processing-grid",     100, 100,       {{"datacell-raw-data", 10},{"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-2",           10, 2*500,      {{"datacell-raw-data", 1}, {"datacell-equation", 1}} )
add_tech_unit("big-solar-energy",                 13, 3*500,      {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-3",           15, 16*500,     {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-4",           20, 54*500,     {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("snouz_better_substation_tech",     40, 27*500,     {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-5",           25, 128*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},} )
add_tech_unit("moshine-tech-ai-tier-6",           30, 250*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},} )
add_tech_unit("long-stack-inserter",              1000, 2.45*500, {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("moshine-tech-ai-tier-7",           35, 432*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("electric-energy-big-accumulators", 36, 437*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("moshine-tech-ai-tier-8",           40, 686*500,    {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1}} )
add_tech_unit("moshine-tech-ai-tier-9",           45, 1024*500,   {{"datacell-raw-data", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1},{"datacell-cosmic-data", 1}} )
add_tech_unit("moshine-tech-ai-tier-10",          50, 1458*500,   {{"datacell-raw-data", 1}, {"datacell-equation", 1}, {"datacell-ai-model-data", 1},{"datacell-solved-equation", 1},{"datacell-cosmic-data-outsignal", 1},{"datacell-cosmic-data", 1}} )
