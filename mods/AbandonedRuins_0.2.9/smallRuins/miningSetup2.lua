
return function(center, surface) --mining setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "burner-mining-drill", position = {center.x + (0.5), center.y + (0.5)}, direction = direct.east, force = fN}
    local e = ce{name = "wooden-chest", position = {center.x + (2.0), center.y + (0.0)}, force = fN}
    if e then
      e.insert{name = "iron-ore", count = math.random(1, 90)}
    end
end
