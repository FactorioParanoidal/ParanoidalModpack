
return function(center, surface) --smeltery
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="medium-electric-pole", position={center.x + (-3.0), center.y + (-2.0)}, force = fN}
    local e = ce{name="medium-electric-pole", position={center.x + (-3.0), center.y + (4.0)}, force = fN}
    if e then
      e.damage(30,"neutral","physical")
    end
    ce{name="stone-furnace", position={center.x + (1.5), center.y + (-2.5)}, force = fN}
    local e = ce{name="stone-furnace", position={center.x + (-1.5), center.y + (4.5)}, force = fN}
    if e then
      e.damage(15,"neutral","physical")
    end
    local e = ce{name="wooden-chest", position = {center.x + (-3.0), center.y + (-3.0)}, force = game.forces.neutral}
    if e then
      e.insert{name = "copper-plate", count = math.random(1, 40)}
    end
    local e = ce{name="inserter", position={center.x + (-1.0), center.y + (-1.0)}, force = fN}
    if e then
      e.damage(60,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (-1.0), center.y + (0.0)}, direction = direct.south, force = fN}
    if e then
      e.damage(45,"neutral","physical")
    end
    local e = ce{name="inserter", position={center.x + (2.0), center.y + (-1.0)}, force = fN}
    if e then
      e.damage(45,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction = direct.south, force = fN}
    local e = ce{name="transport-belt", position={center.x + (-3.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(75,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (2.0)}, force = fN}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    local e = ce{name="transport-belt", position={center.x + (0.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(30,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (2.0), center.y + (2.0)}, force = fN}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (3.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="inserter", position={center.x + (-1.0), center.y + (3.0)}, direction = direct.south, force = fN}
    ce{name="inserter", position={center.x + (2.0), center.y + (3.0)}, direction = direct.south, force = fN}
end
