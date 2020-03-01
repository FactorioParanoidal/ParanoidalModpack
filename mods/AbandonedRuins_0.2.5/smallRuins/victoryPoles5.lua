
return function(center, surface) --victory poles
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    ce{name = "small-electric-pole", position = {center.x + (-2.0), center.y + (0.0)}, force = fN}
    ce{name = "small-electric-pole", position = {center.x + (2.0), center.y + (0.0)}, force = fN}
end
