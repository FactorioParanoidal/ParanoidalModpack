local nuke_materials = require("data-nukes-material")

if(nuke_materials.smallBoomMaterial == "californium") then
  data:extend({
    {
      type = "item",
      name = "californium",
      icon = "__True-Nukes__/graphics/californium.png",
      icon_size = 64, icon_mipmaps = 4,
      pictures =
      {
        layers =
        {
          {
            size = 64,
            filename = "__True-Nukes__/graphics/californium.png",
            scale = 0.25,
            mipmap_count = 4
          },
          {
            draw_as_light = true,
            blend_mode = "additive",
            size = 64,
            filename = "__base__/graphics/icons/uranium-235.png",
            scale = 0.25,
            tint = {r = 0.8, g = 0.8, b = 0.1, a = 0.8},
            mipmap_count = 4
          }
        }
      },
      subgroup = "intermediate-product",
      order = "r[z-californium]",
      stack_size = 100
    },
    {
      type = "recipe",
      name = "californium-processing",
      energy_required = 120,
      enabled = false,
      category = "centrifuging",
      ingredients = {{nuke_materials.boomMaterial, 10}, {nuke_materials.deadMaterial, 1}},
      icon = "__True-Nukes__/graphics/californium-processing.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "intermediate-product",
      order = "r[uranium-processing]-da[californium-processing]",
      main_product = "",
      results = {{nuke_materials.boomMaterial, 9}, {"californium", 1}},
      allow_decomposition = false
    },
    {
      type = "recipe",
      name = "advanced-californium-processing",
      energy_required = 20,
      enabled = false,
      category = "centrifuging",
      ingredients = {{nuke_materials.boomMaterial, 5}, {nuke_materials.reflector, 2}},
      icons = {
        {icon = "__True-Nukes__/graphics/californium-processing.png", icon_size = 64, icon_mipmaps = 4},
        {icon = "__True-Nukes__/graphics/plus-red.png", icon_size = 32, scale = 0.333, shift = {10, -10}}
      },
      subgroup = "intermediate-product",
      order = "r[uranium-processing]-dk[californium-processing]",
      main_product = "",
      results = {{nuke_materials.boomMaterial, 4}, {nuke_materials.deadMaterial, 1}, {nuke_materials.reflector, 1}, {name = nuke_materials.reflector, amount = 1, probability = 0.6}, {"californium", 1}},
      allow_decomposition = false
    },
  });
end

data:extend{
  {
    type = "recipe",
    name = "advanced-kovarex-enrichment-process",
    energy_required = 10,
    enabled = false,
    category = "centrifuging",
    ingredients = {{"uranium-235", 20}, {"uranium-238", 5}, {nuke_materials.reflector, 2}},
    icons = {
      {icon = "__base__/graphics/icons/kovarex-enrichment-process.png", icon_size = 64, icon_mipmaps = 4},
      {icon = "__True-Nukes__/graphics/plus-red.png", icon_size = 32, scale = 0.333, shift = {10, -10}}
    },
    subgroup = "intermediate-product",
    order = "r[uranium-processing]-cc[kovarex-enrichment-process]",
    main_product = "",
    results = {{"uranium-235", 21}, {"uranium-238", 2}, {nuke_materials.reflector, 1}, {name = nuke_materials.reflector, amount = 1, probability = 0.6}},
    allow_decomposition = false
  },
  {
    type = "item",
    name = "FOGBANK",
    icon = "__True-Nukes__/graphics/FOGBANK.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "intermediate-product",
    order = "r[fogbank]",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "FOGBANK",
    category = "chemistry",
    energy_required = 20,
    enabled = false,
    ingredients =
    {
      {type="fluid", name="petroleum-gas", amount=20},
      {type="fluid", name="sulfuric-acid", amount=20},
      {type="item", name="low-density-structure", amount=10},
      {type="item", name="plastic-bar", amount=10}
    },
    results=
    {
      {type="item", name="FOGBANK", amount=1}
    },
    crafting_machine_tint =
    {
      primary = {r = 0.965, g = 0.482, b = 0.338, a = 1.000}, -- #f67a56ff
      secondary = {r = 0.831, g = 0.560, b = 0.222, a = 1.000}, -- #d38e38ff
      tertiary = {r = 0.728, g = 0.818, b = 0.443, a = 1.000}, -- #b9d070ff
      quaternary = {r = 0.939, g = 0.763, b = 0.191, a = 1.000}, -- #efc230ff
    }
  }
};

