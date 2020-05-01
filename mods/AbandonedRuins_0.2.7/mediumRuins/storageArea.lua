return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end

    local fN = game.forces.neutral
    local direct = defines.direction


    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-6.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-2.0), center.y + (-6.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-6.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (-6.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-5.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (-4.0)}, force = fN}
    if e then
      e.insert{name = "iron-plate", count = math.random(10, 200)}
    end
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (-5.0)}, force = fN}
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (-4.0)}, force = fN}
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-5.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (-4.0)}, force = fN}
    if e then
      e.insert{name = "copper-plate", count = math.random(10, 200)}
    end
    ce{name = "wooden-chest", position = {center.x + (2.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-3.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (-2.0)}, force = fN}
    if e then
      e.insert{name = "steel-plate", count = math.random(10, 200)}
    end
    ce{name = "iron-chest", position = {center.x + (-1.0), center.y + (-3.0)}, force = fN}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (-3.0)}, force = fN}
    local e = ce{name = "iron-chest", position = {center.x + (3.0), center.y + (-3.0)}, force = fN}
    if e then
      e.insert{name = "transport-belt", count = math.random(10, 70)}
    end
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (-2.0)}, force = fN}
    ce{name = "gate", position = {center.x + (5.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-3.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-7.0), center.y + (0.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-7.0), center.y + (-1.0)}, force = fN}
    local e = ce{name = "iron-chest", position = {center.x + (-6.0), center.y + (-1.0)}, force = fN}
    if e then
      e.insert{name = "iron-plate", count = math.random(10, 200)}
    end
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (0.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (-3.0), center.y + (0.0)}, force = fN}
    if e then
      e.insert{name = "iron-ore", count = math.random(50, 200)}
    end
    ce{name = "wooden-chest", position = {center.x + (-1.0), center.y + (-1.0)}, force = fN}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (0.0)}, force = fN}
    ce{name = "gate", position = {center.x + (5.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (1.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (2.0)}, force = fN}
    if e then
      e.insert{name = "coal", count = math.random(10, 200)}
    end
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (2.0)}, force = fN}
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (2.0)}, force = fN}
    ce{name = "iron-chest", position = {center.x + (-3.0), center.y + (1.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (1.0)}, force = fN}
    if e then
      e.insert{name = "stone", count = math.random(10, 200)}
    end
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (2.0)}, force = fN}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (1.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (3.0), center.y + (2.0)}, force = fN}
    if e then
      e.insert{name = "inserter", count = math.random(10, 20)}
    end
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (3.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (4.0)}, force = fN}
    if e then
      e.insert{name = "copper-plate", count = math.random(10, 200)}
    end
    ce{name = "iron-chest", position = {center.x + (-4.0), center.y + (4.0)}, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (-3.0), center.y + (3.0)}, force = fN}
    if e then
      e.insert{name = "repair-pack", count = math.random(10, 20)}
    end
    ce{name = "wooden-chest", position = {center.x + (-2.0), center.y + (3.0)}, force = fN}
    ce{name = "iron-chest", position = {center.x + (-1.0), center.y + (4.0)}, force = fN}
    local e = ce{name = "iron-chest", position = {center.x + (2.0), center.y + (4.0)}, force = fN}
    if e then
      e.insert{name = "gun-turret", count = math.random(10, 20)}
    end
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (6.0)}, force = fN}
    ce{name = "gate", position = {center.x + (0.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (6.0)}, force = fN}
end
