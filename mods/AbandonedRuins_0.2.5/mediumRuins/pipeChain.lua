
return function(center, surface) --long chain of pipes
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "pipe-to-ground", position = {center.x + (-1.0), center.y + (-7.0)}, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (-1.0), center.y + (-2.0)}, direction = direct.south, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (-7.0), center.y + (0.0)}, direction = direct.west, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (-1.0), center.y + (-1.0)}, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (4.0), center.y + (0.0)}, direction = direct.west, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (3.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "pipe-to-ground", position = {center.x + (-1.0), center.y + (6.0)}, direction = direct.south, force = fN}
end
