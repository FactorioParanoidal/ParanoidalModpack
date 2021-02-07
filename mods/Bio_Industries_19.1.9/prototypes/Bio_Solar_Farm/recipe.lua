local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

if BI.Settings.BI_Solar_Additions then

  data:extend({

    --- Bio Solar Farm
    {
      type = "recipe",
      name = "bi-bio-solar-farm",
      localised_name = {"entity-name.bi-bio-solar-farm"},
      localised_description = {"entity-description.bi-bio-solar-farm"},
      icon = ICONPATH .. "Bio_Solar_Farm_Icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "Bio_Solar_Farm_Icon.png",
          icon_size = 64,
        }
      },
      enabled = false,
      energy_required = 60,
      ingredients = {
        {"solar-panel", 50},
        {"medium-electric-pole", 25},
        {"concrete", 400},
      },
      result = "bi-bio-solar-farm",
      main_product = "",
      --~ subgroup = "bio-bio-solar-entity",
      --~ order = "a[bi]",
      subgroup = "energy",
      order = "d[solar-panel]-a[solar-panel]-a[bi-bio-solar-farm]",
      --~ always_show_made_in = true,
      --~ allow_decomposition = false,
    allow_as_intermediate = false,      -- Added for 0.18.34/1.1.4
    always_show_made_in = false,        -- Changed for 0.18.34/1.1.4
    allow_decomposition = true,         -- Changed for 0.18.34/1.1.4
    },

    -- solar boiler
    {
      type = "recipe",
      name = "bi-solar-boiler-hidden-panel",
      --~ name = "bi-solar-boiler",
      localised_name = {"entity-name.bi-solar-boiler"},
      localised_description = {"entity-description.bi-solar-boiler"},
      icon = ICONPATH .. "Bio_Solar_Boiler_Icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "Bio_Solar_Boiler_Icon.png",
          icon_size = 64,
        }
      },
      enabled = false,
      energy_required = 15,
      ingredients = {
        {"solar-panel", 30},
        {"storage-tank", 4},
        {"boiler", 1},
      },
      result = "bi-solar-boiler",
      main_product = "",
      subgroup = "energy",
      order = "b[steam-power]-c[steam-engine]",
      --~ always_show_made_in = true,
      --~ allow_decomposition = false,
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },

    -- solar mat
	--[[drd
    {
      type = "recipe",
      name = "bi-solar-mat",
      localised_name = {"entity-name.bi-solar-mat"},
      localised_description = {"entity-description.bi-solar-mat"},
      icon = ICONPATH .. "solar-mat.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "solar-mat.png",
          icon_size = 64,
        }
      },
      enabled = false,
      energy_required = 5,
      ingredients = {
        {"steel-plate", 1},
        {"advanced-circuit", 3},
        {"copper-cable", 4}
      },
      result = "bi-solar-mat",
      main_product = "",
      --~ subgroup = "bio-bio-solar-entity",
      --~ order = "c[bi]",
      subgroup = "energy",
      order = "d[solar-panel]-aa[solar-panel-1-a]",
      --~ always_show_made_in = true,
      --~ allow_decomposition = false,
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },
]]--
    --- BI Accumulator
    {
      type = "recipe",
      name = "bi-bio-accumulator",
      localised_name = {"entity-name.bi-bio-accumulator"},
      localised_description = {"entity-description.bi-bio-accumulator"},
      icon = ICONPATH .. "bi_LargeAccumulator.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_LargeAccumulator.png",
          icon_size = 64,
        }
      },
      energy_required = 60,
      enabled = false,
      ingredients = {
        {"accumulator", 50},
        {"copper-cable", 50},
        {"concrete", 200},
      },
      result = "bi-bio-accumulator",
      main_product = "",
      --~ subgroup = "bio-bio-solar-entity",
      --~ order = "d[bi]",
      subgroup = "energy",
      order = "e[accumulator]-a[bi-accumulator]",
      --~ always_show_made_in = true,
      --~ allow_decomposition = false,
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,       -- Changed for 0.18.34/1.1.4
    },

    -- Large Substation
    {
      type = "recipe",
      --~ name = "bi-huge-substation",
      name = "bi-large-substation",
      localised_name = {"entity-name.bi-large-substation"},
      localised_description = {"entity-description.bi-large-substation"},
      icon = ICONPATH .. "bi_LargeSubstation_icon.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_LargeSubstation_icon.png",
          icon_size = 64,
        }
      },
      enabled = false,
      ingredients = {
        {"steel-plate", 10},
        {"concrete", 200},
		{"copper-plate", 800}, --DrD
        {"substation", 4}
      },
      result = "bi-large-substation",
      main_product = "",
      --~ subgroup = "bio-bio-solar-entity",
      --~ order = "e[bi]",
      subgroup = "energy-pipe-distribution",
      order = "a[energy]-d[substation]-b[large-substation]",
      --~ always_show_made_in = true,
      --~ allow_decomposition = false,
      allow_as_intermediate = false,    -- Added for 0.18.34/1.1.4
      always_show_made_in = false,      -- Changed for 0.18.34/1.1.4
      allow_decomposition = true,               -- Changed for 0.18.34/1.1.4
    },
  })
end
