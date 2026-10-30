-- Runs after zzzparanoidal (optional dependency): wrecks copy the final robot icons, repair recipes follow the final
-- robot unlocks, and the build's recipe-icon sync and recycling rebuild never see the repair recipes.
local shared = require("shared")
local util = require("util")

local robot_icon = "__base__/graphics/icons/logistic-robot.png"
local destroyed_icon = "__core__/graphics/icons/alerts/destroyed-icon.png"

---------------------------------------------------------------------------------------------------
-- Explosions: the look and sound of vanilla explosions (taken here, after sound mods changed them) with area
-- damage instead of their stone particles; the robot's own death adds the metal debris. Rings add up.

local function explosion(name, base_names, rings)
  local base
  for _, base_name in ipairs(base_names) do
    base = base or data.raw.explosion[base_name]
  end
  local prototype = table.deepcopy(base)
  prototype.name = name
  prototype.localised_name = {"entity-name." .. name}
  prototype.hidden = true
  local effects = {}
  for _, ring in ipairs(rings) do
    effects[#effects + 1] = {
      type = "nested-result",
      action = {
        type = "area",
        radius = ring[1],
        action_delivery = {type = "instant",
          target_effects = {{type = "damage", damage = {amount = ring[2], type = "explosion"}}}},
      },
    }
  end
  prototype.created_effect = {type = "direct", action_delivery = {type = "instant", target_effects = effects}}
  return prototype
end

data:extend({
  -- 75 at the centre, 5 at 3.5 tiles.
  explosion(shared.explosion_entity, {"medium-explosion", "explosion"}, {{0.5, 40}, {1.5, 20}, {2.5, 10}, {3.5, 5}}),
  -- Detonating cargo: 265 at the centre, 10 at 5.5 tiles.
  explosion(shared.cargo_explosion_entity, {"big-explosion", "medium-explosion", "explosion"},
    {{1, 150}, {2.5, 75}, {4, 30}, {5.5, 10}}),
})

---------------------------------------------------------------------------------------------------
-- Wreck items and repair recipes, one per logistic robot that has an item to place it.

local function icons_of(prototype)
  if prototype.icons then return table.deepcopy(prototype.icons) end
  return {{icon = prototype.icon, icon_size = prototype.icon_size}}
end

local function name_of(item, robot_name)
  return item.localised_name or {"?", {"item-name." .. item.name}, {"entity-name." .. robot_name}}
end

local placing = {}
for item_name, item in pairs(data.raw.item) do
  local robot = item.place_result and data.raw["logistic-robot"][item.place_result]
  if robot and (not placing[robot.name] or item_name == robot.name) then placing[robot.name] = item end
end

-- Recipes (not recycling) that make an item, and the technologies that unlock each recipe.
local makers = {}
for recipe_name, recipe in pairs(data.raw.recipe) do
  if recipe.category ~= "recycling" and type(recipe.results) == "table" then
    for _, product in pairs(recipe.results) do
      if product.name and (product.type or "item") == "item" then
        makers[product.name] = makers[product.name] or {}
        makers[product.name][recipe_name] = recipe
      end
    end
  end
end
local unlocked_by = {}
for tech_name, technology in pairs(data.raw.technology) do
  for _, effect in pairs(technology.effects or {}) do
    if effect.type == "unlock-recipe" and effect.recipe then
      unlocked_by[effect.recipe] = unlocked_by[effect.recipe] or {}
      table.insert(unlocked_by[effect.recipe], tech_name)
    end
  end
end

