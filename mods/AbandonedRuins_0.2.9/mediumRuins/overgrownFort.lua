
return function(center, surface)
    local ce = function(params)
        params.raise_built = true
        return surface.create_entity(params)
    end
    local fN = game.forces.neutral
    local direct = defines.direction
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (-6.0)}, force = fN}
    ce{name = "gate", position = {center.x + (1.0), center.y + (-6.0)}, direction = direct.east, force = fN}
    ce{name = "gate", position = {center.x + (0.0), center.y + (-6.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (5.5), center.y + (-6.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-6.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-5.5), center.y + (-4.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-4.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-0.5), center.y + (-3.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (-2.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (4.5), center.y + (-1.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (-2.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-6.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-1.0), center.y + (0.0)}, force = fN}
    local chest = ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-1.0)}, force = fN}
    if chest then
      chest.insert{name = "iron-plate", count = math.random(10, 200)}
      chest.insert{name = "copper-plate", count = math.random(10, 200)}
    end
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (0.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-1.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (2.5), center.y + (-0.5)}, force = fN}
    ce{name = "gate", position = {center.x + (6.0), center.y + (0.0)}, force = fN}
    ce{name = "gate", position = {center.x + (6.0), center.y + (-1.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-4.5), center.y + (2.5)}, force = fN}
    ce{name = "gate", position = {center.x + (-6.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (2.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-1.5), center.y + (1.5)}, force = fN}
    local e = ce{name = "gun-turret", position = {center.x + (1.5), center.y + (1.5)}, direction = direct.east, force = game.forces.enemy}
    if e then
      e.insert{name = "firearm-magazine", count = 5}
    end
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (1.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (4.5), center.y + (2.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (1.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (2.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (4.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (3.0)}, force = fN}
    ce{name = "tree-05", position = {center.x + (-0.5), center.y + (4.5)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (3.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (6.0)}, force = fN}
    ce{name = "gate", position = {center.x + (-2.0), center.y + (6.0)}, direction = direct.east, force = fN}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (6.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (5.0)}, force = fN}
    ce{name = "stone-wall", position = {center.x + (6.0), center.y + (6.0)}, force = fN}

end
