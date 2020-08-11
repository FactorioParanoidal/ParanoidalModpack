local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

data:extend({



  --- Seeds from Water (BASIC)
  {
    type = "recipe",
    name = "bi-seed-1",
    localised_name = {"recipe-name.bi-seed-1"},
    localised_description = {"recipe-description.bi-seed-1"},
    icon = ICONPATH .. "bio_seed1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_seed1.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 200,
    ingredients =
    {
      {type = "fluid", name = "water", amount = 100},
      {type = "item", name = "wood", amount = 20},
    },
    results=
    {
      {type = "item", name = "bi-seed", amount = 40},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-1",
    order = "a[bi]-ssw-a1[bi-seed-1]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seeds from Water & Ash
  {
    type = "recipe",
    name = "bi-seed-2",
    localised_name = {"recipe-name.bi-seed-2"},
    localised_description = {"recipe-description.bi-seed-2"},
    icon = ICONPATH .. "bio_seed2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_seed2.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 150,
    ingredients =
    {
      {type = "fluid", name = "water", amount = 40},
      {type = "item", name = "wood", amount = 20},
      {type = "item", name = "bi-ash", amount = 10},
    },
    results=
    {
      {type = "item", name = "bi-seed", amount = 50},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-1",
    order = "a[bi]-ssw-a1[bi-seed-2]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seeds from Water & Fertiliser
  {
    type = "recipe",
    name = "bi-seed-3",
    localised_name = {"recipe-name.bi-seed-3"},
    localised_description = {"recipe-description.bi-seed-3"},
    icon = ICONPATH .. "bio_seed3.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_seed3.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 100,
    ingredients =
    {
      {type = "fluid", name = "water", amount = 40},
      {type = "item", name = "wood", amount = 20},
      {type = "item", name = "fertiliser", amount = 10},
    },
    results=
    {
      {type = "item", name = "bi-seed", amount = 60},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-1",
    order = "a[bi]-ssw-a1[bi-seed-3]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seeds from Water & Adv-fertiliser
  {
    type = "recipe",
    name = "bi-seed-4",
    localised_name = {"recipe-name.bi-seed-4"},
    localised_description = {"recipe-description.bi-seed-4"},
    icon = ICONPATH .. "bio_seed4.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_seed4.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 50,
    ingredients =
    {
      {type = "item", name = "wood", amount = 20},
      {type = "item", name = "bi-adv-fertiliser", amount = 10},
      {type = "fluid", name = "water", amount = 40},
    },
    results=
    {
      {type = "item", name = "bi-seed", amount = 80},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-1",
    order = "a[bi]-ssw-a1[bi-seed-4]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seedlings from Water (BASIC)
  {
    type = "recipe",
    name = "bi-seedling-1",
    localised_name = {"recipe-name.bi-seedling-1"},
    localised_description = {"recipe-description.bi-seedling-1"},
    icon = ICONPATH .. "Seedling1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seedling1.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 400,
    ingredients =
    {
      {type = "item", name = "bi-seed", amount = 20},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "seedling", amount = 40},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-2",
    order = "b[bi]-ssw-b1[bi-Seedling_Mk1]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seedlings from Water & Ash
  {
    type = "recipe",
    name = "bi-seedling-2",
    localised_name = {"recipe-name.bi-seedling-2"},
    localised_description = {"recipe-description.bi-seedling-2"},
    icon = ICONPATH .. "Seedling2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seedling2.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 300,
    ingredients =
    {
      {type = "item", name = "bi-seed", amount = 25},
      {type = "item", name = "bi-ash", amount = 10},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "seedling", amount = 60},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-2",
    order = "b[bi]-ssw-b1[bi-Seedling_Mk2]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seedlings from Water & Fertiliser
  {
    type = "recipe",
    name = "bi-seedling-3",
    localised_name = {"recipe-name.bi-seedling-3"},
    localised_description = {"recipe-description.bi-seedling-3"},
    icon = ICONPATH .. "Seedling3.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seedling3.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 200,
    ingredients =
    {
      {type = "item", name = "bi-seed", amount = 30},
      {type = "item", name = "fertiliser", amount = 10},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "seedling", amount = 90},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    subgroup = "bio-bio-farm-fluid-2",
    order = "b[bi]-ssw-b1[bi-Seedling_Mk3]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seedlings from Water & Adv-fertiliser
  {
    type = "recipe",
    name = "bi-seedling-4",
    localised_name = {"recipe-name.bi-seedling-4"},
    localised_description = {"recipe-description.bi-seedling-4"},
    icon = ICONPATH .. "Seedling4.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seedling4.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-greenhouse",
    energy_required = 100,
    ingredients =
    {
      {type = "item", name = "bi-seed", amount = 40},
      {type = "fluid", name = "water", amount = 100},
      {type = "item", name = "bi-adv-fertiliser", amount = 10},
    },
    results=
    {
      {type = "item", name = "seedling", amount = 160},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bio-bio-farm-fluid-2",
    order = "b[bi]-ssw-b1[bi-Seedling_Mk4]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Raw Wood from Water (BASIC)
  {
    type = "recipe",
    name = "bi-logs-1",
    localised_name = {"recipe-name.bi-logs-1"},
    localised_description = {"recipe-description.bi-logs-1"},
    icon = ICONPATH .. "raw-wood-mk1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "raw-wood-mk1.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-farm",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 400,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 20},
      {type = "fluid", name = "water", amount = 100},
    },
    results =
    {
      {type = "item", name = "wood", amount = 40},
      {type = "item", name = "bi-woodpulp", amount = 80},
    },
    main_product = "wood",
    subgroup = "bio-bio-farm-fluid-3",
    order = "c[bi]-ssw-c1[raw-wood1]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Raw Wood from Water & Ash
  {
    type = "recipe",
    name = "bi-logs-2",
    localised_name = {"recipe-name.bi-logs-2"},
    localised_description = {"recipe-description.bi-logs-2"},
    icon = ICONPATH .. "raw-wood-mk2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "raw-wood-mk2.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-farm",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 360,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 30},
      {type = "item", name = "bi-ash", amount = 10},
      {type = "fluid", name = "water", amount = 100},
    },
    results =
    {
      {type = "item", name = "wood", amount = 75},
      {type = "item", name = "bi-woodpulp", amount = 150},
    },
    main_product = "wood",
    subgroup = "bio-bio-farm-fluid-3",
    order = "c[bi]-ssw-c1[raw-wood2]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Raw Wood from Water & fertiliser
  {
    type = "recipe",
    name = "bi-logs-3",
    localised_name = {"recipe-name.bi-logs-3"},
    localised_description = {"recipe-description.bi-logs-3"},
    icon = ICONPATH .. "raw-wood-mk3.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "raw-wood-mk3.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-farm",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 300,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 45},
      {type = "item", name = "fertiliser", amount = 10},
      {type = "fluid", name = "water", amount = 100},
    },
    results =
    {
      {type = "item", name = "wood", amount = 135},
      {type = "item", name = "bi-woodpulp", amount = 270},
    },
    main_product = "wood",
    subgroup = "bio-bio-farm-fluid-3",
    order = "c[bi]-ssw-c1[raw-wood3]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Raw Wood from adv-fertiliser
  {
    type = "recipe",
    name = "bi-logs-4",
    localised_name = {"recipe-name.bi-logs-4"},
    localised_description = {"recipe-description.bi-logs-4"},
    icon = ICONPATH .. "raw-wood-mk4.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "raw-wood-mk4.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-farm",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    energy_required = 100,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 40},
      {type = "fluid", name = "water", amount = 100},
      {type = "item", name = "bi-adv-fertiliser", amount = 5},
    },
    results =
    {
      {type = "item", name = "wood", amount = 160},
      {type = "item", name = "bi-woodpulp", amount = 320},
    },
    main_product = "wood",
    subgroup = "bio-bio-farm-fluid-3",
    order = "c[bi]-ssw-c1[raw-wood4]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Bio Greenhouse (ENTITY)
  {
    type = "recipe",
    name = "bi-bio-greenhouse",
    icon = ICONPATH .. "bio_greenhouse.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_greenhouse.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      --~ energy_required = 5,
      energy_required = 2.5,
      ingredients =
      {
        {"iron-stick", 10},
        {"stone-brick", 10},
        {"small-lamp", 5},
      },
      result = "bi-bio-greenhouse",
      result_count = 1,
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      --~ energy_required = 8,
      energy_required = 4,
      ingredients =
      {
        {"iron-stick", 15},
        {"stone-brick", 15},
        {"small-lamp", 5},
      },
      result = "bi-bio-greenhouse",
      result_count = 1,
      main_product = "",
    },
    subgroup = "bio-bio-farm-fluid-entity",
    order = "a[bi]",
    always_show_made_in = true,
    allow_decomposition = false,
  },


  --- Bio Farm (ENTITY)
  {
    type = "recipe",
    name = "bi-bio-farm",
    icon = ICONPATH .. "Bio_Farm_Icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Bio_Farm_Icon.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      --~ energy_required = 10,
      energy_required = 5,
      ingredients =
      {
        {"bi-bio-greenhouse", 4},
        {"stone-crushed", 10},
        {"copper-cable", 10},
      },
      result = "bi-bio-farm",
      result_count = 1,
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      --~ energy_required = 15,
      energy_required = 7.5,
      ingredients =
      {
        {"bi-bio-greenhouse", 8},
        {"stone-crushed", 20},
        {"copper-cable", 20},
      },
      result = "bi-bio-farm",
      result_count = 1,
      main_product = "",
    },
    subgroup = "bio-bio-farm-fluid-entity",
    order = "b[bi]",
    always_show_made_in = true,
    allow_decomposition = false,
  },


  -- Woodpulp--
  {
    type = "recipe",
    name = "bi-woodpulp",
    icon = ICONPATH .. "Woodpulp_raw-wood.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Woodpulp_raw-wood.png",
        icon_size = 64,
      }
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-a[bi-1-woodpulp]",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    energy_required = 2,
    ingredients = {{"wood", 2}},
    result = "bi-woodpulp",
    result_count = 4,
    main_product = "",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Resin recipe Pulp
  {
    type = "recipe",
    name = "bi-resin-pulp",
    icon = ICONPATH .. "bi_resin_pulp.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_resin_pulp.png",
        icon_size = 64,
      }
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-ba[bi-2-resin-2-pulp]",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    energy_required = 1,
    ingredients =
    {
       {type = "item", name = "bi-woodpulp", amount = 3},
    },
    result = "resin",
    result_count = 1,
    main_product = "",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },



  -- Wood from pulp--
  {
    type = "recipe",
    name = "bi-wood-from-pulp",
    icon = ICONPATH .. "wood_from_pulp.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "wood_from_pulp.png",
        icon_size = 64,
      }
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-c[bi-3-wood_from_pulp]",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    energy_required = 2.5,
    ingredients =
    {
       {type = "item", name = "bi-woodpulp", amount = 8},
       {type = "item", name = "resin", amount = 2},
    },
    result = "wood",
    result_count = 4,
    main_product = "",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },



  -- Wood Fuel Brick
  {
    type = "recipe",
    name = "bi-wood-fuel-brick",
    icon = ICONPATH .. "Fuel_Brick.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Fuel_Brick.png",
        icon_size = 64,
      }
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-bx[bi-4-woodbrick]",
    energy_required = 2,
    ingredients = {{"bi-woodpulp", 24}},
    result = "wood-bricks",
    result_count = 1,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  -- ASH --
  {
    type = "recipe",
    name = "bi-ash-1",
    localised_name = {"recipe-name.bi-ash-1"},
    localised_description = {"recipe-description.bi-ash-1"},
    icon = ICONPATH .. "ash_raw-wood.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "ash_raw-wood.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-cb[bi-5-ash-1]",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    energy_required = 3,
    ingredients = {{"wood", 5}},
    result = "bi-ash",
    result_count = 5,
    main_product = "",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  -- ASH 2--
  {
    type = "recipe",
    name = "bi-ash-2",
    localised_name = {"recipe-name.bi-ash-2"},
    localised_description = {"recipe-description.bi-ash-2"},
    icon = ICONPATH .. "ash_woodpulp.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "ash_woodpulp.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-ca[bi-5-ash-2]",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    energy_required = 2.5,
    ingredients = {{"bi-woodpulp", 12}},
    result = "bi-ash",
    result_count = 6,
    main_product = "",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  -- CHARCOAL 1
  {
    type = "recipe",
    name = "bi-charcoal-1",
    icon = ICONPATH .. "charcoal_woodpulp.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "charcoal_woodpulp.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-d[bi-6-charcoal-1]",
    energy_required = 15,
    ingredients = {{"bi-woodpulp", 24}},
    result = "wood-charcoal",
    result_count = 5,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  -- CHARCOAL 2
  {
    type = "recipe",
    name = "bi-charcoal-2",
    localised_name = {"recipe-name.bi-charcoal-2"},
    localised_description = {"recipe-description.bi-charcoal-2"},
    icon = ICONPATH .. "charcoal_raw-wood.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "charcoal_raw-wood.png",
        icon_size = 64,
      }
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-d[bi-6-charcoal-2]",
    category = "biofarm-mod-smelting",
    energy_required = 20,
    ingredients = {{"wood", 20}},
    result = "wood-charcoal",
    result_count = 8,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  -- COAL 1 --
  {
    type = "recipe",
    name = "bi-coal-1",
    icon = ICONPATH .. "coal_mk1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "coal_mk1.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-ea[bi-6-coal-1]",
    energy_required = 20,
    ingredients = {{"wood-charcoal", 10}},
    result = "coal",
    result_count = 12,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },


  -- COAL 2 --
  {
    type = "recipe",
    name = "bi-coal-2",
    localised_name = {"recipe-name.bi-coal-2"},
    localised_description = {"recipe-description.bi-coal-2"},
    icon = ICONPATH .. "coal_mk2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "coal_mk2.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-eb[bi-6-coal-2]",
    energy_required = 20,
    ingredients = {{"wood-charcoal", 10}},
    result = "coal",
    result_count = 16,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },


  -- Solid Fuel
  {
    type = "recipe",
    name = "bi-solid-fuel",
    icon = ICONPATH .. "bi_solid_fuel_wood_brick.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_solid_fuel_wood_brick.png",
        icon_size = 64,
      }
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-fa[bi-7-solid_fuel]",
    category = "chemistry",
    energy_required = 2,
    ingredients = {{"wood-bricks", 3}},
    result = "solid-fuel",
    result_count = 2,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },


  -- Pellet-Coke from Coal -- Use to be Coke-Coal
    {
    type = "recipe",
    name = "bi-coke-coal",
    icon = ICONPATH .. "pellet_coke_coal.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "pellet_coke_coal.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-g[bi-8-coke-coal]-1",
    energy_required = 20,
    ingredients = {{"coal", 12}},
    result = "pellet-coke",
    result_count = 2,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
  },


    -- Pellet-Coke from Solid Fuel -- Use to be Coke-Coal
    {
    type = "recipe",
    name = "bi-pellet-coke",
    icon = ICONPATH .. "pellet_coke_solid.png",
    --icon = "__Bio_Industries__/graphics/icons/pellet_coke_c.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "pellet_coke_solid.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-smelting",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-g[bi-8-coke-coal]-3",
    energy_required = 6,
    ingredients = {{"solid-fuel", 5}},
    result = "pellet-coke",
    result_count = 3,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_as_intermediate = false,
  },

 -- CRUSHED STONE from stone --
  {
    type = "recipe",
    name = "bi-crushed-stone-1",
    icon = ICONPATH .. "crushed-stone-stone.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "crushed-stone-stone.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-crushing",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z[bi-9-stone-crushed-1]",
    energy_required = 1.5,
    ingredients = {{"stone", 1}},
    result = "stone-crushed",
    result_count = 2,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

 -- CRUSHED STONE from concrete --
  {
    type = "recipe",
    name = "bi-crushed-stone-2",
    icon = ICONPATH .. "crushed-stone-concrete.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "crushed-stone-concrete.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-crushing",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z[bi-9-stone-crushed-2]",
    energy_required = 2.5,  -- Increased crafting time
    ingredients = {{"concrete", 1}},
    result = "stone-crushed",
    result_count = 2,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

 -- CRUSHED STONE from hazard concrete --
  {
    type = "recipe",
    name = "bi-crushed-stone-3",
    icon = ICONPATH .. "crushed-stone-hazard-concrete.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "crushed-stone-hazard-concrete.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-crushing",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z[bi-9-stone-crushed-3]",
    energy_required = 2.5,  -- Increased crafting time
    ingredients = {{"hazard-concrete", 1}},
    result = "stone-crushed",
    result_count = 2,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

 -- CRUSHED STONE from refined concrete --
  {
    type = "recipe",
    name = "bi-crushed-stone-4",
    icon = ICONPATH .. "crushed-stone-refined-concrete.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "crushed-stone-refined-concrete.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-crushing",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z[bi-9-stone-crushed-4]",
    energy_required = 5,    -- Increased crafting time
    ingredients = {{"refined-concrete", 1}},
    result = "stone-crushed",
    result_count = 4,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

 -- CRUSHED STONE from refined hazard concrete --
  {
    type = "recipe",
    name = "bi-crushed-stone-5",
    icon = ICONPATH .. "crushed-stone-refined-hazard-concrete.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "crushed-stone-refined-hazard-concrete.png",
        icon_size = 64,
      }
    },
    category = "biofarm-mod-crushing",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z[bi-9-stone-crushed-5]",
    energy_required = 5,    -- Increased crafting time
    ingredients = {{"refined-hazard-concrete", 1}},
    result = "stone-crushed",
    result_count = 4,
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

 -- STONE Brick--
  {
    type = "recipe",
    name = "bi-stone-brick",
    icon = ICONPATH .. "bi_stone_brick.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_stone_brick.png",
        icon_size = 64,
      }
    },
    --category = "smelting",
    category = "chemistry",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z2[bi-9-stone-brick]",
    energy_required = 5,
    ingredients =
    {
      {type = "item", name = "stone-crushed", amount = 6},
      {type = "item", name = "bi-ash", amount = 2},
    },
    results =
    {
      {type = "item", name = "stone-brick", amount = 2},
    },
    enabled = false,
    main_product = "",
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
  },

  -- COKERY (ENTITY)--
  {
    type = "recipe",
    name = "bi-cokery",
    icon = ICONPATH .. "cokery.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "cokery.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
        {"stone-furnace", 3},
        {"steel-plate", 10},
      },
      result = "bi-cokery",
      result_count = 1,
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      energy_required = 10,
      ingredients =
      {
        {"stone-furnace", 3},
        {"steel-plate", 12},
      },
      result = "bi-cokery",
      result_count = 1,
      main_product = "",
    },
    subgroup = "bio-bio-farm-raw-entity",
    order = "a[bi]",
    always_show_made_in = true,
    allow_decomposition = false,
  },


  -- STONE CRUSHER (ENTITY) --
  {
    type = "recipe",
    name = "bi-stone-crusher",
    icon = ICONPATH .. "stone_crusher.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "stone_crusher.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      energy_required = 3,
      ingredients =
      {
        {"iron-plate", 10},
        {"steel-plate", 10},
        {"iron-gear-wheel", 5},
      },
      result = "bi-stone-crusher",
      result_count = 1,
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      energy_required = 5,
      ingredients =
      {
        {"iron-plate", 12},
        {"steel-plate", 12},
        {"iron-gear-wheel", 8},
      },
      result = "bi-stone-crusher",
      result_count = 1,
      main_product = "",
    },
    subgroup = "bio-bio-farm-raw-entity",
    order = "b[bi]",
    always_show_made_in = true,
    allow_decomposition = false,
  },


  -- LIQUID-AIR --
  {
    type = "recipe",
    name = "bi-liquid-air",
    icon = ICONPATH .. "liquid-air.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "liquid-air.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 1,
    ingredients = {},
    results=
    {
      {type = "fluid", name = "liquid-air", amount = 10}
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-bio-farm-intermediate-product",
    order = "aa",
  },

  ---NITROGEN --
  {
    type = "recipe",
    name = "bi-nitrogen",
    icon = ICONPATH .. "nitrogen.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "nitrogen.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 10,
    ingredients =
    {
      {type = "fluid", name = "liquid-air", amount = 20}
    },
    results=
    {
      {type = "fluid", name = "nitrogen", amount = 20},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    --main_product= "nitrogen",
    subgroup = "bio-bio-farm-intermediate-product",
    order = "ab",
  },


  -- fertiliser- Sulfur-
  {
    type = "recipe",
    name = "bi-fertiliser-1",
    localised_name = {"recipe-name.bi-fertiliser-1"},
    localised_description = {"recipe-description.bi-fertiliser-1"},
    icon = ICONPATH .. "fertiliser_sulfur.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "fertiliser_sulfur.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 5,
    ingredients =
    {
      {type = "item", name = "sulfur", amount = 1},
      {type = "fluid", name = "nitrogen", amount = 10},
      {type = "item", name = "bi-ash", amount = 10}
    },
    results=
    {
      {type = "item", name = "fertiliser", amount = 5}
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[bi-fertiliser]",
  },


  -- Advanced fertiliser 1 --
  {
    type = "recipe",
    name = "bi-adv-fertiliser-1",
    localised_name = {"recipe-name.bi-adv-fertiliser-1"},
    localised_description = {"recipe-description.bi-adv-fertiliser-1"},
    icon = ICONPATH .. "advanced_fertiliser_64.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "advanced_fertiliser_64.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 50,
    ingredients =
    {
      {type = "item", name = "fertiliser", amount = 25},
      --{type = "item", name = "bi-biomass", amount = 10}, -- <== Need to add during Data Updates
      --{type = "fluid", name = "NE_enhanced-nutrient-solution", amount = 5}, -- Will be added if you have Natural Evolution Buildings Mod installed.
    },
    results=
    {
      {type = "item", name = "bi-adv-fertiliser", amount = 50}
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[fertiliser]-b[bi-adv-fertiliser-1]",
  },


  -- Advanced fertiliser 2--
  {
    type = "recipe",
    name = "bi-adv-fertiliser-2",
    localised_name = {"recipe-name.bi-adv-fertiliser-2"},
    localised_description = {"recipe-description.bi-adv-fertiliser-2"},
    icon = ICONPATH .. "advanced_fertiliser_64.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "advanced_fertiliser_64.png",
        icon_size = 64,
      }
    },
    category = "chemistry",
    energy_required = 50,
    ingredients =
    {
      {type = "item", name = "fertiliser", amount = 20},
      --{type = "item", name = "bi-biomass", amount = 10}, -- <== Need to add during Data Updates
      {type = "item", name = "bi-woodpulp", amount = 10},
    },
    results=
    {
      {type = "item", name = "bi-adv-fertiliser", amount = 20}
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-bio-farm-intermediate-product",
    order = "b[fertiliser]-b[bi-adv-fertiliser-2]",
    -- This is a custom property for use by "Krastorio 2" (it will change
    -- ingredients/results; used for wood/wood pulp)
    mod = "Bio_Industries",
  },


  --- Seed Bomb - Basic
     {
    type = "recipe",
    name = "bi-seed-bomb-basic",
    icon = ICONPATH .. "Seed_bomb_icon_b.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seed_bomb_icon_b.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
      {"bi-seed", 400},
      {"rocket", 1},
      },
      result = "bi-seed-bomb-basic",
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
      {"bi-seed", 400},
      {"rocket", 2},
      },
      result = "bi-seed-bomb-basic",
      main_product = "",
    },
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bi-ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-a",

    },


     --- Seed Bomb - Standard
     {
    type = "recipe",
    name = "bi-seed-bomb-standard",
    icon = ICONPATH .. "Seed_bomb_icon_s.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seed_bomb_icon_s.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
      {"bi-seed", 400},
      {"fertiliser", 200},
      {"rocket", 1},
      },
      result = "bi-seed-bomb-standard",
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
      {"bi-seed", 400},
      {"fertiliser", 200},
      {"rocket", 2},
      },
      result = "bi-seed-bomb-standard",
      main_product = "",
    },
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bi-ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-b",
   },


    --- Seed Bomb - Advanced
     {
    type = "recipe",
    name = "bi-seed-bomb-advanced",
    icon = ICONPATH .. "Seed_bomb_icon_a.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seed_bomb_icon_a.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
      {"bi-seed", 400},
      {"bi-adv-fertiliser", 200},
      {"rocket", 1},
      },
      result = "bi-seed-bomb-advanced",
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      energy_required = 8,
      ingredients =
      {
      {"bi-seed", 400},
      {"bi-adv-fertiliser", 200},
      {"rocket", 2},
      },
      result = "bi-seed-bomb-advanced",
      main_product = "",
    },
    always_show_made_in = true,
    allow_decomposition = false,
    subgroup = "bi-ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-c",
    },


   ---    Arboretum (ENTITY)
  {
    type = "recipe",
    name = "bi-arboretum",
    icon = ICONPATH .. "Arboretum_Icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Arboretum_Icon.png",
        icon_size = 64,
      }
    },
    normal =
    {
      enabled = false,
      energy_required = 10,
      ingredients =
      {
        {"bi-bio-greenhouse", 4},
        {"assembling-machine-2", 2},
        {"stone-brick", 10},
      },
      result = "bi-arboretum-area",
      result_count = 1,
      main_product = "",
    },
    expensive =
    {
      enabled = false,
      energy_required = 15,
      ingredients =
      {
        {"bi-bio-greenhouse", 4},
        {"assembling-machine-2", 4},
        {"stone-brick", 20},
      },
      result = "bi-arboretum-area",
      result_count = 1,
      main_product = "",
    },
    subgroup = "bio-arboretum-fluid",
    order = "1-a[bi]",
    always_show_made_in = true,
    allow_decomposition = false,
  },


  ---     Arboretum -  Plant Trees
  {
    type = "recipe",
    name = "bi-arboretum-r1",
    localised_name = {"recipe-name.bi-arboretum-r1"},
    localised_description = {"recipe-description.bi-arboretum-r1"},
    icon = ICONPATH .. "Seedling_b.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "Seedling_b.png",
        icon_size = 64,
      }
    },
    category = "bi-arboretum",
    energy_required = 10000,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 1},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "bi-arboretum-r1", amount = 1, probability = 0},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-arboretum-fluid",
    order = "a[bi]-ssw-a1[bi-arboretum-r1]",
  },


  ---     Arboretum - Change Terrain
  {
    type = "recipe",
    name = "bi-arboretum-r2",
    localised_name = {"recipe-name.bi-arboretum-r2"},
    localised_description = {"recipe-description.bi-arboretum-r2"},
    icon = ICONPATH .. "bi_change_1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_change_1.png",
        icon_size = 64,
      }
    },
    category = "bi-arboretum",
    energy_required = 10000,
    ingredients =
    {
      {type = "item", name = "fertiliser", amount = 1},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "bi-arboretum-r2", amount = 1, probability = 0},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-arboretum-fluid",
    order = "a[bi]-ssw-a1[bi-arboretum-r2]",
  },


  ---     Arboretum -  Change Terrain - Advanced
  {
    type = "recipe",
    name = "bi-arboretum-r3",
    localised_name = {"recipe-name.bi-arboretum-r3"},
    localised_description = {"recipe-description.bi-arboretum-r3"},
    icon = ICONPATH .. "bi_change_2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_change_2.png",
        icon_size = 64,
      }
    },
    category = "bi-arboretum",
    energy_required = 10000,
    ingredients =
    {
      {type = "item", name = "bi-adv-fertiliser", amount = 1},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "bi-arboretum-r3", amount = 1, probability = 0},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-arboretum-fluid",
    order = "a[bi]-ssw-a1[bi-arboretum-r3]",
  },


  ---     Arboretum -  Plant Trees & Change Terrain
  {
    type = "recipe",
    name = "bi-arboretum-r4",
    localised_name = {"recipe-name.bi-arboretum-r4"},
    localised_description = {"recipe-description.bi-arboretum-r4"},
    icon = ICONPATH .. "bi_change_plant_1.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_change_plant_1.png",
        icon_size = 64,
      }
    },
    category = "bi-arboretum",
    energy_required = 10000,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 1},
      {type = "item", name = "fertiliser", amount = 1},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "bi-arboretum-r4", amount = 1, probability = 0},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-arboretum-fluid",
    order = "a[bi]-ssw-a1[bi-arboretum-r4]",
  },


  ---     Arboretum -  Plant Trees & Change Terrain Advanced
  {
    type = "recipe",
    name = "bi-arboretum-r5",
    localised_name = {"recipe-name.bi-arboretum-r5"},
    localised_description = {"recipe-description.bi-arboretum-r5"},
    icon = ICONPATH .. "bi_change_plant_2.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_change_plant_2.png",
        icon_size = 64,
      }
    },
    category = "bi-arboretum",
    energy_required = 10000,
    ingredients =
    {
      {type = "item", name = "seedling", amount = 1},
      {type = "item", name = "bi-adv-fertiliser", amount = 1},
      {type = "fluid", name = "water", amount = 100},
    },
    results=
    {
      {type = "item", name = "bi-arboretum-r5", amount = 1, probability = 0},
    },
    main_product = "",
    enabled = false,
    always_show_made_in = true,
    allow_decomposition = false,
    allow_as_intermediate = false,
    subgroup = "bio-arboretum-fluid",
    order = "a[bi]-ssw-a1[bi-arboretum-r5]",
  },


})
