local function item(name, icon, subgroup, order, place_result)
  return {
    type = "item",
    name = name,
    icon = icon,
    icon_size = 64,
    subgroup = subgroup,
    order = order,
    place_result = place_result,
    stack_size = (name == "JunkTrain" or name == "ScrapTrailer") and 5 or 10,
    localised_description = {"item-description." .. name},
  }
end

local primitive_tint = {r = 170, g = 130, b = 1, a = 255}
local function infrastructure_item(name, icon, order)
  local result = item(name, icon, "transport-rail-other", order, name)
  result.icon = nil
  result.icons = {{icon = icon, icon_size = 64, tint = primitive_tint}}
  return result
end

data:extend({
  item("JunkTrain", "__JunkTrain3__/graphics/train/t0/usl_icon.png", "bob-locomotive", "a1", "yir_usl"),
  item("ScrapTrailer", "__JunkTrain3__/graphics/train/t0/usw_icon.png", "bob-cargo-wagon", "a1", "yir_us_cargo"),
  infrastructure_item("rail-signal-scrap", "__base__/graphics/icons/rail-signal.png", "a"),
  infrastructure_item("rail-chain-signal-scrap", "__base__/graphics/icons/rail-chain-signal.png", "b"),
  infrastructure_item("train-stop-scrap", "__base__/graphics/icons/train-stop.png", "c"),
})

local recipes = {
  {
    type = "recipe",
    name = "JunkTrain",
    energy_required = 10,
    enabled = false,
    subgroup = "bob-locomotive",
    order = "a1",
    ingredients = {
      {type = "item", name = "motor", amount = 5},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "iron-stick", amount = 6},
      {type = "item", name = "wood", amount = 20},
    },
    results = {{type = "item", name = "JunkTrain", amount = 1}},
  },
  {
    type = "recipe",
    name = "ScrapTrailer",
    energy_required = 10,
    enabled = false,
    subgroup = "bob-cargo-wagon",
    order = "a1",
    ingredients = {
      {type = "item", name = "iron-chest", amount = 1},
      {type = "item", name = "iron-plate", amount = 10},
      {type = "item", name = "iron-stick", amount = 4},
      {type = "item", name = "wood", amount = 20},
    },
    results = {{type = "item", name = "ScrapTrailer", amount = 1}},
  },
  {
    type = "recipe",
    name = "scrap-rail",
    energy_required = 1,
    enabled = false,
    subgroup = "transport-rail",
    order = "a",
    ingredients = {
      {type = "item", name = "stone-crushed", amount = 10},
      {type = "item", name = "iron-stick", amount = 2},
      {type = "item", name = "wood", amount = 10},
      {type = "item", name = "steel-plate", amount = 2},
    },
    results = {{type = "item", name = "scrap-rail", amount = 2}},
    requester_paste_multiplier = 4,
  },
  {
    type = "recipe",
    name = "train-stop-scrap",
    enabled = false,
    subgroup = "transport-rail-other",
    order = "c",
    ingredients = {
      {type = "item", name = "iron-plate", amount = 4},
      {type = "item", name = "small-lamp", amount = 2},
      {type = "item", name = "copper-cable", amount = 6},
      {type = "item", name = "wood", amount = 10},
    },
    results = {{type = "item", name = "train-stop-scrap", amount = 1}},
  },
  {
    type = "recipe",
    name = "rail-signal-scrap",
    enabled = false,
    subgroup = "transport-rail-other",
    order = "a",
    ingredients = {
      {type = "item", name = "iron-stick", amount = 1},
      {type = "item", name = "small-lamp", amount = 2},
      {type = "item", name = "copper-cable", amount = 6},
      {type = "item", name = "wood", amount = 4},
    },
    results = {{type = "item", name = "rail-signal-scrap", amount = 1}},
  },
  {
    type = "recipe",
    name = "rail-chain-signal-scrap",
    enabled = false,
    subgroup = "transport-rail-other",
    order = "b",
    ingredients = {
      {type = "item", name = "iron-stick", amount = 1},
      {type = "item", name = "small-lamp", amount = 2},
      {type = "item", name = "copper-cable", amount = 12},
      {type = "item", name = "wood", amount = 4},
    },
    results = {{type = "item", name = "rail-chain-signal-scrap", amount = 1}},
  },
}

local function upgrade_icons(icon, icon_size, tint)
  local base = {icon = icon, icon_size = icon_size}
  if tint then
    base.tint = tint
  end
  return {
    base,
    {
      icon = "__JunkTrain3__/graphics/upgrade-icon.png",
      icon_size = 16,
      scale = 0.9,
      shift = {-10, -10},
    },
  }
