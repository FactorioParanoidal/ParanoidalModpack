data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-reactor-1",
    icon = "__bobvehicleequipment__/graphics/icons/vehicle-fusion-reactor-1.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-reactor-1",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-reactor]-1",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-reactor-1",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"processing-unit", 250},
    },
    result = "vehicle-fusion-reactor-1"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-reactor-1",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-reactor-1.png",
      width = 64,
      height = 128,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "500kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-reactor-equipment-1",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-reactor.png",
    icon_size = 128,
    order = "v-g-l-a",
    prerequisites =
    {
      "vehicle-solar-panel-equipment-1"
    },
    unit =
    {
      count = 200,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-reactor-1"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-reactor-2",
    icon = "__bobvehicleequipment__/graphics/icons/vehicle-fusion-reactor-2.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-reactor-2",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-reactor]-2",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-reactor-2",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-reactor-1", 1},
      {"processing-unit", 50},
      {"effectivity-module-2", 2},
      {"speed-module-2", 2},
      {"productivity-module-2", 2},
    },
    result = "vehicle-fusion-reactor-2"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-reactor-2",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-reactor-2.png",
      width = 64,
      height = 128,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "750kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-reactor-equipment-2",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-reactor.png",
    icon_size = 128,
    order = "v-g-l-b",
    prerequisites =
    {
      "vehicle-fusion-reactor-equipment-1",
    },
    unit =
    {
      count = 150,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-reactor-2"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-reactor-3",
    icon = "__bobvehicleequipment__/graphics/icons/vehicle-fusion-reactor-3.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-reactor-3",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-reactor]-3",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-reactor-3",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-reactor-2", 1},
      {"processing-unit", 50},
      {"effectivity-module-3", 2},
      {"speed-module-3", 2},
      {"productivity-module-3", 2},
    },
    result = "vehicle-fusion-reactor-3"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-reactor-3",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-reactor-3.png",
      width = 64,
      height = 128,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "1250kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-reactor-equipment-3",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-reactor.png",
    icon_size = 128,
    order = "v-g-l-c",
    prerequisites =
    {
      "vehicle-fusion-reactor-equipment-2"
    },
    unit =
    {
      count = 300,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-reactor-3"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-reactor-4",
    icon = "__bobvehicleequipment__/graphics/icons/vehicle-fusion-reactor-4.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-reactor-4",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-reactor]-4",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-reactor-4",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-reactor-3", 1},
      {"processing-unit", 50},
      {"effectivity-module-3", 2},
      {"speed-module-3", 2},
      {"productivity-module-3", 2},
    },
    result = "vehicle-fusion-reactor-4"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-reactor-4",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-reactor-4.png",
      width = 64,
      height = 128,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "2000kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-reactor-equipment-4",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-reactor.png",
    icon_size = 128,
    order = "v-g-l-d",
    prerequisites =
    {
      "vehicle-fusion-reactor-equipment-3"
    },
    unit =
    {
      count = 350,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-reactor-4"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-reactor-5",
    icon = "__bobvehicleequipment__/graphics/icons/vehicle-fusion-reactor-5.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-reactor-5",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-reactor]-5",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-reactor-5",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-reactor-4", 1},
      {"processing-unit", 50},
      {"effectivity-module-3", 2},
      {"speed-module-3", 2},
      {"productivity-module-3", 2},
    },
    result = "vehicle-fusion-reactor-5"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-reactor-5",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-reactor-5.png",
      width = 64,
      height = 128,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "3000kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-reactor-equipment-5",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-reactor.png",
    icon_size = 128,
    order = "v-g-l-e",
    prerequisites =
    {
      "vehicle-fusion-reactor-equipment-4"
    },
    unit =
    {
      count = 400,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-reactor-5"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-reactor-6",
    icon = "__bobvehicleequipment__/graphics/icons/vehicle-fusion-reactor-6.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-reactor-6",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-reactor]-6",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-reactor-6",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-reactor-5", 1},
      {"processing-unit", 50},
      {"effectivity-module-3", 2},
      {"speed-module-3", 2},
      {"productivity-module-3", 2},
    },
    result = "vehicle-fusion-reactor-6"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-reactor-6",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-reactor-6.png",
      width = 64,
      height = 128,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "4250kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-reactor-equipment-6",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-reactor.png",
    icon_size = 128,
    order = "v-g-l-f",
    prerequisites =
    {
      "vehicle-fusion-reactor-equipment-5"
    },
    unit =
    {
      count = 450,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-reactor-6"
      }
    },
  },
}
)




