return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end

    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (-4.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-2.5), center.y + (-5.5)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-0.5), center.y + (-5.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (2.5), center.y + (-5.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (-5.5)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (-2.5)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (-4.0), center.y + (-4.0)}, force = fN}
    local e = ce{name = "gun-turret", position = {center.x + (2.5), center.y + (-2.5)}, force = game.forces.enemy}
    if e then
      e.insert{name = "piercing-rounds-magazine", count = 5}
    end
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (-3.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-1.0)}, force = fN}
    ce{name = "radar", position = {center.x + (-1.0), center.y + (-1.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (-0.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (0.0)}, force = fN}
    ce{name = "radar", position = {center.x + (-1.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (2.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (3.5)}, force = fN}
    ce{name = "medium-electric-pole", position = {center.x + (1.0), center.y + (2.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (2.5)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (5.5)}, force = fN}
    local e = ce{name = "gun-turret", position = {center.x + (-2.5), center.y + (4.5)}, force = game.forces.enemy}
    if e then
      e.insert{name = "piercing-rounds-magazine", count = 5}
    end
    ce{name = "land-mine", position = {center.x + (4.86328125), center.y + (4.16796875)}, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (6.0), center.y + (5.0)}, force = fN}
    ce{name = "gate", position = {center.x + (6.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (7.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (7.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (7.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (7.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-1.5), center.y + (6.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (7.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (1.5), center.y + (6.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (7.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (4.5), center.y + (6.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (7.0)}, force = fN}
end
