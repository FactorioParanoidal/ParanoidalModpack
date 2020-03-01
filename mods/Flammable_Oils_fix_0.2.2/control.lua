local flammable_types

init_flammable_types = function()
  global.flammable_types =
  {
    ["crude-oil"] = true,
    ["heavy-oil"] = true,
    ["light-oil"] = true,
    ["lubricant"] = true,
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
    ["petroleum-gas"] = true
  }
  flammable_types = global.flammable_types
end

script.on_init(init_flammable_types)
script.on_configuration_changed(function()
  if not global.flammable_types then
    init_flammable_types()
  end
  flammable_types = global.flammable_types
end)

script.on_load(function()
  flammable_types = global.flammable_types
end)

remote.add_interface("flammable_oils", 
{
  add_flammable_type = function(name)
    global.flammable_types[name] = true
  end,
  remove_flammable_type = function(name)
    global.flammable_types[name] = nil
  end,
  get_flammable_types = function()
    return global.flammable_types
  end
})



script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  local boxes = entity.fluidbox
  local num_pots = #boxes
  if num_pots == 0 then return end
  local fluids = game.fluid_prototypes
  for k = 1, num_pots do
    local pot = boxes[k]
    if pot then 
      if flammable_types[pot.name] then
        local fraction = pot.amount/boxes.get_capacity(k)
        if fraction > 0.025 then 
          return flammable_explosion(entity, fraction)
        end
      end
    end
  end
end)

function flammable_explosion(entity, fraction)

  if not entity.valid then return end
  local pos = entity.position
  local surface = entity.surface
  local radius = 0.5 * ((entity.bounding_box.right_bottom.x - pos.x) + (entity.bounding_box.right_bottom.y - pos.y))
  local width = radius * 2
  local area = {{pos.x - (radius + 0.5),pos.y - (radius + 0.5)},{pos.x + (radius + 0.5),pos.y + (radius + 0.5)}}
  local damage = math.random(20, 40) * fraction
  
  if width <= 1 then
    entity.surface.create_entity{name = "explosion", position = pos}
    entity.surface.create_entity{name = "oil-fire-flame", position = pos, raise_built =true}
  else
    surface.create_entity{name = "medium-explosion", position = {pos.x+math.random(-radius,radius), pos.y+math.random(-radius,radius)}}
    for k = 1, math.ceil(width) do
      surface.create_entity{name = "oil-fire-flame", position = {pos.x+math.random(-radius,radius), pos.y+math.random(-radius,radius)}, raise_built =true}
      for j = 1, math.ceil(4 * fraction) do
        local burst = width + (2 * fraction)
        surface.create_entity{name = "oil-fire-flame", position = {pos.x+math.random(-burst,burst), pos.y+math.random(-burst,burst)}, raise_built =true}
      end
    end
  end
  
  if entity.type == "pipe-to-ground" then
    if entity.neighbours then
      for k, neighbour in pairs (entity.neighbours[1]) do
        if neighbour and neighbour.valid and (neighbour.type == "pipe-to-ground") then
          surface.create_entity{name = "oil-fire-flame", position = neighbour.position, raise_built =true}
          neighbour.damage(damage, entity.force, "explosion")
          break
        end
      end
    end
  end
  
  for k, nearby in pairs (surface.find_entities(area)) do
    if nearby.valid and nearby.health then
      nearby.damage(damage, entity.force, "explosion")
    end
  end

end