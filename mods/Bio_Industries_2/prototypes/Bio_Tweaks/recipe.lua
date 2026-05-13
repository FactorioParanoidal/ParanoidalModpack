local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

log("BI.Settings.BI_Game_Tweaks_Disassemble: " .. tostring(BI.Settings.BI_Game_Tweaks_Disassemble))

if BI.Settings.BI_Game_Tweaks_Disassemble then
log("Enabling disassemble recipes!")
  --- Bio Tweaks
  data:extend({
    -- Item subgroup
    {
      type = "item-subgroup",
      name = "bio-disassemble",
      group = "bio-industries",
      order = "zzzz",
    },

    -- Recipes
    {
      type = "recipe",
      name = "bi-burner-mining-drill-disassemble",
      localised_description = {"recipe-description.bi-disassemble-recipes"},
      icons = { {icon = ICONPATH .. "burner-mining-drill_disassemble.png", icon_size = 64, } },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-a[bi-burner-mining-drill-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "burner-mining-drill", amount = 1},
      },
      results = {
        {type="item", name="stone", amount=4},
        {type="item", name="iron-plate", amount=4}
      },
      main_product = "",
    },
----
    {
      type = "recipe",
      name = "bi-burner-inserter-disassemble",
      localised_description = {"recipe-description.bi-disassemble-recipes"},
	  icons = { {icon = ICONPATH .. "burner_inserter_disassemble.png", icon_size = 64, } },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-b[bi-burner-inserter-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "burner-inserter", amount = 1},
      },
      results = {
        {type="item", name="iron-plate", amount=2},
      },
      main_product = "",
    },
----
    {
      type = "recipe",
      name = "bi-long-handed-inserter-disassemble",
      localised_description = {"recipe-description.bi-disassemble-recipes"},
	  icons = { {icon = ICONPATH .. "long_handed_inserter_disassemble.png", icon_size = 64, } },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-c[bi-long-handed-inserter-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "long-handed-inserter", amount = 1},
      },
      results = {
        {type="item", name="iron-gear-wheel", amount=1},
        {type="item", name="iron-plate", amount=1},
        {type="item", name="electronic-circuit", amount=1},
      },
      main_product = "",
    },
---
    {
      type = "recipe",
      name = "bi-stone-furnace-disassemble",
      localised_description = {"recipe-description.bi-disassemble-recipes"},
	  icons = { {icon = ICONPATH .. "stone_furnace_disassemble.png", icon_size = 64, } },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-d[bi-stone-furnace-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "stone-furnace", amount = 1},
      },
      results = {
        {type="item", name="stone", amount=3},
      },
      main_product = "",
    },
---
    {
      type = "recipe",
      name = "bi-steel-furnace-disassemble",
      localised_description = {"recipe-description.bi-disassemble-recipes"},
	  icons = { {icon = ICONPATH .. "steel-furnace_disassemble.png", icon_size = 64, } },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-e[bi-steel-furnace-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "steel-furnace", amount = 1},
      },
      results = {
        {type="item", name="steel-plate", amount=4},
        {type="item", name="stone-brick", amount=4}
      },
      main_product = "",
    },
	
  })
end