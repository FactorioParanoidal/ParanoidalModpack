util = require("util")

local flammable_types = {}

-- Initialize the local flammable_types table
local init_flammable_types = function()
  --look through all fluids
  local fluids = prototypes.fluid
  gas_types = {}
  for name, fluid in pairs(fluids) do
    --Fluid is flammable if it has ful value
    if fluid.fuel_value and fluid.fuel_value > 0 then
      flammable_types[name] = true
    else
      flammable_types[name] = false
    end


    --Fluid is gas if it's temperature is > gas temperature
    if fluid.default_temperature and fluid.gas_temperature and fluid.default_temperature > fluid.gas_temperature then
      gas_types[name] = true
    else
      if string.find(fluid.name, "gasoline") == nil and (string.find(fluid.name, "-gas") ~= nil or string.find(fluid.name, "gas-") ~= nil) then
        gas_types[name] = true
      else
        gas_types[name] = false
      end
    end
  end



  local flammable_types_override = {
    ["crude-oil"] = true,
    ["heavy-oil"] = true,
    ["light-oil"] = true,
    ["lubricant"] = false,
    ["gas-hydrogen"] = true,
    ["gas-methane"] = true,
    ["gas-ethane"] = true,
    ["gas-butane"] = true,
    ["gas-propene"] = true,
    ["liquid-naphtha"] = true,
    ["liquid-mineral-oil"] = true,
    ["liquid-fuel-oil"] = true,
    ["gas-methanol"] = true,
    ["gas-ethylene"] = true,
    ["gas-benzene"] = true,
    ["gas-synthesis"] = true,
    ["gas-butadiene"] = true,
    ["gas-phenol"] = true,
    ["gas-ethylbenzene"] = true,
    ["gas-styrene"] = true,
    ["gas-formaldehyde"] = true,
    ["gas-polyethylene"] = true,
    ["gas-glycerol"] = true,
    ["gas-natural-1"] = true,
    ["liquid-multi-phase-oil"] = true,
    ["gas-raw-1"] = true,
    ["liquid-condensates"] = true,
    ["liquid-ngl"] = true,
    ["gas-chlor-methane"] = true,
    ["hydrogen"] = true,
    ["liquid-fuel"] = true,
    ["diesel-fuel"] = true,
    ["petroleum-gas"] = true,
    ["water"] = false,
    ["sulfuric-acid "] = false,
    ["molten-tiberium"] = true,
    ["tiberium-waste"] = false,
    ["tiberium-sludge"] = false,
    ["tiberium-slurry"] = false,
    ["liquid-tiberium"] = true,
    ["tiberium-slurry-blue"] = false,
    ["cubeine-solution"] = false,
  }


  for name, value in pairs(flammable_types_override) do
    flammable_types[name] = value
  end

  local gas_types_override = {
    ["liquid-cubonium"] = true,
  }


  for name, value in pairs(gas_types_override) do
    gas_types[name] = value
  end
end


-- Initialize when the mod is first loaded
script.on_init(function()
  init_flammable_types()
end)

-- Reinitialize if configuration changes
script.on_configuration_changed(function()
  init_flammable_types()
end)

-- Reinitialize if the game is reloaded
script.on_load(function()
  init_flammable_types()
end)

-- ??? Dunno why you need a remote
-- Remote interface for adding/removing/fluid queries
remote.add_interface("flammable_oils", {
  add_flammable_type = function(name)
    flammable_types[name] = true
  end,
  remove_flammable_type = function(name)
    flammable_types[name] = nil
  end,
  get_flammable_types = function()
    return flammable_types
  end
})

-- Event handler for entities that died
script.on_event(defines.events.on_entity_died, function(event)
  if event.entity.type == "pump" then
    return
  end

  local chances = {
    ["fire"] = 0.95,
    ["explosion"] = 0.75,
    ["acid"] = 0.5,
    ["electric"] = 0.5,
    ["laser"] = 0.5
  }


  local damage_type = event.damage_type
  if not damage_type then
    return
  end
  if not chances[damage_type.name] or chances[damage_type.name] < math.random() then
    return
  end


  local entity = event.entity
  local boxes = entity.fluidbox
  local num_pots = #boxes
  if num_pots == 0 then return end
  local fluids = prototypes.fluid
  for k = 1, num_pots do
    local pot = boxes[k]
    if pot and flammable_types[pot.name] then
      local fluid = fluids[pot.name]
      -- Boiler produces 0.5 pollution per second at 1.8 MW power
      -- Calculate pollution as if this was being burned in a boiler
      local pollution = fluid.fuel_value / 1.8e6 * 0.5 * fluid.emissions_multiplier * pot.amount / 1.5
      local fraction = pot.amount /
      boxes.get_capacity(k)                               --This returns odd results ... Like 0.0000011651651 for a full pipe with 100 fluid
      local energy = fluid.fuel_value *
          pot.amount /
          1000000.0                                       --Megajoules                                                                            -- Combustion energy stored in the fluid
      if --[[fraction > 0.025 and--]] energy > 10 then
        return flammable_explosion(entity, fraction, pollution, energy, gas_types[fluid.name] and "explosion" or "fire")
      end
    end
  end
end)

