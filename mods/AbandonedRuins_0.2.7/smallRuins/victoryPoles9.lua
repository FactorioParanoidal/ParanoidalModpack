
return function(center, surface) --victory poles
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    ce{name = "medium-electric-pole", position = {center.x + (0.0), center.y + (-1.0)}, force = fN}
    ce{name="small-lamp", position={center.x + (-1.0), center.y + (-1.0)}, force = fN}
end
