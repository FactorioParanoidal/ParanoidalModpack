
return function(center, surface) --small mountain
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    ce{name = "rock-big", position = {center.x-1, center.y-1}, force = fN}
    ce{name = "rock-big", position = {center.x + 1, center.y-1}, force = fN}
    ce{name = "rock-big", position = {center.x-1, center.y + 1}, force = fN}
    ce{name = "rock-big", position = {center.x + 1, center.y + 1}, force = fN}
end
