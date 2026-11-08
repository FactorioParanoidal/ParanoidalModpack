data:extend({
--    ██████  ███████  ██████ ██ ██████  ███████        ██████  █████  ████████ ███████  ██████   ██████  ██████  ██    ██ 
--    ██   ██ ██      ██      ██ ██   ██ ██            ██      ██   ██    ██    ██      ██       ██    ██ ██   ██  ██  ██  
--    ██████  █████   ██      ██ ██████  █████   █████ ██      ███████    ██    █████   ██   ███ ██    ██ ██████    ████   
--    ██   ██ ██      ██      ██ ██      ██            ██      ██   ██    ██    ██      ██    ██ ██    ██ ██   ██    ██    
--    ██   ██ ███████  ██████ ██ ██      ███████        ██████ ██   ██    ██    ███████  ██████   ██████  ██   ██    ██    
--                                                                                                                         
  {
    type = "recipe-category",
    name = "ai-training"
  },
  {
    type = "recipe-category",
    name = "cosmic-data-creation"
  },

--    ███████ ███    ██ ████████ ██ ████████ ██    ██ 
--    ██      ████   ██    ██    ██    ██     ██  ██  
--    █████   ██ ██  ██    ██    ██    ██      ████   
--    ██      ██  ██ ██    ██    ██    ██       ██    
--    ███████ ██   ████    ██    ██    ██       ██    

  {
    type = "recipe",
    name = "data-processor",
    energy_required = 10,
    ingredients =
    {
      {type = "item", name = "assembling-machine-3", amount = 1},
      {type = "item", name = "silicon-carbide", amount = 5},
      {type = "item", name = "productivity-module-2", amount = 5},
    },
    results = {
      {type = "item", name = "data-processor", amount = 1}
    },
    surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "neural_computer",
    energy_required = 30,
    ingredients =
    {
      {type = "item", name = "lab", amount = 1},
      {type = "item", name = "datacell-empty", amount = 100},
      {type = "item", name = "processing-unit", amount = 50},
      {type = "item", name = "silicon-carbide", amount = 40},
      {type = "item", name = "magnet", amount = 20},

    },
    surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    results = {{type = "item", name = "neural_computer", amount = 1}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "data-extractor",
    localised_name = {"recipe-name.data-extractor"},
    energy_required = 10,
    surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    ingredients = {
      {type = "item", name = "display-panel", amount = 10},
      {type = "item", name = "magnet", amount = 5},
      {type = "item", name = "constant-combinator", amount = 4},
      {type = "item", name = "processing-unit", amount = 4},
    },
    results = {{type = "item", name = "data-extractor", amount = 1}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "optical-cable",
    energy_required = 1,
    --surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    ingredients = {
      {type = "item", name = "silicon-carbide", amount = 1},
      {type = "item", name = "moshine-glass", amount = 1},
      {type = "item", name = "silicon", amount = 1},
    },
    results = {{type = "item", name = "optical-cable", amount = 2}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "opticalfiber-storage-tank",
    energy_required = 12,
    --surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 100},
      {type = "item", name = "electronic-circuit", amount = 15},
      {type = "item", name = "optical-cable", amount = 5},
    },
    results = {{type = "item", name = "opticalfiber-storage-tank", amount = 1}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },


  {
    type = "recipe",
    name = "processing-grid",
    energy_required = 20,
    categories = {"crafting"},
    surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    ingredients =
    {
      {type = "item", name = "data-processor", amount = 1},
      {type = "item", name = "model-stable", amount = 50},
      {type = "item", name = "silicon-carbide", amount = 10},
      {type = "item", name = "processing-unit", amount = 5},
    },
    results = {{type="item", name="processing-grid", amount=1}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  
  {
    type = "recipe",
    name = "webbed_processor_tile",
    energy_required = 2,
    categories = {"crafting"},
    surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    ingredients =
    {
      {type = "item", name = "space-platform-foundation", amount = 1},
      {type = "item", name = "model-stable", amount = 1},
      {type = "item", name = "processing-unit", amount = 1},
      {type = "item", name = "optical-cable", amount = 1},
    },
    results = {
      {type = "item", name = "webbed_processor_tile", amount = 1}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "ai-trainer",
    energy_required = 20,
    categories = {"crafting"},
    surface_conditions = {{ property = "pressure", min = 701, max = 701}},
    ingredients =
    {
      {type = "item", name = "concrete", amount = 100},
      {type = "item", name = "moshine-glass", amount = 100},
      {type = "item", name = "processing-unit", amount = 50},
      {type = "item", name = "model-stable", amount = 10},
      {type = "item", name = "data-processor", amount = 1},
      {type = "item", name = "model-unstable", amount = 1},
    },
    results = {{type="item", name="ai-trainer", amount=1}},
    allow_productivity = false,
    enabled = false,
    sort_item_ingredients = false,
  },
  --[[
  {
    type = "recipe",
    name = "ai-support",
    energy_required = 1,
    categories = {"crafting-with-fluid"},
    ingredients =
    {
      {type = "item", name = "iron-plate", amount = 1},
    },
    results = {{type="item", name="ai-support", amount=10}},
    allow_productivity = false,
    enabled = true,
  },
  ]]





-- post-nauvis
  {
    type = "recipe",
    name = "concrete-from-molten-iron-and-sand",
    categories = {"metallurgy"},
    icon = "__Moshine__/graphics/icons/concrete-from-molten-iron-and-sand.png",
    subgroup = "moshine-processes",
    order = "aab",
    enabled = false,
    ingredients =
    {
      {type = "item", name = "moshine-quartz-sand", amount = 80},
      {type = "fluid", name = "molten-iron", amount = 20},
      {type = "fluid", name = "water", amount = 100},
    },
    energy_required = 10,
    results = {{type = "item", name = "concrete", amount = 10}},
    allow_decomposition = false,
    auto_recycle = false,
    allow_productivity = true,
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "petroleum-from-sand-sulfur-steam-carbon",
    categories = {"oil-processing"},
    icon = "__Moshine__/graphics/icons/petroleum-from-sand-sulfur-steam-carbon.png",
    subgroup = "moshine-processes",
    order = "aac",
    enabled = false,
    ingredients =
    {
      {type = "item", name = "moshine-quartz-sand", amount = 40},
      {type = "item", name = "sulfur", amount = 10},
      {type = "item", name = "coal", amount = 5},
      {type = "fluid", name = "steam", amount = 50},
    },
    energy_required = 3,
    results = {
      {type = "fluid", name = "petroleum-gas", amount = 100, show_details_in_recipe_tooltip = true},
      {type = "item", name = "carbon", amount = 2, show_details_in_recipe_tooltip = false},
    },
    main_product = "petroleum-gas",
    allow_decomposition = false,
    auto_recycle = false,
    allow_productivity = true,
    sort_item_ingredients = false,
  },

  {
    type = "recipe",
    name = "silicon",
    categories = {"chemistry"},
    energy_required = 2,
    ingredients = {
      {type = "item", name = "moshine-quartz-sand", amount = 5},
      {type = "item", name = "coal", amount = 1},
      {type = "fluid", name = "steam", amount = 10},
    },
    results = {{type = "item", name = "silicon", amount = 1}},
    allow_productivity = true,
    enabled = false,
    sort_item_ingredients = false,
  },
})

do -- Paranoidal: Moshine's own glass always (the glass of the build is another material)
  data:extend({
    {
      type = "recipe",
      name = "moshine-glass",
      categories = {"smelting"},
      energy_required = 4,
      ingredients = {
        {type = "item", name = "moshine-quartz-sand", amount = 4}
      },
      results = {{type = "item", name = "moshine-glass", amount = 1}},
      allow_productivity = true,
      enabled = false,
    },
  })
end

data:extend({
  {
    type = "recipe",
    name = "silicon-cell",
    categories = {"crafting", "electromagnetics"},
    energy_required = 2,
    ingredients =
    {
      {type = "item", name = "silicon", amount = 5},
      {type = "item", name = "electronic-circuit", amount = 1},
    },
    results = {{type = "item", name = "silicon-cell", amount = 1}},
    allow_productivity = true,
    enabled = false,
    sort_item_ingredients = false,
  },

  {
    type = "recipe",
    name = "silicon-carbide",
    categories = {"crafting-with-fluid"},
    energy_required = 8,
    ingredients =
    {
      {type = "item", name = "silicon", amount = 2},
      {type = "item", name = "carbon", amount = 1},
      {type = "fluid", name = "sulfuric-acid", amount = 10},
    },
    results = {{type = "item", name = "silicon-carbide", amount = 2}},
    allow_productivity = true,
    enabled = false,
    sort_item_ingredients = false,
  },




---post fulgora

  {
    type = "recipe",
    name = "magnet",
    categories = {"electromagnetics"}, -- only electromagnetic plant
    energy_required = 5,
    ingredients = {
      {type = "item", name = "neodymium", amount = 1},
      {type = "fluid", name = "molten-iron", amount = 10},
    },
    results = {{type = "item", name = "magnet", amount = 1}},
    allow_productivity = true,
    enabled = false,
  },

--    ██████   █████  ████████  █████   ██████ ███████ ██      ██      
--    ██   ██ ██   ██    ██    ██   ██ ██      ██      ██      ██      
--    ██   ██ ███████    ██    ███████ ██      █████   ██      ██      
--    ██   ██ ██   ██    ██    ██   ██ ██      ██      ██      ██      
--    ██████  ██   ██    ██    ██   ██  ██████ ███████ ███████ ███████ 
  {
    type = "recipe",
    name = "datacell-empty", -- datacell empty
    categories = {"crafting", "electromagnetics"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-aa",
    energy_required = 10,
    ingredients = {
      {type = "item", name = "magnet", amount = 1},
      {type = "item", name = "silicon-cell", amount = 1},
      {type = "item", name = "advanced-circuit", amount = 1},
    },
    results = {{type = "item", name = "datacell-empty", amount = 1}},
    allow_productivity = true,
    enabled = false,
    sort_item_ingredients = false,
    allow_decomposition = false,
  },
  {
    type = "recipe",
    name = "datacell-raw-data",
    localised_name = {"recipe-name.datacell-raw-data"},
    icon = "__Moshine__/graphics/icons/data/datacell-raw-data.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-ab",
    hide_from_player_crafting = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "raw-data", amount = 100, ignored_by_stats = 100},
    },
    results = {{type = "item", name = "datacell-raw-data", amount = 1, ignored_by_stats = 1}},
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    crafting_machine_tint = {primary = {109,207,154}}, --#6dd15e
  },
  {
    type = "recipe",
    name = "datacell-remove-raw-data",
    icon = "__Moshine__/graphics/icons/data/datacell-raw-data-remove.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-ac",
    hide_from_player_crafting = true,
    hide_from_stats = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-raw-data", amount = 1, ignored_by_stats = 1},
    },
    results = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "raw-data", amount = 100, ignored_by_stats = 100},
    },
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    hide_from_player_crafting = true,
    crafting_machine_tint = {primary = {109,207,154}}, --#6dd15e
  },



  {
    type = "recipe",
    name = "datacell-ai-model-data",
    localised_name = {"recipe-name.datacell-ai-model-data"},
    icon = "__Moshine__/graphics/icons/data/datacell-ai-model-data.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-ba",
    energy_required = 10,
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "item", name = "model-stable", amount = 1, ignored_by_stats = 1},
    },
    results = {
      {type = "item", name = "datacell-ai-model-data", amount = 1, ignored_by_stats = 1},
      {type = "item", name = "3d-data-storage", amount = 1, ignored_by_stats = 1},
    },
    main_product = "datacell-ai-model-data",
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    allow_decomposition = false,
    crafting_machine_tint = {primary = {123,186,240}}, --#6ac4e6
    sort_item_ingredients = false,
  },


  {
    type = "recipe",
    name = "datacell-remove-ai-model-data",
    icon = "__Moshine__/graphics/icons/data/datacell-ai-model-data-remove.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-bb",
    energy_required = 15,
    ingredients = {
      {type = "item", name = "datacell-ai-model-data", amount = 1, ignored_by_stats = 1},
      {type = "item", name = "3d-data-storage", amount = 1, ignored_by_stats = 1},
    },
    results = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "item", name = "model-stable", amount = 1, ignored_by_stats = 1},
    },
    main_product = "model-stable",
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    hide_from_player_crafting = true,
    crafting_machine_tint = {primary = {123,186,240}}, --#6ac4e6
    allow_decomposition = false,
    sort_item_ingredients = false,
  },

  {
    type = "recipe",
    name = "datacell-equation",
    localised_name = {"recipe-name.datacell-equation"},
    icon = "__Moshine__/graphics/icons/data/datacell-equation.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-ca",
    energy_required = 4,
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 1},
    },
    results = {
      {type = "item", name = "datacell-equation", amount = 1}
    },
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    crafting_machine_tint = {primary = {22,165,255}}, --#427deb
  },


  {
    type = "recipe",
    name = "datacell-solved-equation",
    icon = "__Moshine__/graphics/icons/data/datacell-solved-equation.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-cb",
    hide_from_player_crafting = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "solved-equation-data", amount = 60, ignored_by_stats = 60},
    },
    results = {{type = "item", name = "datacell-solved-equation", amount = 1, ignored_by_stats = 1}},
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    crafting_machine_tint = {primary = {212,212,5}}, --#f2eb76
  },
  {
    type = "recipe",
    name = "datacell-remove-solved-equation",
    localised_name = {"recipe-name.datacell-remove-solved-equation"},
    icon = "__Moshine__/graphics/icons/data/datacell-solved-equation-remove.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-cc",
    hide_from_player_crafting = true,
    hide_from_stats = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-solved-equation", amount = 1, ignored_by_stats = 1},
    },
    results = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "solved-equation-data", amount = 60, ignored_by_stats = 60},
    },
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    hide_from_player_crafting = true,
    crafting_machine_tint = {primary = {212,212,5}}, --#f2eb76
  },



