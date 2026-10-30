local shared = require("shared")

local robot_icon = "__base__/graphics/icons/logistic-robot.png"
local destroyed_icon = "__core__/graphics/icons/alerts/destroyed-icon.png"

local function technology_icons(constant)
  return {
    {icon = "__base__/graphics/technology/logistic-robotics.png", icon_size = 256},
    {icon = "__core__/graphics/icons/technology/constants/" .. constant .. ".png", icon_size = 128, scale = 0.5,
      shift = {50, 50}, floating = true},
  }
end

local list = {
  {
    type = "technology",
    name = shared.technology,
    icons = technology_icons("constant-health"),
    effects = {
      {type = "nothing", icon = robot_icon,
        effect_description = {"modifier-description.pra-swarm-safety", tostring(shared.safety_per_level)}},
    },
    prerequisites = {"logistic-system", "utility-science-pack"},
    unit = {
      count_formula = "100*L^2",
      time = 30,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
    },
    max_level = "infinite",
    upgrade = true,
    order = "e-g",
  },
}

-- Swarm dispatch 1–5: each level multiplies the crash rate by dispatch_multiplier.
local dispatch = {
  {count = 150, packs = {"automation", "logistic"}, after = "logistic-robotics"},
  {count = 300, packs = {"automation", "logistic", "chemical"}, after = "chemical-science-pack"},
  {count = 500, packs = {"automation", "logistic", "chemical"}, after = "logistic-system"},
  {count = 750, packs = {"automation", "logistic", "chemical", "production"}, after = "production-science-pack"},
  {count = 1000, packs = {"automation", "logistic", "chemical", "production", "utility"}, after = "utility-science-pack"},
}
local reduction = tostring(math.floor((1 - shared.dispatch_multiplier) * 100 + 0.5))
for level, spec in ipairs(dispatch) do
  local ingredients = {}
  for _, pack in ipairs(spec.packs) do ingredients[#ingredients + 1] = {pack .. "-science-pack", 1} end
  local prerequisites = {spec.after}
  if level > 1 then table.insert(prerequisites, 1, shared.dispatch_prefix .. (level - 1)) end
  list[#list + 1] = {
    type = "technology",
    -- Locale: the engine drops the level suffix and shows the level (technology-name.pra-swarm-dispatch).
    name = shared.dispatch_prefix .. level,
    icons = technology_icons("constant-count"),
    effects = {
      {type = "nothing", icon = robot_icon, effect_description = {"modifier-description.pra-swarm-dispatch", reduction}},
    },
    prerequisites = prerequisites,
    unit = {count = spec.count, time = 30, ingredients = ingredients},
    upgrade = true,
    order = "e-f-" .. level,
  }
end

-- The wreck of a crashed robot: holds its cargo and its wreck item until construction robots or a player
-- take them. Made indestructible by the script when it is created.
list[#list + 1] = {
  type = "container",
  name = shared.wreck_entity,
  icons = {
    {icon = robot_icon},
    {icon = destroyed_icon, icon_size = 64, scale = 0.25, shift = {8, 8}},
  },
  flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-blueprintable",
    "not-upgradable", "no-automated-item-insertion"},
  -- An item to place it by and mining without a result (the contents go to the miner): the arrangement
  -- construction robots are known to deconstruct (cargo crate of the earlier robot attrition mod).
  placeable_by = {item = "logistic-robot", count = 1},
  minable = {mining_time = 0.1},
  hidden_in_factoriopedia = true,
  max_health = 100,
  create_ghost_on_death = false,
  inventory_size = 2,
  collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
  collision_mask = {layers = {}},
  selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_priority = 51,
  circuit_wire_max_distance = 0,
  picture = {
    filename = "__base__/graphics/entity/logistic-robot/remnants/logistic-robot-remnants.png",
    width = 116,
    height = 114,
    shift = {0.03125, 0.03125},
    scale = 0.5,
  },
}

-- Tips and tricks (text only: simulations crash in the build). zzzparanoidal keeps this category.
list[#list + 1] = {type = "tips-and-tricks-item-category", name = shared.tips_category, order = "c-r"}
local tips = {
  {"pra-intro", "[item=logistic-robot]"},
  {"pra-congestion", "[entity=roboport]"},
  {"pra-wreck", "[item=repair-pack]"},
  {"pra-cargo", "[item=explosives]"},
  {"pra-reliability", "[technology=" .. shared.dispatch_prefix .. "1]"},
}
for index, tip in ipairs(tips) do
  list[#list + 1] = {
    type = "tips-and-tricks-item",
    name = tip[1],
    category = shared.tips_category,
    order = string.format("%02d", index),
    indent = index == 1 and 0 or 1,
    is_title = index == 1 or nil,
    tag = tip[2],
    starting_status = "locked",
    trigger = {type = "research", technology = "logistic-robotics"},
  }
end

data:extend(list)