end

local upgrade_recipes = {
  {
    name = "scrap-rail-to-rail",
    subgroup = "transport-rail",
    order = "aa",
    icons = upgrade_icons("__JunkTrain3__/graphics/rail/rail.png", 32),
    ingredients = {
      {type = "item", name = "scrap-rail", amount = 2},
      {type = "item", name = "concrete", amount = 6},
    },
    result = "rail",
    amount = 2,
  },
  {
    name = "rail-signal-scrap-to-rail-signal",
    subgroup = "transport-rail-other",
    order = "aa",
    icons = upgrade_icons("__base__/graphics/icons/rail-signal.png", 64, primitive_tint),
    ingredients = {
      {type = "item", name = "rail-signal-scrap", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 1},
    },
    result = "rail-signal",
    amount = 1,
  },
  {
    name = "rail-chain-signal-scrap-to-rail-chain-signal",
    subgroup = "transport-rail-other",
    order = "ba",
    icons = upgrade_icons("__base__/graphics/icons/rail-chain-signal.png", 64, primitive_tint),
    ingredients = {
      {type = "item", name = "rail-chain-signal-scrap", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 1},
    },
    result = "rail-chain-signal",
    amount = 1,
  },
  {
    name = "train-stop-scrap-to-train-stop",
    subgroup = "transport-rail-other",
    order = "ca",
    icons = upgrade_icons("__base__/graphics/icons/train-stop.png", 64, primitive_tint),
    ingredients = {
      {type = "item", name = "train-stop-scrap", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 5},
      {type = "item", name = "steel-plate", amount = 10},
    },
    result = "train-stop",
    amount = 1,
  },
}

for _, definition in ipairs(upgrade_recipes) do
  recipes[#recipes + 1] = {
    type = "recipe",
    name = definition.name,
    category = "crafting",
    subgroup = definition.subgroup,
    order = definition.order,
    icons = definition.icons,
    energy_required = 0.5,
    enabled = false,
    allow_decomposition = false,
    always_show_products = true,
    ingredients = definition.ingredients,
    results = {{type = "item", name = definition.result, amount = definition.amount}},
  }
end

data:extend(recipes)

data:extend({
  {
    type = "technology",
    name = "JunkTrain_tech",
    icon = "__JunkTrain3__/graphics/train/t0/usl_icon.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "scrap-rail"},
      {type = "unlock-recipe", recipe = "JunkTrain"},
      {type = "unlock-recipe", recipe = "ScrapTrailer"},
    },
    prerequisites = {"automation", "steel-processing"},
    unit = {
      count = 20,
      ingredients = {{"automation-science-pack", 1}},
      time = 20,
    },
    order = "c-g-b-a",
  },
  {
    type = "technology",
    name = "automated-scrap-rail-transportation",
    icon = "__base__/graphics/technology/automated-rail-transportation.png",
    icon_size = 256,
    effects = {
      {type = "unlock-recipe", recipe = "train-stop-scrap"},
      {type = "unlock-recipe", recipe = "rail-signal-scrap"},
      {type = "unlock-recipe", recipe = "rail-chain-signal-scrap"},
    },
    prerequisites = {"JunkTrain_tech", "lamp"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack", 1}},
      time = 30,
    },
    order = "c-g-b",
  },
})

local function add_prerequisite(technology_name, prerequisite)
  local technology = data.raw.technology[technology_name]
  if not technology then
    return
  end
  technology.prerequisites = technology.prerequisites or {}
  for _, existing in pairs(technology.prerequisites) do
    if existing == prerequisite then
      return
    end
  end
  technology.prerequisites[#technology.prerequisites + 1] = prerequisite
end

local function add_unlock(technology_name, recipe)
  local technology = data.raw.technology[technology_name]
  if not technology then
    return
  end
  technology.effects = technology.effects or {}
  for _, effect in pairs(technology.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe then
      return
    end
  end
  technology.effects[#technology.effects + 1] = {type = "unlock-recipe", recipe = recipe}
end

add_prerequisite("railway", "JunkTrain_tech")
add_unlock("railway", "scrap-rail-to-rail")
-- Factorio 2.0 merged the former rail-signals unlocks into automated rail transportation.
add_unlock("automated-rail-transportation", "rail-signal-scrap-to-rail-signal")
add_unlock("automated-rail-transportation", "rail-chain-signal-scrap-to-rail-chain-signal")
add_unlock("automated-rail-transportation", "train-stop-scrap-to-train-stop")
