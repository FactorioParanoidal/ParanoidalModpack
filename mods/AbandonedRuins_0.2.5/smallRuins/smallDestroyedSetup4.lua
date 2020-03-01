
return function(center, surface) --small destroyed setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "assembling-machine-2", position = {center.x-2.5, center.y-0.5}, force = fN}.damage(193,"neutral","physical")
    ce{name = "inserter", position = {center.x-1.5, center.y-2.5}, force = fN}.damage(121,"neutral","physical")
    ce{name = "inserter", position = {center.x + 1.5, center.y-0.5}, force = fN}.damage(44,"neutral","physical")

    ce{name = "transport-belt", position = {center.x-1, center.y + 1.5}, force = fN}.damage(67,"neutral","physical")
    ce{name = "transport-belt", position = {center.x, center.y + 1.5}, force = fN}.damage(92,"neutral","physical")
    ce{name = "transport-belt", position = {center.x + 1, center.y + 1.5}, force = fN}.damage(85,"neutral","physical")
end
