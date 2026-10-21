local shared = require("prototypes.shared")
local util = require("util")

local raw = data.raw
local unlock = shared.unlock

-- Unlocks in existing technologies (Beta 8 placement; fusion-reactor-equipment is fission-reactor-equipment in 2.0).
for _, recipe in pairs({"explosive-autocannon-shell", "Schall-tank-L", "Schall-tank-M"}) do
  unlock("tank", recipe)
end
for _, recipe in pairs({
  "Schall-sniper-uranium-rounds-magazine",
  "uranium-cannon-H1-shell", "uranium-cannon-H2-shell",
  "explosive-uranium-cannon-H1-shell", "explosive-uranium-cannon-H2-shell",
  "explosive-uranium-autocannon-shell",
}) do
  unlock("uranium-ammo", recipe)
end
unlock("rocketry", "Schall-incendiary-rocket")
unlock("fission-reactor-equipment", "fusion-reactor-2-equipment")
unlock("fission-reactor-equipment", "fusion-reactor-3-equipment")

if shared.setting("vehicle-energy-shield-enable") then
  unlock("energy-shield-equipment", "vehicle-energy-shield-equipment")
  unlock("energy-shield-mk2-equipment", "vehicle-energy-shield-mk2-equipment")
end
if shared.setting("vehicle-battery-enable") then
  unlock("battery-equipment", "vehicle-battery-equipment")
  unlock("battery-mk2-equipment", "vehicle-battery-mk2-equipment")
end
if shared.setting("vehicle-fuel-cell-enable") then
  for size = 2, 4 do
    unlock("electric-engine", "vehicle-fuel-cell-" .. size .. "-equipment")
  end
end
if shared.setting("vehicle-nuclear-reactor-enable") then
  unlock("nuclear-power", "vehicle-nuclear-reactor-equipment")
end

-- Vanilla tank recipe.
if not shared.setting("tank-to-recipe-keep") then
  local technology = raw.technology["tank"]
  if technology and technology.effects then
    for index = #technology.effects, 1, -1 do
      local effect = technology.effects[index]
      if effect.type == "unlock-recipe" and effect.recipe == "tank" then
        table.remove(technology.effects, index)
      end
    end
  end
  if raw.recipe["tank"] then
    raw.recipe["tank"].enabled = false
    raw.recipe["tank"].hidden = true
  end
end

-- Vanilla tank guns as in Beta 8.
local function set_attack(gun_name, values)
  local gun = raw.gun[gun_name]
  if not gun then return end
  for key, value in pairs(values) do
    gun.attack_parameters[key] = value
  end
end
set_attack("tank-flamethrower", {range = 15})
set_attack("tank-cannon", {range = 27, min_range = 5, damage_modifier = 1.5})
set_attack("tank-machine-gun", {damage_modifier = 1.5})

local flamethrower_ammo = raw.ammo["flamethrower-ammo"]
if flamethrower_ammo and flamethrower_ammo.ammo_type then
  for _, ammo_type in pairs(flamethrower_ammo.ammo_type) do
    if type(ammo_type) == "table" and ammo_type.source_type == "vehicle" then
      ammo_type.consumption_modifier = 1
      local delivery = ammo_type.action and ammo_type.action.action_delivery
      if delivery and shared.setting("tank-flamethrower-fire-stream-incendiary") then
        delivery.stream = "handheld-flamethrower-fire-stream"
      end
    end
  end
end

-- Friendly fire of the vanilla 75 mm shells follows the cannon setting, as for the new shells.
local cannon_force = shared.setting("tank-cannon-force-condition")
for _, name in pairs({"cannon-projectile", "uranium-cannon-projectile", "explosive-cannon-projectile", "explosive-uranium-cannon-projectile"}) do
  if raw.projectile[name] then
    raw.projectile[name].force_condition = cannon_force
  end
end

-- Stone walls and gates resist electric damage like laser damage.
for _, wall in pairs({raw.wall["stone-wall"], raw.gate["gate"]}) do
  if wall then
    wall.resistances = wall.resistances or {}
    local has_electric, laser_percent = false, 70
    for _, resistance in pairs(wall.resistances) do
      if resistance.type == "electric" then has_electric = true end
      if resistance.type == "laser" and resistance.percent then laser_percent = resistance.percent end
    end
    if not has_electric then
      table.insert(wall.resistances, {type = "electric", percent = laser_percent})
    end
  end
end

-- Personal equipment.
local discharge = raw["active-defense-equipment"]["discharge-defense-equipment"]
if discharge then
  discharge.automatic = shared.setting("discharge-defense-equipment-automatic")
end

local laser_defense = raw["active-defense-equipment"]["personal-laser-defense-equipment"]
local ammo_type = laser_defense and laser_defense.attack_parameters and laser_defense.attack_parameters.ammo_type
if ammo_type then
  local shot = shared.setting("personal-laser-defense-equipment-energy-consumption")
  ammo_type.energy_consumption = shot
  local shot_energy = util.parse_energy(shot)
  local source = laser_defense.energy_source
  if source and (not source.buffer_capacity or util.parse_energy(source.buffer_capacity) < shot_energy) then
    source.buffer_capacity = string.format("%dJ", math.floor(shot_energy * 1.1))
  end
else
  log("[paranoidal-tank-platoon] personal-laser-defense-equipment ammo_type not found; shot energy unchanged")
end

if not shared.setting("vehicle-hide-resistances") then
  for _, vehicle in pairs({raw.car["car"], raw.car["tank"], raw["spider-vehicle"]["spidertron"]}) do
    if vehicle then vehicle.hide_resistances = false end
  end
end
