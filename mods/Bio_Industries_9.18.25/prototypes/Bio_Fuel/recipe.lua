local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

if BI.Settings.BI_Bio_Fuel then

  data:extend({
    -- Basic petroleum-gas processing
    -- (Added for 0.17.49/0.18.17)
    {
      type = "recipe",
      name = "bi-basic-gas-processing",
      localised_name = {"recipe-name.bi-basic-gas-processing"},
      localised_description = {"recipe-description.bi-basic-gas-processing"},
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
      main_product = ""
    },

    --- Bio Boiler (ENTITY) ---
    {
      type = "recipe",
      name = "bi-bio-boiler",
      icon = ICONPATH .. "bio_boiler.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bio_boiler.png",
          icon_size = 64,
        }
      },
      normal = {
        enabled = false,
        energy_required = 10,
        ingredients = {
          {"boiler", 1},
          {"steel-plate", 5},
          {"concrete", 5},
        },
        result = "bi-bio-boiler",
        result_count = 1,
        main_product = "",
      },
      expensive = {
        enabled = false,
        energy_required = 15,
        ingredients = {
          {"boiler", 2},
          {"steel-plate", 5},
          {"concrete", 5},
        },
        result = "bi-bio-boiler",
        result_count = 1,
        main_product = "",
      },
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-energy-boiler",
    },

    -- BIO Reactor (ENTITY)--
    {
      type = "recipe",
      name = "bi-bio-reactor",
      icon = ICONPATH .. "bioreactor.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bioreactor.png",
          icon_size = 64,
        }
      },
      normal = {
        enabled = false,
        energy_required = 20,
        ingredients = {
          {"assembling-machine-1", 1},
          {"steel-plate", 5},
          {"electronic-circuit", 5},
        },
        result = "bi-bio-reactor",
        result_count = 1,
        main_product = "",
      },
      expensive = {
        enabled = false,
        energy_required = 30,
        ingredients = {
          {"assembling-machine-1", 2},
          {"steel-plate", 5},
          {"electronic-circuit", 5},
        },
        result = "bi-bio-reactor",
        result_count = 1,
        main_product = "",
      },
      subgroup = "bio-bio-fuel-fluid",
      order = "a",
      always_show_made_in = true,
      allow_decomposition = false,
    },

    -- CELLULOSE 1 --
    {
      type = "recipe",
      name = "bi-cellulose-1",
      localised_name = {"recipe-name.bi-cellulose-1"},
      localised_description = {"recipe-description.bi-cellulose-1"},
      icon = ICONPATH .. "cellulose.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "cellulose.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      energy_required = 20,
      ingredients = {
        {type = "item", name = "bi-woodpulp", amount = 10},
        {type = "fluid", name = "sulfuric-acid", amount = 10},
      },
      results= {
        {type = "item", name = "bi-cellulose", amount = 10 }
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-other",
      order = "[bi-cellulose-1]",
      --~ subgroup = "intermediate-product",
      --~ order = "b[cellulose-1]",
    },

    -- CELLULOSE 2 --
    {
      type = "recipe",
      name = "bi-cellulose-2",
      localised_name = {"recipe-name.bi-cellulose-2"},
      localised_description = {"recipe-description.bi-cellulose-2"},
      icon = ICONPATH .. "cellulose_2.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "cellulose_2.png",
          icon_size = 64,
        }
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
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-other",
      order = "[bi-cellulose-2]",
      --~ subgroup = "intermediate-product",
      --~ order = "b[cellulose-2]",
      -- This is a custom property for use by "Krastorio 2" (it will change
      -- ingredients/results; used for wood/wood pulp)
      mod = "Bio_Industries",
    },

    -- PLASTIC 1 --
    {
      type = "recipe",
      name = "bi-plastic-1",
      localised_name = {"recipe-name.bi-plastic-1"},
      localised_description = {"recipe-description.bi-plastic-1"},
      icon = ICONPATH .. "plastic_bar_1.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "plastic_bar_1.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      --subgroup = "raw-material",
      energy_required = 1,
      ingredients = {
        {type = "fluid", name = "steam", amount = 10},
        {type = "item", name = "wood", amount = 10},
        {type = "fluid", name = "light-oil", amount = 20},
      },
      results = {
        {type = "item", name = "plastic-bar", amount = 2}
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-solid",
      order = "g[plastic-bar-1]",
      --~ subgroup = "intermediate-product",
      --~ order = "b[bi-plastic-1]",
      -- This is a custom property for use by "Krastorio 2" (it will change
      -- ingredients/results; used for wood/wood pulp)
      mod = "Bio_Industries",
    },

    -- PLASTIC 2 --
    {
      type = "recipe",
      name = "bi-plastic-2",
      localised_name = {"recipe-name.bi-plastic-2"},
      localised_description = {"recipe-description.bi-plastic-2"},
      icon = ICONPATH .. "plastic_bar_2.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "plastic_bar_2.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      energy_required = 1,
      ingredients = {
        {type = "item", name = "bi-cellulose", amount = 1},
        {type = "fluid", name = "petroleum-gas", amount = 10},
      },
      results = {
        {type = "item", name = "plastic-bar", amount = 2}
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-solid",
      order = "g[plastic-bar-2]",
      --~ subgroup = "intermediate-product",
      --~ order = "b[bi-plastic-2]",
    },

    -- BIOMASS 1 --
    {
      type = "recipe",
      name = "bi-biomass-1",
      localised_name = {"recipe-name.bi-biomass-1"},
      localised_description = {"recipe-description.bi-biomass-1"},
      icon = ICONPATH .. "biomass_1.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "biomass_1.png",
          icon_size = 64,
        }
      },
      category = "biofarm-mod-bioreactor",
      energy_required = 10,
      ingredients = {
        {type = "fluid", name = "water", amount = 100},
        {type = "item", name = "fertiliser", amount = 10},
      },
      results = {
        {type = "fluid", name = "bi-biomass", amount = 50},
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      subgroup = "bio-bio-fuel-fluid",
      order = "x[oil-processing]-z1[bi-biomass]"
    },

    -- BIOMASS 2 --
    {
      type = "recipe",
      name = "bi-biomass-2",
      localised_name = {"recipe-name.bi-biomass-2"},
      localised_description = {"recipe-description.bi-biomass-2"},
      icon = ICONPATH .. "biomass_3.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "biomass_3.png",
          icon_size = 64,
        }
      },
      category = "biofarm-mod-bioreactor",
      energy_required = 10,
      ingredients = {
        {type = "fluid", name = "water", amount = 90},
        {type = "fluid", name = "liquid-air", amount = 10},
        {type = "fluid", name = "bi-biomass", amount = 10},
        {type = "item", name = "bi-ash", amount = 10},
      },
      results = {
        {type = "fluid", name = "bi-biomass", amount = 100},
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      --~ subgroup = "bio-bio-fuel-fluid",
      --~ order = "x[oil-processing]-z2[bi-biomass]"
      subgroup = "bio-bio-fuel-fluid",
      order = "x[oil-processing]-z3[bi-biomass]" -- This recipe is more powerful than bi_biomass_3!
    },

    -- BIOMASS 3 --
    {
      type = "recipe",
      name = "bi-biomass-3",
      localised_name = {"recipe-name.bi-biomass-3"},
      localised_description = {"recipe-description.bi-biomass-3"},
      icon = ICONPATH .. "biomass_2.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "biomass_2.png",
          icon_size = 64,
        }
      },
      category = "biofarm-mod-bioreactor",
      energy_required = 60,
      ingredients = {
        {type = "fluid", name = "water", amount = 90},
        {type = "fluid", name = "liquid-air", amount = 10},
        {type = "fluid", name = "bi-biomass", amount = 10},
      },
      results = {
        {type = "fluid", name = "bi-biomass", amount = 35},
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      --~ subgroup = "bio-bio-fuel-fluid",
      --~ order = "x[oil-processing]-z3[bi-biomass]"
      subgroup = "bio-bio-fuel-fluid",
      order = "x[oil-processing]-z2[bi-biomass]" -- This recipe is not as good as bi_biomass_2!
    },

    ---- Biomass to Light-oil
    {
      type = "recipe",
      name = "bi-biomass-conversion-1",
    localised_name = {"recipe-name.bi-biomass-conversion-1"},
    localised_description = {"recipe-description.bi-biomass-conversion-1"},
    icon = ICONPATH .. "bio_conversion_1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_conversion_1.png",
        icon_size = 64,
      }
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
    main_product = "",
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-1]",
    },

    ---- Biomass to PG
    {
    type = "recipe",
    name = "bi-biomass-conversion-2",
    localised_name = {"recipe-name.bi-biomass-conversion-2"},
    localised_description = {"recipe-description.bi-biomass-conversion-2"},
    icon = ICONPATH .. "bio_conversion_2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_conversion_2.png",
        icon_size = 64,
      }
    },
    category = "oil-processing",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 5,
    ingredients = {
      {type = "fluid", name = "bi-biomass", amount = 10},
      {type = "fluid", name = "water", amount = 10},
    },
    results=
    {
      {type = "fluid", name = "petroleum-gas", amount = 20}
    },
    main_product = "",
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-2]",
    },

    ---- Biomass to Lube
    {
    type = "recipe",
    name = "bi-biomass-conversion-3",
    localised_name = {"recipe-name.bi-biomass-conversion-3"},
    localised_description = {"recipe-description.bi-biomass-conversion-3"},
    icon = ICONPATH .. "bio_conversion_3.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_conversion_3.png",
        icon_size = 64,
      }
    },
    category = "oil-processing",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 2.5,
    ingredients =
    {
      {type = "fluid", name = "bi-biomass", amount = 10},
      {type = "fluid", name = "water", amount = 10},
    },
    results = {
      {type = "fluid", name = "lubricant", amount = 10}
    },
    main_product ="",
    crafting_machine_tint =
    {
      primary = {r = 0.000, g = 0.260, b = 0.010, a = 0.000}, -- #00420200
      secondary = {r = 0.071, g = 0.640, b = 0.000, a = 0.000}, -- #12a30000
      tertiary = {r = 0.026, g = 0.520, b = 0.000, a = 0.000}, -- #06840000
    },
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-3]",
    },

    ---- Biomass to Crude
    {
    type = "recipe",
    name = "bi-biomass-conversion-4",
    localised_name = {"recipe-name.bi-biomass-conversion-4"},
    localised_description = {"recipe-description.bi-biomass-conversion-4"},
    icon = ICONPATH .. "bio_conversion_4.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_conversion_4.png",
        icon_size = 64,
      }
    },
    category = "oil-processing",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "coal", amount = 20},
      {type = "fluid", name = "bi-biomass", amount = 10},
      {type = "fluid", name = "steam", amount = 50}
    },
    results = {
      {type = "fluid", name = "crude-oil", amount = 50},
      {type = "fluid", name = "water", amount = 50},
    },
    main_product = "",
    crafting_machine_tint = {
      primary = {r = 0.000, g = 0.260, b = 0.010, a = 0.000}, -- #00420200
      secondary = {r = 0.071, g = 0.640, b = 0.000, a = 0.000}, -- #12a30000
      tertiary = {r = 0.026, g = 0.520, b = 0.000, a = 0.000}, -- #06840000
    },
    subgroup = "bio-bio-fuel-other",
    order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-4]",
    },


    --- Bio Battery
    {
      type = "recipe",
      name = "bi-battery",
      icon = ICONPATH .. "bio_battery.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bio_battery.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      energy_required = 5,
      ingredients = {
        {type = "item", name = "plastic-bar", amount = 1},
        {type = "fluid", name = "bi-biomass", amount = 10},
        {type = "item", name = "bi-cellulose", amount = 1},
      },
      results = {
        {type = "item", name = "battery", amount = 1},
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      crafting_machine_tint = {
        primary = {r = 0.970, g = 0.611, b = 0.000, a = 0.000}, -- #f79b0000
        secondary = {r = 0.000, g = 0.680, b = 0.894, a = 0.357}, -- #00ade45b
        tertiary = {r = 0.430, g = 0.805, b = 0.726, a = 0.000}, -- #6dcdb900
      },
      subgroup = "bio-bio-fuel-solid",
      order = "h",
      --~ subgroup = "raw-material",
      --~ order = "h[bi-battery]",
    },

      --- Bio Acid
    {
      type = "recipe",
      name = "bi-acid",
      icon = ICONPATH .. "bio_acid.png",
      icon_size = 64,
      icons = {
        {
          icon = ICONPATH .. "bio_acid.png",
          icon_size = 64,
        }
      },
      category = "chemistry",
      energy_required = 10,
      ingredients = {
        {type = "fluid", name = "water", amount = 90},
        {type = "fluid", name = "bi-biomass", amount = 10},
        {type = "item", name = "bi-cellulose", amount = 5},
      },
      results = {
        {type = "fluid", name = "sulfuric-acid", amount = 50},
      },
      main_product = "",
      enabled = false,
      always_show_made_in = true,
      allow_decomposition = false,
      crafting_machine_tint = {
        primary = {r = 0.875, g = 0.735, b = 0.000, a = 0.000}, -- #dfbb0000
        secondary = {r = 0.103, g = 0.940, b = 0.000, a = 0.000}, -- #1aef0000
        tertiary = {r = 0.564, g = 0.795, b = 0.000, a = 0.000}, -- #8fca0000
      },
      subgroup = "bio-bio-fuel-other",
      order = "a",
      --~ subgroup = "fluid-recipes",
      --~ order = "a",
    },

    -- Sulfuric acid to Sulfur --
    {
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

    -- Sulfuric acid to Sulfur --IF ANGELS INSTALLED (More Expensice)
    {
      type = "recipe",
      name = "bi-sulfur-angels",
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
        {type = "fluid", name = "sulfuric-acid", amount = 50},
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
      order = "i2",
    },


  })

end
