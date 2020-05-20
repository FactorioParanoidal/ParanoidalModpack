
return function(center, surface) --section of rails
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (-10.0)}, force = fN}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (0.0)}, force = fN}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (2.0)}, force = fN}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (10.0)}, force = fN}
    ce{name = "straight-rail", position = {center.x + (0.0), center.y + (12.0)}, force = fN}
end
