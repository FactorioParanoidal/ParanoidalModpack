
return function(center, surface) --I of splitters
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "fast-splitter", position = {center.x + (0.5), center.y + (-1.0)}, direction = direct.south, force = fN}
end
