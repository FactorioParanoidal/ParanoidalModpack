return function(center, surface)  --small smelting station
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-furnace", position = {center.x-2, center.y-2}, force = fN}.damage(40,"neutral","physical")
    local chest = ce{name = "wooden-chest", position = {center.x, center.y-1}, force = fN}
    chest.insert{name = "coal", count = math.random(1, 10)}
    chest.insert{name = "stone", count = math.random(1, 20)}
    chest.insert{name = "iron-ore", count = math.random(1, 15)}
end
