return function(center, surface) -- small mining
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name="electric-mining-drill", position={center.x + (-2.0), center.y + (-1.0)}, direction = direct.south, force = fN}
    ce{name="electric-mining-drill", position={center.x + (1.0), center.y + (3.0)}, direction = direct.north, force = fN}
    ce{name="fast-transport-belt", position={center.x + (-1.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="fast-transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="fast-transport-belt", position={center.x + (-3.0), center.y + (1.0)}, direction = direct.west, force = fN}
    ce{name="fast-transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.west, force = fN}
end