-- Function to handle flammable explosions
function flammable_explosion(entity, fraction, pollution, energy, damage_type)
  if not entity.valid then return end

  local r_mult = settings.global["flo-radius-mult"].value * 1.0 --default 0.1
  local r_pow = 1.0 / settings.global["flo-radius-power"].value --default 1/3

  local d_mult = settings.global["flo-damage-mult"].value * 1.0 --default 5
  local d_pow = 1.0 / settings.global["flo-damage-power"].value --default 1/3

  --local explosion_radius = 0.1 * math.pow(energy * 10, 1/3)-- Assumming 100 MJ baseline, radius will be 1
  --local explosion_damage = 5 * math.pow(energy * 10, 1/3)-- Assumming 100 MJ baseline, damage will be 50
  local explosion_radius = r_mult * math.pow(energy * 10, r_pow)
  local explosion_damage = d_mult * math.pow(energy * 10, d_pow)

  local pos = entity.position
  local surface = entity.surface
  local radius = 0.5 * ((entity.bounding_box.right_bottom.x - pos.x) + (entity.bounding_box.right_bottom.y - pos.y))
  local width = radius * 2
  local area = { { pos.x - (radius + 0.5 + explosion_radius), pos.y - (radius + 0.5 + explosion_radius) }, { pos.x + (radius + 0.5 + explosion_radius), pos.y + (radius + 0.5 + explosion_radius) } }

  --local damage = math.random(20, 40) * fraction

  surface.pollute(pos, pollution / 10) -- Apparently normal amount is too much, let's / 10

  if width <= 1 then
    surface.create_entity { name = "explosion", position = pos }
    surface.create_entity { name = "oil-fire-flame", position = pos, raise_built = true }
  else
    surface.create_entity { name = "medium-explosion", position = { pos.x + math.random(-radius, radius), pos.y + math.random(-radius, radius) } }
    if (energy > 10000) then
      surface.create_entity { name = "big-explosion", position = { pos.x + math.random(-radius, radius), pos.y + math.random(-radius, radius) } }
    end

    if (energy > 100000) then
      surface.create_entity { name = "massive-explosion", position = { pos.x + math.random(-radius, radius), pos.y + math.random(-radius, radius) } }
    end

    for k = 1, math.ceil(width) do
      local offset_x = math.random(-radius, radius)
      local offset_y = math.random(-radius, radius)
      surface.create_entity { name = "oil-fire-flame", position = { pos.x + offset_x, pos.y + offset_y }, raise_built = true }


      for j = 1, math.ceil(4 * fraction) do
        local burst_radius = width + (2 * fraction)
        local burst_x = math.random(-burst_radius, burst_radius)
        local burst_y = math.random(-burst_radius, burst_radius)
        surface.create_entity { name = "oil-fire-flame", position = { pos.x + burst_x, pos.y + burst_y }, raise_built = true }
      end
    end
  end


  if entity.type == "pipe-to-ground" then
    if entity.neighbours then
      for k, neighbour in pairs(entity.neighbours[1]) do
        if neighbour and neighbour.valid and neighbour.type == "pipe-to-ground" then
          surface.create_entity { name = "oil-fire-flame", position = neighbour.position, raise_built = true }
          neighbour.damage(explosion_damage, entity.force, damage_type)
          break
        end
      end
    end
  end

  for k, nearby in pairs(surface.find_entities(area)) do
    if nearby.valid and nearby.health then
      local distance = math.sqrt((nearby.position.x - pos.x) ^ 2 + (nearby.position.y - pos.y) ^ 2)


      nearby.damage(math.max(0, explosion_damage * (1 - distance / explosion_radius)), entity.force, damage_type) --linear falloff
    end
  end

  -- spread fires around if the explosion is big enough
  if explosion_radius > 2 and damage_type == "fire" then
    local danger = math.min(explosion_radius * math.sqrt(explosion_radius), 400)
    for i = 1, danger, 1 do
      angle = math.pi * 2 * math.random()
      range = math.random() * math.random() * explosion_radius

      entity.surface.create_entity({
        name = "oil-fire-flame",
        position = { entity.position.x + math.cos(angle) * range, entity.position.y + math.sin(angle) * range },
        force = "neutral"
      })
    end
  end
end
