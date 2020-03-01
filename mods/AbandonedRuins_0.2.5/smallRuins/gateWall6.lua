return function(center, surface) --section of wall with gate
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    ce{name = "stone-wall", position = {center.x-5.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-3.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-1.5, center.y + 0.5}, force = fN}

    ce{name = "gate", position = {center.x-0.5, center.y + 0.5}, direction=defines.direction.west, force = fN}
    ce{name = "gate", position = {center.x + 0.5, center.y + 0.5}, direction=defines.direction.west, force = fN}
    ce{name = "gate", position = {center.x + 1.5, center.y + 0.5}, direction=defines.direction.west, force = fN}

    ce{name = "stone-wall", position = {center.x + 2.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 4.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 5.5, center.y + 0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 6.5, center.y + 0.5}, force = fN}
end
