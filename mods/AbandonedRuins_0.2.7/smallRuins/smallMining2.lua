return function(center, surface) -- small mining
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="electric-mining-drill", position={center.x + (-2.0), center.y + (3.0)}, direction = direct.north, force = fN}
    ce{name="electric-mining-drill", position={center.x + (1.0), center.y + (3.0)}, direction = direct.north, force = fN}
    ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="transport-belt", position={center.x + (-3.0), center.y + (1.0)}, direction = direct.west, force = fN}
    local e = ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(15,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(34,"neutral","physical")
    end
end
