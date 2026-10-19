-- Kinds of catalog entries in content/*.lua and scripted.lua: one engine achievement type each.
--   resolve(entry)  finds the targets; returns nil and a reason when the entry cannot work in this mod set
--   apply(achievement, entry, target, amount)  sets the fields of the engine type
--   describe(entry, target, amount)  generated description; kinds without it use
--                   {"mxlr-description.<description or name_key or id>", amount text, target label}
-- Target: {prototype, family, quality, label (localised, for names and descriptions), icon_prototype}.

local util = require("prototypes.util")

local kinds = {}

local TICKS_PER_HOUR = 216000

local function one_or_list(list)
  if #list == 1 then return list[1] end
  return list
end

local function target_of(prototype, family, quality)
  return {
    prototype = prototype,
    family = family,
    quality = quality,
    name_label = util.name_of(prototype, family),
    label = util.text_of(prototype, family, quality),
  }
end

local function resolve_quality(entry)
  if not entry.quality then return true end
  if not util.available(util.quality(entry.quality)) then
    return false, "quality " .. entry.quality .. " is missing or hidden"
  end
  return true
end

-- Item (or fluid with entry.fluid) that something can produce.
local function resolve_product(entry)
  local ok, reason = resolve_quality(entry)
  if not ok then return nil, reason end
  if entry.fluid then
    local fluid = util.first(entry.fluid, util.fluid, true)
    if not fluid then return nil, "fluid is missing, hidden or not producible" end
    return target_of(fluid, "fluid")
  end
  local item = util.first(entry.item, util.item, true)
  if not item then return nil, "item is missing, hidden or not producible" end
  return target_of(item, "item", entry.quality)
end

local function resolve_item(entry, field)
  local ok, reason = resolve_quality(entry)
  if not ok then return nil, reason end
  local item = util.first(entry[field], util.item)
  if not item then return nil, field .. " item is missing or hidden" end
  local quality = entry.quality ~= "normal" and entry.quality or nil
  return target_of(item, "item", quality)
end

-- A list of entities given as a name, a list of names or {names, patterns, types, exclude}.
local function entity_list(spec)
  if spec == nil then return nil end
  if type(spec) == "string" then spec = {names = {spec}} end
  if spec[1] then spec = {names = spec} end
  return util.entities(spec)
end

local function describe_count(single_key, many_key)
  return function(_, target, amount)
    if (amount or 1) <= 1 then return {single_key, target.label} end
    return {many_key, util.number_text(amount), target.label}
  end
end

kinds["produce"] = {
  type = "produce-achievement",
  resolve = resolve_product,
  apply = function(achievement, entry, target, amount)
    if target.family == "fluid" then
      achievement.fluid_product = target.prototype.name
    elseif entry.quality then
      achievement.item_product = {name = target.prototype.name, quality = entry.quality}
    else
      achievement.item_product = target.prototype.name
    end
    achievement.amount = amount
    achievement.limited_to_one_game = false
  end,
  describe = function(_, target, amount)
    return {"mxlr.produce", util.number_text(amount), target.label}
  end,
}

kinds["produce-per-hour"] = {
  type = "produce-per-hour-achievement",
  resolve = resolve_product,
  apply = function(achievement, entry, target, amount)
    kinds["produce"].apply(achievement, entry, target, amount)
    achievement.limited_to_one_game = nil
  end,
  describe = function(_, target, amount)
    return {"mxlr.produce-per-hour", util.number_text(amount), target.label}
  end,
}

kinds["build"] = {
  type = "build-entity-achievement",
  resolve = function(entry)
    local name = entry.entity
    if not name and entry.item then
      local item = util.item(entry.item)
      name = item and item.place_result
    end
    local entity = util.first(name, util.entity)
    if not entity then return nil, "entity is missing or hidden" end
    if not util.placeable(entity.name) then return nil, "no item places " .. entity.name end
    return target_of(entity, "entity")
  end,
  apply = function(achievement, entry, target, amount)
    achievement.to_build = target.prototype.name
    achievement.amount = amount
    achievement.limited_to_one_game = false
    if entry.hours then achievement.within = entry.hours * TICKS_PER_HOUR end
  end,
  describe = function(entry, target, amount)
    if entry.hours then return {"mxlr.build-within", target.label, tostring(entry.hours)} end
    return describe_count("mxlr.build", "mxlr.build-many")(entry, target, amount)
  end,
}

kinds["kill"] = {
  type = "kill-achievement",
  fight = true,
  resolve = function(entry)
    local target = {label = entry.label and {"mxlr-target." .. entry.label}}
    target.name_label = target.label
    if entry.to_kill then
      target.to_kill = entity_list(entry.to_kill)
      if #target.to_kill == 0 then return nil, "no entity to kill" end
      target.prototype = util.entity(target.to_kill[1])
    end
    if entry.damage_dealer then
      target.damage_dealer = entity_list(entry.damage_dealer)
      if #target.damage_dealer == 0 then return nil, "no damage dealer" end
      target.prototype = target.prototype or util.entity(target.damage_dealer[1])
    end
    if entry.damage_type and not (data.raw["damage-type"] or {})[entry.damage_type] then
      return nil, "damage type " .. entry.damage_type .. " is missing"
    end
    if not (target.to_kill or entry.type_to_kill) then return nil, "kill entry without a target" end
    if not (target.prototype or target.label) then return nil, "kill entry without a label" end
    target.family = "entity"
    target.label = target.label or util.text_of(target.prototype, "entity")
    target.name_label = target.name_label or util.name_of(target.prototype, "entity")
    return target
  end,
  apply = function(achievement, entry, target, amount)
    achievement.to_kill = target.to_kill and one_or_list(target.to_kill)
    achievement.type_to_kill = entry.type_to_kill
    achievement.damage_dealer = target.damage_dealer and one_or_list(target.damage_dealer)
    achievement.damage_type = entry.damage_type
    achievement.in_vehicle = entry.in_vehicle
    achievement.personally = entry.personally
    achievement.amount = amount
  end,
}

kinds["research"] = {
  type = "research-achievement",
  resolve = function(entry)
    local technology = util.first(entry.technology, util.technology)
    if not technology then return nil, "technology is missing or hidden" end
    return target_of(technology, "technology")
  end,
  apply = function(achievement, _, target)
    achievement.technology = target.prototype.name
  end,
  describe = function(_, target) return {"mxlr.research", target.label} end,
}

kinds["science"] = {
  type = "research-with-science-pack-achievement",
  resolve = function(entry) return resolve_item(entry, "item") end,
  apply = function(achievement, _, target, amount)
    achievement.science_pack = target.prototype.name
    achievement.amount = amount
  end,
  describe = describe_count("mxlr.science", "mxlr.science-many"),
}

kinds["use-item"] = {
  type = "use-item-achievement",
  resolve = function(entry) return resolve_item(entry, "item") end,
  apply = function(achievement, entry, target, amount)
    achievement.to_use = target.prototype.name
    achievement.limit_quality = entry.quality or "normal"
    achievement.amount = amount
    achievement.limited_to_one_game = false
  end,
  describe = describe_count("mxlr.use", "mxlr.use-many"),
}

kinds["equip"] = {
  type = "equip-armor-achievement",
  resolve = function(entry) return resolve_item(entry, "item") end,
  apply = function(achievement, entry, target)
    achievement.armor = target.prototype.name
    achievement.alternative_armor = target.prototype.name
    achievement.limit_quality = entry.quality or "normal"
    achievement.limited_to_one_game = false
  end,
  describe = function(_, target) return {"mxlr.equip", target.label} end,
}

kinds["shoot"] = {
  type = "shoot-achievement",
  fight = true,
  resolve = function(entry) return resolve_item(entry, "item") end,
  apply = function(achievement, _, target, amount)
    achievement.ammo_type = target.prototype.name
    achievement.amount = amount
  end,
  describe = function(_, target, amount)
    return {"mxlr.shoot", util.number_text(amount), target.label}
  end,
}

local function robot_kind(type_name, key, extra)
  return {
    type = type_name,
    resolve = function() return {label = "", name_label = ""} end,
    apply = function(achievement, _, _, amount)
      achievement.amount = amount
      if extra then extra(achievement) end
    end,
    describe = function(_, _, amount) return {key, util.number_text(amount)} end,
  }
end

kinds["robots-construct"] = robot_kind("construct-with-robots-achievement", "mxlr.robots-construct",
  function(achievement) achievement.limited_to_one_game = false end)
kinds["robots-deconstruct"] = robot_kind("deconstruct-with-robots-achievement", "mxlr.robots-deconstruct")
kinds["robots-deliver"] = robot_kind("deliver-by-robots-achievement", "mxlr.robots-deliver")

kinds["combat-robots"] = {
  type = "combat-robot-count-achievement",
  resolve = function() return {label = "", name_label = ""} end,
  apply = function(achievement, _, _, amount) achievement.count = amount end,
  describe = function(_, _, amount) return {"mxlr.combat-robots", util.number_text(amount)} end,
}

kinds["damaged"] = {
  type = "player-damaged-achievement",
  resolve = function(entry)
    if entry.dealer_type and not data.raw[entry.dealer_type] then return nil, "no entity type " .. entry.dealer_type end
    return {label = "", name_label = ""}
  end,
  apply = function(achievement, entry, _, amount)
    achievement.minimum_damage = amount
    achievement.should_survive = entry.survive == true
    achievement.type_of_dealer = entry.dealer_type
  end,
}

kinds["group-attack"] = {
  type = "group-attack-achievement",
  fight = true,
  resolve = function() return {label = "", name_label = ""} end,
  apply = function(achievement, _, _, amount) achievement.amount = amount end,
}

kinds["dont-build"] = {
  type = "dont-build-entity-achievement",
  resolve = function(entry)
    local list = entity_list(entry.entities)
    if #list == 0 then return nil, "nothing to avoid" end
    return {list = list, prototype = util.entity(list[1]), family = "entity", label = "", name_label = ""}
  end,
  apply = function(achievement, entry, target)
    achievement.dont_build = target.list
    achievement.objective_condition = entry.objective or "rocket-launched"
  end,
}

kinds["dont-craft"] = {
  type = "dont-craft-manually-achievement",
  resolve = function() return {label = "", name_label = ""} end,
  apply = function(achievement, entry, _, amount)
    achievement.amount = amount
    achievement.objective_condition = entry.objective or "rocket-launched"
  end,
}

-- Complete the objective within entry.amounts hours.
kinds["objective"] = {
  type = "complete-objective-achievement",
  resolve = function() return {label = "", name_label = ""} end,
  apply = function(achievement, entry, _, hours)
    achievement.objective_condition = entry.objective or "rocket-launched"
    achievement.within = hours * TICKS_PER_HOUR
  end,
  amount_text = function(hours) return tostring(hours) end,
}

kinds["energy"] = {
  type = "use-entity-in-energy-production-achievement",
  resolve = function(entry)
    local entity = util.first(entry.entity, util.entity)
    if not entity then return nil, "entity is missing or hidden" end
    if not util.placeable(entity.name) then return nil, "no item places " .. entity.name end
    return target_of(entity, "entity")
  end,
  apply = function(achievement, _, target) achievement.entity = target.prototype.name end,
  describe = function(_, target) return {"mxlr.energy", target.label} end,
}

-- Unlocked by control.lua; the data stage only checks that the required mods and prototypes exist.
kinds["script"] = {
  type = "achievement",
  resolve = function(entry)
    local needs = entry.needs or {}
    for _, name in ipairs(needs.entities or {}) do
      if not util.available(util.entity(name)) then return nil, "entity " .. name .. " is missing" end
    end
    for _, name in ipairs(needs.items or {}) do
      if not util.available(util.item(name)) then return nil, "item " .. name .. " is missing" end
    end
    for _, name in ipairs(needs.technologies or {}) do
      if not util.available(util.technology(name)) then return nil, "technology " .. name .. " is missing" end
    end
    if needs.any_entity and #entity_list(needs.any_entity) == 0 then return nil, "no matching entity" end
    if needs.any_item then
      local found = false
      for _, name in ipairs(needs.any_item) do
        if util.available(util.item(name)) then found = true break end
      end
      if not found then return nil, "no matching item" end
    end
    return {label = "", name_label = ""}
  end,
  apply = function(achievement, entry)
    if entry.fight then achievement.allowed_without_fight = false end
  end,
}

-- Default icon source of a resolved target: its own prototype when it has icons.
function kinds.icon_layers(entry, target)
  local spec = entry.icon
  if spec then
    if spec.file then
      return {{icon = util.GRAPHICS .. spec.file, icon_size = spec.size or 128, scale = 64 / (spec.size or 128) * 0.7}}
    end
    for _, family in ipairs({"item", "entity", "fluid", "technology"}) do
      if spec[family] then
        local prototype = util[family](spec[family])
        if prototype then return util.icon_layers(prototype, family) end
        return nil
      end
    end
  end
  if target and target.prototype then
    local layers = util.icon_layers(target.prototype, target.family)
    if layers then return layers end
    if target.family == "entity" then
      local item = util.item(target.prototype.name)
      if item then return util.icon_layers(item, "item") end
    end
  end
end

return kinds
