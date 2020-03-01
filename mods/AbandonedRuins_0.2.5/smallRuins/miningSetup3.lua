
return function(center, surface) --mining setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "burner-mining-drill", position = {center.x + (0.5), center.y + (0.5)}, direction = direct.north, force = fN}.damage(96,"neutral","physical")
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-1.0)}, force = fN}.insert{name = "coal", count = math.random(1, 75)}
end
