
return function(center, surface) --small destroyed setup
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    local e = ce{name = "assembling-machine-1", position = {center.x-0.5, center.y-2.5}, force = fN}
    if e then
      e.damage(33,"neutral","physical")
    end
    local e = ce{name = "inserter", position = {center.x-2.5, center.y-1.5}, force = fN}
    if e then
      e.damage(106,"neutral","physical")
    end
    local e = ce{name = "inserter", position = {center.x-0.5, center.y + 1.5}, force = fN}
    if e then
      e.damage(3,"neutral","physical")
    end

    local e = ce{name = "transport-belt", position = {center.x + 1.5, center.y-1}, force = fN}
    if e then
      e.damage(14,"neutral","physical")
    end
    local e = ce{name = "transport-belt", position = {center.x + 1.5, center.y}, force = fN}
    if e then
      e.damage(21,"neutral","physical")
    end
    ce{name = "transport-belt", position = {center.x + 1.5, center.y + 1}, force = fN}
    local e = ce{name = "transport-belt", position = {center.x + 1.5, center.y + 2}, force = fN}
    if e then
      e.damage(36,"neutral","physical")
    end
    ce{name = "transport-belt", position = {center.x + 1.5, center.y + 4}, force = fN}
end
