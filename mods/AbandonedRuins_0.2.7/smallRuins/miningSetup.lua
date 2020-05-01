
return function(center, surface) --mining setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "electric-mining-drill", position = {center.x + (0.0), center.y + (0.0)}, direction = direct.south, force = fN}
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (2.0)}, force = fN}
end
