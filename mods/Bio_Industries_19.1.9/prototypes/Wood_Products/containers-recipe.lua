data:extend({
-- Large Wooden Chest
  {
    type = "recipe",
    name = "bi-wooden-chest-large",
    localised_name = {"entity-name.bi-wooden-chest-large"},
    localised_description = {"entity-description.bi-wooden-chest-large"},
    normal = 
    {
      energy_required = 2,
      enabled = false,
      ingredients = 
      {
        {"copper-plate", 16},
        {"resin", 24},
        {"wooden-chest", 8}
      },
      result = "bi-wooden-chest-large",
      result_count = 1,
      requester_paste_multiplier = 4,
      allow_as_intermediate = true,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    expensive = 
    {
      energy_required = 4,
      enabled = false,
      ingredients = 
      {
        {"copper-plate", 24},
        {"resin", 32},
        {"wooden-chest", 8}
      },
      result = "bi-wooden-chest-large",
      result_count = 1,
      requester_paste_multiplier = 4,
      allow_as_intermediate = true,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    allow_as_intermediate = true,
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "storage",
    order = "a[items]-aa[wooden-chest]",
  },
--###############################################################################################
-- Huge Wooden Chest
  {
    type = "recipe",
    name = "bi-wooden-chest-huge",
    localised_name = {"entity-name.bi-wooden-chest-huge"},
    localised_description = {"entity-description.bi-wooden-chest-huge"},
    normal = 
    {
      energy_required = 2,
      enabled = false,
      ingredients = 
      {
        {"iron-stick", 32},
        {"stone-brick", 32},
        {"bi-wooden-chest-large", 16}
      },
      result = "bi-wooden-chest-huge",
      result_count = 1,
      requester_paste_multiplier = 4,
      allow_as_intermediate = true,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    expensive = 
    {
      energy_required = 4,
      enabled = false,
      ingredients = 
      {
        {"iron-stick", 48},
        {"stone-brick", 48},
        {"bi-wooden-chest-large", 16}
      },
      result = "bi-wooden-chest-huge",
      result_count = 1,
      requester_paste_multiplier = 4,
      allow_as_intermediate = true,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    allow_as_intermediate = true,
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "storage",
    order = "a[items]-ab[wooden-chest]",
  },
--###############################################################################################
-- Giga Wooden Chest
  {
    type = "recipe",
    name = "bi-wooden-chest-giga",
    localised_name = {"entity-name.bi-wooden-chest-giga"},
    localised_description = {"entity-description.bi-wooden-chest-giga"},
    normal = 
    {
      energy_required = 4,
      enabled = false,
      ingredients = 
      {
        {"steel-plate", 32},
        {"concrete", 32},
        {"bi-wooden-chest-huge", 16}
      },
      result = "bi-wooden-chest-giga",
      result_count = 1,
      requester_paste_multiplier = 4,
      allow_as_intermediate = true,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    expensive = 
    {
      energy_required = 6,
      enabled = false,
      ingredients = 
      {
        {"steel-plate", 48},
        {"concrete", 48},
        {"bi-wooden-chest-huge", 16}
      },
      result = "bi-wooden-chest-giga",
      result_count = 1,
      requester_paste_multiplier = 4,
      allow_as_intermediate = true,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    allow_as_intermediate = true,
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "storage",
    order = "a[items]-ac[wooden-chest]",
  },
})