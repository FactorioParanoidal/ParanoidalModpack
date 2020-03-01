return function(center, surface) --section of wall with gate
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    ce{name = "stone-wall", position = {center.x + 0.5, center.y-3.5}, force = fN}.damage(68,"neutral","physical")
    ce{name = "stone-wall", position = {center.x + 0.5, center.y-2.5}, force = fN}.damage(82,"neutral","physical")
    ce{name = "stone-wall", position = {center.x + 0.5, center.y-1.5}, force = fN}

    ce{name = "gate", position = {center.x + 0.5, center.y-0.5}, force = fN}
    ce{name = "gate", position = {center.x + 0.5, center.y + 0.5}, force = fN}
    ce{name = "gate", position = {center.x + 0.5, center.y + 1.5}, force = fN}

    ce{name = "stone-wall", position = {center.x + 0.5, center.y + 2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 0.5, center.y + 3.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 0.5, center.y + 5.5}, force = fN}
end
