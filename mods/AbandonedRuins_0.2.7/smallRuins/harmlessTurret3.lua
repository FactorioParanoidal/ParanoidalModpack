
return function(center, surface) --harmless turret
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local e = ce{name = "gun-turret", position = {center.x, center.y}, force = game.forces.enemy}
    if e then
      e.damage(math.random(50, 200),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x-2.5, center.y-2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x-1.5, center.y-2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x-0.5, center.y-2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x + 0.5, center.y-2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    ce{name = "stone-wall", position = {center.x + 1.5, center.y-2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 2.5, center.y-2.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x-2.5, center.y-1.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    ce{name = "stone-wall", position = {center.x + 2.5, center.y-1.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x-2.5, center.y-0.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y-0.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    ce{name = "stone-wall", position = {center.x-2.5, center.y + 0.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y + 0.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x-2.5, center.y + 1.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y + 1.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x-2.5, center.y + 2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x-1.5, center.y + 2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    ce{name = "stone-wall", position = {center.x-0.5, center.y + 2.5}, force = fN}
    ce{name = "stone-wall", position = {center.x + 0.5, center.y + 2.5}, force = fN}
    local e = ce{name = "stone-wall", position = {center.x + 1.5, center.y + 2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
    local e = ce{name = "stone-wall", position = {center.x + 2.5, center.y + 2.5}, force = fN}
    if e then
      e.damage(math.random(1, 500),"neutral","physical")
    end
end
