
return function(center, surface) --small destroyed setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "assembling-machine-1", position = {center.x-0.5, center.y-2.5}, force = fN}.damage(33,"neutral","physical")
    ce{name = "inserter", position = {center.x-2.5, center.y-1.5}, force = fN}.damage(106,"neutral","physical")
    ce{name = "inserter", position = {center.x-0.5, center.y + 1.5}, force = fN}.damage(3,"neutral","physical")

    ce{name = "transport-belt", position = {center.x + 1.5, center.y-1}, force = fN}.damage(14,"neutral","physical")
    ce{name = "transport-belt", position = {center.x + 1.5, center.y}, force = fN}.damage(21,"neutral","physical")
    ce{name = "transport-belt", position = {center.x + 1.5, center.y + 1}, force = fN}
    ce{name = "transport-belt", position = {center.x + 1.5, center.y + 2}, force = fN}.damage(36,"neutral","physical")
    ce{name = "transport-belt", position = {center.x + 1.5, center.y + 4}, force = fN}
end
