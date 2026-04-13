local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"

if BI.Settings.BI_Solar_Additions then

  data:extend({

    --- Bio Solar Farm
    {
      type = "recipe",
      name = "bi-bio-solar-farm",
      localised_name = {"entity-name.bi-bio-solar-farm"},
      localised_description = {"entity-description.bi-bio-solar-farm"},
	  icons = { {icon = ICONPATH_E .. "bio_Solar_Farm_Icon.png", icon_size = 64, } },
      enabled = false,
      energy_required = 60,
      ingredients = {
        {type="item", name="solar-panel", amount=50},
        {type="item", name="medium-electric-pole", amount=25},
        {type="item", name="concrete", amount=400},
      },
      results = {{type="item", name="bi-bio-solar-farm", amount=1}},
      main_product = "",
                  subgroup = "energy",
      order = "d[solar-panel]-a[solar-panel]-a[bi-bio-solar-farm]",
                allow_as_intermediate = false,      -- Added for 0.18.34/1.1.4
    always_show_made_in = false,        -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,         -- Changed for 0.18.34/1.1.4
    },

    -- solar boiler
    {
      type = "recipe",
      name = "bi-solar-boiler-hidden-panel",
      localised_name = {"entity-name.bi-solar-boiler"},
      localised_description = {"entity-description.bi-solar-boiler"},
	  icons = { {icon = ICONPATH_E .. "bio_Solar_Boiler_Icon.png", icon_size = 64, } },
      enabled = false,
      energy_required = 15,
      ingredients = {
        {type="item", name="solar-panel", amount=30},
        {type="item", name="storage-tank", amount=4},
        {type="item", name="boiler", amount=1},
      },
      results = {{type="item", name="bi-solar-boiler", amount=1}},
      main_product = "",
      subgroup = "energy",
      order = "b[steam-power]-c[steam-engine]",
                  allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },

    -- solar mat
    {
      type = "recipe",
      name = "bi-solar-mat",
      localised_name = {"entity-name.bi-solar-mat"},
      localised_description = {"entity-description.bi-solar-mat"},
	  icons = { {icon = ICONPATH_E .. "solar-mat.png", icon_size = 64, } },
      enabled = false,
      energy_required = 5,
      ingredients = {
        {type="item", name="steel-plate", amount=1},
        {type="item", name="advanced-circuit", amount=3},
        {type="item", name="copper-cable", amount=4}
      },
      results = {{type="item", name="bi-solar-mat", amount=1}},
      main_product = "",
                  subgroup = "energy",
      order = "d[solar-panel]-aa[solar-panel-1-a]",
                  allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },

    --- BI Accumulator
    {
      type = "recipe",
      name = "bi-bio-accumulator",
      localised_name = {"entity-name.bi-bio-accumulator"},
      localised_description = {"entity-description.bi-bio-accumulator"},
	  icons = { {icon = ICONPATH_E .. "bi_LargeAccumulator.png", icon_size = 64, } },
      energy_required = 60,
      enabled = false,
      ingredients = {
        {type="item", name="accumulator", amount=50},
        {type="item", name="copper-cable", amount=50},
        {type="item", name="concrete", amount=200},
      },
      results = {{type="item", name="bi-bio-accumulator", amount=1}},
      main_product = "",
      subgroup = "energy",
      order = "e[accumulator]-a[bi-accumulator]",
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,       -- Changed for 0.18.34/1.1.4
    },

    -- Large Substation
    {
      type = "recipe",
      name = "bi-large-substation",
      localised_name = {"entity-name.bi-large-substation"},
      localised_description = {"entity-description.bi-large-substation"},
	  icons = { {icon = ICONPATH_E .. "bi_LargeSubstation_icon.png", icon_size = 64, } },
      enabled = false,
      ingredients = {
        {type="item", name="steel-plate", amount=10},
        {type="item", name="concrete", amount=200},
        {type="item", name="substation", amount=4}
      },
      results = {{type="item", name="bi-large-substation", amount=1}},
      main_product = "",
                  subgroup = "energy-pipe-distribution",
      order = "a[energy]-d[substation]-b[large-substation]",
                  allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },
  })
end
