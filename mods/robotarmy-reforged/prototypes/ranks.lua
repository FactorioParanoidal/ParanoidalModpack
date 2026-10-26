-- Rank prototypes, droid tooltips and the entity filters of the command tool. Loaded from
-- data-updates.lua: after every mod's data.lua, so that Bob's drones exist.
--
-- A droid that reaches the kills of a rank (shared.rank_kills) is replaced by the control script
-- with "<droid>-rank-<n>": a copy of the droid with more health, damage, range, speed, regen or
-- resistances, as set by the growth of that droid kind (lib/shared.lua). Rank droids cannot be
-- mined or picked up as items (the rank would be lost); a drop pod carries them with their rank.
local util = require("util")
local shared = require("lib.shared")

local STAR = "__base__/graphics/icons/signal/signal-star.png"
local DIGIT = "__base__/graphics/icons/signal/signal_%d.png"

-- Special abilities shown in the tooltip (locale robotarmy-tooltip.role-<droid>).
local ABILITY = {
  ["droid-scout"] = true, ["droid-miner"] = true, ["droid-repair"] = true, ["droid-tesla"] = true,
  ["droid-rocket"] = true, ["droid-poison"] = true, ["droid-flame"] = true, ["terminator-plasma"] = true,
}

local function as_list(value)
  if value == nil then return {} end
  if value[1] ~= nil or next(value) == nil then return value end
  return {value}
end

--- First damage {amount, type} of an attack: instant hits, projectiles, beams and nested results
--- (fire streams, poison clouds and chain jumps are not counted).
local function first_damage(action, depth)
  if not action or depth > 6 then return nil end
  for _, a in pairs(as_list(action)) do
    for _, delivery in pairs(as_list(a.action_delivery)) do
      local amount, damage_type
      if delivery.type == "instant" then
        for _, effect in pairs(as_list(delivery.target_effects)) do
          if effect.type == "damage" then
            return effect.damage.amount, effect.damage.type
          elseif effect.type == "nested-result" then
            amount, damage_type = first_damage(effect.action, depth + 1)
            if amount then return amount, damage_type end
          end
        end
      elseif delivery.type == "projectile" then
        local p = data.raw.projectile[delivery.projectile]
        amount, damage_type = first_damage(p and p.action, depth + 1)
      elseif delivery.type == "beam" then
        local b = data.raw.beam[delivery.beam]
        amount, damage_type = first_damage(b and b.action, depth + 1)
      end
      if amount then return amount, damage_type end
    end
  end
end

local function number(value)
  return string.format("%g", math.floor(value * 10 + 0.5) / 10)
end

