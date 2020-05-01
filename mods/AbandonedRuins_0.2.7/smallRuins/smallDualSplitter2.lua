
return function(center, surface) -- small dual splitter
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    local e = ce{name="transport-belt", position={center.x + (1.0), center.y + (-1.0)}, force = fN}
    if e then
      e.damage(114,"neutral","physical")
    end
    ce{name="splitter", position={center.x + (0.0), center.y + (-0.5)}, direction = direct.west, force = fN}
    local e = ce{name="splitter", position={center.x + (-1.0), center.y + (0.5)}, direction = direct.west, force = fN}
    if e then
      e.damage(36,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (0.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (0.0)}, direction = direct.west, force = fN}
    local e = ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(29,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction = direct.west, force = fN}
    local e = ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(56,"neutral","physical")
    end
    ce{name="transport-belt", position={center.x + (3.0), center.y + (0.0)}, direction = direct.west, force = fN}

end
