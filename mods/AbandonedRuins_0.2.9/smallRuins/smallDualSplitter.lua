
return function(center, surface) -- small dual splitter
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name="transport-belt", position={center.x + (1.0), center.y + (-1.0)}, force = fN}
    ce{name="splitter", position={center.x + (0.0), center.y + (-0.5)}, direction = direct.east, force = fN}
    ce{name="splitter", position={center.x + (-1.0), center.y + (0.5)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (0.0), center.y + (1.0)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction = direct.east, force = fN}

end
