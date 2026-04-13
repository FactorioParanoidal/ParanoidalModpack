local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"

data:extend({

  --- Big Electric Pole
  {
    type = "recipe",
    name = "bi-wooden-pole-big",
    localised_name = {"entity-name.bi-wooden-pole-big"},
    localised_description = {"entity-description.bi-wooden-pole-big"},
	icons = { {icon = ICONPATH_E .. "big-wooden-pole.png", icon_size = 64, } },
    enabled = false,
    ingredients = {
        {type="item", name="wood", amount=5},
        {type="item", name="small-electric-pole", amount=2},
      },
    results = {{type="item", name="bi-wooden-pole-big", amount=1}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-b[small-electric-pole]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Huge Wooden Pole
  {
    type = "recipe",
    name = "bi-wooden-pole-huge",
    localised_name = {"entity-name.bi-wooden-pole-huge"},
    localised_description = {"entity-description.bi-wooden-pole-huge"},
	icons = { {icon = ICONPATH_E .. "huge-wooden-pole.png", icon_size = 64, } },
    enabled = false,
    ingredients = {
        {type="item", name="wood", amount=5},
        {type="item", name="concrete", amount=100},
        {type="item", name="bi-wooden-pole-big", amount=6},
      },
    results = {{type="item", name="bi-wooden-pole-huge", amount=1}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-d[big-electric-pole]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Wooden Fence
  {
    type = "recipe",
    name = "bi-wooden-fence",
    localised_name = {"entity-name.bi-wooden-fence"},
    localised_description = {"entity-description.bi-wooden-fence"},
	icons = { {icon = ICONPATH_E .. "wooden-fence.png", icon_size = 64, } },
    enabled = true,
    ingredients = {
        {type="item", name="wood", amount=2},
      },
    results = {{type="item", name="bi-wooden-fence", amount=1}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "defensive-structure",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  --- Wood Pipe
  {
    type = "recipe",
    name = "bi-wood-pipe",
    localised_name = {"entity-name.bi-wood-pipe"},
    localised_description = {"entity-description.bi-wood-pipe"},
	icons = { {icon = ICONPATH_E .. "wood_pipe.png", icon_size = 64, } },
    energy_required = 1,
    enabled = true,
      ingredients = {
        {type="item", name="copper-plate", amount=1},
        {type="item", name="wood", amount=8}
      },
    results = {{type="item", name="bi-wood-pipe", amount=4}},
    main_product = "",
    requester_paste_multiplier = 15,
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1a[pipe]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries_2",
  },

  -- Wood Pipe to Ground
  {
    type = "recipe",
    name = "bi-wood-pipe-to-ground",
    localised_name = {"entity-name.bi-wood-pipe-to-ground"},
    localised_description = {"entity-description.bi-wood-pipe-to-ground"},
	icons = { {icon = ICONPATH_E .. "pipe-to-ground-wood.png", icon_size = 64, } },
    energy_required = 2,
    enabled = true,
    ingredients = {
        {type="item", name="copper-plate", amount=4},
        {type="item", name="bi-wood-pipe", amount=5}
      },
    results = {{type="item", name="bi-wood-pipe-to-ground", amount=2}},
    main_product = "",
    allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
    always_show_made_in = false,      -- Added for 0.18.34/1.1.4
    allow_decomposition = true,       -- Added for 0.18.34/1.1.4
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1b[pipe-to-ground]",
  },
  
})
