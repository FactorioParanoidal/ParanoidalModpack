-- Lighted poles (after Lighted Electric Poles + by Optera): a "lighted-<pole>" copy of every electric pole that
-- has copper wires and its own item, with a hidden lamp "lighted-<pole>-lamp" placed under it by control.lua.
-- The lamp keeps the energy use of a real lamp; an electric pole prototype has no energy consumption of its own.
local light_scale = settings.startup["lepp_light_size_factor"].value
local LIGHT_SIZE_LIMIT = 75 -- largest light radius the engine draws without artefacts
local POLE_WEIGHT = 40000 -- lamp 20 kg + pole 20 kg
local FALLBACK_TECHNOLOGY = "lamp"
local BADGE = {{
  icon = "__paranoidal-lighting__/graphics/icons/lighted-pole-badge.png",
  icon_size = 32,
  tint = {r = 1, g = 1, b = 1, a = 0.85},
}}
local EMPTY = {filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1}

local function copy(prototype, name)
  local p = table.deepcopy(prototype)
  p.name = name
  if p.minable and p.minable.result then p.minable.result = name end
  if p.place_result then p.place_result = name end
  p.icon, p.icon_size, p.icons = nil, nil, nil
  return p
end

-- Icons of the prototype with the badge on top (nil if the prototype has no usable icon).
local function badged_icons(prototype)
  local icons
  if prototype.icons then
    icons = {}
    for _, v in pairs(prototype.icons) do
      icons[#icons + 1] = {
        icon = v.icon, icon_size = v.icon_size or prototype.icon_size, tint = v.tint, scale = v.scale, shift = v.shift,
      }
    end
  elseif prototype.icon then
    icons = {{icon = prototype.icon, icon_size = prototype.icon_size, tint = {r = 1, g = 1, b = 1, a = 1}}}
  else
    return nil
  end
  icons[#icons + 1] = BADGE[1]
  return icons
end

-- Recipes that produce one of the given items: recipe name -> {product, subgroup, order}.
local function recipes_making(products)
  local found = {}
  for _, recipe in pairs(data.raw.recipe) do
    for _, result in pairs(recipe.results or {}) do
      if type(result) == "table" and (result.type == nil or result.type == "item") and products[result.name] then
        found[recipe.name] = {product = result.name, subgroup = recipe.subgroup, order = recipe.order}
      end
    end
  end
  return found
end

-- Poles that get a lighted copy: item name -> pole prototype.
local sources = {}
local lighted = {} -- original pole entity name -> true
for _, item in pairs(data.raw.item) do
  local pole = item.place_result and data.raw["electric-pole"][item.place_result]
  if pole and pole.draw_copper_wires ~= false
    and pole.maximum_wire_distance and pole.maximum_wire_distance > 0
    and pole.minable and pole.minable.result == item.name then
    sources[item.name] = pole
    lighted[pole.name] = true
  end
end

local pole_names = {} -- original item name -> lighted name
local new_prototypes = {}
for _, item in pairs(data.raw.item) do
  local pole = sources[item.name]
  if pole then
    pole.fast_replaceable_group = pole.fast_replaceable_group or "electric-pole"
    local name = "lighted-" .. pole.name
    local localised_name = {"entity-name.lighted-pole", {"entity-name." .. pole.name}}

    local new_pole = copy(pole, name)
    new_pole.icons = badged_icons(pole) or table.deepcopy(BADGE)
    new_pole.localised_name = localised_name
    if new_pole.next_upgrade then
      new_pole.next_upgrade = lighted[new_pole.next_upgrade] and "lighted-" .. new_pole.next_upgrade or nil
    end

    pole_names[item.name] = name
    local new_item = copy(item, name)
    new_item.icons = badged_icons(item) or table.deepcopy(BADGE)
    new_item.localised_name = localised_name
    new_item.order = (item.order or "") .. "-0"
    new_item.weight = POLE_WEIGHT

    local lamp = copy(data.raw.lamp["small-lamp"], name .. "-lamp")
    lamp.icons = new_pole.icons
    lamp.localised_name = localised_name
    lamp.minable = nil
    lamp.next_upgrade = nil
    lamp.flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"}
    lamp.selectable_in_game = false
    lamp.collision_box = {{-0.1, -0.1}, {0.1, 0.1}}
    lamp.selection_box = {{-0.4, -0.4}, {0.4, 0.4}}
    lamp.collision_mask = {layers = {resource = true}}
    lamp.picture_off = EMPTY
    lamp.picture_on = EMPTY
    local light_size, lamp_count = 40, 1 -- a small lamp
    lamp.energy_usage_per_tick = "5kW"
    if light_scale > 0 then
      -- A small pole (wire reach 7.5) lights like a small lamp; the radius grows with the square root of the reach.
      light_size = math.floor(math.sqrt(new_pole.maximum_wire_distance) * (40 / math.sqrt(7.5)) * light_scale + 0.5)
      if light_size > LIGHT_SIZE_LIMIT then light_size = LIGHT_SIZE_LIMIT end
      lamp_count = math.ceil(light_size / 40)
      lamp.energy_usage_per_tick = light_size * 0.125 .. "kW"
    end
    lamp.light = {intensity = 0.9, size = light_size, color = {r = 1.0, g = 1.0, b = 1.0}}
    lamp.light_when_colored = {intensity = 1, size = light_size * 0.15, color = {r = 1.0, g = 1.0, b = 1.0}}

    local recipe = {
      type = "recipe",
      name = name,
      enabled = false,
      ingredients = {
        {type = "item", name = item.name, amount = 1},
        {type = "item", name = "small-lamp", amount = lamp_count},
      },
      results = {{type = "item", name = name, amount = 1}},
    }
    -- Sort next to the first recipe of the original pole.
    for _, found in pairs(recipes_making({[item.name] = true})) do
      if found.subgroup then recipe.subgroup = found.subgroup end
      if found.order then recipe.order = found.order .. "-0" end
      break
    end

    new_prototypes[#new_prototypes + 1] = new_pole
    new_prototypes[#new_prototypes + 1] = new_item
    new_prototypes[#new_prototypes + 1] = lamp
    new_prototypes[#new_prototypes + 1] = recipe
  end
end
if not next(new_prototypes) then return end
data:extend(new_prototypes)

-- Unlock each lighted pole wherever its original is unlocked (once per technology).
local recipe_lookup = recipes_making(pole_names)
local unlocked = {} -- original item -> {technology -> true}
for _, tech in pairs(data.raw.technology) do
  local added = {}
  for _, effect in pairs(tech.effects or {}) do
    local found = effect.recipe and recipe_lookup[effect.recipe]
    if found then
      local by_tech = unlocked[found.product] or {}
      unlocked[found.product] = by_tech
      if not by_tech[tech.name] then
        by_tech[tech.name] = true
        added[#added + 1] = {type = "unlock-recipe", recipe = pole_names[found.product]}
      end
    end
  end
  for _, effect in ipairs(added) do table.insert(tech.effects, effect) end
end

-- Poles available without research (the small wooden pole) are unlocked with lamps.
local fallback = data.raw.technology[FALLBACK_TECHNOLOGY]
if fallback then
  fallback.effects = fallback.effects or {}
  for original, name in pairs(pole_names) do
    if not unlocked[original] then
      table.insert(fallback.effects, {type = "unlock-recipe", recipe = name})
    end
  end
end
