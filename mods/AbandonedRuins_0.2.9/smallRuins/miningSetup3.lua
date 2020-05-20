
return function(center, surface) --mining setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    local e = ce{name = "burner-mining-drill", position = {center.x + (0.5), center.y + (0.5)}, direction = direct.north, force = fN}
    if e then
      e.damage(96,"neutral","physical")
    end
    local e = ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-1.0)}, force = fN}
    if e then
      e.insert{name = "coal", count = math.random(1, 75)}
    end
end