data:extend{
  {
    type = "item",
    name = "neutron-reflector",
    icon = "__True-Nukes__/graphics/neutron-reflector.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "intermediate-product",
    order = "r[neutron-reflector]",
    stack_size = 50
  },
  {
    type = "recipe",
    name = "neutron-reflector",
    category = "chemistry",
    energy_required = 10,
    enabled = false,
    ingredients =
    {
      {type="item", name="low-density-structure", amount=1},
      {type="fluid", name="petroleum-gas", amount=10},
      {type="item", name="plastic-bar", amount=10},
      {type="item", name="iron-plate", amount=5},
      {type="item", name="sulfur", amount=10}
    },
    results=
    {
      {type="item", name="neutron-reflector", amount=1}
    },
    crafting_machine_tint =
    {
      primary = {r = 0.965, g = 0.482, b = 0.338, a = 1.000}, -- #f67a56ff
      secondary = {r = 0.831, g = 0.560, b = 0.222, a = 1.000}, -- #d38e38ff
      tertiary = {r = 0.728, g = 0.818, b = 0.443, a = 1.000}, -- #b9d070ff
      quaternary = {r = 0.939, g = 0.763, b = 0.191, a = 1.000}, -- #efc230ff
    }
  }
};

if(nuke_materials.fusionMaterial == "tritium-canister") then
  data:extend({
    {
      type = "item",
      name = "tritium-breeder-fuel-cell",
      icon = "__True-Nukes__/graphics/tritium-breeder-fuel-cell.png",
      icon_size = 64, icon_mipmaps = 4,
      pictures =
      {
        layers =
        {
          {
            size = 64,
            filename = "__True-Nukes__/graphics/tritium-breeder-fuel-cell.png",
            scale = 0.25,
            mipmap_count = 4
          },
          {
            draw_as_light = true,
            flags = {"light"},
            size = 64,
            filename = "__True-Nukes__/graphics/tritium-breeder-fuel-cell-light.png",
            scale = 0.25,
            mipmap_count = 4
          }
        }
      },
      subgroup = "intermediate-product",
      order = "r[uranium-processing]-ce[tritium-breeder-fuel-cell]",
      fuel_category = "nuclear",
      burnt_result = "used-up-tritium-breeder-fuel-cell",
      fuel_value = "4GJ",
      stack_size = 50
    },
    {
      type = "item",
      name = "advanced-tritium-breeder-fuel-cell",
      icons = {
        {icon = "__True-Nukes__/graphics/tritium-breeder-fuel-cell.png", icon_size = 64, icon_mipmaps = 4},
        {icon = "__True-Nukes__/graphics/plus-red.png", icon_size = 32, scale = 0.333, shift = {10, -10}}
      },
      pictures =
      {
        layers =
        {
          {
            size = 64,
            filename = "__True-Nukes__/graphics/tritium-breeder-fuel-cell.png",
            scale = 0.25,
            mipmap_count = 4
          },
          {
            filename = "__True-Nukes__/graphics/plus-red.png",
            size = 32,
            scale = 0.166,
            shift = {0.1875, -0.1875}
          },
          {
            draw_as_light = true,
            flags = {"light"},
            size = 64,
            filename = "__True-Nukes__/graphics/tritium-breeder-fuel-cell-light.png",
            scale = 0.25,
            mipmap_count = 4
          }
        }
      },
      subgroup = "intermediate-product",
      order = "r[uranium-processing]-cg[adv-tritium-breeder-fuel-cell]",
      fuel_category = "nuclear",
      burnt_result = "used-up-advanced-tritium-breeder-fuel-cell",
      fuel_value = "2GJ",
      stack_size = 50
    },
    {
      type = "item",
      name = "used-up-tritium-breeder-fuel-cell",
      icon = "__True-Nukes__/graphics/used-up-tritium-breeder-fuel-cell.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "intermediate-product",
      order = "s[used-up-tritium-breeder-fuel-cell]",
      stack_size = 50
    },
    {
      type = "item",
      name = "used-up-advanced-tritium-breeder-fuel-cell",
      icons = {
        {icon = "__True-Nukes__/graphics/used-up-tritium-breeder-fuel-cell.png", icon_size = 64, icon_mipmaps = 4},
        {icon = "__True-Nukes__/graphics/plus-red.png", icon_size = 32, scale = 0.333, shift = {10, -10}}
      },
      subgroup = "intermediate-product",
      order = "t[used-up-tritium-breeder-fuel-cell]",
      stack_size = 50
    },

    {
      type = "recipe",
      name = "tritium-extraction",
      energy_required = 60,
      enabled = false,
      category = "centrifuging",
      ingredients = {{"used-up-tritium-breeder-fuel-cell", 5}, {"plastic-bar", 5}},
      icon = "__True-Nukes__/graphics/tritium-extraction.png",
      icon_size = 64, icon_mipmaps = 1,
      subgroup = "intermediate-product",
      order = "r[uranium-processing]-cj[tritium-extraction]",
      main_product = "",
      results = {{"tritium-canister", 1}, {"uranium-238", 3}},
      allow_decomposition = false
    },

    {
      type = "recipe",
      name = "advanced-tritium-extraction",
      energy_required = 30,
      enabled = false,
      category = "centrifuging",
      ingredients = {{"used-up-advanced-tritium-breeder-fuel-cell", 2}, {"plastic-bar", 5}},
      icons = {
        {icon = "__True-Nukes__/graphics/tritium-extraction.png", icon_size = 64, icon_mipmaps = 4},
        {icon = "__True-Nukes__/graphics/plus-red.png", icon_size = 32, scale = 0.333, shift = {10, -10}}
      },
      subgroup = "intermediate-product",
      order = "r[uranium-processing]-cm[tritium-extraction]",
      main_product = "",
      results = {{"tritium-canister", 1}, {"uranium-238", 2}, {name = nuke_materials.reflector, amount = 1, probability = 0.8}},
      allow_decomposition = false
    },
    {
      type = "recipe",
      name = "advanced-tritium-breeder-fuel-cell",
      energy_required = 15,
      enabled = false,
      category = "crafting-with-fluid",
      ingredients = table.deepcopy(data.raw.recipe["uranium-fuel-cell"].ingredients),
      result = "advanced-tritium-breeder-fuel-cell",
      result_count = 10
    },
    {
      type = "recipe",
      name = "tritium-breeder-fuel-cell",
      energy_required = 10,
      enabled = false,
      category = "crafting-with-fluid",
      ingredients = table.deepcopy(data.raw.recipe["uranium-fuel-cell"].ingredients),
      result = "tritium-breeder-fuel-cell",
      result_count = 10
    },
    {
      type = "item",
      name = "tritium-canister",
      icon = "__True-Nukes__/graphics/tritium-canister.png",
      icon_size = 64, icon_mipmaps = 1,
      pictures =
      {
        layers =
        {
          {
            size = 64,
            filename = "__True-Nukes__/graphics/tritium-canister.png",
            scale = 0.25,
            mipmap_count = 1
          },
          {
            draw_as_light = true,
            flags = {"light"},
            size = 64,
            filename = "__True-Nukes__/graphics/tritium-canister-light.png",
            scale = 0.25,
            mipmap_count = 1
          }
        }
      },
      subgroup = "intermediate-product",
      order = "q[tritium-canister]",
      stack_size = 50
    }
  })