--     ██████  ██████  ███████ ███    ███ ██  ██████     ██████   █████  ████████  █████  
--    ██      ██    ██ ██      ████  ████ ██ ██          ██   ██ ██   ██    ██    ██   ██ 
--    ██      ██    ██ ███████ ██ ████ ██ ██ ██          ██   ██ ███████    ██    ███████ 
--    ██      ██    ██      ██ ██  ██  ██ ██ ██          ██   ██ ██   ██    ██    ██   ██ 
--     ██████  ██████  ███████ ██      ██ ██  ██████     ██████  ██   ██    ██    ██   ██ 

  {
    type = "recipe",
    name = "cosmic-data-outsignal-creation",
    icon = "__Moshine__/graphics/icons/data/cosmic-data-outsignal.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-da",
    --hide_from_player_crafting = true,
    energy_required = 10,
    ingredients = {
      {type = "fluid", name = "raw-data", amount = 1500},
      {type = "fluid", name = "solved-equation-data", amount = 100},
      {type = "item", name = "space-science-pack", amount = 1},
    },
    results = {{type = "fluid", name = "cosmic-data-outsignal", amount = 20}},
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    crafting_machine_tint = {primary = {197,8,181}}, --#260d7f
  },

  {
    type = "recipe",
    name = "datacell-cosmic-data-outsignal",
    icon = "__Moshine__/graphics/icons/data/datacell-outsignal.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-db",
    hide_from_player_crafting = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "cosmic-data-outsignal", amount = 100, ignored_by_stats = 100},
    },
    results = {{type = "item", name = "datacell-cosmic-data-outsignal", amount = 1, ignored_by_stats = 1}},
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    crafting_machine_tint = {primary = {197,8,181}}, --#260d7f
  },
  {
    type = "recipe",
    name = "datacell-remove-cosmic-data-outsignal",
    icon = "__Moshine__/graphics/icons/data/datacell-outsignal-remove.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-dc",
    hide_from_player_crafting = true,
    hide_from_stats = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-cosmic-data-outsignal", amount = 1, ignored_by_stats = 1},
    },
    results = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "cosmic-data-outsignal", amount = 100, ignored_by_stats = 100},
    },
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    hide_from_player_crafting = true,
    crafting_machine_tint = {primary = {197,8,181}}, --#260d7f
  },

  {
    type = "recipe",
    name = "cosmic-data-creation",
    icon = "__Moshine__/graphics/icons/data/cosmos-scanning.png",
    categories = {"cosmic-data-creation"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-ea",
    --hide_from_player_crafting = true,
    energy_required = 170,
    ingredients = {
      {type = "fluid", name = "cosmic-data-outsignal", amount = 990},
    },
    results = {{
      type = "fluid", 
      name = "cosmic-data", 
      independent_probability = 0.4,
      amount_min = 1240, 
      amount_max = 13480,
    }},
    --allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    allow_productivity = true,
    crafting_machine_tint = {primary = util.color("#8086ff"),}, --#260d7f
  },

  {
    type = "recipe",
    name = "datacell-cosmic-data",
    icon = "__Moshine__/graphics/icons/data/datacell-cosmic-data.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-eb",
    hide_from_player_crafting = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "cosmic-data", amount = 100, ignored_by_stats = 100},
    },
    results = {{type = "item", name = "datacell-cosmic-data", amount = 1, ignored_by_stats = 1}},
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    crafting_machine_tint = {primary = util.color("#8086ff"),}, --#260d7f
  },
  {
    type = "recipe",
    name = "datacell-remove-cosmic-data",
    icon = "__Moshine__/graphics/icons/data/datacell-cosmic-data-remove.png",
    categories = {"data-processing"},
    subgroup = "moshine-datacells",
    order = "a[moshine]-ec",
    hide_from_player_crafting = true,
    hide_from_stats = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "datacell-cosmic-data", amount = 1, ignored_by_stats = 1},
    },
    results = {
      {type = "item", name = "datacell-empty", amount = 1, ignored_by_stats = 1},
      {type = "fluid", name = "cosmic-data", amount = 100, ignored_by_stats = 100},
    },
    allow_productivity = false,
    auto_recycle = false,
    enabled = false,
    hide_from_player_crafting = true,
    crafting_machine_tint = {primary = util.color("#8086ff"),}, --#260d7f
  },







  {
    type = "recipe",
    name = "3d-data-storage",
    categories = {"crafting", "electromagnetics"},
    energy_required = 10,
    ingredients = {
      {type = "item", name = "magnet", amount = 3},
      {type = "item", name = "silicon-cell", amount = 3},
      {type = "item", name = "datacell-empty", amount = 4},
      {type = "item", name = "moshine-glass", amount = 5},
    },
    results = {{type = "item", name = "3d-data-storage", amount = 1}},
    allow_productivity = true,
    enabled = false,
  },




  {
    type = "recipe-category",
    name = "data-processing"
  },

  {
    type = "recipe",
    name = "model-unstable",
    categories = {"data-processing"},
    energy_required = 10,
    ingredients = {
      {type = "item", name = "3d-data-storage", amount = 1},
      {type = "fluid", name = "raw-data", amount = 50},
    },
    results = {{type = "item", name = "model-unstable", amount = 1, always_fresh = true, reset_freshness_on_craft = true}},
    enabled = false,
    crafting_machine_tint = {primary = {255, 0, 0}}, --#ff0000
  },






  {
    type = "recipe",
    name = "model-stable",
    categories = {"data-processing"},
    energy_required = 40,
    ingredients = {
      {type = "item", name = "model-unstable", amount = 1},
      {type = "fluid", name = "raw-data", amount = 100},
    },
    results = {{type = "item", name = "model-stable", amount = 1}},
    enabled = false,
    crafting_machine_tint = {primary = {20, 251, 255}}, --#14fbff
  },
  {
    type = "recipe",
    name = "ai-tier-1",
    icons = {
      {icon = "__Moshine__/graphics/icons/aicores/tier-1.png", icon_size = 64, scale = 0.5},
      --{icon = "__Moshine__/graphics/icons/tiers/tier-1.png", icon_size = 64, scale = 0.35, shift = {0,0.3}},
      {icon = "__Moshine__/graphics/icons/training-arrows.png", icon_size = 64, scale = 0.5},
    },
    --hide_from_player_crafting = true,
    --hidden_in_factoriopedia = true,
    categories = {"ai-training"},
    subgroup = "moshine-processes",
    order = "kkk",
    energy_required = 10,
    ingredients = {{type = "item", name = "model-stable", amount = 1}},
    results = {
      {type = "item", name = "model-stable", amount = 1, shared_probability = { min = 0, max = 0.5 }},
      {type = "item", name = "ai-tier-1", amount = 1, shared_probability = { min = 0.5, max = 1 }},
    },
    main_product = "ai-tier-1",
    allow_productivity = false,
    enabled = false,
    crafting_machine_tint =
    {
      primary = {40, 66, 65, 255},
      secondary = {r = 0, g = 0, b = 0, a = 0},
      tertiary = {r = 0, g = 0, b = 0, a = 0},
      quaternary = {r = 0, g = 0, b = 0, a = 0},
    },
    sort_item_ingredients = false,
  },
  {
    type = "recipe",
    name = "ai-tier-2",
    icons = {
      {icon = "__Moshine__/graphics/icons/aicores/tier-2.png", icon_size = 64, scale = 0.5},
      --{icon = "__Moshine__/graphics/icons/tiers/tier-2.png", icon_size = 64, scale = 0.35, shift = {0,0.3}},
      {icon = "__Moshine__/graphics/icons/training-arrows.png", icon_size = 64, scale = 0.5},
    },
    hide_from_player_crafting = true,
    hidden_in_factoriopedia = false,
    categories = {"ai-training"},
    subgroup = "moshine-processes",
    order = "kkk",
    energy_required = 10,
    ingredients = {{type = "item", name = "ai-tier-1", amount = 1}},
    results = {
      {type="item", name="ai-tier-2", amount=1, shared_probability = { min = 0, max = 0.50 }},
      {type="item", name="ai-tier-1", amount=1, shared_probability = { min = 0.50, max = 0.99 }},
      {type="item", name="model-unstable", amount=1, shared_probability = { min = 0.99, max = 1 }},
    },
    main_product = "ai-tier-2",
    allow_productivity = false,
    enabled = false,
    crafting_machine_tint = 
    {
      primary = {70, 128, 124, 255},
      secondary = {r = 0, g = 0, b = 0, a = 0},
      tertiary = {r = 0, g = 0, b = 0, a = 0},
      quaternary = {r = 0, g = 0, b = 0, a = 0},
    },
    sort_item_ingredients = false,
  },
})

