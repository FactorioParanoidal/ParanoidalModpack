data:extend({
-- BIO Reactor (ENTITY)
  {
    type = "recipe",
    name = "bi-bio-reactor",
    localised_name = {"entity-name.bi-bio-reactor"},
    localised_description = {"entity-description.bi-bio-reactor"},
    normal = 
    {
      enabled = false,
      energy_required = 20,
      ingredients = 
      {
        {"assembling-machine-1", 1},
        {"steel-plate", 5},
        {"electronic-circuit", 5},
      },
      result = "bi-bio-reactor",
      result_count = 1,
      allow_as_intermediate = false,
      always_show_made_in = false,
      allow_decomposition = true,
    },
    expensive = 
    {
      enabled = false,
      energy_required = 30,
      ingredients = 
      {
        {"assembling-machine-1", 2},
        {"steel-plate", 5},
        {"electronic-circuit", 5},
      },
      result = "bi-bio-reactor",
      result_count = 1,
      allow_as_intermediate = false,
      always_show_made_in = false,  
      allow_decomposition = true,   
    },
    subgroup = "bio-bio-fuel-fluid",
    order = "a",
    allow_as_intermediate = false,
    always_show_made_in = false,
    allow_decomposition = true,
},
--###############################################################################################
-- BIOMASS 1
  {
    type = "recipe",
    name = "bi-biomass-1",
    localised_name = {"recipe-name.bi-biomass-1"},
    localised_description = {"recipe-description.bi-biomass-1"},
    icons = 
    {
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
    },
    category = "biofarm-mod-bioreactor",
    energy_required = 10,
    ingredients = 
    {
      {type = "fluid", name = "water", amount = 100},
      {type = "item", name = "fertilizer", amount = 10},
    },
    results = {{type = "fluid", name = "bi-biomass", amount = 50}},
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = true,
    crafting_machine_tint = {primary = util.color("43f436")},
    subgroup = "bio-bio-fuel-fluid",
    order = "x[oil-processing]-z1[bi-biomass]"
  },
})
--###############################################################################################
if BI.Settings.BI_Bio_Fuel then
  data:extend({
--[[    {
      type = "recipe",
      name = "bi-basic-gas-processing",
      icon = ICONPATH .. "bi_basic_gas_processing.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bi_basic_gas_processing.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      enabled = false,
      energy_required = 5,
      ingredients = {
        {type = "item", name = "coal", amount = 20},
        {type = "item", name = "resin", amount = 10},
        {type = "fluid", name ="steam", amount = 50}
      },
      results = {
        --~ {type = "fluid", name = "petroleum-gas", amount = 15, fluidbox_index = 3},
        {type = "fluid", name = "petroleum-gas", amount = 15},
        {type = "item", name = "bi-ash", amount = 15}
      },
      subgroup = "bio-bio-fuel-other",
      order = "[bi_basic_gas_processing]",
      main_product = "",
      allow_as_intermediate = false,
      always_show_made_in = true,   
      allow_decomposition = true,   
    },
]]
--###############################################################################################
-- Bio Boiler (ENTITY)
    {
      type = "recipe",
      name = "bi-bio-boiler",
      localised_name = {"entity-name.bi-bio-boiler"},
      localised_description = {"entity-description.bi-bio-boiler"},
      normal = 
      {
        enabled = false,
        energy_required = 10,
        ingredients = 
        { --drd
          {"boiler", 2},
          {"steel-plate", 20},
          {"concrete", 20},
          {"electronic-circuit", 5},	
        },
        result = "bi-bio-boiler",
        result_count = 1,
        allow_as_intermediate = false,
        always_show_made_in = false,
        allow_decomposition = true, 
      },
      expensive = 
      {
        enabled = false,
        energy_required = 15,
        ingredients = 
        { --drd
          {"boiler", 2},
          {"steel-plate", 30},
          {"concrete", 30},
          {"electronic-circuit", 10},	
        },
        result = "bi-bio-boiler",
        result_count = 1,
        allow_as_intermediate = false,
        always_show_made_in = false,
        allow_decomposition = true, 
     },
      allow_as_intermediate = false,
      always_show_made_in = false,
      allow_decomposition = true, 
      subgroup = "energy",        
      order = "b-[steam-power]-a[boiler]-a[bi-bio-boiler]"
    },
--###############################################################################################
-- CELLULOSE 1
{
      type = "recipe",
      name = "bi-cellulose-1",
      localised_name = {"recipe-name.bi-cellulose-1"},
      localised_description = {"recipe-description.bi-cellulose-1"},
      category = "chemistry",
      energy_required = 20,
      ingredients = 
      {
        {type = "item", name = "bi-woodpulp", amount = 10},
        {type = "fluid", name = "sulfuric-acid", amount = 10},
      },
      results = {{type = "item", name = "bi-cellulose", amount = 10 }},
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-other",
      order = "[bi-cellulose-1]",
      crafting_machine_tint = {
        primary     = util.color("d1c73b"),
        secondary   = util.color("bdb057"),
        tertiary    = util.color("dec864"),
        quaternary  = util.color("bdbc55")
      },
},
--###############################################################################################
-- CELLULOSE 2
    {
      type = "recipe",
      name = "bi-cellulose-2",
      localised_name = {"recipe-name.bi-cellulose-2"},
      localised_description = {"recipe-description.bi-cellulose-2"},
      icons = 
      {
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/cellulose.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__base__/graphics/icons/fluid/steam.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}},
      },
      category = "chemistry",
      energy_required = 5,
      ingredients = {
        {type = "fluid", name = "steam", amount = 10},
        {type = "item", name = "bi-woodpulp", amount = 10},
        {type = "fluid", name = "sulfuric-acid", amount = 20},
      },
      results = {
        {type = "item", name = "bi-cellulose", amount = 10 }
      },
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-other",
      order = "[bi-cellulose-2]",
      crafting_machine_tint = {
        primary     = util.color("d1c73b"),
        secondary   = util.color("bdb057"),
        tertiary    = util.color("dec864"),
        quaternary  = util.color("bdbc55")
      },
    },