table.insert(data.raw.recipe["tritium-breeder-fuel-cell"].ingredients, {type="fluid", name="water", amount=100})
table.insert(data.raw.recipe["advanced-tritium-breeder-fuel-cell"].ingredients, {type="fluid", name="water", amount=100})
table.insert(data.raw.recipe["advanced-tritium-breeder-fuel-cell"].ingredients, {nuke_materials.reflector, 5})
end
for i = 0,100 do
  if(data.raw.module["productivity-module-" .. i] and data.raw.module["productivity-module-" .. i].limitation) then
    if(nuke_materials.smallBoomMaterial == "californium") then
      table.insert(data.raw.module["productivity-module-" .. i].limitation, "californium-processing")
      table.insert(data.raw.module["productivity-module-" .. i].limitation, "advanced-californium-processing")
    end
    if(nuke_materials.fusionMaterial == "tritium-canister") then
      table.insert(data.raw.module["productivity-module-" .. i].limitation, "tritium-breeder-fuel-cell")
      table.insert(data.raw.module["productivity-module-" .. i].limitation, "advanced-tritium-breeder-fuel-cell")
      table.insert(data.raw.module["productivity-module-" .. i].limitation, "tritium-extraction")
      table.insert(data.raw.module["productivity-module-" .. i].limitation, "advanced-tritium-extraction")
    end
    table.insert(data.raw.module["productivity-module-" .. i].limitation, "advanced-kovarex-enrichment-process")
    table.insert(data.raw.module["productivity-module-" .. i].limitation, "FOGBANK")
    table.insert(data.raw.module["productivity-module-" .. i].limitation, "neutron-reflector")
  end
end
if(data.raw.module["productivity-module"] and data.raw.module["productivity-module"].limitation) then
  if(nuke_materials.smallBoomMaterial == "californium") then
    table.insert(data.raw.module["productivity-module"].limitation, "californium-processing")
    table.insert(data.raw.module["productivity-module"].limitation, "advanced-californium-processing")
  end
  if(nuke_materials.fusionMaterial == "tritium-canister") then
    table.insert(data.raw.module["productivity-module"].limitation, "tritium-breeder-fuel-cell")
    table.insert(data.raw.module["productivity-module"].limitation, "advanced-tritium-breeder-fuel-cell")
    table.insert(data.raw.module["productivity-module"].limitation, "tritium-extraction")
    table.insert(data.raw.module["productivity-module"].limitation, "advanced-tritium-extraction")
  end
  table.insert(data.raw.module["productivity-module"].limitation, "advanced-kovarex-enrichment-process")
  table.insert(data.raw.module["productivity-module"].limitation, "FOGBANK")
  table.insert(data.raw.module["productivity-module"].limitation, "neutron-reflector")
end
