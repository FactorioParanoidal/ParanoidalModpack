
return function(center, surface) --research station
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    ce{name = "lab", position = {center.x + 1.5, center.y-0.5}, force = fN}
    local chest = ce{name = "wooden-chest", position = {center.x + 1.5, center.y + 1.5}, force = fN}
    if chest then
      chest.insert{name = "automation-science-pack", count = math.random(20, 40)}
      chest.insert{name = "logistic-science-pack", count = math.random(10, 20)}
    end
end