--###############################################################################################
-- PLASTIC 1
    {
      type = "recipe",
      name = "bi-plastic-1",
      localised_name = {"recipe-name.bi-plastic-1"},
      localised_description = {"recipe-description.bi-plastic-1"},
      icons = 
      {
        {icon = "__base__/graphics/icons/plastic-bar.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/woodpulp.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}},
        {icon = "__base__/graphics/icons/fluid/light-oil.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, 8}}
      },
      category = "chemistry",
      energy_required = 1,
      ingredients = 
      {
        {type = "fluid", name = "steam", amount = 10},
        {type = "item", name = "bi-woodpulp", amount = 20},
        --{type = "item", name = "wood", amount = 10},
        {type = "fluid", name = "light-oil", amount = 20},
      },
      crafting_machine_tint = {
        primary     = util.color("e3d7aa"),
        secondary   = util.color("c2b99f"),
        tertiary    = util.color("d4ac48"),
        quaternary  = util.color("e0b572")
      },
      results = {{type = "item", name = "plastic-bar", amount = 2}},
      enabled = false,
      show_amount_in_title = true,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-solid",
      order = "g[plastic-bar-1]",
    },
--###############################################################################################
-- PLASTIC 2
{
      type = "recipe",
      name = "bi-plastic-2",
      localised_name = {"recipe-name.bi-plastic-2"},
      localised_description = {"recipe-description.bi-plastic-2"},
      icons = 
      {
        {icon = "__base__/graphics/icons/plastic-bar.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/cellulose.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}},
        {icon = "__angelspetrochem__/graphics/icons/molecules/methane.png",
        icon_size = 72, icon_mipmaps = 1, scale = 0.2, shift = {8, 8}}
      },
      category = "chemistry",
      energy_required = 1,
      ingredients = 
      {
        {type = "item", name = "bi-cellulose", amount = 1},
        {type = "fluid", name = "petroleum-gas", amount = 10},
      },
      results = {{type = "item", name = "plastic-bar", amount = 2}},
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-solid",
      order = "g[plastic-bar-2]",
      crafting_machine_tint = {
        primary     = util.color("e3d7aa"),
        secondary   = util.color("c2b99f"),
        tertiary    = util.color("e3d1ba"),
        quaternary  = util.color("e3d7aa")
      },
},
--###############################################################################################
-- BIOMASS 2
{
      type = "recipe",
      name = "bi-biomass-2",
      localised_name = {"recipe-name.bi-biomass-2"},
      localised_description = {"recipe-description.bi-biomass-2"},
      icons = 
      {
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__angelspetrochem__/graphics/icons/molecules/oxygen.png",
        icon_size = 72, icon_mipmaps = 1, scale = 0.2, shift = {-8, 8}}
      },
      category = "biofarm-mod-bioreactor",
      energy_required = 60,
      ingredients = 
      {
        {type = "fluid", name = "water", amount = 90},
        {type = "fluid", name = "liquid-air", amount = 10},
        {type = "fluid", name = "bi-biomass", amount = 10},
      },
      results = {{type = "fluid", name = "bi-biomass", amount = 35}},
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-fluid",
      order = "x[oil-processing]-z2[bi-biomass]", -- This recipe is not as good as bi_biomass_2!
      crafting_machine_tint = {primary = util.color("67f45d")},
},
--###############################################################################################
-- BIOMASS 3
    {
      type = "recipe",
      name = "bi-biomass-3",
      localised_name = {"recipe-name.bi-biomass-3"},
      localised_description = {"recipe-description.bi-biomass-3"},
      icons = 
      {
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__angelspetrochem__/graphics/icons/molecules/oxygen.png",
        icon_size = 72, icon_mipmaps = 1, scale = 0.2, shift = {-8, 8}},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/ash.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, 8}}
      },
      category = "biofarm-mod-bioreactor",
      energy_required = 10,
      ingredients = 
      {
        {type = "fluid", name = "water", amount = 90},
        {type = "fluid", name = "liquid-air", amount = 10},
        {type = "fluid", name = "bi-biomass", amount = 10},
        {type = "item", name = "bi-ash", amount = 10},
      },
      results = {{type = "fluid", name = "bi-biomass", amount = 100}},
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-fluid",
      order = "x[oil-processing]-z3[bi-biomass]", -- This recipe is more powerful than bi_biomass_3!
      crafting_machine_tint = {primary = util.color("60c159")},
},
--###############################################################################################
-- Biomass to Light-oil
    {
      type = "recipe",
      name = "bi-biomass-conversion-1",
    localised_name = {"recipe-name.bi-biomass-conversion-1"},
    localised_description = {"recipe-description.bi-biomass-conversion-1"},
    icons = 
    {
      {icon = "__base__/graphics/icons/fluid/light-oil.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = {-7, -7}},
    },
    category = "oil-processing",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 5,
    ingredients = {
      {type = "fluid", name = "bi-biomass", amount = 100},
      {type = "fluid", name = "water", amount = 10},
    },
    results = {
      {type = "item", name = "bi-cellulose", amount = 2},
      {type = "fluid", name = "light-oil", amount = 80},
    },
    crafting_machine_tint = { primary = util.color("efd544") },
    allow_as_intermediate = false,
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-1]",
    },
