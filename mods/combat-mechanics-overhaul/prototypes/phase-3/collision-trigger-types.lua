--[[
TODO: can't seem to make spider-vehicle collide with projectiles.
]]

-- This layer is used to make certain projectiles collide with not-friend walls.
-- If you have a mod with similar functionality you are encoureaged to use the same layer.
--use force_condition = "not-friend" or "not-same" on the projectile.
local data_util = require("prototypes/data-util")

-- get a collision layer by name, if the name is not assigned to a layer it will assign one
local flying_layer = collision_mask_util_extended.get_make_named_collision_mask("flying-layer")
local projectile_layer = collision_mask_util_extended.get_make_named_collision_mask("projectile-layer")
local vehicle_layer = collision_mask_util_extended.get_make_named_collision_mask("vehicle-layer")

local suffix = "-blockable"

local function add_collision_to_entity(prototype, projectile_layer)
  prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
  collision_mask_util_extended.add_layer(prototype.collision_mask, projectile_layer)
end

local function make_unit_projectile_blockable (unit)
  if unit.attack_parameters.ammo_type
      and unit.attack_parameters.ammo_type.action
      and unit.attack_parameters.ammo_type.action.action_delivery
      and unit.attack_parameters.ammo_type.action.action_delivery.type
      and unit.attack_parameters.ammo_type.action.action_delivery.type == "projectile" then

        unit.attack_parameters.ammo_type.target_type = "position"
        local projectile_name = unit.attack_parameters.ammo_type.action.action_delivery.projectile
        local projectile = data.raw.projectile[projectile_name]
        if projectile then
          projectile.collision_box = projectile.collision_box or { { -0.05, -0.25 }, { 0.05, 0.25 } }
          projectile.hit_collision_mask = {projectile_layer, flying_layer, "player-layer", "train-layer", "not-colliding-with-itself"}
          projectile.force_condition = "not-friend"
        end
  end
end

local function make_unit_projectile_from_stream (unit)
  if unit.attack_parameters.ammo_type
      and unit.attack_parameters.ammo_type.action
      and unit.attack_parameters.ammo_type.action.action_delivery
      and unit.attack_parameters.ammo_type.action.action_delivery.type
      and unit.attack_parameters.ammo_type.action.action_delivery.type == "stream" then

      unit.attack_parameters.type = "projectile"
      unit.attack_parameters.ammo_type.target_type = "position"

      -- do the stuff
      local stream_name = unit.attack_parameters.ammo_type.action.action_delivery.stream
      local projectile_name =  stream_name .. "-blockable"
      unit.attack_parameters.ammo_type.action.action_delivery = {
              max_range = unit.attack_parameters.ammo_type.action.action_delivery.max_range or ((unit.attack_parameters.range or 16 ) * 1.5),
              projectile = projectile_name,
              starting_speed = unit.attack_parameters.ammo_type.action.action_delivery.starting_speed or 0.5,
              type = "projectile"
      }

      local stream_prototype = data.raw.stream[stream_name]
      local projectile = {
        acceleration = 0.005,
        action = table.deepcopy(stream_prototype.initial_action),
        animation = stream_prototype.particle,
        collision_box = { { -0.05, -0.25 }, { 0.05, 0.25 } },
        hit_collision_mask = {projectile_layer, flying_layer, "player-layer", "train-layer", "not-colliding-with-itself"},
        force_condition = "not-friend", --don't hit trees, trees are like the biters walls "not-same",
        direction_only = false,
        flags = { "not-on-map" },
        name = projectile_name,
        rotatable = true,
        shadow = stream_prototype.shadow,
        type = "projectile"
      }
      if projectile.action then
        for _, action in pairs(projectile.action) do
          if action.force == "enemy" then
            action.force = "not-same" -- allow damage to rocks and trees if they are the direct target
          end
        end
      end

      data:extend({projectile})
  end

end