data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-cell-1",
    icon = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-1.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-cell-1",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-cell]-1",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-cell-1",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"processing-unit", 125},
    },
    result = "vehicle-fusion-cell-1"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-cell-1",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-1.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "200kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-cell-equipment-1",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-cell.png",
    icon_size = 128,
    order = "v-g-l-a",
    prerequisites =
    {
      "vehicle-solar-panel-equipment-1"
    },
    unit =
    {
      count = 100,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-cell-1"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-cell-2",
    icon = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-2.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-cell-2",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-cell]-2",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-cell-2",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-cell-1", 1},
      {"processing-unit", 25},
      {"effectivity-module-2", 1},
      {"speed-module-2", 1},
      {"productivity-module-2", 1},
    },
    result = "vehicle-fusion-cell-2"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-cell-2",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-2.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "300kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-cell-equipment-2",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-cell.png",
    icon_size = 128,
    order = "v-g-l-b",
    prerequisites =
    {
      "vehicle-fusion-cell-equipment-1",
    },
    unit =
    {
      count = 125,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-cell-2"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-cell-3",
    icon = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-3.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-cell-3",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-cell]-3",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-cell-3",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-cell-2", 1},
      {"processing-unit", 25},
      {"effectivity-module-3", 1},
      {"speed-module-3", 1},
      {"productivity-module-3", 1},
    },
    result = "vehicle-fusion-cell-3"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-cell-3",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-3.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "450kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-cell-equipment-3",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-cell.png",
    icon_size = 128,
    order = "v-g-l-c",
    prerequisites =
    {
      "vehicle-fusion-cell-equipment-2"
    },
    unit =
    {
      count = 150,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-cell-3"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-cell-4",
    icon = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-4.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-cell-4",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-cell]-4",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-cell-4",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-cell-3", 1},
      {"processing-unit", 25},
      {"effectivity-module-3", 1},
      {"speed-module-3", 1},
      {"productivity-module-3", 1},
    },
    result = "vehicle-fusion-cell-4"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-cell-4",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-4.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "650kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-cell-equipment-4",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-cell.png",
    icon_size = 128,
    order = "v-g-l-d",
    prerequisites =
    {
      "vehicle-fusion-cell-equipment-3"
    },
    unit =
    {
      count = 200,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-cell-4"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-cell-5",
    icon = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-5.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-cell-5",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-cell]-5",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-cell-5",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-cell-4", 1},
      {"processing-unit", 25},
      {"effectivity-module-3", 1},
      {"speed-module-3", 1},
      {"productivity-module-3", 1},
    },
    result = "vehicle-fusion-cell-5"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-cell-5",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-5.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "900kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-cell-equipment-5",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-cell.png",
    icon_size = 128,
    order = "v-g-l-e",
    prerequisites =
    {
      "vehicle-fusion-cell-equipment-4"
    },
    unit =
    {
      count = 250,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-cell-5"
      }
    },
  },
}
)

data:extend(
{
  {
    type = "item",
    name = "vehicle-fusion-cell-6",
    icon = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-6.png",
    icon_size = 64,
    placed_as_equipment_result = "vehicle-fusion-cell-6",
    subgroup = "vehicle-equipment",
    order = "v[vehicle-equipment]-b[fusion-cell]-6",
    stack_size = 50,
    default_request_amount = 10
  },

  {
    type = "recipe",
    name = "vehicle-fusion-cell-6",
    enabled = "false",
    energy_required = 10,
    ingredients =
    {
      {"vehicle-fusion-cell-5", 1},
      {"processing-unit", 25},
      {"effectivity-module-3", 1},
      {"speed-module-3", 1},
      {"productivity-module-3", 1},
    },
    result = "vehicle-fusion-cell-6"
  },

  {
    type = "generator-equipment",
    name = "vehicle-fusion-cell-6",
    sprite =
    {
      filename = "__bobvehicleequipment__/graphics/equipment/vehicle-fusion-cell-6.png",
      width = 64,
      height = 64,
      priority = "medium"
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "1200kW",
    categories = {"vehicle"}
  },

  {
    type = "technology",
    name = "vehicle-fusion-cell-equipment-6",
    icon = "__bobvehicleequipment__/graphics/technology/vehicle-fusion-cell.png",
    icon_size = 128,
    order = "v-g-l-f",
    prerequisites =
    {
      "vehicle-fusion-cell-equipment-5"
    },
    unit =
    {
      count = 300,
      time = 45,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vehicle-fusion-cell-6"
      }
    },
  },
}
)

