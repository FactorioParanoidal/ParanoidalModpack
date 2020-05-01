
return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral

    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-1.0)}, force = fN}
    ce{name = "radar", position = {center.x + (0.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-2.0)}, force = fN}
    ce{name = "gate", position = {center.x + (4.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (1.0)}, force = fN}
    local e = ce{name = "gun-turret", position = {center.x + (-3.5), center.y + (0.5)}, force = game.forces.enemy}
    if e then
      e.insert{name = "firearm-magazine", count = 5}
    end
    ce{name = "medium-electric-pole", position = {center.x + (-2.0), center.y + (0.0)}, force = fN}
    ce{name = "gate", position = {center.x + (4.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (2.0)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (4.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (2.0)}, force = fN}
end
