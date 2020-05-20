return function(center, surface) --small gears setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="fast-transport-belt", position={center.x + (-0.0), center.y + (3.0)}, direction = direct.east, force = fN}
    ce{name="fast-transport-belt", position={center.x + (-0.0), center.y + (2.0)}, force = fN}
    ce{name="fast-transport-belt", position={center.x + (1.0), center.y + (2.0)}, direction = direct.east, force = fN}
    local e = ce{name="fast-transport-belt", position={center.x + (-2.0), center.y + (3.0)}, direction = direct.east, force = fN}
    if e then
      e.damage(42,"neutral","physical")
    end
    local e = ce{name="fast-transport-belt", position={center.x + (-1.0), center.y + (3.0)}, direction = direct.east, force = fN}
    if e then
      e.damage(18,"neutral","physical")
    end
    ce{name="fast-transport-belt", position={center.x + (-1.0), center.y + (2.0)}, direction = direct.west, force = fN}
    ce{name="fast-transport-belt", position={center.x + (-3.0), center.y + (2.0)}, direction = direct.east, force = fN}
    ce{name="fast-transport-belt", position={center.x + (-3.0), center.y + (3.0)}, direction = direct.south, force = fN}
    local e = ce{name="assembling-machine-2", position={center.x + (2.0), center.y + (-1.0)}, force = fN}
    if e then
      e.damage(98,"neutral","physical")
    end
    ce{name="medium-electric-pole", position={center.x + (-0.0), center.y + (1.0)}, force = fN}
    ce{name="fast-inserter", position={center.x + (1.0), center.y + (1.0)}, direction = direct.south, force = fN}
    ce{name="assembling-machine-2", position={center.x + (-1.0), center.y + (-1.0)}, force = fN}
    ce{name="fast-inserter", position={center.x + (-1.0), center.y + (1.0)}, direction = direct.south, force = fN}
    local e = ce{name="fast-inserter", position={center.x + (2.0), center.y + (-3.0)}, direction = direct.south, force = fN}
    if e then
      e.damage(36,"neutral","physical")
    end
    local e = ce{name="fast-inserter", position={center.x + (3.0), center.y + (-3.0)}, direction = direct.south, force = fN}
    if e then
      e.damage(50,"neutral","physical")
    end
    ce{name="fast-inserter", position={center.x + (-0.0), center.y + (-3.0)}, direction = direct.south, force = fN}
    ce{name="medium-electric-pole", position={center.x + (1.0), center.y + (-3.0)}, force = fN}
    ce{name="fast-inserter", position={center.x + (-1.0), center.y + (-3.0)}, direction = direct.south, force = fN}

end
