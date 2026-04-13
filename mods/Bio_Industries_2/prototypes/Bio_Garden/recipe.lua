local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"

--- Bio Gardens
data:extend({

  --- Garden (ENTITY)
  {
    type = "recipe",
    name = "bi-bio-garden",
    localised_name = {"entity-name.bi-bio-garden"},
    localised_description = {"entity-description.bi-bio-garden"},
	icons = { {icon = ICONPATH_E .. "bio_garden_icon.png", icon_size = 64, } },
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type="item", name="stone-wall", amount=12},
      {type="item", name="stone-crushed", amount=50},
      {type="item", name="seedling", amount=50}
    },
    results = {{type="item", name="bi-bio-garden", amount=1}},
    main_product = "",
    subgroup = "bio-bio-gardens-fluid",
    order = "a[bi-garden-1]",
    allow_as_intermediate = false,      -- Changed for 0.18.34/1.1.4
    always_show_made_in = false,        -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,         -- Changed for 0.18.34/1.1.4    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Garden - Large(ENTITY)
  {
    type = "recipe",
    name = "bi-bio-garden-large",
    localised_name = {"entity-name.bi-bio-garden-large"},
    localised_description = {"entity-description.bi-bio-garden-large"},
	icons = { {icon = ICONPATH_E .. "bio_garden_large_icon.png", icon_size = 64, } },
    enabled = false,
    energy_required = 15,
    ingredients = {
      {type="item", name="stone-wall", amount=48},
      {type="item", name="stone-crushed", amount=200},
      {type="item", name="bi-bio-garden", amount=4}
    },
    results = {{type="item", name="bi-bio-garden-large", amount=1}},
    main_product = "",
    subgroup = "bio-bio-gardens-fluid",
    order = "a[bi-garden-2]",
    allow_as_intermediate = false,      -- Changed for 0.18.34/1.1.4
    always_show_made_in = false,        -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,         -- Changed for 0.18.34/1.1.4    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Garden - Huge(ENTITY)
  {
    type = "recipe",
    name = "bi-bio-garden-huge",
    localised_name = {"entity-name.bi-bio-garden-huge"},
    localised_description = {"entity-description.bi-bio-garden-huge"},
	icons = { {icon = ICONPATH_E .. "bio_garden_huge_icon.png", icon_size = 64, } },
    enabled = false,
    energy_required = 15,
    ingredients = {
      {type="item", name="stone-wall", amount=192},
      {type="item", name="stone-crushed", amount=800},
      {type="item", name="bi-bio-garden-large", amount=4}
    },
    results = {{type="item", name="bi-bio-garden-huge", amount=1}},
    main_product = "",
    subgroup = "bio-bio-gardens-fluid",
    order = "a[bi-garden-3]",
    allow_as_intermediate = false,      -- Changed for 0.18.34/1.1.4
    always_show_made_in = false,        -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,         -- Changed for 0.18.34/1.1.4    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Clean Air 1
  {
    type = "recipe",
    name = "bi-purified-air-1",
	icons = { {icon = ICONPATH .. "clean-air_mk1.png", icon_size = 64, } },
    order = "zzz-clean-air",
    category = "clean-air",
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air-1",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 40,
    ingredients = {
      {type = "fluid", name = "water", amount = 50},
      {type = "item", name = "fertilizer", amount = 1}
    },
    results = {
      {type = "item", name = "bi-purified-air", amount = 1, probability = 0},
    },
    main_product = "",
  },


  --- Clean Air 2
  {
    type = "recipe",
    name = "bi-purified-air-2",
	icons = { {icon = ICONPATH .. "clean-air_mk2.png", icon_size = 64, } },
    order = "zzz-clean-air2",
    category = "clean-air",
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air-2",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 100,
    ingredients = {
      {type = "fluid", name = "water", amount = 50},
      {type = "item", name = "bi-adv-fertilizer", amount = 1},
    },
    results = {
      {type = "item", name = "bi-purified-air", amount = 1, probability = 0},
    },
    main_product = "",
  },

})
