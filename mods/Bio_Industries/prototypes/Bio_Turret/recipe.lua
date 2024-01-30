data:extend({
-- Basic Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-basic",
    localised_name = {"item-name.bi-dart-magazine-basic"},
    localised_description = {"item-description.bi-dart-magazine-basic"},
    normal = 
    {
      enabled = false,
      energy_required = 4,
      ingredients = {{"wood", 10}},
      result = "bi-dart-magazine-basic",
      result_count = 10,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    expensive = 
    {
      enabled = false,
      energy_required = 6,
      ingredients = {{"wood", 10}},
      result = "bi-dart-magazine-basic",
      result_count = 8,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    allow_as_intermediate = false,  
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-1",
},
--###############################################################################################
-- Standard Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-standard",
    localised_name = {"item-name.bi-dart-magazine-standard"},
    localised_description = {"item-description.bi-dart-magazine-standard"},
    normal = 
    {
      enabled = false,
      energy_required = 5,
      ingredients = 
      {
        {"bi-dart-magazine-basic", 10},
        {"copper-plate", 5},
      },
      result = "bi-dart-magazine-standard",
      result_count = 10,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    expensive = 
    {
      enabled = false,
      energy_required = 8,
      ingredients = 
      {
        {"bi-dart-magazine-basic", 8},
        {"copper-plate", 5},
      },
      result = "bi-dart-magazine-standard",
      result_count = 8,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    allow_as_intermediate = false,  
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-2",
  },
--###############################################################################################
-- Enhanced Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-enhanced",
    localised_name = {"item-name.bi-dart-magazine-enhanced"},
    localised_description = {"item-description.bi-dart-magazine-enhanced"},
    normal = 
    {
      enabled = false,
      energy_required = 6,
      ingredients = 
      {
        {"bi-dart-magazine-standard", 10},
        {"plastic-bar", 5},
      },
      result = "bi-dart-magazine-enhanced",
      result_count = 10,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    expensive = 
    {
      enabled = false,
      energy_required = 9,
      ingredients = 
      {
        {"bi-dart-magazine-standard", 8},
        {"plastic-bar", 5},
      },
      result = "bi-dart-magazine-enhanced",
      result_count = 8,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    allow_as_intermediate = false,  
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-3",
  },
--###############################################################################################
-- Poison Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-poison",
    localised_name = {"item-name.bi-dart-magazine-poison"},
    localised_description = {"item-description.bi-dart-magazine-poison"},
    normal = 
    {
      enabled = false,
      energy_required = 8,
      ingredients = 
      {
        {"bi-dart-magazine-enhanced", 10},
        {"poison-capsule", 5},
      },
      result = "bi-dart-magazine-poison",
      result_count = 10,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    expensive = 
    {
      enabled = false,
      energy_required = 12,
      ingredients = 
      {
        {"bi-dart-magazine-enhanced", 8},
        {"poison-capsule", 5},
      },
      result = "bi-dart-magazine-poison",
      result_count = 8,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    allow_as_intermediate = false,  
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-4",
  },
--###############################################################################################
-- Dart Turret
  {
    type = "recipe",
    name = "bi-dart-turret",
    localised_name = {"entity-name.bi-dart-turret"},
    localised_description = {"entity-description.bi-dart-turret"},
    normal = 
    {
      enabled = false,
      energy_required = 8,
      ingredients = 
      {
        {"iron-gear-wheel", 5},
        {"wood", 20},
      },
      result = "bi-dart-turret",
      result_count = 1,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    expensive = 
    {
      enabled = false,
      energy_required = 16,
      ingredients = 
      {
        {"iron-gear-wheel", 10},
        {"wood", 25},
      },
      result = "bi-dart-turret",
      result_count = 1,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    allow_as_intermediate = false,  
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "defensive-structure",
    order = "b[turret]-e[bi-dart-turret]",
},
--###############################################################################################
-- Dart Rifle
  {
    type = "recipe",
    name = "bi-dart-rifle",
    localised_name = {"item-name.bi-dart-rifle"},
    localised_description = {"item-description.bi-dart-rifle"},
    normal = 
    {
      enabled = false,
      energy_required = 8,
      ingredients = 
      {
        {"copper-plate", 5},
        {"wood", 15},
      },
      result = "bi-dart-rifle",
      result_count = 1,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    expensive = 
    {
      enabled = false,
      energy_required = 16,
      ingredients = 
      {
        {"copper-plate", 10},
        {"wood", 25},
      },
      result = "bi-dart-rifle",
      result_count = 1,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    allow_as_intermediate = false,  
    always_show_made_in = false,
    allow_decomposition = true, 
    subgroup = "gun",
    order = "a[basic-clips]-b[bi-dart-rifle]"
  },

})