
return function(center, surface) --section of rails
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "straight-rail", position = {center.x + (-12.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (-10.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (-8.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (-4.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (-2.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (4.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (6.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (10.0), center.y + (0.0)}, direction = direct.east, force = fN}
    ce{name = "straight-rail", position = {center.x + (12.0), center.y + (0.0)}, direction = direct.east, force = fN}
end
