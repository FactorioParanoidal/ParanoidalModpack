return function(center, surface)  --small smelting station
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-furnace", position = {center.x-2.5, center.y-2.5}, force = fN}
    local chest = ce{name = "wooden-chest", position = {center.x-2, center.y}, force = fN}
    chest.insert{name = "coal", count = math.random(1, 10)}
    chest.insert{name = "copper-ore", count = math.random(1, 40)}
end
