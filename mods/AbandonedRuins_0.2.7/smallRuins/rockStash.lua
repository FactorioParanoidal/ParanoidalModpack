
return function(center, surface) --suspicious rock, stash
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local chest = ce{name = "wooden-chest", position = {center.x+1, center.y+1}, force = fN}
    if chest then
      chest.insert{name = "engine-unit", count=8}
      chest.insert{name = "iron-plate", count=20}
      chest.insert{name = "steel-plate", count=5}
    end
    ce{name = "rock-big", position = {center.x, center.y}, force = fN}
end