local robot_names = {}
for robot_name in pairs(placing) do robot_names[#robot_names + 1] = robot_name end
table.sort(robot_names)

local new = {}
for _, robot_name in ipairs(robot_names) do
  local item = placing[robot_name]
  local tier = tonumber(robot_name:match("%-(%d+)$") or "1")
  local pack = data.raw["repair-tool"]["bob-repair-pack-" .. tier] and "bob-repair-pack-" .. tier or "repair-pack"
  local wreck_name = shared.wreck_item_prefix .. robot_name
  local robot_label = name_of(item, robot_name)

  local wreck_icons = icons_of(item)
  wreck_icons[#wreck_icons + 1] = {icon = destroyed_icon, icon_size = 64, scale = 0.25, shift = {8, -8}}
  new[#new + 1] = {
    type = "item",
    name = wreck_name,
    localised_name = {"item-name.pra-wreck", robot_label},
    localised_description = {"item-description.pra-wreck", tostring(shared.repair_packs),
      tostring(math.floor(shared.repair_success * 100 + 0.5))},
    icons = wreck_icons,
    subgroup = item.subgroup,
    order = (item.order or robot_name) .. "-w",
    stack_size = 50,
  }

  local repair_icons = icons_of(item)
  local pack_prototype = data.raw["repair-tool"][pack]
  if pack_prototype then
    for _, layer in ipairs(icons_of(pack_prototype)) do
      layer.scale = (layer.scale or (64 / 2) / (layer.icon_size or 64)) * 0.5
      layer.shift = {-8, 8}
      repair_icons[#repair_icons + 1] = layer
    end
  end
  local enabled, technologies = false, {}
  for recipe_name, recipe in pairs(makers[item.name] or {}) do
    if recipe.enabled ~= false and not recipe.hidden then enabled = true end
    for _, tech_name in ipairs(unlocked_by[recipe_name] or {}) do technologies[tech_name] = true end
  end
  local recipe_name = shared.repair_recipe_prefix .. robot_name
  new[#new + 1] = {
    type = "recipe",
    name = recipe_name,
    localised_name = {"recipe-name.pra-repair", robot_label},
    localised_description = {"recipe-description.pra-repair",
      tostring(math.floor(shared.repair_success * 100 + 0.5))},
    icons = repair_icons,
    category = "crafting",
    subgroup = item.subgroup,
    order = (item.order or robot_name) .. "-x",
    enabled = enabled,
    energy_required = shared.repair_time,
    ingredients = {
      {type = "item", name = wreck_name, amount = 1},
      {type = "item", name = pack, amount = shared.repair_packs},
    },
    results = {{type = "item", name = item.name, amount = 1, probability = shared.repair_success}},
    main_product = item.name,
    allow_productivity = false,
    allow_decomposition = false,
    auto_recycle = false,
  }
  local sorted = {}
  for tech_name in pairs(technologies) do sorted[#sorted + 1] = tech_name end
  table.sort(sorted)
  for _, tech_name in ipairs(sorted) do
    table.insert(data.raw.technology[tech_name].effects, {type = "unlock-recipe", recipe = recipe_name})
  end
end
data:extend(new)

---------------------------------------------------------------------------------------------------
-- Dangerous cargo classes for the control stage.

local function explosive_category(category)
  if type(category) ~= "string" then return false end
  return category:find("rocket", 1, true) or category:find("artillery", 1, true) or category:find("mirv", 1, true)
    or (category:find("shell", 1, true) and not category:find("shotgun", 1, true))
end

local item_types = defines and defines.prototypes and defines.prototypes.item
  or {item = 0, ammo = 0, capsule = 0, tool = 0, module = 0, ["repair-tool"] = 0, ["item-with-entity-data"] = 0}
local explosive, flammable = {}, {}
local counts = {explosive = 0, flammable = 0}
for item_type in pairs(item_types) do
  for name, item in pairs(data.raw[item_type] or {}) do
    local category = item.ammo_category or (type(item.ammo_type) == "table" and item.ammo_type.category)
    local place = item.place_result
    -- Buildings (except land mines) and guns are never dangerous cargo; seed bombs only plant trees.
    local mine = place and data.raw["land-mine"] and data.raw["land-mine"][place] and name:find("mine", 1, true)
    local cargo = item_type ~= "gun" and (not place or mine) and not name:find("seed", 1, true)
    local is_explosive = cargo and (mine or name:find("explosive", 1, true) or name:find("grenade", 1, true)
      or name:find("atomic", 1, true) or (item_type == "ammo" and explosive_category(category)))
    local is_flammable = cargo and ((item.fuel_category == "chemical" and item.fuel_value
        and util.parse_energy(item.fuel_value) >= shared.flammable_fuel_value)
      or (item_type == "ammo" and category == "flamethrower")
      or name:find("napalm", 1, true) or name:find("incendiary", 1, true))
    if is_explosive then
      explosive[name] = true
      counts.explosive = counts.explosive + 1
    elseif is_flammable then
      flammable[name] = true
      counts.flammable = counts.flammable + 1
    end
  end
end
data:extend({{type = "mod-data", name = shared.cargo_data, data = {explosive = explosive, flammable = flammable}}})
log(("paranoidal-robot-attrition: wreck items %d, explosive cargo %d, flammable cargo %d")
  :format(#robot_names, counts.explosive, counts.flammable))

---------------------------------------------------------------------------------------------------
-- Robot speed research also raises the crash risk: say so in its tooltip.

for _, technology in pairs(data.raw.technology) do
  local speed, noted = false, false
  for _, effect in pairs(technology.effects or {}) do
    if effect.type == "worker-robot-speed" then speed = true end
    if effect.type == "nothing" and type(effect.effect_description) == "table"
      and effect.effect_description[1] == "modifier-description.pra-speed-risk" then noted = true end
  end
  if speed and not noted then
    table.insert(technology.effects, {type = "nothing", icon = robot_icon,
      effect_description = {"modifier-description.pra-speed-risk"}})
  end
end
