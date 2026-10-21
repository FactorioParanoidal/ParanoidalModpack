require "util"
data:extend(
{
  {
    type = "item",
    name = "electric-steel-furnace",
    icon = "__MilesBobsExpansion2__/graphics/icons/electric-steel-furnace.png",
    icon_size = 32,
    subgroup = "smelting-machine",
    order = "bd",
    place_result = "electric-steel-furnace",
    stack_size = 50,
  },
  {
    type = "furnace",
    name = "electric-steel-furnace",
    icon = "__base__/graphics/icons/steel-furnace.png",
    icon_size = 32,
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 1, results = { { type = "item", name = "electric-steel-furnace", amount = 1 } } },
    max_health = 300,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } },
    selection_box = { { -0.8, -1 }, { 0.8, 1 } },
    resistances = { { type = "fire", percent = 100 } },
    crafting_categories = { "smelting" },
    crafting_speed = 1,
    result_inventory_size = 1,
    source_inventory_size = 1,
    fast_replaceable_group = "furnace",
    energy_usage = "100kW",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 1 },
    },
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = { sound = { filename = "__base__/sound/furnace.ogg" } },
  },
  {
    type = "recipe",
    name = "electric-steel-furnace",
    enabled = false,
    ingredients =
    {
      { type = "item", name = "steel-furnace", amount = 1 },
      { type = "item", name = "electronic-circuit", amount = 5 },
      { type = "item", name = "steel-plate", amount = 10 },
      { type = "item", name = "iron-gear-wheel", amount = 10 },
    },
    results = { { type = "item", name = "electric-steel-furnace", amount = 1 } },
  },
  {
    type = "technology",
    name = "electric-steel-furnace",
    icon = "__base__/graphics/technology/automation-1.png",
    icon_size = 256,
    effects =
    {
      { type = "unlock-recipe", recipe = "electric-steel-furnace" },
    },
    prerequisites =
    {
      "bob-electronics-machine-1",
      "advanced-material-processing",
    },
    unit =
    {
      count = 100,
      time = 50,
      ingredients =
      {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
      },
    },
    upgrade = true,
  },
}
)

-- 2.0: графика печей живёт в graphics_set — наследуем вид базовой steel-furnace
data.raw.furnace["electric-steel-furnace"].graphics_set =
  table.deepcopy(data.raw.furnace["steel-furnace"].graphics_set)
