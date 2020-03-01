
return function(center, surface) --mining setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "electric-mining-drill", position = {center.x + (0.0), center.y + (0.0)}, direction = direct.west, force = fN}
    ce{name = "iron-chest", position = {center.x + (-2.0), center.y + (0.0)}, force = fN}.insert{name = "copper-ore", count = math.random(1, 75)}
end