--###############################################################################################
-- Biomass to PG
{
    type = "recipe",
    name = "bi-biomass-conversion-2",
    localised_name = {"recipe-name.bi-biomass-conversion-2"},
    localised_description = {"recipe-description.bi-biomass-conversion-2"},
    icons = 
    {
      {icon = "__angelsrefining__/graphics/icons/angels-gas/gas-item-base.png",
      icon_size = 596, scale = 0.053691275167785, tint = {r = 0.25, g = 0.25, b = 0.25, a = 0.7}},
      {icon = "__angelsrefining__/graphics/icons/angels-gas/gas-item-top.png",
      icon_size = 596, scale = 0.053691275167785, tint = {r = 0.17254901960784315, g = 0.17254901960784315, b = 0.17254901960784315, a = 1}},
      {icon = "__angelsrefining__/graphics/icons/angels-gas/gas-item-mid.png",
      icon_size = 596, scale = 0.053691275167785, tint = {r = 0.95294117647058822, g = 0.95294117647058822, b = 0.95294117647058822, a = 1}},
      {icon = "__angelsrefining__/graphics/icons/angels-gas/gas-item-bot.png",
      icon_size = 596, scale = 0.053691275167785, tint = {r = 0.94901960784313726, g = 0.94901960784313726, b = 0.94901960784313726, a = 1}},
      --{icon = "__angelspetrochem__/graphics/icons/molecules/methane.png",
      --icon_size = 72, shift = {-10, -10}, scale = 0.20833333333333},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = {-8, -6}},
    },
    category = "oil-processing",
    enabled = false,
    allow_as_intermediate = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 5,
    ingredients = 
    {
      {type = "fluid", name = "bi-biomass", amount = 10},
      {type = "fluid", name = "water", amount = 10},
    },
    results = {{type = "fluid", name = "petroleum-gas", amount = 20}},
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-2]",
    crafting_machine_tint = {primary = util.color("9adf95")},
},
--###############################################################################################
-- Biomass to Lube
{
    type = "recipe",
    name = "bi-biomass-conversion-3",
    localised_name = {"recipe-name.bi-biomass-conversion-3"},
    localised_description = {"recipe-description.bi-biomass-conversion-3"},
    icons = 
    {
      {icon = "__base__/graphics/icons/fluid/lubricant.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = {-7, -7}},
    },
    category = "oil-processing",
    enabled = false,
    allow_as_intermediate = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 2.5,
    ingredients = 
    {
      {type = "fluid", name = "bi-biomass", amount = 10},
      {type = "fluid", name = "water", amount = 10},
    },
    results = {{type = "fluid", name = "lubricant", amount = 10}},
    crafting_machine_tint = {primary = util.color("64de41")},
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-3]",
},
--###############################################################################################
-- Biomass to Crude
{
    type = "recipe",
    name = "bi-biomass-conversion-4",
    localised_name = {"recipe-name.bi-biomass-conversion-4"},
    localised_description = {"recipe-description.bi-biomass-conversion-4"},
    icons = 
    {
      {icon = "__base__/graphics/icons/fluid/crude-oil.png",
      icon_size = 64, icon_mipmaps = 4},
      {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
      icon_size = 64, icon_mipmaps = 4, scale = 0.35, shift = {-7, -7}},
    },
    category = "oil-processing",
    enabled = false,
    allow_as_intermediate = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 10,
    ingredients = 
    {
      {type = "item", name = "coal", amount = 20},
      {type = "fluid", name = "bi-biomass", amount = 10},
      {type = "fluid", name = "steam", amount = 50}
    },
    results = 
    {
      {type = "fluid", name = "crude-oil", amount = 50},
      {type = "fluid", name = "water", amount = 50},
    },
    crafting_machine_tint = { primary = util.color("2c482a") },
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-4]",
},
--###############################################################################################
-- Bio Battery
    {
      type = "recipe",
      name = "bi-battery",
      icons = 
      {
        {icon = "__base__/graphics/icons/battery.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}},
      },
      category = "chemistry",
      energy_required = 5,
      ingredients = 
      {
        {type = "item", name = "plastic-bar", amount = 1},
        {type = "fluid", name = "bi-biomass", amount = 10},
        {type = "item", name = "bi-cellulose", amount = 1},
      },
      results = {{type = "item", name = "battery", amount = 1}},
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,   
      allow_decomposition = true,   
      crafting_machine_tint = {
        primary     = util.color("dff0da"),
        secondary   = util.color("e0df77"),
        tertiary    = util.color("88ba8a"),
        quaternary  = util.color("bbb38f")
      },
      subgroup = "bio-bio-fuel-solid",
      order = "h",
},
--###############################################################################################
-- Bio Acid
    {
      type = "recipe",
      name = "bi-acid",
      icons = 
      {
        {icon = "__base__/graphics/icons/fluid/sulfuric-acid.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/cellulose.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, 8}}
      },
      category = "chemistry",
      energy_required = 10,
      ingredients = 
      {
        {type = "fluid", name = "water", amount = 90},
        {type = "fluid", name = "bi-biomass", amount = 10},
        {type = "item", name = "bi-cellulose", amount = 5},
      },
      results = {{type = "fluid", name = "sulfuric-acid", amount = 50}},
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      crafting_machine_tint = {
        primary     = util.color("e2df69"),
        secondary   = util.color("b6c4a7"),
        tertiary    = util.color("85b87d"),
        quaternary  = util.color("b9ba8a")
      },
      subgroup = "bio-bio-fuel-other",
      order = "a",
},
--###############################################################################################
-- Sulfuric acid to Sulfur
    --[[{
      type = "recipe",
      name = "bi-sulfur",
      icon = ICONPATH .. "bio_sulfur.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bio_sulfur.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      energy_required = 10,
      ingredients = {
        {type = "fluid", name = "sulfuric-acid", amount = 10},
        {type = "item", name = "bi-ash", amount = 10},
      },
      results = {
        {type = "item", name = "sulfur", amount = 10}
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-solid",
      order = "i1",
      --~ subgroup = "raw-material",
      --~ order = "g[sulfur]-[bi-sulfur]",
    },
]]
--###############################################################################################
-- Sulfuric acid to Sulfur --IF ANGELS INSTALLED (More Expensice)
    {
      type = "recipe",
      name = "bi-sulfur-angels",
      icons = 
      {
        {icon = "__base__/graphics/icons/sulfur.png",
        icon_size = 64, icon_mipmaps = 4},
        {icon = "__base__/graphics/icons/fluid/sulfuric-acid.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}},
        {icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/ash.png",
        icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, 8}}
      },
      category = "chemistry",
      energy_required = 12, --drd from 10
      ingredients = 
      {
        {type = "fluid", name = "sulfuric-acid", amount = 50},
        {type = "item", name = "bi-ash", amount = 10},
      },
      results = {{type = "item", name = "sulfur", amount = 8}}, --drd from 10
      enabled = false,
      allow_as_intermediate = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-solid",
      order = "i2",
      crafting_machine_tint = {
        primary     = util.color("eadc30"),
        secondary   = util.color("ebdd28"),
        tertiary    = util.color("eadc30"),
        quaternary  = util.color("ebdd28")
      },
    },
  })
end