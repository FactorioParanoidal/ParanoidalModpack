local data_util = require("prototypes/data-util")

data:extend({
  {
    type = "trigger-target-type",
    name = "common", -- exists in base
  },
  {
    type = "trigger-target-type",
    name = "ground-unit", -- exists in base, opposite of flying but can move, cars, player, etc.
  },
  {
    type = "trigger-target-type",
    name = "ground-static", --  opposite of flying but can't move, turrets, walls, etc.
  },
  {
    type = "trigger-target-type",
    name = "rock", -- rocks
  },
  {
    type = "trigger-target-type",
    name = "tree", -- trees
  },
  {
    type = "trigger-target-type",
    name = "flying", -- flying vehicles, units, characters, combat robots, logistic robots,
  },
  {
    type = "trigger-target-type",
    name = "biological", -- trees, characters, biters, spawners, worms, cyborgs
  },
  {
    type = "trigger-target-type",
    name = "mechanical", -- vehicles, turrets, robots, etc
  }
})

for _, prototype in pairs(data.raw.unit) do
  prototype.trigger_target_mask = prototype.trigger_target_mask or {}
  if string.find(prototype.name, "biter", 1, true) or string.find(prototype.name, "spitter", 1, true) then
    if not data_util.table_contains(prototype.trigger_target_mask, "biological") then
      table.insert(prototype.trigger_target_mask, "biological")
    end
  else
    if not data_util.table_contains(prototype.trigger_target_mask, "biological") then
      table.insert(prototype.trigger_target_mask, "mechanical")
    end
  end
end

for _, prototype in pairs(data.raw.fire) do
  if string.find(prototype.name, "acid-splash", 1, true) then
    prototype.trigger_target_mask = {"ground-unit", "rock", "tree"}
    if settings.startup["pools-affect-structures"].value then
      table.insert(prototype.trigger_target_mask, "ground-static")
    end
    if settings.startup["pools-affect-flying"].value then
      table.insert(prototype.on_damage_tick_effect.trigger_target_mask, "flying")
      log("Pools affect flying " .._)
    end
    prototype.force_condition = "not-same" -- affect rocks trees
  end
end

local function trigger_target_defaults_add(type_name, additions)
  additions = type(additions) == "table" and additions or {additions}
  data.raw["utility-constants"].default.default_trigger_target_mask_by_type[type_name] =
  data.raw["utility-constants"].default.default_trigger_target_mask_by_type[type_name] or {}
  local defaults = data.raw["utility-constants"].default.default_trigger_target_mask_by_type[type_name]
  for _, addition in pairs(additions) do
    if not data_util.table_contains(defaults, addition) then
      table.insert(defaults, addition)
    end
  end
end

trigger_target_defaults_add("character", {"common", "ground-unit", "biological"})
trigger_target_defaults_add("car", {"common", "ground-unit", "mechanical"})
trigger_target_defaults_add("unit", {"common", "ground-unit", "mechanical"})
trigger_target_defaults_add("combat-robot", {"common", "flying", "mechanical"})
trigger_target_defaults_add("logistic-robot", {"common", "flying", "mechanical"})
trigger_target_defaults_add("construction-robot", {"common", "flying", "mechanical"})
trigger_target_defaults_add("turret", {"common", "ground-static", "biological"})
trigger_target_defaults_add("ammo-turret", {"common", "ground-static", "mechanical"})
trigger_target_defaults_add("electric-turret", {"common", "ground-static", "mechanical"})
trigger_target_defaults_add("fluid-turret", {"common", "ground-static", "mechanical"})
trigger_target_defaults_add("artillery-turret", {"common", "ground-static", "mechanical"})
trigger_target_defaults_add("wall", {"common", "ground-static"})
