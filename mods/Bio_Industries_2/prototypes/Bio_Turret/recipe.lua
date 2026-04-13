local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/weapons/"
local ICONPATH_W = BioInd.modRoot .. "/graphics/icons/weapons/"

data:extend({
  --- Basic Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-basic",
    localised_name = {"item-name.bi-dart-magazine-basic"},
    localised_description = {"item-description.bi-dart-magazine-basic"},
    icons = { {icon = ICONPATH .. "basic_dart_icon.png", icon_size = 64, } },
    enabled = true,
    energy_required = 4,
    ingredients = {
        {type="item", name="wood", amount=10},
    },
    results = {{type="item", name="bi-dart-magazine-basic", amount=10}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-1",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Standard Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-standard",
    localised_name = {"item-name.bi-dart-magazine-standard"},
    localised_description = {"item-description.bi-dart-magazine-standard"},
	icons = { {icon = ICONPATH .. "standard_dart_icon.png", icon_size = 64, } },
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type="item", name="bi-dart-magazine-basic", amount=10},
        {type="item", name="copper-plate", amount=5},
      },
    results = {{type="item", name="bi-dart-magazine-standard", amount=10}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-2",
  },

  --- Enhanced Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-enhanced",
    localised_name = {"item-name.bi-dart-magazine-enhanced"},
    localised_description = {"item-description.bi-dart-magazine-enhanced"},
	icons = { {icon = ICONPATH .. "enhanced_dart_icon.png", icon_size = 64, } },
    enabled = false,
    energy_required = 6,
    ingredients = {
        {type="item", name="bi-dart-magazine-standard", amount=10},
        {type="item", name="plastic-bar", amount=5},
      },
    results = {{type="item", name="bi-dart-magazine-enhanced", amount=10}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-3",
  },

  --- Poison Dart Ammo
  {
    type = "recipe",
    name = "bi-dart-magazine-poison",
    localised_name = {"item-name.bi-dart-magazine-poison"},
    localised_description = {"item-description.bi-dart-magazine-poison"},
	icons = { {icon = ICONPATH .. "poison_dart_icon.png", icon_size = 64, } },
    enabled = false,
    energy_required = 8,
    ingredients = {
        {type="item", name="bi-dart-magazine-enhanced", amount=10},
        {type="item", name="poison-capsule", amount=5},
      },
    results = {{type="item", name="bi-dart-magazine-poison", amount=10}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "bi-ammo",
    order = "[bio-ammo]-a-[darts]-4",
  },

  --- Dart Turret
  {
    type = "recipe",
    name = "bi-dart-turret",
    localised_name = {"entity-name.bi-dart-turret"},
    localised_description = {"entity-description.bi-dart-turret"},
	icons = { {icon = ICONPATH .. "bio_turret_icon.png", icon_size = 64, } },
    enabled = true,
    energy_required = 8,
    ingredients = {
        {type="item", name="iron-gear-wheel", amount=5},
        {type="item", name="wood", amount=20},
      },
    results = {{type="item", name="bi-dart-turret", amount=1}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "defensive-structure",
    order = "b[turret]-e[bi-dart-turret]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Dart Rifle
  {
    type = "recipe",
    name = "bi-dart-rifle",
    localised_name = {"item-name.bi-dart-rifle"},
    localised_description = {"item-description.bi-dart-rifle"},
	icons = { {icon = ICONPATH .. "bi_dart_rifle_icon.png", icon_size = 64, } },
	enabled = true,
    energy_required = 8,
    ingredients = {
        {type="item", name="copper-plate", amount=5},
        {type="item", name="wood", amount=15},
      },
    results = {{type="item", name="bi-dart-rifle", amount=1}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "gun",
    order = "a[basic-clips]-b[bi-dart-rifle]",
  -- This is a custom property for use by "Krastorio 2" (it will change
  -- ingredients/results; used for wood/wood pulp)
	mod = "Bio_Industries_2",
  },

       
})
