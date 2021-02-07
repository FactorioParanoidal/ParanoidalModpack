------------------------------------------------------------------------------------
--   Create fluid fertilizers, recipes, and unlocks if the setting requires it!   --
------------------------------------------------------------------------------------
local BioInd = require('common')('Bio_Industries')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

--~ BioInd.show("fluid_fertilizer.lua -- BI.Settings.BI_Easy_Bio_Gardens", BI.Settings.BI_Easy_Bio_Gardens)
--~ if BI.Settings.BI_Easy_Bio_Gardens then

local function make_colors(color)
  local r, g, b = color.r, color.g, color.b
  local black = {r = 0, g = 0, b = 0, a = .25}

  local function mult(v, f)
    return (v * f) % 1
  end

  ret = {
    base = color,
    flow = {r = mult(r, 3), g = mult(g, 3), b = mult(b, 3), a = .25},
    primary = {r = r, g = g, b = b, a = .5},
    secondary = {r = mult(r, .5), g = mult(g, .5), b = mult(b, .5), a = .25},
    tertiary = {r = mult(r, 2), g = mult(g, 2), b = mult(b, 2), a = .25},
    secondary = black,
  }
  return ret
end

local fertilizer_fluid_colors = make_colors({r = 0.098, g = 0.811, b = 0.269, a = .5})
local adv_fertilizer_fluid_colors = make_colors({r = 0, g = 1, b = 0.071, a = .5})

data:extend({
  ------------------------------------------------------------------------------------
  --                                     FLUIDS                                     --
  ------------------------------------------------------------------------------------

  -- Fertilizer fluid
  {
    type = "fluid",
    name = "bi-fertilizer-fluid",
    icon = ICONPATH .. "fluid_fertilizer_64.png",
    icon_size = 64,
    icon_mipmaps = 1,
    icons = {
      {
        icon = ICONPATH .. "fluid_fertilizer_64.png",
        icon_size = 64,
        icon_mipmaps = 1,
      }
    },
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "1KJ",
    --~ base_color = {r = 0.478, g = 0.341, b = 0.118},
    -- 19cf44
    --~ base_color = {r = 0.098, g = 0.811, b = 0.269},
    base_color = fertilizer_fluid_colors.base,
    --~ flow_color = {r = 0, g = 0, b = 0},
    flow_color = fertilizer_fluid_colors.flow,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    order = "a[fluid]-b[fertilizer]"
  },

  -- Advanced fertilizer fluid
  {
    type = "fluid",
    name = "bi-adv-fertilizer-fluid",
    icon = ICONPATH .. "fluid_advanced_fertilizer_64.png",
    icon_size = 64,
    icon_mipmaps = 1,
    icons = {
      {
        icon = ICONPATH .. "fluid_advanced_fertilizer_64.png",
        icon_size = 64,
        icon_mipmaps = 1,
      }
    },
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "1KJ",
    --00ff12
    --~ base_color = {r = 0.465, g = 0.306, b = 0.272},
    --~ base_color = {r = 0, g = 1, b = 0.071},
    base_color = adv_fertilizer_fluid_colors.base,
    --~ flow_color = {r = 0, g = 0, b = 0},
    flow_color = adv_fertilizer_fluid_colors.flow,
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    order = "a[fluid]-b[fertilizer-advanced]"
  },


  ------------------------------------------------------------------------------------
  --                                     RECIPES                                    --
  ------------------------------------------------------------------------------------

  -- Fertilizer fluid
  {
    type = "recipe",
    name = "bi-fertilizer-fluid",
    icon = ICONPATH .. "fluid_fertilizer_recipe_64.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "fluid_fertilizer_recipe_64.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 5,
    ingredients = {
      {type = "item", name = "fertilizer", amount = 3},
      {type = "fluid", name = "water", amount = 100},
    },
    results = {
      {type = "fluid", name = "bi-fertilizer-fluid", amount = 100}
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[bi-fertilizer]-b[bi-fertilizer-fluid-1]",
    crafting_machine_tint = {
      -- Kettle
      primary = fertilizer_fluid_colors.primary,
      secondary = fertilizer_fluid_colors.secondary,
      -- Chimney
      tertiary = fertilizer_fluid_colors.tertiary,
      quaternary = fertilizer_fluid_colors.quaternary,
    },
  },

  -- Advanced fertilizer fluid
  {
    type = "recipe",
    name = "bi-adv-fertilizer-fluid",
    icon = ICONPATH .. "fluid_advanced_fertilizer_recipe_64.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "fluid_advanced_fertilizer_recipe_64.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 5,
    ingredients = {
      {type = "item", name = "bi-adv-fertilizer", amount = 3},
      {type = "fluid", name = "water", amount = 100},
    },
    results = {
      {type = "fluid", name = "bi-adv-fertilizer-fluid", amount = 100}
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[bi-fertilizer]-b[bi-fertilizer-fluid-2]",
    crafting_machine_tint = {
      primary = adv_fertilizer_fluid_colors.primary,
      secondary = adv_fertilizer_fluid_colors.secondary,
      -- Chimney
      tertiary = adv_fertilizer_fluid_colors.tertiary,
      quaternary = adv_fertilizer_fluid_colors.quaternary,
    },
  },
})

------------------------------------------------------------------------------------
--                                     UNLOCKS                                    --
------------------------------------------------------------------------------------
BioInd.writeDebug("Unlocking fluid fertilizers!")
thxbob.lib.tech.add_recipe_unlock ("bi-tech-fertilizer", "bi-fertilizer-fluid")
thxbob.lib.tech.add_recipe_unlock ("bi-tech-advanced-biotechnology", "bi-adv-fertilizer-fluid")



------------------------------------------------------------------------------------
--                                 CHANGE RECIPES                                 --
------------------------------------------------------------------------------------
-- Purified air (fertilizer)
thxbob.lib.recipe.remove_ingredient("bi-purified-air-1", "fertilizer")
thxbob.lib.recipe.remove_ingredient("bi-purified-air-1", "water")
thxbob.lib.recipe.add_new_ingredient("bi-purified-air-1", {
  type = "fluid",
  name = "bi-fertilizer-fluid",
  amount = 50
})
data.raw.recipe["bi-purified-air-1"].localised_description = {"recipe-description.bi-purified-air-1-fluid"}

-- Purified air (advanced fertilizer)
thxbob.lib.recipe.remove_ingredient("bi-purified-air-2", "bi-adv-fertilizer")
thxbob.lib.recipe.remove_ingredient("bi-purified-air-2", "water")
thxbob.lib.recipe.add_new_ingredient("bi-purified-air-2", {
  type = "fluid",
  name = "bi-adv-fertilizer-fluid",
  amount = 50
})
data.raw.recipe["bi-purified-air-2"].localised_description = {"recipe-description.bi-purified-air-2-fluid"}