for _, prototype in pairs(data.raw.projectile) do
  if not prototype.cmo_ignore then
    if (not prototype.collision_box) and (
      not (
          string.find(prototype.name, "atomic-bomb", 1, true)
          or string.find(prototype.name, "antimatter-bomb", 1, true) -- Krastorio 2 compatibility
          or string.find(prototype.name, "artillery", 1, true)
        )
      ) and (
        (settings.startup["rockets-blockable"].value and string.find(prototype.name, "rocket", 1, true))
      or string.find(prototype.name, "bomb", 1, true)
      or string.find(prototype.name, "shell", 1, true)
    ) then
      prototype.collision_box = { { -0.05, -0.25 }, { 0.05, 0.25 } }
    end
    if prototype.collision_box and not prototype.hit_collision_mask then
      prototype.hit_collision_mask = collision_mask_util_extended.get_default_hit_mask("projectile")
    end
    if prototype.hit_collision_mask then
      if ( string.find(prototype.name, "bomb", 1, true)
        or string.find(prototype.name, "rocket", 1, true)
        --or string.find(prototype.name, "pellet", 1, true)
        or string.find(prototype.name, "shell", 1, true)
        or string.find(prototype.name, "bullet", 1, true)
        or string.find(prototype.name, "round", 1, true)
        or string.find(prototype.name, "-ammo", 1, true)
        or string.find(prototype.name, "magazine", 1, true)
        or string.find(prototype.name, "cannon", 1, true)
      ) and (not string.find(prototype.name, "shockwave", 1, true)) then
        prototype.force_condition = "not-same" -- allow to hit rocks
      end

      if not settings.startup["shotguns-hit-friendly"].value
        and string.find(prototype.name, "pellet", 1, true) then
          prototype.force_condition = "not-same" -- allow to hit rocks
      end

      if data_util.table_contains(prototype.hit_collision_mask, "player-layer") then -- allow hitting trees too
        table.insert(prototype.hit_collision_mask, vehicle_layer)
      end

      if not data_util.table_contains(prototype.hit_collision_mask, projectile_layer) then
        table.insert(prototype.hit_collision_mask, projectile_layer)
      end
      if not data_util.table_contains(prototype.hit_collision_mask, flying_layer) then
        table.insert(prototype.hit_collision_mask, flying_layer)
      end
      if not data_util.table_contains(prototype.hit_collision_mask, "not-colliding-with-itself") then
        table.insert(prototype.hit_collision_mask, "not-colliding-with-itself")
      end
    end
  end
end

-- setup trigger type
for _, type in pairs({"accumulator", "arithmetic-combinator", "turret", "electric-turret", "fluid-turret", "unit-spawner", "artillery-turret", "assembling-machine",
  "beacon", "boiler", "burner-generator","constant-combinator","container","curved-rail","decider-combinator","electric-energy-interface","electric-pole",
  "furnace","gate","generator","heat-interface","heat-pipe", "infinity-container","infinity-pipe","inserter", "lab", "lamp", "land-mine", "loader", "loader-1x1",
  "logistic-container", "market", "mining-drill", "offshore-pump", "pipe", "pipe-to-ground", "player-port", "power-switch", "programmable-speaker", "pump",
  "rail-chain-signal", "rail-signal", "reactor", "roboport", "rocket-silo", "simple-entity", "simple-entity-with-force", "simple-entity-with-owner", "solar-panel",
  "splitter", "storage-tank", "straight-rail", "train-stop", "transport-belt", "tree", "underground-belt", "wall"
}) do
  for _, prototype in pairs(data.raw[type]) do
    prototype.trigger_target_mask = prototype.trigger_target_mask or {}
    if not data_util.table_contains(prototype.trigger_target_mask, "ground-static") then
      table.insert(prototype.trigger_target_mask, "ground-static")
    end
  end
end

-- make vehicles collide with trees and pipes (train-layer)
-- stop characters colliding with pipes (player-layer)
for _, type in pairs({"pipe", "pipe-to-ground"}) do
  for _, prototype in pairs(data.raw[type]) do
    prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
    collision_mask_util_extended.remove_layer(prototype.collision_mask, "player-layer")
    collision_mask_util_extended.add_layer(prototype.collision_mask, collision_mask_util_extended.get_make_named_collision_mask("vehicle-layer"))
  end
end

-- make projectiles hit
for _, type in pairs({"wall", "ammo-turret", "turret", "electric-turret", "fluid-turret", "unit-spawner", "artillery-turret",
  }) do
  for _, prototype in pairs(data.raw[type]) do
    add_collision_to_entity(prototype, projectile_layer)
  end
end

