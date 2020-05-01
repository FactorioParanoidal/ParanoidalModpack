
return function(center, surface) --destroyed fort
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-8.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (7.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (8.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (-2.0)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (-7.0), center.y + (-1.0)}, force = fN}
    ce{name = "radar", position = {center.x + (-1.0), center.y + (-1.0)}, force = fN}
    ce{name = "radar", position = {center.x + (2.0), center.y + (-1.0)}, force = fN}
    ce{name = "radar", position = {center.x + (5.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (0.0)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (2.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (2.0)}, force = fN}
    local e = ce{name = "gun-turret", position = {center.x + (-7.5), center.y + (2.5)}, force = game.forces.enemy}
    if e then
      e.insert{name = "firearm-magazine", count = 2}
    end
    local e = ce{name = "gun-turret", position = {center.x + (7.5), center.y + (2.5)}, force = game.forces.enemy}
    if e then
      e.insert{name = "firearm-magazine", count = 2}
    end
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-9.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-8.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (4.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (4.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (4.0)}, force = fN}
    ce{name = "gate", position = {center.x + (0.0), center.y + (4.0)}, direction = direct.east, force = fN}
    ce{name = "gate", position = {center.x + (2.0), center.y + (4.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (7.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (9.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (8.0), center.y + (4.0)}, force = fN}
end
