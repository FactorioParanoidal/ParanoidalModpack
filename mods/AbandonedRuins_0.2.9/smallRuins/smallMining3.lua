return function(center, surface) -- small mining
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="burner-mining-drill", position={center.x + (-1.5), center.y + (-0.5)}, direction = direct.south, force = fN}
    local e = ce{name="burner-mining-drill", position={center.x + (0.5), center.y + (-0.5)}, direction = direct.south, force = fN}
    if e then
      e.damage(99,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(112,"neutral","physical")
    end
    local e = ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    if e then
      e.damage(138,"neutral","physical")
    end
end