for _, prototype in pairs(data.raw.tree) do
  prototype.trigger_target_mask = prototype.trigger_target_mask or {}
  if not data_util.table_contains(prototype.trigger_target_mask, "ground-static") then
    table.insert(prototype.trigger_target_mask, "ground-static")
  end
  if string.find(prototype.name, "tree", 1, true) then
    add_collision_to_entity(prototype, projectile_layer)
    if not data_util.table_contains(prototype.trigger_target_mask, "tree") then
      table.insert(prototype.trigger_target_mask, "tree")
    end
  end
end
for _, prototype in pairs(data.raw["simple-entity"]) do
  prototype.trigger_target_mask = prototype.trigger_target_mask or {}
  if not data_util.table_contains(prototype.trigger_target_mask, "ground-static") then
    table.insert(prototype.trigger_target_mask, "ground-static")
  end
  if string.find(prototype.name, "rock", 1, true) then
    add_collision_to_entity(prototype, projectile_layer)
    if not data_util.table_contains(prototype.trigger_target_mask, "rock") then
      table.insert(prototype.trigger_target_mask, "rock")
    end
  end
end

-- also assign corect trigger-target type

for _, type in pairs({"car", "character", "unit", "spider-vehicle", "combat-robot", "logistic-robot", "construction-robot",
  "artillery-wagon", "cargo-wagon", "fluid-wagon", "locomotive", "fish"}) do
  for _, prototype in pairs(data.raw[type]) do
    prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
    if collision_mask_util_extended.is_mask_empty(prototype.collision_mask) or data_util.table_contains(prototype.collision_mask, flying_layer) then
      -- this appears to be a flying thing
      prototype.collision_mask = prototype.collision_mask or {flying_layer}
      table.insert(prototype.collision_mask, "not-colliding-with-itself")
      prototype.trigger_target_mask = prototype.trigger_target_mask or {}
      if type == "spider-vehicle" then
        if not data_util.table_contains(prototype.trigger_target_mask, "ground-unit") then
          table.insert(prototype.trigger_target_mask, "ground-unit")
        end
      else
        if not data_util.table_contains(prototype.trigger_target_mask, "flying") then
          table.insert(prototype.trigger_target_mask, "flying")
        end
      end
    else
      prototype.trigger_target_mask = prototype.trigger_target_mask or {}
      if not data_util.table_contains(prototype.trigger_target_mask, "ground-unit") then
        table.insert(prototype.trigger_target_mask, "ground-unit")
      end
    end
  end
end

for _, type in pairs({"character", "unit"}) do
  for _, prototype in pairs(data.raw[type]) do
    if not string.find(prototype.name, "proxy", 1, true) then -- proxy = fake player?
      prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
      if collision_mask_util_extended.is_mask_empty(prototype.collision_mask) or data_util.table_contains(prototype.collision_mask, flying_layer) then
        -- this appears to be a flying thing
        prototype.collision_mask = {flying_layer, "not-colliding-with-itself"}
        prototype.trigger_target_mask = prototype.trigger_target_mask or {}
        if not data_util.table_contains(prototype.trigger_target_mask, "flying") then
          table.insert(prototype.trigger_target_mask, "flying")
        end
      else
        --add_collision_to_entity(prototype, "player-layer") -- not relaly needed?
        prototype.trigger_target_mask = prototype.trigger_target_mask or {}
        if not data_util.table_contains(prototype.trigger_target_mask, "ground-unit") then
          table.insert(prototype.trigger_target_mask, "ground-unit")
        end
      end
    end
  end
end

-- biters
for _, unit in pairs(data.raw.unit) do
  if string.find(unit.name, "spitter", 1, true) then
    if unit.attack_parameters and settings.startup["spitter-spit-blockable"].value then
      unit.attack_parameters.min_attack_distance = nil
      if unit.attack_parameters.cooldown then
        unit.attack_parameters.cooldown = unit.attack_parameters.cooldown * 0.75
      end
      if unit.attack_parameters.warmup then
        unit.attack_parameters.warmup = unit.attack_parameters.warmup * 0.75
      end
      make_unit_projectile_blockable(unit)
      make_unit_projectile_from_stream(unit)
    end
  end
end

-- turrets
for _, turret in pairs(data.raw.turret) do
  if string.find(turret.name, "worm", 1, true) then
    if settings.startup["worm-spit-blockable"].value then
      make_unit_projectile_blockable(turret)
      make_unit_projectile_from_stream(turret)
    end
  end
end

collision_mask_util_extended.named_collision_mask_integrity_check()
