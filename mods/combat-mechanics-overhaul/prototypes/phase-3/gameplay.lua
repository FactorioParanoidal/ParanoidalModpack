local unit_speed = settings.startup["unit-speed"].value / 100
local unit_health = settings.startup["unit-health"].value / 100
local unit_range = settings.startup["unit-range"].value / 100
local worm_health = settings.startup["worm-health"].value / 100
local worm_range = settings.startup["worm-range"].value / 100
local spawner_health = settings.startup["spawner-health"].value / 100

-- biters
for _, unit in pairs(data.raw.unit) do
  if string.find(unit.name, "biter", 1, true) then
    if unit.movement_speed then
      unit.movement_speed = unit.movement_speed * unit_speed
    end
    if unit.max_health and unit.max_health > 0 then
      unit.max_health = math.ceil(unit.max_health * unit_health)
    end
  elseif string.find(unit.name, "spitter", 1, true) then
    if unit.movement_speed then
      unit.movement_speed = unit.movement_speed * unit_speed
    end
    if unit.max_health and unit.max_health > 0 then
      unit.max_health = math.ceil(unit.max_health * unit_health)
    end
    if unit.attack_parameters then
      unit.attack_parameters.range = unit.attack_parameters.range * unit_range
    end
  end
end

-- turrets
for _, turret in pairs(data.raw.turret) do
  if string.find(turret.name, "worm", 1, true) then
    if turret.max_health and turret.max_health > 0 then
      turret.max_health =  math.ceil(turret.max_health * worm_health)
    end
    if turret.attack_parameters and turret.attack_parameters.range then
      turret.attack_parameters.range = turret.attack_parameters.range * worm_range
      turret.attack_parameters.prepare_range = math.max(
        (turret.attack_parameters.prepare_range or 0) * worm_range,
        turret.attack_parameters.range * 1.1 + 5
      )
    end
  end
end

-- spawners
for _, spawner in pairs(data.raw["unit-spawner"]) do
  if string.find(spawner.name, "spawner", 1, true) then
    if spawner.max_health and spawner.max_health > 0 then
      spawner.max_health = math.ceil(spawner.max_health * spawner_health)
    end
  end
end