--- Characteristics shown in the item and entity tooltips (and Factoriopedia).
local function tooltip(unit, kind, rank)
  local a = unit.attack_parameters
  local fields = {
    {name = {"robotarmy-tooltip.health"}, value = number(unit.max_health), order = 1},
    {name = {"robotarmy-tooltip.range"}, value = number(a.range), order = 3},
    {name = {"robotarmy-tooltip.speed"}, value = {"robotarmy-tooltip.speed-value", number(unit.movement_speed * 60)}, order = 4},
  }
  local amount, damage_type = first_damage(a.ammo_type and a.ammo_type.action, 0)
  if amount then
    fields[#fields + 1] = {
      name = {"robotarmy-tooltip.attack"},
      value = {"robotarmy-tooltip.attack-value", number(amount * (a.damage_modifier or 1)),
        {"damage-type-name." .. damage_type}, number(a.cooldown / 60)},
      order = 2,
    }
  end
  if (unit.healing_per_tick or 0) > 0 then
    fields[#fields + 1] = {name = {"robotarmy-tooltip.regen"},
      value = {"robotarmy-tooltip.regen-value", number(unit.healing_per_tick * 60)}, order = 5}
  end
  if ABILITY[kind] then
    fields[#fields + 1] = {name = {"robotarmy-tooltip.ability"}, value = {"robotarmy-tooltip.role-" .. kind}, order = 6}
  end
  if rank > 0 then
    fields[#fields + 1] = {name = {"robotarmy-tooltip.rank"}, value = {"robotarmy-rank.rank-" .. rank}, order = 0}
  end
  local next_kills = shared.rank_threshold(kind, rank + 1)
  if next_kills then
    fields[#fields + 1] = {name = {"robotarmy-tooltip.next-rank"},
      value = {"robotarmy-tooltip.next-rank-value", {"robotarmy-rank.rank-" .. (rank + 1)}, tostring(next_kills)}, order = 7}
  end
  return fields
end

local function icons_of(proto)
  if proto.icons then return util.table.deepcopy(proto.icons) end
  return {{icon = proto.icon, icon_size = proto.icon_size or 64}}
end

--- Icon of a rank droid: the droid icon with a star and the rank number.
local function rank_icons(unit, rank)
  local icons = icons_of(unit)
  local size = icons[1].icon_size or 64
  local scale = 0.18 * size / 64
  icons[#icons + 1] = {icon = STAR, icon_size = 64, scale = scale, shift = {-10, -10}, floating = true}
  local digits = tostring(rank)
  for i = 1, #digits do
    icons[#icons + 1] = {icon = string.format(DIGIT, tonumber(digits:sub(i, i))), icon_size = 64, scale = scale,
      shift = {2 + (i - 1) * 9, -10}, floating = true}
  end
  return icons
end

local function grow(u, g, r)
  local a = u.attack_parameters
  if g.health then u.max_health = u.max_health * (1 + g.health * r) end
  if g.regen then u.healing_per_tick = (u.healing_per_tick or 0) + g.regen * r / 60 end
  if g.speed then
    u.movement_speed = u.movement_speed * (1 + g.speed * r)
    u.distance_per_frame = (u.distance_per_frame or 0.1) * (1 + g.speed * r)
  end
  if g.range then
    a.range = a.range + g.range * r
    if (u.vision_distance or 0) < a.range + 5 then u.vision_distance = math.min(49, a.range + 5) end
  end
  if g.cooldown then a.cooldown = math.max(1, a.cooldown * math.max(0.25, 1 - g.cooldown * r)) end
  if g.damage then a.damage_modifier = (a.damage_modifier or 1) * (1 + g.damage * r) end
  if g.resist then
    local list = u.resistances or {}
    if #list == 0 then list = {{type = "physical", percent = 0}} end
    for _, res in pairs(list) do res.percent = math.min(95, (res.percent or 0) + g.resist * r) end
    u.resistances = list
  end
end

local tool_filters = {}
local new = {}
for _, d in pairs(shared.droids) do
  local base = data.raw.unit[d.unit]
  if base and (not d.external or data.raw.recipe[d.deploy]) then
    tool_filters[#tool_filters + 1] = d.unit
    if not d.external then
      base.custom_tooltip_fields = tooltip(base, d.unit, 0)
      local item = data.raw.item[d.unit]
      if item then item.custom_tooltip_fields = util.table.deepcopy(base.custom_tooltip_fields) end
    end
    for r = 1, #shared.rank_kills do
      local u = util.table.deepcopy(base)
      u.name = shared.rank_name(d.unit, r)
      u.localised_name = {"robotarmy-rank.unit-name", base.localised_name or {"entity-name." .. d.unit}, {"robotarmy-rank.rank-in-name-" .. r}}
      u.localised_description = base.localised_description or {"?", {"entity-description." .. d.unit}, ""}
      u.icons = rank_icons(base, r)
      u.icon, u.icon_size = nil, nil
      u.minable = nil -- only a drop pod carries a rank droid
      u.hidden_in_factoriopedia = true
      -- not listed in the tooltips of the ammo research (the bonuses of the ammo category still apply)
      u.hidden = true
      u.order = (base.order or "") .. "-r" .. r
      grow(u, d.growth or {health = 0.1, damage = 0.1}, r)
      u.custom_tooltip_fields = tooltip(u, d.unit, r)
      new[#new + 1] = u
      tool_filters[#tool_filters + 1] = u.name
    end
  end
end
data:extend(new)

-- Insignia of HeroTurrets over rank droids (the files stay in that mod; without it: star and number).
if mods["HeroTurretRedux"] then
  local sprites = {}
  for r = 1, #shared.rank_kills do
    sprites[r] = {
      type = "sprite",
      name = shared.rank_sprite_prefix .. r,
      filename = "__HeroTurretRedux__/graphics/entity/turret/hero-" .. r .. "-base.png",
      width = 23,
      height = 24,
      priority = "extra-high-no-scale",
    }
  end
  data:extend(sprites)
end

local tool = data.raw["selection-tool"][shared.tool]
for _, mode in pairs({"select", "reverse_select", "alt_reverse_select"}) do
  tool[mode].entity_filters = tool_filters
end
