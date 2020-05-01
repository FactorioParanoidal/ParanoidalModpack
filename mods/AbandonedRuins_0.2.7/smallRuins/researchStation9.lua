
return function(center, surface) --research station
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local e = ce{name = "wooden-chest", position = {center.x-1.5, center.y + 0.5}, force = fN}
    if e then
      e.insert{name = "logistic-science-pack", count = math.random(40, 100)}
    end
end
