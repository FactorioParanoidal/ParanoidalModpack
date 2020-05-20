return function(center, surface) --random walls
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    local e = ce{name = "wooden-chest", position = {center.x, center.y}, force = fN}
    if e then
      e.insert{name = "firearm-magazine", count = math.random(1, 300)}
    end
    ce{name = "stone-wall", position = {center.x-2.5, center.y-0.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y + 1.5}, force = fN}
    ce{name = "stone-wall", position = {center.x-2.5, center.y + 2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 2.5, center.y-0.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y + 0.5}, force = fN}
    if e then
      e.damage(22,"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y + 1.5}, force = fN}
    if e then
      e.damage(46,"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y + 2.5}, force = fN}
    if e then
      e.damage(68,"neutral","physical")
    end
    ce{name = "stone-wall", position = {center.x-0.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 0.5, center.y-2.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x + 0.5, center.y + 2.5}, force = fN}
    if e then
      e.damage(25,"neutral","physical")
    end
end
