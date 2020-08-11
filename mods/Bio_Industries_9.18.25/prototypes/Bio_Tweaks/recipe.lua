local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

if BI.Settings.BI_Game_Tweaks_Disassemble then
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
      icon = ICONPATH .. "burner-mining-drill_disassemble.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "burner-mining-drill_disassemble.png",
          icon_size = 64,
        }
      },
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
        {"stone", 4},
        {"iron-plate", 4}
      },
      main_product = "",
    },


    {
      type = "recipe",
      name = "bi-stone-furnace-disassemble",
      icon = ICONPATH .. "stone_furnace_disassemble.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "stone_furnace_disassemble.png",
          icon_size = 64,
        }
      },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-b[bi-stone-furnace-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "stone-furnace", amount = 1},
      },
      results = {
        {"stone", 3},
      },
      main_product = "",
    },

    {
      type = "recipe",
      name = "bi-burner-inserter-disassemble",
      icon = ICONPATH .. "burner_inserter_disassemble.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "burner_inserter_disassemble.png",
          icon_size = 64,
        }
      },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-c[bi-burner-inserter-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "burner-inserter", amount = 1},
      },
      results = {
        {"iron-plate", 2},
      },
      main_product = "",
    },

    {
      type = "recipe",
      name = "bi-long-handed-inserter-disassemble",
      icon = ICONPATH .. "long_handed_inserter_disassemble.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "long_handed_inserter_disassemble.png",
          icon_size = 64,
        }
      },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-e[bi-long-handed-inserter-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "long-handed-inserter", amount = 1},
      },
      results = {
        {"iron-gear-wheel", 1},
        {"iron-plate", 1},
        {"electronic-circuit", 1},
      },
      main_product = "",
    },

    {
      type = "recipe",
      name = "bi-steel-furnace-disassemble",
      icon = ICONPATH .. "steel-furnace_disassemble.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "steel-furnace_disassemble.png",
          icon_size = 64,
        }
      },
      category = "advanced-crafting",
      subgroup = "bio-disassemble",
      order = "a[Disassemble]-f[bi-steel-furnace-disassemble]",
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      energy_required = 2,
      ingredients = {
        {type = "item", name = "steel-furnace", amount = 1},
      },
      results = {
        {"steel-plate", 4},
        {"stone-brick", 4}
      },
      main_product = "",
    },
  })
end


-- Add alternative Production Science Pack using Wooden rails instead of regular rails.
-- This will only be created if "Krastorio 2" IS NOT active (new recipe would break the
-- balance then) and if the setting for the recipe IS enabled.
local KRAS = (mods["Krastorio2"] or mods["Krastorio"]) and true or false
local SET = settings.startup["BI_Game_Tweaks_Production_Science"].value
if SET and not KRAS then
  data:extend({
    {
      type = "recipe",
      name = "bi-production-science-pack",
      enabled = false,
      energy_required = 21,
      ingredients = {
        {"electric-furnace", 1},
        {"productivity-module", 1},
        {"bi-rail-wood", 40}
      },
      result_count = 3,
      result = "production-science-pack"
    },
  })
  --~ BI_Functions.lib.allow_productivity("bi-production-science-pack")
  --~ thxbob.lib.tech.add_recipe_unlock("production-science-pack", "bi-production-science-pack")
  BioInd.writeDebug("Added alternative recipe for Production science packs.")
else
  BioInd.writeDebug("Didn't add alternative recipe for Production science packs! (\"Krastorio\": " ..
                    tostring(KRAS and "active" or "not active") .. ", Setting: " ..
                    tostring(SET and "enabled" or "disabled") .. ")")
end
