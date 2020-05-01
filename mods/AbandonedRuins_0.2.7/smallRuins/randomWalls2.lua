return function(center, surface) --random walls
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-wall", position = {center.x-2.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 0.5, center.y-2.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x-1.5, center.y-0.5}, force = fN}
    if e then
      e.damage(12,"neutral","physical")
    end
    ce{name = "stone-wall", position = {center.x + 2.5, center.y-0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-0.5, center.y + 2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y + 3.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-1.5, center.y + 3.5}, force = fN}
end