local one =
{
  primary = {179, 255, 250, 255},
  secondary = {r = 0, g = 0, b = 0, a = 0},
  tertiary = {r = 0, g = 0, b = 0, a = 0},
  quaternary = {r = 0, g = 0, b = 0, a = 0},
}
local two =
{
  primary = {r = 0, g = 0, b = 0, a = 0},
  secondary = {r = 1, g = 1, b = 1, a = 1},
  tertiary = {r = 0, g = 0, b = 0, a = 0},
  quaternary = {r = 0, g = 0, b = 0, a = 0},
}
local three =
{
  primary = {r = 0, g = 0, b = 0, a = 0},
  secondary = {r = 0, g = 0, b = 0, a = 0},
  tertiary = {r = 1, g = 1, b = 1, a = 1},
  quaternary = {r = 0, g = 0, b = 0, a = 0},
}
local four =
{
  primary = {r = 0, g = 0, b = 0, a = 0},
  secondary = {r = 0, g = 0, b = 0, a = 0},
  tertiary = {r = 0, g = 0, b = 0, a = 0},
  quaternary = {r = 1, g = 1, b = 1, a = 1},
}

for i=2,9 do

  local typeofanim = one

  if i >= 8 then
    typeofanim = four
  elseif i >= 6 then
    typeofanim = three
  elseif i >= 3 then
    typeofanim = two
  end


  data:extend({
    {
      type = "recipe",
      name = "ai-tier-" .. i+1,
      icons = {
        {icon = "__Moshine__/graphics/icons/aicores/tier-" .. i+1 .. ".png", icon_size = 64, scale = 0.5},
        --{icon = "__Moshine__/graphics/icons/tiers/tier-" .. i+1 .. ".png", icon_size = 64, scale = 0.35, shift = {0,0.3}},
        {icon = "__Moshine__/graphics/icons/training-arrows.png", icon_size = 64, scale = 0.5},
      },
      hide_from_player_crafting = true,
      hidden_in_factoriopedia = false,
      categories = {"ai-training"},
      --subgroup = "moshine-processes",
      --order = "kkk",
      energy_required = 10,
      ingredients = {
        {type = "item", name = "ai-tier-" .. i, amount = 1}
      },
      results = {
        {type = "item", name = "ai-tier-" .. i+1, amount = 1, shared_probability = { min = 0.47, max = (0.47 + 0.32 - i/100) }},
        {type = "item", name = "ai-tier-" .. i,   amount = 1, shared_probability = { min = 0, max = 0.47 }},
        {type = "item", name = "ai-tier-" .. i-1, amount = 1, shared_probability = { min = (0.47 + 0.32 - i/100), max = 0.99 }},
        {type = "item", name = "model-unstable",  amount = 1, shared_probability = { min = 0.99, max = 1 }},
      },
      main_product = "ai-tier-" .. i+1,
      allow_productivity = false,
      enabled = false,
      crafting_machine_tint = typeofanim,
      sort_item_ingredients = false,

    },


  })
end